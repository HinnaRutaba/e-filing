part of 'dashboard_screen.dart';

class PieChartSample extends StatelessWidget {
  final List<String> labels = [
    'Action Required',
    'My Files',
    'Pending Files',
    'Disposed Off',
  ];

  final List<double> values = [
    12,
    4,
    6,
    4,
  ];

  final List<Color> colors = [
    AppColors.primary,
    AppColors.secondary,
    Colors.yellow[800]!,
    Colors.teal[800]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 56,
              sections: List.generate(
                labels.length,
                (index) => PieChartSectionData(
                  color: colors[index],
                  value: values[index],
                  gradient: LinearGradient(
                    colors: [
                      colors[index].withOpacity(0.4),
                      colors[index].withOpacity(0.8),
                      colors[index],
                    ],
                  ),
                  title: '${values[index].toInt()}',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: titleBuilder(0)),
            const SizedBox(width: 16),
            Expanded(child: titleBuilder(1)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: titleBuilder(2)),
            const SizedBox(width: 16),
            Expanded(child: titleBuilder(3)),
          ],
        ),
      ],
    );
  }

  Widget titleBuilder(int index) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors[index],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: AppText.titleSmall("${labels[index]}:"),
        ),
        const SizedBox(width: 4),
        AppText.titleSmall(
          values[index].toInt().toString(),
          fontWeight: FontWeight.w900,
        ),
      ],
    );
  }
}
