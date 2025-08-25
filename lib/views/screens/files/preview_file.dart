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
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText.titleMedium(details.fileType ?? ''),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodyLarge("Subject: "),
                                    Expanded(
                                      child: AppText.titleMedium(
                                          details.subject ?? 'N/A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 0),
                      ...content!.map((e) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 24),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: AppText.bodySmall(e.fileMovNo ?? ''),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: AppText.titleMedium(
                                      e.designation ?? '',
                                    ),
                                  ),
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
                                            e.signatureUrl!,
                                            width: 80,
                                          ),
                                        const SizedBox(height: 8),
                                        AppText.titleLarge(e.sender ?? '---'),
                                        AppText.bodyMedium(
                                            "(${e.designation ?? '---'})"),
                                        const SizedBox(height: 4),
                                        AppText.bodyMedium(
                                          DateTimeHelper.datFormatSlash(
                                              e.sendingDate),
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
                    if (html != null)
                      HtmlReader(
                        html: html!,
                      )
                    else ...[
                      AppText.titleMedium("PUC"),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          AppText.bodyLarge("Subject: "),
                          AppText.titleMedium("The Subject of The File"),
                        ],
                      ),
                    ],
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/0/00/Todd_Strasser_signature.png',
                            width: 120,
                          ),
                          const SizedBox(height: 8),
                          AppText.headlineSmall("User Name"),
                          const SizedBox(height: 4),
                          AppText.bodyLarge(
                            DateTimeHelper.datFormatSlash(
                              DateTime.now(),
                            ),
                          ),
                        ],
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
