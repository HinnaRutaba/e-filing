import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class MovementTimelineSection extends StatefulWidget {
  final List<SummaryMovementEntry> movementHistory;

  const MovementTimelineSection({super.key, required this.movementHistory});

  @override
  State<MovementTimelineSection> createState() =>
      _MovementTimelineSectionState();
}

class _MovementTimelineSectionState extends State<MovementTimelineSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final current = widget.movementHistory
        .where((e) => e.current)
        .toList(growable: false);
    final past = widget.movementHistory
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
          for (int i = 0; i < past.length; i++) ...[
            _movementEntry(past[i])
                .animate()
                .fadeIn(
                  delay: (80 * i).ms,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                )
                .slideX(
                  begin: -0.15,
                  end: 0,
                  delay: (80 * i).ms,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 8),
          ],
          if (current.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (int i = 0; i < current.length; i++)
              _movementEntry(current[i])
                  .animate()
                  .fadeIn(
                    delay: (80 * (past.length + i)).ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: -0.15,
                    end: 0,
                    delay: (80 * (past.length + i)).ms,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
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
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
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
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
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
                  Expanded(
                    child: AppText.bodyMedium(
                      header,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: headerColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
