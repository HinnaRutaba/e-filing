import 'dart:io';

import 'package:camera/camera.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _thumbSize = 64.0;
const _thumbRowHeight = 96.0;

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _rowScrollController = ScrollController();
  bool _capturing = false;
  String? _error;

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

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (mounted) await _flyThumbnailToRow(image);
    } catch (e) {
      // Capture failed — leave the array untouched, user can just retry.
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Animates a copy of the captured photo flying from the center of the
  /// screen to its resting slot in the thumbnail row, then reveals it there.
  Future<void> _flyThumbnailToRow(XFile image) async {
    final overlayState = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final startOffset = Offset(
      screenSize.width / 2 - _thumbSize / 2,
      screenSize.height / 2 - _thumbSize / 2,
    );

    var endOffset = startOffset;
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox != null && rowBox.hasSize) {
      final rowPosition = rowBox.localToGlobal(Offset.zero);
      endOffset = Offset(
        rowPosition.dx + rowBox.size.width - _thumbSize - 16,
        rowPosition.dy + (rowBox.size.height - _thumbSize) / 2,
      );
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    final offsetAnim = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(curved);
    final scaleAnim = Tween<double>(begin: 1.3, end: 0.7).animate(curved);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Positioned(
          left: offsetAnim.value.dx,
          top: offsetAnim.value.dy,
          width: _thumbSize,
          height: _thumbSize,
          child: Transform.scale(scale: scaleAnim.value, child: child),
        ),
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
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildPreview()),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: "Capture",
                    onTap: _controller == null || _capturing ? null : _capture,
                  ),
                  _buildActionButton(
                    icon: Icons.check_circle,
                    label: "Finish",
                    color: AppColors.primary,
                    onTap: _capturing ? null : _finish,
                  ),
                ],
              ),
            ),
            _buildThumbnailRow(),
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
            child: CameraPreview(controller),
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
  }) {
    final effectiveColor = onTap == null ? Colors.grey : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: 40),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: effectiveColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
