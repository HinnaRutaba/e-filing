import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_detals_screen.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/models/daak_model.dart';

class DaakCard extends StatelessWidget {
  final DaakModel daak;
  final Function(DaakViewFilter)? onStatusChange;

  const DaakCard({super.key, required this.daak, this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = context.appColors;
    final bool noDetails =
        daak.status == DaakStatus.disposedOff || daak.status == DaakStatus.nfa;
    final Color statusColor = daak.status?.color ?? appColors.secondaryDark;

    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: isDark ? 0.25 : 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: isDark ? 0.45 : 0.08),
            blurRadius: isDark ? 20 : 16,
            spreadRadius: isDark ? 0 : -2,
            offset: const Offset(0, 6),
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
                    Builder(
                      builder: (context) {
                        final pillBg = isDark
                            ? Color.lerp(
                                    statusColor,
                                    appColors.accent,
                                    0.75,
                                  ) ??
                                  statusColor
                            : theme.cardColor;
                        final pillFg = isDark
                            ? Color.lerp(statusColor, appColors.accent, 0.15) ??
                                  statusColor
                            : statusColor;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 12,
                                color: pillFg,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${daak.diaryNo}",
                                style: TextStyle(
                                  color: pillFg,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                                    color: appColors.secondaryDark.withValues(
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
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                          child: Icon(
                                            Icons.remove_red_eye,
                                            size: 18,
                                            color: colorScheme.secondary,
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
                                  Icon(
                                    Icons.apartment,
                                    size: 16,
                                    color: appColors.secondaryDark,
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
                            context,
                            'Letter Date',
                            DateTimeHelper.datFormatSlash(daak.letterDate),
                          ),
                        _infoTile(
                          context,
                          'Letter No',
                          daak.letterNo ?? "Unknown",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        // Theme-aware brand blue: dark blue on light cards,
                        // light blue on dark navy cards.
                        final Color brand = isDark
                            ? appColors.secondaryLight
                            : appColors.secondaryDark;
                        final labelStyle = TextStyle(
                          color: brand.withValues(alpha: 0.75),
                          fontSize: 14,
                        );
                        final valueStyle = TextStyle(
                          color: brand,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        );
                        return daak.status == DaakStatus.forwarded
                            ? RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Forwarded to ',
                                      style: labelStyle,
                                    ),
                                    TextSpan(
                                      text:
                                          daak
                                              .forwardDetails
                                              ?.lastForward
                                              ?.forwardedTo ??
                                          "Unknown",
                                      style: valueStyle,
                                    ),
                                    TextSpan(text: ' on ', style: labelStyle),
                                    TextSpan(
                                      text: DateTimeHelper
                                          .dateFormatddMMYYWithTime(
                                        daak
                                            .forwardDetails
                                            ?.lastForward
                                            ?.forwardedAt,
                                      ),
                                      style: valueStyle,
                                    ),
                                  ],
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Received by ',
                                      style: labelStyle,
                                    ),
                                    TextSpan(
                                      text: daak.receivedBy ?? "Unknown",
                                      style: valueStyle,
                                    ),
                                    TextSpan(text: ' on ', style: labelStyle),
                                    TextSpan(
                                      text: DateTimeHelper
                                          .dateFormatddMMYYWithTime(
                                        daak.receivedAt,
                                      ),
                                      style: valueStyle,
                                    ),
                                  ],
                                ),
                              );
                      },
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

  Widget _infoTile(BuildContext context, String label, String value) {
    final appColors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: appColors.secondaryDark),
        const SizedBox(width: 4),
        AppText.bodySmall('$label: ', fontWeight: FontWeight.w800),
        AppText.bodySmall(value),
      ],
    );
  }
}
