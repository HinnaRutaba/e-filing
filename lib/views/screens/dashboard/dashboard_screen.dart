import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

part 'bar_chart.dart';
part 'dashboard_card.dart';
part 'pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
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
                    value: "12",
                    onTap: () {
                      RouteHelper.push(Routes.actionRequiredFiles);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    cardColor: AppColors.secondaryLight,
                    iconColor: AppColors.secondaryDark,
                    title: "My Files",
                    value: "4",
                    onTap: () {
                      RouteHelper.push(Routes.myFiles);
                    },
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
                    value: "6",
                    onTap: () {
                      RouteHelper.push(Routes.pendingFiles);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    cardColor: Colors.teal[500]!,
                    iconColor: Colors.teal[800]!,
                    title: "Disposed Off",
                    value: "4",
                    onTap: () {
                      RouteHelper.push(Routes.archived);
                    },
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
                child: PieChartSample(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
