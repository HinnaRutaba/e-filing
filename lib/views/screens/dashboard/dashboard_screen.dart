import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/dashboard_controller.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/loading_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart'; // Add this package
part 'bar_chart.dart';
part 'dashboard_card.dart';
part 'pie_chart.dart';

// Route Observer Integration
class DashboardRouteAware extends StatefulWidget {
  final Widget child;
  final WidgetRef ref;

  const DashboardRouteAware({
    super.key,
    required this.child,
    required this.ref,
  });

  @override
  State<DashboardRouteAware> createState() => _DashboardRouteAwareState();
}

class _DashboardRouteAwareState extends State<DashboardRouteAware>
    with RouteAware {
  @override
  void didPopNext() {
    // Screen is coming back into view (user returned from another screen)
    _refreshData();
    super.didPopNext();
  }

  @override
  void didPush() {
    // Screen was pushed onto the stack
    _refreshData();
    super.didPush();
  }

  void _refreshData() {
    // Use Future.microtask to ensure it runs after build phase
    Future.microtask(() {
      widget.ref.read(dashboardController.notifier).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Main Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final RefreshController _refreshController = RefreshController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Initialize notifications
    NotificationService().initNotification();

    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    // Use Future.delayed to prevent blocking the UI thread
    Future.delayed(Duration.zero, () {
      ref.read(dashboardController.notifier).initData().then((_) {
        setState(() {
          _isFirstLoad = false;
        });
      }).catchError((error) {
        // Handle initial load error
        setState(() {
          _isFirstLoad = false;
        });
        _showErrorSnackbar(error.toString());
      });
    });
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(dashboardController.notifier).initData();
      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
      _showErrorSnackbar('Failed to refresh data');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(dashboardController);

    return DashboardRouteAware(
      ref: ref,
      child: BaseScreen(
        showUserDetails: true,
        body: _isFirstLoad
            ? _buildLoadingState()
            : SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                enablePullDown: true,
                enablePullUp: false,
                header: const ClassicHeader(
                  idleText: 'Pull to refresh',
                  releaseText: 'Release to refresh',
                  refreshingText: 'Refreshing...',
                  completeText: 'Refresh complete',
                  failedText: 'Refresh failed',
                  textStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Stats Cards Row 1
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

                        // Stats Cards Row 2
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

                        const SizedBox(height: 42),

                        // Pie Chart Section
                        // if (model.error != null) _buildErrorState(),
                        _buildChartSection(model),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildChartSection(DashboardModel model) {
    return SizedBox(
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
    );
  }
}
