import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final SummaryModel item;
  const SummaryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final bool isDark = theme.brightness == Brightness.dark;
    final statusColor = item.statusBadge ?? Colors.grey;

    final bool isReturnedToOriginator =
        item.statusCode == 7 &&
        item.originatingUser != null &&
        item.originatingUser?.trim() == item.currentHolder?.trim();
    const Color highlightColor = Color(0xFFDC2626);

    final statusBg = isReturnedToOriginator
        ? highlightColor.withValues(alpha: isDark ? 0.32 : 0.22)
        : statusColor.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isReturnedToOriginator
              ? highlightColor.withValues(alpha: isDark ? 0.9 : 0.8)
              : appColors.secondaryLight.withValues(
                  alpha: isDark ? 0.25 : 0.18,
                ),
          width: isReturnedToOriginator ? 1.6 : 0.8,
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
          onTap: () {
            debugPrint('Tapped summary ${item.id}');
            RouteHelper.push(Routes.summaryDetails, extra: item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Accent header strip --------
              Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Status dot
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
                        item.statusLabel ?? '-',
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
                            ? Color.lerp(statusColor, appColors.accent, 0.75) ??
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
                                Icons.schedule_rounded,
                                size: 12,
                                color: pillFg,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateTimeHelper.timeAgo(
                                  item.createdAt ?? item.summaryDate,
                                ),
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
                  ],
                ),
              ),
              // -------- Body --------
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference label
                    Row(
                      children: [
                        Text(
                          item.summaryNo ?? '-',
                          style: TextStyle(
                            color: appColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: appColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            AppText.labelSmall(
                              DateTimeHelper.dateFormatddMMYYWithTime(
                                item.createdAt ?? item.summaryDate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: appColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Title
                    Text(
                      item.subject ?? '-',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.currentDepartment != null)
                          _InfoChip(
                            icon: Icons.account_tree_outlined,
                            label: 'Section',
                            value: item.currentDepartment!,
                            color: const Color(0xFF2563EB),
                          ),
                        if (item.draftTargetDepartment != null)
                          _InfoChip(
                            icon: Icons.gps_fixed_rounded,
                            label: 'Target',
                            value: item.draftTargetDepartment!,
                            color: const Color(0xFF0891B2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (item.originatingUser != null ||
                        item.currentHolder != null)
                      _PeopleRow(item: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact two-column row showing Remarks by / Drafted by with avatar initials.
class _PeopleRow extends StatelessWidget {
  final SummaryModel item;
  const _PeopleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final people = <Widget>[];
    if (item.originatingUser != null) {
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Originating',
            name: item.originatingUser!,
            sub: item.originatingDesignation,
            color: const Color(0xFF7C3AED),
          ),
        ),
      );
    }
    if (item.currentHolder != null) {
      if (people.isNotEmpty) people.add(const SizedBox(width: 10));
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Current Holder',
            name: item.currentHolder!,
            sub: item.currentHolderDesignation,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: people);
  }
}

class _PersonTile extends StatelessWidget {
  final String label;
  final String name;
  final String? sub;
  final Color color;

  const _PersonTile({
    required this.label,
    required this.name,
    required this.color,
    this.sub,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tinted chip used for Section / Target metadata.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appColors = context.appColors;
    // Pale tinted chip with brightened fg in dark mode, matching the status
    // pill treatment.
    final chipBg = isDark
        ? Color.lerp(color, appColors.accent, 0.78) ?? color
        : color.withValues(alpha: 0.08);
    final chipFg = isDark
        ? Color.lerp(color, appColors.accent, 0.1) ?? color
        : color;
    final chipBorder = isDark
        ? color.withValues(alpha: 0.5)
        : color.withValues(alpha: 0.18);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipFg),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: chipFg.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: chipFg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
