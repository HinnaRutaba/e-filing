import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/summaries/summary_movement_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MovementTimelineSection extends StatefulWidget {
  final List<SummaryMovementModel> movements;
  final String? currentHolderName;

  const MovementTimelineSection({
    super.key,
    required this.movements,
    this.currentHolderName,
  });

  @override
  State<MovementTimelineSection> createState() =>
      _MovementTimelineSectionState();
}

class _MovementTimelineSectionState extends State<MovementTimelineSection> {
  bool _expanded = false;

  String _humanizeActionType(String? actionType) {
    if (actionType == null || actionType.trim().isEmpty) return '-';
    final parts = actionType.split(RegExp(r'[_\s]+'));
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      final p = parts[i];
      if (p.isEmpty) continue;
      if (p.toLowerCase() == 'and') {
        buffer.write('&');
      } else {
        buffer.write(p[0].toUpperCase());
        if (p.length > 1) buffer.write(p.substring(1).toLowerCase());
      }
      if (i < parts.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  String _statusFor(SummaryMovementModel m) {
    final from = m.fromDepartment?.trim();
    final to = m.toDepartment?.trim();
    if (from != null &&
        from.isNotEmpty &&
        to != null &&
        to.isNotEmpty &&
        from != to) {
      return '$from → $to';
    }
    return to ?? from ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.movements]..sort((a, b) {
      final ad = a.actedAt;
      final bd = b.actedAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return ad.compareTo(bd);
    });

    int currentIndex = -1;
    if (sorted.isNotEmpty) {
      final holder = widget.currentHolderName?.trim();
      final lastTo = sorted.last.toUser?.trim();
      if (holder != null &&
          holder.isNotEmpty &&
          lastTo != null &&
          lastTo.isNotEmpty &&
          holder == lastTo) {
        currentIndex = sorted.length - 1;
      }
    }

    final past = <SummaryMovementModel>[];
    final current = <SummaryMovementModel>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i == currentIndex) {
        current.add(sorted[i]);
      } else {
        past.add(sorted[i]);
      }
    }

    final appColors = context.appColors;
    return _sidebarShell(
      context: context,
      header: 'Movement Timeline',
      headerColor: appColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (past.isEmpty && current.isEmpty)
            AppText.bodySmall(
              'No movement history yet.',
              color: appColors.textSecondary,
              fontSize: 12,
            ),
          for (int i = 0; i < past.length; i++) ...[
            _movementEntry(context, past[i], isCurrent: false)
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
              _movementEntry(context, current[i], isCurrent: true)
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

  Widget _movementEntry(
    BuildContext context,
    SummaryMovementModel entry, {
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final accent = isCurrent
        ? theme.colorScheme.primary
        : appColors.secondaryLight;
    final stage = _humanizeActionType(entry.actionType);
    final status = isCurrent ? 'Current Pending' : _statusFor(entry);
    final department = entry.toDepartment ?? entry.fromDepartment ?? '-';
    final user = entry.toUser ?? entry.actor ?? '-';
    final actedAt = entry.actedAt;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.bodyMedium(
                  stage,
                  fontWeight: FontWeight.w700,
                  color: appColors.textPrimary,
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
                    status,
                    color: isCurrent
                        ? appColors.primaryDark
                        : appColors.secondaryDark,
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
                      user,
                      color: appColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    AppText.titleSmall(
                      '($department)',
                      color: appColors.textSecondary,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
              if (actedAt != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: appColors.textSecondary,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    AppText.labelSmall(
                      DateTimeHelper.datFormatSlash(actedAt),
                      color: appColors.textSecondary,
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
    required BuildContext context,
    required String header,
    required Color headerColor,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: 0.08),
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
