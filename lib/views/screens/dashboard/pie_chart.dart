part of 'dashboard_screen.dart';

class PieChartSample extends StatelessWidget {
  final List<ChartModel> data;

  const PieChartSample({super.key, required this.data});

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
                data.length,
                (index) => PieChartSectionData(
                  color: data[index].color,
                  value: data[index].count,
                  gradient: LinearGradient(
                    colors: [
                      data[index].color.withOpacity(0.4),
                      data[index].color.withOpacity(0.8),
                      data[index].color,
                    ],
                  ),
                  title: '${data[index].count.toInt()}',
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
            color: data[index].color,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: AppText.titleSmall("${data[index].title}:"),
        ),
        const SizedBox(width: 4),
        AppText.titleSmall(
          data[index].count.toInt().toString(),
          fontWeight: FontWeight.w900,
        ),
      ],
    );
  }
}

class ChartModel {
  final String title;
  final double count;
  final Color color;

  ChartModel({
    required this.title,
    required this.count,
    required this.color,
  });
}
  // Widget _buildChartSection(DashboardModel model) {
  //   return SizedBox(
  //     height: 300,
  //     width: double.infinity,
  //     child: Card(
  //       //color: AppColors.white,
  //       margin: EdgeInsets.zero,
  //       elevation: 0,
  //       child: PieChartSample(
  //         data: [
  //           ChartModel(
  //             title: "Action Required",
  //             count: model.actionRequiredCount.toDouble(),
  //             color: AppColors.primary,
  //           ),
  //           ChartModel(
  //             title: "My Files",
  //             count: model.myFilesCount.toDouble(),
  //             color: AppColors.secondary,
  //           ),
  //           ChartModel(
  //             title: "Pending Files",
  //             count: model.pendingFilesCount.toDouble(),
  //             color: Colors.yellow[800]!,
  //           ),
  //           ChartModel(
  //             title: "Disposed Off",
  //             count: model.disposedOffCount.toDouble(),
  //             color: Colors.teal[800]!,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
// part 'bar_chart.dart';
// part 'dashboard_card.dart';
// part 'pie_chart.dart';