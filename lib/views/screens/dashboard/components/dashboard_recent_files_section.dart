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

  static const _entries = [
    (label: 'Pending',        color: Color(0xFFFFB74D), icon: Icons.hourglass_top_rounded),
    (label: 'Sent',           color: Color(0xFF5C6BC0), icon: Icons.send_rounded),
    (label: 'Received',       color: Color(0xFF2E9E6B), icon: Icons.move_to_inbox_rounded),
    (label: 'Action Req.',    color: Color(0xFFE57373), icon: Icons.info_outline_rounded),
    (label: 'My Files',       color: Color(0xFF7C5CBF), icon: Icons.folder_special_rounded),
    (label: 'Archive',        color: Color(0xFF90A4AE), icon: Icons.archive_rounded),
  ];

  List<int> _values(DashboardEfileKpisModel? k) => [
    k?.pending ?? 0,
    k?.filesSent ?? 0,
    k?.filesReceived ?? 0,
    k?.filesActionRequired ?? 0,
    k?.myFiles ?? 0,
    k?.archive ?? 0,
  ];

  @override
  Widget build(BuildContext context) {
    final values = _values(kpis);
    final total = values.fold(0, (a, b) => a + b);

    return DashboardSectionCard(
      icon: Icons.pie_chart_outline_rounded,
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
    final sections = [
      for (var i = 0; i < _entries.length; i++)
        if (values[i] > 0)
          PieChartSectionData(
            color: _entries[i].color,
            value: values[i].toDouble(),
            title: '${values[i]}',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            radius: 52,
            gradient: LinearGradient(
              colors: [_entries[i].color.withValues(alpha: 0.6), _entries[i].color],
            ),
          ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 44,
                    sections: sections,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.6, 0.6),
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
            spacing: 10,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _entries.length; i++)
                if (values[i] > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _entries[i].color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_entries[i].label}: ${values[i]}',
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
      ),
    );
  }
}
