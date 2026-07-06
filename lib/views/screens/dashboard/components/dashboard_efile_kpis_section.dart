import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardEfileKpisSection extends StatelessWidget {
  const DashboardEfileKpisSection({super.key, required this.kpis});

  final DashboardEfileKpisModel? kpis;

  static const _rows = [
    (label: 'Pending',        color: Color(0xFFFFB74D), icon: Icons.hourglass_top_rounded),
    (label: 'Sent',           color: Color(0xFF5C6BC0), icon: Icons.send_rounded),
    (label: 'Received',       color: Color(0xFF2E9E6B), icon: Icons.move_to_inbox_rounded),
    (label: 'Action Required',color: Color(0xFFE57373), icon: Icons.info_outline_rounded),
    (label: 'My Files',       color: Color(0xFF7C5CBF), icon: Icons.folder_special_rounded),
    (label: 'Archive',        color: Color(0xFF90A4AE), icon: Icons.archive_rounded),
  ];

  List<int> _values() => [
        kpis?.pending ?? 0,
        kpis?.filesSent ?? 0,
        kpis?.filesReceived ?? 0,
        kpis?.filesActionRequired ?? 0,
        kpis?.myFiles ?? 0,
        kpis?.archive ?? 0,
      ];

  static final _onTaps = <VoidCallback?>[
    () => RouteHelper.push(Routes.pendingFiles),
    () => RouteHelper.push(Routes.forwarded),
    null,
    () => RouteHelper.push(Routes.actionRequiredFiles),
    () => RouteHelper.push(Routes.myFiles),
    () => RouteHelper.push(Routes.archived),
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values();
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.folder_open_rounded,
      iconBgColor: const Color(0xFF2E9E6B),
      title: 'Files Overview',
      badgeLabel: 'Total: $total',
      badgeColor: const Color(0xFF2E9E6B).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF2E9E6B),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            for (var i = 0; i < _rows.length; i++)
              _StatTile(
                    label: _rows[i].label,
                    value: values[i],
                    color: _rows[i].color,
                    icon: _rows[i].icon,
                    onTap: _onTaps[i],
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
