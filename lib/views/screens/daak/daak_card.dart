import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/models/daak_model.dart';

class DaakCard extends StatelessWidget {
  final DaakModel daak;

  const DaakCard({super.key, required this.daak});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        RouteHelper.push(Routes.daakDetails(6));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 5,
        shadowColor: AppColors.secondaryDark.withValues(alpha: .2),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: daak.statusColor, width: 1),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText.labelMedium(
                          "Daak - ${daak.daakNumber}",
                          color: AppColors.secondaryDark,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: daak.statusColor.withValues(alpha: .2),
                          border: Border.all(color: daak.statusColor),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        child: AppText.labelLarge(
                          daak.status,
                          color: daak.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_right,
                        color: AppColors.secondaryDark,
                      )
                    ],
                  ),
                  AppText.titleLarge(
                    daak.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.apartment,
                          size: 16, color: AppColors.secondaryDark),
                      const SizedBox(width: 4),
                      AppText.bodyMedium(
                        "${daak.department} Department",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _infoTile('Letter No', daak.letterNumber),
                      _infoTile('Letter Date',
                          DateTimeHelper.datFormatSlash(daak.letterDate)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppText.bodySmall(
                    'Received by ${daak.receivedBy} on ${DateTimeHelper.dateFormatddMMYYWithTime(daak.receivedDate)}',
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
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
