import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class InternalCorrespondenceEntry {
  final String fromUser;
  final String toUser;
  final String toDesignation;
  final String status;
  final DateTime date;
  final String remarksTitle;
  final String remarks;

  const InternalCorrespondenceEntry({
    required this.fromUser,
    required this.toUser,
    required this.toDesignation,
    required this.status,
    required this.date,
    required this.remarksTitle,
    required this.remarks,
  });
}

class DepartmentalCorrespondenceSection extends StatefulWidget {
  final List<InternalCorrespondenceEntry> entries;

  const DepartmentalCorrespondenceSection({super.key, required this.entries});

  @override
  State<DepartmentalCorrespondenceSection> createState() =>
      _DepartmentalCorrespondenceSectionState();
}

class _DepartmentalCorrespondenceSectionState
    extends State<DepartmentalCorrespondenceSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return _sidebarShell(
      context: context,
      header: 'Deparmental Correspondence',
      headerColor: appColors.primaryDark,
      trailing: _countBadge(context, widget.entries.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.entries.isEmpty)
            AppText.bodySmall(
              'No correspondence yet.',
              color: appColors.textSecondary,
              fontSize: 12,
            ),
          for (int i = 0; i < widget.entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _correspondenceEntry(context, widget.entries[i])
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
          ],
        ],
      ),
    );
  }

  Widget _countBadge(BuildContext context, int count) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.primaryDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: AppText.bodySmall(
        '$count item(s)',
        color: appColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _correspondenceEntry(
    BuildContext context,
    InternalCorrespondenceEntry entry,
  ) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _userChip(
                context,
                entry.fromUser,
                'Secreatary',
                color: appColors.textSecondary,
              ),
              Icon(
                Icons.undo_rounded,
                size: 14,
                color: appColors.textSecondary,
              ),
              _userChip(
                context,
                entry.toUser,
                'DEO',
                color: appColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodySmall(
                entry.remarksTitle,
                color: theme.colorScheme.error,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
              Text(
                entry.remarks,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusPill(context, entry.status),
              const Spacer(),
              AppText.bodySmall(
                DateFormat('dd MMM yyyy, hh:mm a').format(entry.date),
                color: appColors.textSecondary,
                fontSize: 11,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userChip(
    BuildContext context,
    String name,
    String designation, {
    required Color color,
  }) {
    final appColors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
          child: Icon(Icons.person, size: 12, color: appColors.accent),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodySmall(
              name,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            AppText.labelSmall(
              designation,
              color: appColors.textSecondary,
              fontSize: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusPill(BuildContext context, String status) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.undo_rounded, size: 12, color: theme.colorScheme.error),
          const SizedBox(width: 4),
          AppText.bodySmall(
            status,
            color: theme.colorScheme.error,
            fontSize: 11,
            fontWeight: FontWeight.w700,
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
    Widget? trailing,
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
                  if (trailing != null) ...[trailing, const SizedBox(width: 8)],
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
