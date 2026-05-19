import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardDaakOverviewSection extends StatelessWidget {
  const DashboardDaakOverviewSection({
    super.key,
    required this.items,
    required this.loading,
  });

  final List<DaakModel> items;
  final bool loading;

  static const _rows = [
    (label: 'In Progress', color: Color(0xFF42A5F5), icon: Icons.hourglass_top_rounded),
    (label: 'Forwarded',   color: Color(0xFFFFB74D), icon: Icons.send_rounded),
    (label: 'NFA',         color: Color(0xFF90A4AE), icon: Icons.do_not_disturb_alt_rounded),
    (label: 'Disposed',    color: Color(0xFFEF5350), icon: Icons.archive_rounded),
  ];

  Map<String, int> _groupCounts(List<DaakModel> items) {
    final counts = <String, int>{
      'In Progress': 0,
      'Forwarded': 0,
      'NFA': 0,
      'Disposed': 0,
    };
    for (final item in items) {
      switch (item.status) {
        case DaakStatus.inProgress1:
        case DaakStatus.inProgress2:
        case DaakStatus.inProgress3:
        case DaakStatus.filePutup:
          counts['In Progress'] = (counts['In Progress'] ?? 0) + 1;
          break;
        case DaakStatus.forwarded:
          counts['Forwarded'] = (counts['Forwarded'] ?? 0) + 1;
          break;
        case DaakStatus.nfa:
          counts['NFA'] = (counts['NFA'] ?? 0) + 1;
          break;
        case DaakStatus.disposedOff:
          counts['Disposed'] = (counts['Disposed'] ?? 0) + 1;
          break;
        case null:
          counts['In Progress'] = (counts['In Progress'] ?? 0) + 1;
          break;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _groupCounts(items);
    final values = _rows.map((r) => counts[r.label] ?? 0).toList();
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.bar_chart_rounded,
      iconBgColor: const Color(0xFF42A5F5),
      title: 'Daak Overview',
      badgeLabel: loading ? '...' : 'Total: $total',
      badgeColor: const Color(0xFF42A5F5).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF42A5F5),
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
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
