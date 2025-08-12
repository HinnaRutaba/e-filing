part of 'dashboard_screen.dart';

class BarChartSample extends StatelessWidget {
  final List<String> labels = [
    'Action Required',
    'My Files',
    'Pending Files',
    'Disposed Off'
  ];

  final List<double> values = [
    12,
    4,
    6,
    4,
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15, // adjust according to max value
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= labels.length) return Container();
                final label = labels[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AppText.labelLarge(label),
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
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          labels.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                width: 24,
                borderRadius: BorderRadius.circular(4),
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
