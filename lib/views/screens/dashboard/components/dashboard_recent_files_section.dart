import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardRecentFilesSection extends StatelessWidget {
  const DashboardRecentFilesSection({
    super.key,
    required this.kpis,
    required this.loading,
  });

  final DashboardEfileKpisModel? kpis;
  final bool loading;

  static const _labels = ['Pending', 'Sent', 'Received', 'Action Req.'];

  static const _colors = [
    Color(0xFFFFB74D),
    Color(0xFF5C6BC0),
    Color(0xFF2E9E6B),
    Color(0xFFE57373),
  ];

  List<int> _values(DashboardEfileKpisModel? k) => [
    k?.pending ?? 0,
    k?.filesSent ?? 0,
    k?.filesReceived ?? 0,
    k?.filesActionRequired ?? 0,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values(kpis);
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.folder_open_rounded,
      iconBgColor: const Color(0xFFE07B20),
      title: 'File Activity',
      badgeLabel: 'Total: $total',
      badgeColor: const Color(0xFFE07B20).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFFE07B20),
      body: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : total == 0
          ? _buildEmptyState(context)
          : _buildChart(context, values, total),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
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
    for (var i = 0; i < _labels.length; i++) {
      if (values[i] == 0) continue;
      final color = _colors[i];
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
            fontSize: 11,
          ),
          radius: 52,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 3,
                    centerSpaceRadius: 42,
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
                          fontSize: 18,
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
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(_labels.length, (i) {
              if (values[i] == 0) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
