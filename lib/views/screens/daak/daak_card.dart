import 'package:flutter/material.dart';

import 'package:efiling_balochistan/views/widgets/chips/custom_app_chip.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/models/daak_model.dart';

class DaakCard extends StatelessWidget {
  final DaakModel daak;

  const DaakCard({super.key, required this.daak});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Preview (icon or thumbnail)
            Container(
              width: 56,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.secondaryDark,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText.titleLarge(
                          daak.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomAppChip(
                        label: daak.status,
                        chipColor: daak.statusColor,
                        borderColor: daak.statusColor,
                        minWidth: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.apartment,
                          size: 16, color: AppColors.secondaryDark),
                      const SizedBox(width: 4),
                      AppText.bodyMedium(daak.department),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _infoTile('Letter No.', daak.letterNumber),
                      _infoTile('Daak No.', daak.daakNumber),
                      _infoTile('Letter Date', daak.letterDate),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppText.bodySmall(
                    'Received by ${daak.receivedBy} on ${daak.receivedDate}',
                    color: AppColors.secondaryDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.bodySmall('$label: ', fontWeight: FontWeight.w600),
        AppText.bodySmall(value),
      ],
    );
  }
}
