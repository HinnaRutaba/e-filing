import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardRecentSummariesSection extends StatelessWidget {
  const DashboardRecentSummariesSection({
    super.key,
    required this.tabCounts,
    required this.loading,
  });

  final DashboardTabCountsModel? tabCounts;
  final bool loading;

  static const _rows = [
    (label: 'Inbox',    color: Color(0xFF7C5CBF), icon: Icons.inbox_rounded),
    (label: 'Sent',     color: Color(0xFF5C6BC0), icon: Icons.send_rounded),
    (label: 'Drafts',   color: Color(0xFFFFB74D), icon: Icons.drafts_rounded),
    (label: 'Internal', color: Color(0xFF2E9E6B), icon: Icons.swap_horiz_rounded),
    (label: 'Pending',  color: Color(0xFFE07B20), icon: Icons.hourglass_top_rounded),
    (label: 'Disposed', color: Color(0xFF90A4AE), icon: Icons.archive_rounded),
  ];

  List<int> _values(DashboardTabCountsModel? t) => [
    t?.inbox ?? 0,
    t?.sent ?? 0,
    t?.drafts ?? 0,
    t?.internal ?? 0,
    t?.pendingDisposal ?? 0,
    t?.disposed ?? 0,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values(tabCounts);
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.summarize_rounded,
      iconBgColor: const Color(0xFF7C5CBF),
      title: 'Summary Overview',
      badgeLabel: 'Total: $total',
      badgeColor: const Color(0xFF7C5CBF).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF7C5CBF),
      body: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < _rows.length; i++)
                    _StatTile(
                          label: _rows[i].label,
                          value: values[i],
                          color: _rows[i].color,
                          icon: _rows[i].icon,
                          onTap: () => RouteHelper.push(Routes.summaries),
                        )
                        .animate(delay: (i * 80).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(
                          begin: -0.06,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                ],
              ),
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
