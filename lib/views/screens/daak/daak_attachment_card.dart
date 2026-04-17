import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DaakAttachmentCard extends StatelessWidget {
  final DaakAttachmentModel? attachment;
  const DaakAttachmentCard({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Card(
      color: colors.cardColor,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: const Icon(Icons.attach_file, color: AppColors.secondary),
        horizontalTitleGap: 8,
        title: AppText.titleMedium(
          attachment?.originalName ?? "Unknown Attachment",
        ),
        subtitle: AppText.labelMedium(
          "Uploaded at: ${DateTimeHelper.datFormatSlashShort(attachment!.uploadedAt!)}",
        ),
        trailing: AppText.labelSmall(attachment?.fileSizeText ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewer(
                url: attachment?.fileUrl,
                title: attachment?.originalName ?? 'Daak Attachment',
              ),
            ),
          );
        },
      ),
    );
  }
}
