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
    final Color statusColor = daak.status?.color ?? AppColors.secondaryDark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Accent header strip --------
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (daak.status?.label ?? "Unknown").toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            "${daak.diaryNo}",
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!noDetails) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
              // -------- Body --------
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            daak.status ??
                                            DaakStatus.inProgress1,
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
                                  Expanded(
                                    child: AppText.bodyMedium(
                                      daak.sourceDepartment ??
                                          "Unknown Department",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
        const Icon(Icons.circle, size: 6, color: AppColors.secondaryDark),
        const SizedBox(width: 4),
        AppText.bodySmall('$label: ', fontWeight: FontWeight.w800),
        AppText.bodySmall(value),
      ],
    );
  }
}
