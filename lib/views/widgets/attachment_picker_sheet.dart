import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/multi_photo_capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum _AttachmentSource { pdf, camera }

/// Shows a bottom sheet letting the user pick a PDF file or take a photo
/// (which is converted to a PDF). Returns the picked attachment, or null
/// if the user dismissed the sheet or picking failed.
Future<XFile?> showAttachmentPickerSheet(BuildContext context) async {
  final source = await showModalBottomSheet<_AttachmentSource>(
    context: context,
    showDragHandle: false,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppText.titleLarge(
                    "Add Attachment",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ],
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.secondaryDark,
              ),
              title: AppText.bodyMedium("Select PDF"),
              onTap: () => Navigator.pop(context, _AttachmentSource.pdf),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.secondaryDark,
              ),
              title: AppText.bodyMedium("Take Photo"),
              onTap: () => Navigator.pop(context, _AttachmentSource.camera),
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null) return null;

  final filePicker = FilePickerService();
  if (source == _AttachmentSource.pdf) {
    final files = await filePicker.pickFiles();
    return files.isNotEmpty ? files.first : null;
  }

  if (!context.mounted) return null;
  final images = await showMultiPhotoCaptureScreen(context);
  if (images == null || images.isEmpty) return null;
  return filePicker.imagesToPdf(images);
}
