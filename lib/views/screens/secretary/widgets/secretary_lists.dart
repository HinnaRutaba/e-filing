import 'dart:math' as math;

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Ranked list of users; bars are relative to the list's leader.
class SecretaryTopUsersPanel extends StatelessWidget {
  const SecretaryTopUsersPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
    this.delay = Duration.zero,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<SecretaryTopUserModel> items;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(0, (m, e) => math.max(m, e.count ?? 0));

    return SecretaryPanel(
      delay: delay,
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      child: items.isEmpty
          ? const SecretaryEmptyState()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _TopUserRow(
                          item: items[i],
                          rank: i + 1,
                          fraction: maxCount == 0
                              ? 0
                              : (items[i].count ?? 0) / maxCount,
                          color: color,
                        )
                        .animate(delay: delay + (150 + i * 80).ms)
                        .fadeIn()
                        .slideX(
                          begin: 0.06,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                    if (i < items.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
    );
  }
}

class _TopUserRow extends StatelessWidget {
  const _TopUserRow({
    required this.item,
    required this.rank,
    required this.fraction,
    required this.color,
  });

  final SecretaryTopUserModel item;
  final int rank;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final leader = rank == 1;
    final subtitle = [
      item.designation,
      item.section,
    ].whereType<String>().join(' • ');

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: leader ? color : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: leader
              ? const Icon(Icons.star_rounded, size: 18, color: Colors.white)
              : Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.userTitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedCount(
                    value: item.count ?? 0,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
              const SizedBox(height: 5),
              AnimatedBar(fraction: fraction, color: color, height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Per-section totals as stacked archived / pending bars. Bar length is the
/// section's total relative to the busiest section.
class SecretarySectionsPanel extends StatefulWidget {
  const SecretarySectionsPanel({
    super.key,
    required this.sections,
    this.delay = Duration.zero,
  });

  final List<SecretarySectionStatModel> sections;
  final Duration delay;

  @override
  State<SecretarySectionsPanel> createState() => _SecretarySectionsPanelState();
}

class _SecretarySectionsPanelState extends State<SecretarySectionsPanel> {
  static const int _collapsedCount = 8;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viz = SecretaryVizColors.of(context);
    final visible = widget.sections.where((e) => (e.total ?? 0) > 0).toList()
      ..sort((a, b) => (b.total ?? 0).compareTo(a.total ?? 0));
    final hidden = widget.sections.length - visible.length;
    final shown = _expanded ? visible : visible.take(_collapsedCount).toList();
    final maxTotal = visible.isEmpty ? 1 : (visible.first.total ?? 1);

    return SecretaryPanel(
      delay: widget.delay,
      icon: Icons.account_tree_outlined,
      color: viz.blue,
      title: 'Section Overview',
      headerBottomGap: 8,
      child: visible.isEmpty
          ? const SecretaryEmptyState()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wraps rather than overflowing on narrow screens.
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            _LegendDot(color: viz.blue, label: 'Archived'),
                            _LegendDot(color: viz.amber, label: 'Pending'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${visible.length} sections',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        for (var i = 0; i < shown.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child:
                                _SectionRow(
                                      item: shown[i],
                                      fraction:
                                          (shown[i].total ?? 0) / maxTotal,
                                      archivedColor: viz.blue,
                                      pendingColor: viz.amber,
                                    )
                                    .animate(delay: (150 + i * 60).ms)
                                    .fadeIn()
                                    .slideX(
                                      begin: 0.06,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  if (visible.length > _collapsedCount)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        icon: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: 250.ms,
                          child: const Icon(Icons.expand_more_rounded),
                        ),
                        label: Text(
                          _expanded
                              ? 'Show less'
                              : 'Show all ${visible.length} sections',
                        ),
                      ),
                    ),
                  if (hidden > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$hidden sections with no files are hidden',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.item,
    required this.fraction,
    required this.archivedColor,
    required this.pendingColor,
  });

  final SecretarySectionStatModel item;
  final double fraction;
  final Color archivedColor;
  final Color pendingColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final archived = item.archived ?? 0;
    final pending = item.pending ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.section ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            AnimatedCount(
              value: item.total ?? 0,
              style: TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: fraction.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (archived > 0)
                  Expanded(
                    flex: archived,
                    child: ColoredBox(color: archivedColor),
                  ),
                if (archived > 0 && pending > 0) const SizedBox(width: 2),
                if (pending > 0)
                  Expanded(
                    flex: pending,
                    child: ColoredBox(color: pendingColor),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: colors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Archived '),
              TextSpan(
                text: formatCount(archived),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: archivedColor,
                ),
              ),
              const TextSpan(text: '   •   Pending '),
              TextSpan(
                text: formatCount(pending),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: pendingColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
