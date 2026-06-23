import 'dart:math';

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardRecentMyFilesSection extends StatelessWidget {
  const DashboardRecentMyFilesSection({
    super.key,
    required this.kpis,
    required this.loading,
  });

  final DashboardEfileKpisModel? kpis;
  final bool loading;

  static const _labels = ['My Files', 'Pending', 'Archive', 'Action Req.'];

  static const _colors = [
    Color(0xFF7C5CBF),
    Color(0xFFFFB74D),
    Color(0xFF90A4AE),
    Color(0xFFE57373),
  ];

  List<int> _values(DashboardEfileKpisModel? k) => [
    k?.myFiles ?? 0,
    k?.pending ?? 0,
    k?.archive ?? 0,
    k?.filesActionRequired ?? 0,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values(kpis);
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.file_copy_rounded,
      iconBgColor: const Color(0xFF7C5CBF),
      title: 'My Files Breakdown',
      badgeLabel: 'Total: $total',
      badgeColor: const Color(0xFF7C5CBF).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF7C5CBF),
      body: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : total == 0
          ? _buildEmptyState(context)
          : _buildChart(context, values),
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

  Widget _buildChart(BuildContext context, List<int> values) {
    final maxVal = values.fold(0, max).toDouble();
    final maxY = maxVal == 0 ? 5.0 : maxVal * 1.25;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1E1E2E),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${_labels[groupIndex]}\n${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= _labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _labels[index],
                        style: TextStyle(
                          fontSize: 9,
                          color: context.appColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: const Color(0xFF7C5CBF).withValues(alpha: 0.08),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(_labels.length, (i) {
              final color = _colors[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i].toDouble(),
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color.withValues(alpha: 0.5),
                        color,
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}
