import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

enum FileType { pending, my, actionRequired, archived, forwarded }

class FileCard extends StatelessWidget {
  final FileType fileType;
  final FileModel? data;
  const FileCard({super.key, required this.fileType, this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = context.appColors;
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: appColors.shadow.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                // Tight contact shadow for crisp edge definition.
                BoxShadow(
                  color: appColors.shadow.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
                // Softer ambient shadow that gives the card lift.
                BoxShadow(
                  color: appColors.shadow.withValues(alpha: 0.12),
                  blurRadius: 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
                // Subtle brand tint to warm up the shadow.
                BoxShadow(
                  color: appColors.secondaryLight.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            RouteHelper.push(Routes.fileDetails(data?.fileId), extra: fileType);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: (data?.tag?.color ?? colorScheme.primary).withValues(
                alpha: 0.6,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appColors.secondaryLight.withValues(
                    alpha: isDark ? 0.3 : 0.2,
                  ),
                  width: 0.8,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: appColors.primaryDark,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AppText.labelLarge(
                              data?.barcode ?? '',
                              color: appColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                            if (fileType == FileType.forwarded) ...[
                              const SizedBox(width: 6),
                              _forwardedCountChip(context, 4),
                            ],
                            const Spacer(),
                            if (data?.tag != null) ...[
                              _tagPill(
                                context,
                                data!.tag!.title ?? '',
                                data!.tag!.color,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (fileType == FileType.forwarded ||
                                data?.status != null)
                              _statusPill(
                                context,
                                fileType == FileType.forwarded
                                    ? "Forwarded"
                                    : data?.status?.label ?? '',
                              ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: _brandOnSurface(context),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppText.bodyMedium(
                          data?.subject ?? '---',
                          color: appColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data?.sender != null)
                              Expanded(
                                child: infoTile(
                                  context: context,
                                  title: "Sender",
                                  value: data?.sender ?? "N/A",
                                ),
                              ),
                            if (data?.receiver != null) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: infoTile(
                                  context: context,
                                  title: "Receiver",
                                  value: data?.receiver ?? '---',
                                ),
                              ),
                            ],
                            const SizedBox(width: 10),
                            Expanded(
                              child:
                                  fileType == FileType.pending ||
                                      fileType == FileType.actionRequired
                                  ? infoTile(
                                      context: context,
                                      title: "Received on",
                                      value: DateTimeHelper.datFormatSlashShort(
                                        data?.receivedAt,
                                      ),
                                      icon: Icons.calendar_month,
                                    )
                                  : fileType == FileType.archived
                                  ? infoTile(
                                      context: context,
                                      title: "Archived on",
                                      value: DateTimeHelper.datFormatSlashShort(
                                        data?.archivedAt,
                                      ),
                                      icon: Icons.calendar_month,
                                    )
                                  : fileType == FileType.forwarded
                                  ? infoTile(
                                      context: context,
                                      title: "Forwarded on",
                                      value: DateTimeHelper.datFormatSlashShort(
                                        data?.latestDate,
                                      ),
                                      icon: Icons.calendar_month,
                                    )
                                  : infoTile(
                                      context: context,
                                      title: "Created on",
                                      value: DateTimeHelper.datFormatSlashShort(
                                        data?.createdAt,
                                      ),
                                      icon: Icons.calendar_month,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (data?.referenceNo != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: appColors.secondaryLight.withValues(alpha: 0.12),
                        border: Border(
                          top: BorderSide(
                            color: appColors.secondaryLight.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            color: colorScheme.secondary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          AppText.bodySmall(
                            data?.referenceNo ?? "Reference No. Not Available",
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: appColors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Brand-blue foreground tuned for the current surface: dark blue on light
  /// cards, light blue on dark navy cards.
  Color _brandOnSurface(BuildContext context) {
    final appColors = context.appColors;
    return Theme.of(context).brightness == Brightness.dark
        ? appColors.secondaryLight
        : appColors.secondaryDark;
  }

  /// Pick a readable foreground for a tag's own base color. If the base is
  /// too dark in dark mode (low luminance), lighten toward white.
  Color _onTagColor(BuildContext context, Color base) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return base;
    return base.computeLuminance() < 0.4
        ? Color.lerp(base, Colors.white, 0.6) ?? base
        : base;
  }

  Widget _tagPill(BuildContext context, String label, Color? color) {
    final base = color ?? Theme.of(context).colorScheme.secondary;
    final fg = _onTagColor(context, base);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: base.withValues(alpha: 0.5)),
      ),
      child: AppText.labelSmall(
        label,
        color: fg,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  Widget _statusPill(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = _brandOnSurface(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: AppText.labelSmall(
        label,
        color: fg,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  Widget _forwardedCountChip(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = _brandOnSurface(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forward_rounded, size: 10, color: fg),
          const SizedBox(width: 3),
          AppText.labelSmall(
            '$count×',
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required BuildContext context,
    required String title,
    required String value,
    IconData icon = Icons.person,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = _brandOnSurface(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.35),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: fg, size: 11),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.labelSmall(
                title,
                color: fg,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              AppText.bodySmall(
                value,
                color: context.appColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
