import 'package:efiling_balochistan/config/network/network_base.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';

class PreviewFile extends StatelessWidget {
  final String? html;
  final List<FileContentModel>? content;
  const PreviewFile({super.key, this.html, this.content});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
          child: content != null && content?.isNotEmpty == true
              ? Builder(builder: (context) {
                  FileContentModel details = content!.first;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: AppText.labelLarge(
                                details.barcode ?? '---',
                                maxLines: 2,
                                fontFamily: fileFont,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // AppText.titleMedium(
                                //   details.fileType ?? '',
                                //   fontFamily: fileFont,
                                // ),
                                // const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodyLarge(
                                      "Subject: ",
                                      fontFamily: fileFont,
                                    ),
                                    Expanded(
                                      child: AppText.titleMedium(
                                        details.subject ?? 'N/A',
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        fontFamily: fileFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...content!.map((e) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 24),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: AppText.bodySmall(
                                  e.fileMovNo ?? '',
                                  fontFamily: fileFont,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),
                                  // AppText.titleMedium(
                                  //   e.receiver ?? '---',
                                  //   fontFamily: fileFont,
                                  // ),
                                  HtmlReader(
                                    html: e.content ?? '',
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (e.signature != null &&
                                            e.signature!.isNotEmpty)
                                          Image.network(
                                            e.signature!.startsWith(
                                                    NetworkBase.base)
                                                ? e.signature!
                                                : e.signatureUrl!,
                                            width: 80,
                                          ),
                                        const SizedBox(height: 8),
                                        AppText.titleMedium(
                                          e.sender ?? '---',
                                          fontFamily: fileFont,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        AppText.bodyMedium(
                                          "(${e.designation ?? '---'})",
                                          fontFamily: fileFont,
                                        ),
                                        const SizedBox(height: 4),
                                        AppText.bodyMedium(
                                          DateTimeHelper
                                              .dateFormatSlashWithTime(
                                                  e.sendingDate),
                                          fontFamily: fileFont,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: AppText.titleMedium(
                                            e.receiver ?? '---',
                                            fontFamily: fileFont,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                })
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (html != null) ...[
                      HtmlReader(
                        html: html!,
                      ),
                      const SizedBox(height: 48),
                    ],
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(52, 80, 0, 80),
                        child: AppText.titleSmall(
                          "Nothing to show. File data is empty",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Positioned(
          left: 48,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2.5,
            color: Colors.green[800],
          ),
        ),
      ],
    );
  }
}
