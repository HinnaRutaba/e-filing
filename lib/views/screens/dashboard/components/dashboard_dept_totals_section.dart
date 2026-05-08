import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardDeptTotalsSection extends StatelessWidget {
  const DashboardDeptTotalsSection({super.key, required this.totals});

  final DashboardDepartmentTotalsModel? totals;

  static const _rows = [
    (
      label: 'Created Total',
      color: Color(0xFF5C6BC0),
      icon: Icons.add_circle_outline,
    ),
    (
      label: 'In Department',
      color: Color(0xFF2E9E6B),
      icon: Icons.business_rounded,
    ),
    (
      label: 'Forwarded Externally',
      color: Color(0xFFE07B20),
      icon: Icons.send_rounded,
    ),
    (
      label: 'Disposed Total',
      color: Color(0xFF9E9E9E),
      icon: Icons.archive_rounded,
    ),
    (label: 'With CM', color: Color(0xFF7C5CBF), icon: Icons.person_rounded),
  ];

  List<int> _values(DashboardDepartmentTotalsModel? t) => [
    t?.createdTotal ?? 0,
    t?.currentlyInDepartment ?? 0,
    t?.forwardedExternally ?? 0,
    t?.disposedTotal ?? 0,
    t?.withCm ?? 0,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values(totals);
    return DashboardSectionCard(
      icon: Icons.account_tree_rounded,
      iconBgColor: const Color(0xFF5C6BC0),
      title: 'Summaries in Departments',
      badgeLabel: 'Overview',
      badgeColor: const Color(0xFFEDE7F6),
      badgeTextColor: const Color(0xFF5C35B0),
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
              style: const TextStyle(fontSize: 13, color: Color(0xFF5D5D5D)),
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
