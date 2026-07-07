import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user take one or more photos in sequence and review them as
/// thumbnails before confirming. Returns the captured images in the order
/// taken, or null if the user cancelled without keeping any photo.
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

class _MultiPhotoCaptureScreenState extends State<_MultiPhotoCaptureScreen> {
  final _filePicker = FilePickerService();
  final List<XFile> _images = [];
  bool _capturing = false;

  Future<void> _takePhoto() async {
    setState(() => _capturing = true);
    final images = await _filePicker.imagePick(ImageSource.camera);
    if (!mounted) return;
    setState(() {
      _capturing = false;
      if (images.isNotEmpty) _images.add(images.first);
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Take Photos"),
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _images.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 56,
                      color: AppColors.secondaryLight,
                    ),
                    const SizedBox(height: 12),
                    AppText.bodyMedium(
                      "Take a photo to get started.",
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 20),
                    AppSolidButton(
                      onPressed: _capturing ? null : _takePhoto,
                      text: _capturing ? "Opening camera..." : "Take Photo",
                      icon: Icons.camera_alt,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMedium(
                    "${_images.length} photo${_images.length == 1 ? '' : 's'} captured. Add more or tap Done to create the PDF.",
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: FileGrid(
                        filePaths: _images.map((e) => e.path).toList(),
                        fileNames: _images.map((e) => e.name).toList(),
                        size: FileViewerSize.large,
                        crossAxisCount: 3,
                        showRemoveButtons: true,
                        onFileRemove: _removeImage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlineButton(
                          onPressed: _capturing ? null : _takePhoto,
                          text: _capturing ? "Opening camera..." : "Add Photo",
                          icon: Icons.camera_alt,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppSolidButton(
                          onPressed: _capturing
                              ? null
                              : () => Navigator.pop(context, _images),
                          text: "Done",
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
