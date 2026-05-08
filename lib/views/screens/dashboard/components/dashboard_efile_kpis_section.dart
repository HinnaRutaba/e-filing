import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardEfileKpisSection extends StatelessWidget {
  const DashboardEfileKpisSection({super.key, required this.kpis});

  final DashboardEfileKpisModel? kpis;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.pie_chart_outline_rounded,
      iconBgColor: const Color(0xFF2E9E6B),
      title: 'Files Overview',
      badgeLabel: 'eFile KPIs',
      badgeColor: const Color(0xFFDFF5EC),
      badgeTextColor: const Color(0xFF1E7A50),
      body: _buildBody(),
    );
  }

  static const _entries = [
    (label: 'Pending', color: Color(0xFFFFB74D)),
    (label: 'Sent', color: Color(0xFF5C6BC0)),
    (label: 'Received', color: Color(0xFF2E9E6B)),
    (label: 'Action Req.', color: Color(0xFFE57373)),
    (label: 'My Files', color: Color(0xFF7C5CBF)),
    (label: 'Archive', color: Color(0xFF90A4AE)),
  ];

  List<double> get _values => [
        (kpis?.pending ?? 0).toDouble(),
        (kpis?.filesSent ?? 0).toDouble(),
        (kpis?.filesReceived ?? 0).toDouble(),
        (kpis?.filesActionRequired ?? 0).toDouble(),
        (kpis?.myFiles ?? 0).toDouble(),
        (kpis?.archive ?? 0).toDouble(),
      ];

  Widget _buildBody() {
    final values = _values;
    final total = values.fold(0.0, (s, v) => s + v);

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'No file data available.',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ),
      );
    }

    final sections = [
      for (var i = 0; i < _entries.length; i++)
        if (values[i] > 0)
          PieChartSectionData(
            color: _entries[i].color,
            value: values[i],
            title: '${values[i].toInt()}',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            gradient: LinearGradient(
              colors: [
                _entries[i].color.withValues(alpha: 0.6),
                _entries[i].color,
              ],
            ),
          ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: sections,
              ),
            ).animate().fadeIn(duration: 600.ms).scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _entries.length; i++)
                _LegendDot(
                  label: '${_entries[i].label}: ${values[i].toInt()}',
                  color: _entries[i].color,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF5D5D5D)),
        ),
      ],
    );
  }
}
