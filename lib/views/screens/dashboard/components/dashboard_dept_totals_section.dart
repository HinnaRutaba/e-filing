import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardDeptTotalsSection extends StatelessWidget {
  const DashboardDeptTotalsSection({super.key, required this.totals});

  final DashboardDepartmentTotalsModel? totals;

  static const _rows = [
    (label: 'Created',    color: Color(0xFF5C6BC0), icon: Icons.add_circle_outline),
    (label: 'In Dept',    color: Color(0xFF2E9E6B), icon: Icons.business_rounded),
    (label: 'Forwarded',  color: Color(0xFFE07B20), icon: Icons.send_rounded),
    (label: 'Disposed',   color: Color(0xFF9E9E9E), icon: Icons.archive_rounded),
    (label: 'With CM',    color: Color(0xFF7C5CBF), icon: Icons.person_rounded),
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: total == 0
            ? _buildEmptyState(context)
            : _buildChart(context, values, total),
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

  Widget _buildChart(BuildContext context, List<int> values, int total) {
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < _rows.length; i++) {
      if (values[i] == 0) continue;
      final color = _rows[i].color;
      sections.add(
        PieChartSectionData(
          value: values[i].toDouble(),
          color: color,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color.withValues(alpha: 0.6), color],
          ),
          title: '${values[i]}',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          radius: 54,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 3,
                  centerSpaceRadius: 44,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Text(
                      'total',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _rows.length; i++)
              if (values[i] > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _rows[i].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_rows[i].label}: ${values[i]}',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ],
    );
  }
}
