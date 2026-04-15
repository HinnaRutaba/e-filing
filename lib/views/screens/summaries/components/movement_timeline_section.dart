import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SummaryMovementEntry {
  final String status;
  final String stage;
  final String department;
  final String user;
  final bool current;
  const SummaryMovementEntry({
    required this.status,
    required this.stage,
    required this.department,
    required this.user,
    this.current = false,
  });
}

class MovementTimelineSection extends StatelessWidget {
  final List<SummaryMovementEntry> movementHistory;

  const MovementTimelineSection({super.key, required this.movementHistory});

  @override
  Widget build(BuildContext context) {
    final current = movementHistory
        .where((e) => e.current)
        .toList(growable: false);
    final past = movementHistory
        .where((e) => !e.current)
        .toList(growable: false);

    return _sidebarShell(
      header: 'Movement Timeline',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (past.isEmpty)
            AppText.bodySmall(
              'No movement history yet.',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          for (final entry in past) ...[
            _movementEntry(entry),
            const SizedBox(height: 8),
          ],
          if (current.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final entry in current) _movementEntry(entry),
          ],
        ],
      ),
    );
  }

  Widget _movementEntry(SummaryMovementEntry entry) {
    final accent = entry.current ? AppColors.primary : AppColors.secondaryLight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.current
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodyMedium(
                  entry.stage,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppText.bodySmall(
                    entry.status,
                    color: accent == AppColors.primary
                        ? AppColors.primaryDark
                        : AppColors.secondaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleSmall(
                      entry.user,
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    AppText.titleSmall(
                      '(${entry.department})',
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.grey,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  AppText.labelSmall(
                    DateTimeHelper.datFormatSlash(DateTime.now()),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sidebarShell({
    required String header,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: headerColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                AppText.bodyMedium(
                  header,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
