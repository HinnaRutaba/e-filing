import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/pdf_viewer.dart';
import 'package:flutter/material.dart';

class ReadOnlyFlagAttachmentList extends StatelessWidget {
  final List<FileAttachmentModel> data;
  final Widget header;

  const ReadOnlyFlagAttachmentList(
      {super.key, required this.data, required this.header});

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
          return ReadOnlyFlagAttachmentRow(
            attachment: item,
          );
        }).toList(),
      ),
    );
  }
}

class ReadOnlyFlagAttachmentRow extends StatelessWidget {
  final FileAttachmentModel attachment;

  const ReadOnlyFlagAttachmentRow({
    super.key,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge(
                  "Flag Type",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14.5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.secondaryLight.withOpacity(0.5)),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge(
                  "Attachment/View",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14.5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.secondaryLight.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                  ),
                  child: InkWell(
                    onTap: attachment.attachmentFlag == null
                        ? null
                        : () {
                            showModalBottomSheet(
                              context: context,
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.sizeOf(context).height * 0.9),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child:
                                      PdfViewer(url: attachment.attachmentFlag),
                                );
                              },
                            );
                          },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.bodyLarge(
                            attachment.flagAttach ?? "No Attachment",
                            color: AppColors.secondaryLight,
                            overflow: TextOverflow.ellipsis,
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
}
