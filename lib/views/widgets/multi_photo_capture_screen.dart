import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const _thumbSize = 64.0;
const _thumbRowHeight = 96.0;
const _focusRingSize = 72.0;

/// Opens a live camera preview with Capture/Finish controls, letting the
/// user take one or more photos in sequence. Returns the captured images
/// in the order taken, or null if the user finished without capturing
/// anything.
Future<List<XFile>?> showMultiPhotoCaptureScreen(BuildContext context) {
  return Navigator.of(context).push<List<XFile>>(
    MaterialPageRoute(builder: (context) => const _MultiPhotoCaptureScreen()),
  );
}

class _MultiPhotoCaptureScreen extends StatefulWidget {
  const _MultiPhotoCaptureScreen();

  @override
  State<_MultiPhotoCaptureScreen> createState() =>
      _MultiPhotoCaptureScreenState();
}

class _MultiPhotoCaptureScreenState extends State<_MultiPhotoCaptureScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final List<XFile> _images = [];
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _pendingImageKey = GlobalKey();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _rowScrollController = ScrollController();
  final CropController _cropController = CropController();
  bool _capturing = false;
  String? _error;

  // Review flow: the most recently captured photo, shown full-screen in the
  // crop editor before it joins the thumbnail row.
  XFile? _pendingImage;
  Uint8List? _cropSourceBytes;
  bool _cropBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeControllerFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _error = "No camera available on this device.");
        }
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = "Could not start the camera.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _initializeControllerFuture = _initCamera());
    }
  }

  /// Focuses (and meters exposure) at the tapped point on the preview, and
  /// shows a brief focus ring where the user tapped.
  Future<void> _onFocusTap(TapUpDetails details) async {
    final controller = _controller;
    if (controller == null) return;
    final box = _previewKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;
    final normalized = Offset(
      (details.localPosition.dx / size.width).clamp(0.0, 1.0),
      (details.localPosition.dy / size.height).clamp(0.0, 1.0),
    );
    _showFocusRing(box.localToGlobal(details.localPosition));
    try {
      await controller.setExposurePoint(normalized);
      await controller.setFocusPoint(normalized);
    } catch (e) {
      // Manual focus/exposure points aren't supported on this device.
    }
  }

  void _showFocusRing(Offset globalPosition) {
    final overlayState = Overlay.of(context);
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final scaleAnim = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    final opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(controller);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Positioned(
          left: globalPosition.dx - _focusRingSize / 2,
          top: globalPosition.dy - _focusRingSize / 2,
          width: _focusRingSize,
          height: _focusRingSize,
          child: Opacity(
            opacity: opacityAnim.value,
            child: Transform.scale(scale: scaleAnim.value, child: child),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      controller.dispose();
    });
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing || _pendingImage != null) return;
    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      // Opens straight into the crop editor with the whole photo selected.
      setState(() {
        _pendingImage = image;
        _cropSourceBytes = null;
      });
      final bytes = await File(image.path).readAsBytes();
      if (mounted) setState(() => _cropSourceBytes = bytes);
    } catch (e) {
      // Capture failed — leave the array untouched, user can just retry.
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Called when the user confirms the crop selection. Saves the cropped
  /// image and animates it from its on-screen position into the thumbnail
  /// row.
  Future<void> _onCropResult(CropResult result) async {
    if (result is! CropSuccess) {
      Toast.error(message: "Could not crop the image.");
      if (mounted) setState(() => _cropBusy = false);
      return;
    }

    final box =
        _pendingImageKey.currentContext?.findRenderObject() as RenderBox?;
    final Rect startRect;
    if (box != null && box.hasSize) {
      startRect = box.localToGlobal(Offset.zero) & box.size;
    } else {
      final screenSize = MediaQuery.of(context).size;
      startRect = Rect.fromLTWH(
        screenSize.width / 2 - _thumbSize / 2,
        screenSize.height / 2 - _thumbSize / 2,
        _thumbSize,
        _thumbSize,
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/daak_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(result.croppedImage);

    if (!mounted) return;
    setState(() {
      _pendingImage = null;
      _cropSourceBytes = null;
      _cropBusy = false;
    });
    await _flyThumbnailToRow(XFile(file.path), startRect: startRect);
  }

  void _confirmCrop() {
    if (_cropSourceBytes == null || _cropBusy) return;
    setState(() => _cropBusy = true);
    _cropController.crop();
  }

  /// Animates a copy of the captured photo flying from [startRect] to its
  /// resting slot in the thumbnail row, then reveals it there.
  Future<void> _flyThumbnailToRow(
    XFile image, {
    required Rect startRect,
  }) async {
    final overlayState = Overlay.of(context);

    var endRect = startRect;
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox != null && rowBox.hasSize) {
      final rowPosition = rowBox.localToGlobal(Offset.zero);
      endRect = Rect.fromLTWH(
        rowPosition.dx + rowBox.size.width - _thumbSize - 16,
        rowPosition.dy + (rowBox.size.height - _thumbSize) / 2,
        _thumbSize,
        _thumbSize,
      );
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final rectAnim = RectTween(
      begin: startRect,
      end: endRect,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final rect = rectAnim.value!;
          return Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: child!,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(image.path), fit: BoxFit.cover),
        ),
      ),
    );

    overlayState.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();

    if (!mounted) return;
    _images.add(image);
    _listKey.currentState?.insertItem(
      _images.length - 1,
      duration: const Duration(milliseconds: 300),
    );
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rowScrollController.hasClients) {
        _rowScrollController.animateTo(
          _rowScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _finish() {
    Navigator.pop(context, _images.isEmpty ? null : _images);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _rowScrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Take Photo"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildPreview()),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        label: "Capture",
                        onTap: _controller == null || _capturing
                            ? null
                            : _capture,
                      ),
                      _buildActionButton(
                        icon: Icons.check_circle,
                        label: "Generate PDF",
                        color: AppColors.primary,
                        onTap: _capturing ? null : _finish,
                      ),
                    ],
                  ),
                ),
                _buildThumbnailRow(),
              ],
            ),
            if (_pendingImage != null) _buildReviewOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: _cropBusy ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _cropSourceBytes == null
                      ? const CircularProgressIndicator(color: Colors.white)
                      : KeyedSubtree(
                          key: _pendingImageKey,
                          child: Crop(
                            controller: _cropController,
                            image: _cropSourceBytes!,
                            // Crop selection starts covering the whole photo.
                            initialRectBuilder: InitialRectBuilder.withBuilder(
                              (viewportRect, imageRect) => imageRect,
                            ),
                            onCropped: _onCropResult,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: _buildActionButton(
                  icon: Icons.check_circle,
                  label: "Done",
                  color: AppColors.primary,
                  loading: _cropBusy,
                  // Keeping the same button size/shape whether idle or
                  // busy matters here: swapping to a differently-sized
                  // widget would resize the Expanded crop area above,
                  // which makes crop_your_image reset its crop rect back
                  // to the whole image mid-crop.
                  onTap: _cropSourceBytes == null ? null : _confirmCrop,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailRow() {
    return Container(
      key: _rowKey,
      height: _thumbRowHeight,
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _images.isEmpty
          ? Center(
              child: AppText.bodySmall(
                "Captured photos will appear here",
                color: Colors.white54,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText.bodySmall(
                    "${_images.length} photo${_images.length == 1 ? '' : 's'} captured",
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    scrollDirection: Axis.horizontal,
                    controller: _rowScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    initialItemCount: _images.length,
                    itemBuilder: (context, index, animation) =>
                        _buildThumbnail(index, animation),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildThumbnail(int index, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_images[index].path),
              width: _thumbSize,
              height: _thumbSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppText.bodyMedium(
            _error!,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        final controller = _controller;
        if (snapshot.connectionState != ConnectionState.done ||
            controller == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return Center(
          child: AspectRatio(
            aspectRatio: 1 / controller.value.aspectRatio,
            child: GestureDetector(
              key: _previewKey,
              behavior: HitTestBehavior.opaque,
              onTapUp: _onFocusTap,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color color = Colors.white,
    bool loading = false,
  }) {
    final effectiveColor = onTap == null ? Colors.grey : color;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Same footprint as the Icon it replaces (size 40) so toggling
            // `loading` never resizes surrounding layout.
            loading
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: effectiveColor,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : Icon(icon, color: effectiveColor, size: 40),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: effectiveColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
