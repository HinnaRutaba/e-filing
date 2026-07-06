import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardDeptTotalsSection extends StatelessWidget {
  const DashboardDeptTotalsSection({super.key, required this.totals});

  final DashboardDepartmentTotalsModel? totals;

  static const _rows = [
    (label: 'Created',   color: Color(0xFF5C6BC0), icon: Icons.add_circle_outline),
    (label: 'In Dept',   color: Color(0xFF2E9E6B), icon: Icons.business_rounded),
    (label: 'Forwarded', color: Color(0xFFE07B20), icon: Icons.send_rounded),
    (label: 'Disposed',  color: Color(0xFF9E9E9E), icon: Icons.archive_rounded),
    (label: 'With CM',   color: Color(0xFF7C5CBF), icon: Icons.person_rounded),
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
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.account_tree_rounded,
      iconBgColor: const Color(0xFF5C6BC0),
      title: 'Summaries in Departments',
      badgeLabel: 'Total: $total',
      badgeColor: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF5C6BC0),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        child: total == 0
            ? _buildEmptyState(context)
            : _buildChart(context, values),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No data available.',
          style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<int> values) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (var i = 0; i < _rows.length; i++)
          _HorizontalBar(
                label: _rows[i].label,
                icon: _rows[i].icon,
                value: values[i],
                maxValue: maxValue,
                color: _rows[i].color,
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
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({
    required this.label,
    required this.icon,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final IconData icon;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue > 0 ? value / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction.clamp(0.0, 1.0),
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
