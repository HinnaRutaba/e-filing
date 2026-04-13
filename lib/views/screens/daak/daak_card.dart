import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_detals_screen.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/models/daak_model.dart';

class DaakCard extends StatelessWidget {
  final DaakModel daak;
  final Function(DaakViewFilter)? onStatusChange;

  const DaakCard({super.key, required this.daak, this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final bool noDetails =
        daak.status == DaakStatus.disposedOff || daak.status == DaakStatus.nfa;
    return InkWell(
      onTap: noDetails
          ? null
          : () {
              RouteHelper.push(
                Routes.daakDetails(daak.id),
                extra: DaakDetailsInfo(
                  daak: daak,
                  openPDF: true,
                  status: daak.status ?? DaakStatus.inProgress1,
                ),
              ).then((value) {
                if (value != null && value is DaakViewFilter) {
                  onStatusChange?.call(value);
                }
              });
            },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 5,
        shadowColor: AppColors.secondaryDark.withValues(alpha: .2),
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: daak.status?.color,
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.white,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.labelMedium(
                        "${daak.diaryNo}",
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color:
                            daak.status?.color.withOpacity(0.2) ??
                            AppColors.secondaryDark.withOpacity(0.2),
                        border: Border.all(
                          color: daak.status?.color ?? AppColors.secondaryDark,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: AppText.labelLarge(
                        daak.status?.label ?? "Unknown",
                        color: daak.status?.color ?? AppColors.secondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!noDetails)
                      const Icon(
                        Icons.arrow_right,
                        color: AppColors.secondaryDark,
                      ),
                  ],
                ),
                Row(
                  children: [
                    if (daak.incomingScanUrl != null)
                      InkWell(
                        onTap: noDetails
                            ? null
                            : () {
                                RouteHelper.push(
                                  Routes.daakDetails(daak.id),
                                  extra: DaakDetailsInfo(
                                    daak: daak,
                                    openPDF: true,
                                    status:
                                        daak.status ?? DaakStatus.inProgress1,
                                  ),
                                );
                              },
                        child: Container(
                          width: 34,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryDark.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                PdfViewer(
                                  url: daak.incomingScanUrl,
                                  fullScreen: false,
                                ),
                                if (!noDetails)
                                  const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        size: 18,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText.titleLarge(
                            daak.subject ?? "No Subject",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.apartment,
                                size: 16,
                                color: AppColors.secondaryDark,
                              ),
                              const SizedBox(width: 4),
                              AppText.bodyMedium(
                                daak.sourceDepartment ?? "Unknown Department",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (daak.letterDate != null)
                          _infoTile(
                            'Letter Date',
                            DateTimeHelper.datFormatSlash(daak.letterDate),
                          ),
                        _infoTile('Letter No', daak.letterNo ?? "Unknown"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    daak.status == DaakStatus.forwarded
                        ? RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Forwarded to ',
                                  style: TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      daak
                                          .forwardDetails
                                          ?.lastForward
                                          ?.forwardedTo ??
                                      "Unknown",
                                  style: const TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' on ',
                                  style: TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: DateTimeHelper.dateFormatddMMYYWithTime(
                                    daak
                                        .forwardDetails
                                        ?.lastForward
                                        ?.forwardedAt,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Received by ',
                                  style: TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: daak.receivedBy ?? "Unknown",
                                  style: const TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' on ',
                                  style: TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: DateTimeHelper.dateFormatddMMYYWithTime(
                                    daak.receivedAt,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.secondaryDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 6, color: AppColors.secondaryDark),
        const SizedBox(width: 4),
        AppText.bodySmall('$label: ', fontWeight: FontWeight.w800),
        AppText.bodySmall(value),
      ],
    );
  }
}
