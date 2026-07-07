import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;

class ReadOnlyFlagAttachmentList extends StatelessWidget {
  final List<FileAttachmentModel> data;
  final Widget header;

  const ReadOnlyFlagAttachmentList({
    super.key,
    required this.data,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey[300]),
      child: ExpansionTile(
        title: header,
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        tilePadding: const EdgeInsets.all(0),
        iconColor: AppColors.secondaryDark,
        collapsedIconColor: AppColors.secondaryDark,
        children: data.map((item) {
          return ReadOnlyFlagAttachmentRow(attachment: item);
        }).toList(),
      ),
    );
  }
}

class ReadOnlyFlagAttachmentRow extends StatelessWidget {
  final FileAttachmentModel attachment;

  const ReadOnlyFlagAttachmentRow({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge("Flag Type", fontWeight: FontWeight.w500),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14.5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                  ),
                  child: AppText.bodyLarge(
                    attachment.flagTitle ?? '',
                    color: AppColors.secondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge(
                  "Attachment/View",
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14.5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                  ),
                  child: InkWell(
                    onTap: attachment.attachmentFlag == null
                        ? null
                        : () {
                            final url = attachment.attachmentFlag!;
                            final ext = p
                                .extension(url.split('?').first)
                                .toLowerCase();
                            if (ext == '.doc' || ext == '.docx') {
                              final fileName = url
                                  .split('/')
                                  .last
                                  .split('?')
                                  .first;
                              FilePickerService().downloadFile(
                                context,
                                url,
                                fileName,
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.sizeOf(context).height * 0.9,
                                ),
                                showDragHandle: false,
                                isScrollControlled: true,
                                backgroundColor: AppColors.background,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      8,
                                      8,
                                      0,
                                    ),
                                    child: PdfViewer(
                                      url: attachment.attachmentFlag,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                    child: Row(
                      children: [
                        Icon(
                          _iconForFileType(attachment.fileType),
                          color: AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.bodyLarge(
                            attachment.flagAttach != null
                                ? attachment?.cleanName ?? 'View Attachment'
                                : "No Attachment",
                            color: AppColors.secondaryLight,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForFileType(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'word':
        return FontAwesomeIcons.fileWord;
      case 'excel':
        return Icons.table_chart;
      case 'powerpoint':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}
