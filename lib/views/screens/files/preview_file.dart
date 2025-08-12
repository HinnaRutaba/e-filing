import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/html_reader.dart';
import 'package:flutter/material.dart';

class PreviewFile extends StatelessWidget {
  final String? html;
  const PreviewFile({super.key, this.html});

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
          padding: const EdgeInsets.fromLTRB(72.0, 16, 16, 16),
          child: Column(
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
          left: 52,
          top: 0,
          bottom: 0,
          child: Container(
            width: 6.0,
            color: Colors.green[800],
          ),
        ),
      ],
    );
  }
}
