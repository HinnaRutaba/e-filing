import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/loading_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'bar_chart.dart';
part 'dashboard_card.dart';
part 'pie_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    NotificationService().initNotification();
    ref.read(dashboardController.notifier).initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(dashboardController);
    return BaseScreen(
      showUserDetails: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    cardColor: AppColors.primary,
                    iconColor: AppColors.primaryDark,
                    title: "Action Required",
                    value: "${model.actionRequiredCount}",
                    onTap: () {
                      RouteHelper.push(Routes.actionRequiredFiles);
                    },
                    loading: model.loading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    cardColor: AppColors.secondaryLight,
                    iconColor: AppColors.secondaryDark,
                    title: "My Files",
                    value: "${model.myFilesCount}",
                    onTap: () {
                      RouteHelper.push(Routes.myFiles);
                    },
                    loading: model.loading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    cardColor: Colors.yellow[800]!,
                    iconColor: Colors.orange[800]!,
                    title: "Pending Files",
                    value: "${model.pendingFilesCount}",
                    onTap: () {
                      RouteHelper.push(Routes.pendingFiles);
                    },
                    loading: model.loading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    cardColor: Colors.teal[500]!,
                    iconColor: Colors.teal[800]!,
                    title: "Disposed Off",
                    value: "${model.disposedOffCount}",
                    onTap: () {
                      RouteHelper.push(Routes.archived);
                    },
                    loading: model.loading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Card(
                //color: AppColors.white,
                margin: EdgeInsets.zero,
                elevation: 0,
                child: PieChartSample(
                  data: [
                    ChartModel(
                      title: "Action Required",
                      count: model.actionRequiredCount.toDouble(),
                      color: AppColors.primary,
                    ),
                    ChartModel(
                      title: "My Files",
                      count: model.myFilesCount.toDouble(),
                      color: AppColors.secondary,
                    ),
                    ChartModel(
                      title: "Pending Files",
                      count: model.pendingFilesCount.toDouble(),
                      color: Colors.yellow[800]!,
                    ),
                    ChartModel(
                      title: "Disposed Off",
                      count: model.disposedOffCount.toDouble(),
                      color: Colors.teal[800]!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
