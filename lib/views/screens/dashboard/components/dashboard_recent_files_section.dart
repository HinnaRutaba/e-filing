import 'package:efiling_balochistan/models/dashboard_stats_model.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_charts.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// "E-file Activity": the same panel and donut as the secretary and Daak
/// dashboards, so the three read as one chart style.
class DashboardRecentFilesSection extends StatelessWidget {
  const DashboardRecentFilesSection({
    super.key,
    required this.kpis,
    required this.loading,
  });

  final DashboardEfileKpisModel? kpis;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final viz = SecretaryVizColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    final k = kpis;

    // Colors follow the secretary dashboard: amber = pending, green = sent,
    // blue = archived (done).
    final slices = [
      SecretaryDonutSlice('Pending', k?.pending ?? 0, viz.amber),
      SecretaryDonutSlice('Sent', k?.filesSent ?? 0, viz.green),
      SecretaryDonutSlice('Received', k?.filesReceived ?? 0, viz.sky),
      SecretaryDonutSlice('Action Req.', k?.filesActionRequired ?? 0, error),
      SecretaryDonutSlice('My Files', k?.myFiles ?? 0, viz.navy),
      SecretaryDonutSlice('Archive', k?.archive ?? 0, viz.blue),
    ];
    final total = slices.fold<int>(0, (a, s) => a + s.value);

    return SecretaryPanel(
      delay: 100.ms,
      icon: Icons.pie_chart_outline_rounded,
      color: viz.amber,
      title: 'E-file Activity',
      subtitle: 'Where your files currently stand',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : SecretaryDonutWithLegend(
                centerLabel: 'Total',
                centerValue: total,
                blobs: true,
                slices: slices,
              ),
      ),
    );
  }
}
