import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/loading_card.dart';
import 'package:efiling_balochistan/views/widgets/not_found.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
part 'bar_chart.dart';
part 'dashboard_card.dart';
part 'pie_chart.dart';

// Main Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  late TabController _tabController;
  bool _isLoading = true;
  FileType _currentFileType = FileType.actionRequired;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    NotificationService().initNotification();
    _loadInitialData();

    // Listen to tab changes to fetch correct files
    _tabController.addListener(() {
      if (!mounted) return;

      final newFileType = _getFileTypeForTab(_tabController.index);
      if (newFileType != _currentFileType) {
        setState(() {
          _currentFileType = newFileType;
        });
        // Fetch files for this tab
        _fetchFilesForCurrentTab();
      }
    });
  }

  FileType _getFileTypeForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return FileType.actionRequired;
      case 1:
        return FileType.pending;
      case 2:
        return FileType.forwarded;
      default:
        return FileType.actionRequired;
    }
  }

  Future<void> _fetchFilesForCurrentTab() async {
    try {
      await ref.read(filesController.notifier).fetchFiles(_currentFileType);
    } catch (error) {
      print('Error fetching files: $error');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load dashboard stats
      await ref.read(dashboardController.notifier).initData();

      // Load initial tab files (Action Required)
      await ref
          .read(filesController.notifier)
          .fetchFiles(FileType.actionRequired);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(error.toString());
    }
  }

  Future<void> _onRefresh() async {
    try {
      // Refresh dashboard stats
      await ref.read(dashboardController.notifier).initData();

      // Refresh current tab files
      await ref.read(filesController.notifier).fetchFiles(_currentFileType);

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
  Widget build(BuildContext context) {
    final model = ref.watch(dashboardController);
    final filesState = ref.watch(filesController);

    // Get filtered files (just like your other screens)
    final files = filesState.filteredFiles;

    print('Dashboard - Current file type: $_currentFileType');
    print('Dashboard - Filtered files count: ${files.length}');

    return BaseScreen(
      showUserDetails: true,
      body: _isLoading
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
                child: Column(
                  children: [
                    // Stats Cards Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Row 1
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  cardColor: AppColors.primary,
                                  iconColor: AppColors.primaryDark,
                                  title: "Action Required",
                                  value: "${model.actionRequiredCount}",
                                  onTap: () {
                                    RouteHelper.push(
                                        Routes.actionRequiredFiles);
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
                          // Row 2
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
                        ],
                      ),
                    ),

                    // Tab Section
                    Expanded(
                      child: Column(
                        children: [
                          // Tab Bar
                          Container(
                            color: AppColors.white,
                            child: TabBar(
                              controller: _tabController,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              tabs: const [
                                Tab(text: 'Action Required'),
                                Tab(text: 'Pending Files'),
                                Tab(text: 'Forwarded Files'),
                              ],
                            ),
                          ),

                          // Tab Content - ALL TABS SHOW THE SAME filteredFiles
                          // but filtered based on the current _currentFileType
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // All tabs show filteredFiles, which is already
                                // filtered by the current file type
                                _buildFileList(
                                  files: files,
                                  fileType: FileType.actionRequired,
                                  emptyMessage: 'No action required files',
                                  onRefresh: () async {
                                    await ref
                                        .read(filesController.notifier)
                                        .fetchFiles(FileType.actionRequired);
                                  },
                                ),

                                _buildFileList(
                                  files: files,
                                  fileType: FileType.pending,
                                  emptyMessage: 'No pending files',
                                  onRefresh: () async {
                                    await ref
                                        .read(filesController.notifier)
                                        .fetchFiles(FileType.pending);
                                  },
                                ),
                                _buildFileList(
                                  files: files,
                                  fileType: FileType.forwarded,
                                  emptyMessage: 'No forwarded files',
                                  onRefresh: () async {
                                    await ref
                                        .read(filesController.notifier)
                                        .fetchFiles(FileType.forwarded);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // File List Widget
  Widget _buildFileList({
    required List<FileModel> files,
    required FileType fileType,
    required String emptyMessage,
    required Future<void> Function() onRefresh,
  }) {
    print('Building $fileType list with ${files.length} files');

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NotFound(),
            const SizedBox(height: 16),
            AppText.bodyMedium(emptyMessage),
            const SizedBox(height: 16),
            AppSolidButton(
              onPressed: onRefresh,
              text: "Reload",
              width: 120,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FileCard(
          fileType: fileType, // Pass the current tab type
          data: files[i],
        ),
      ),
    );
  }

  // Empty Tab for Forwarded Files
  Widget _buildEmptyTab({
    required String message,
    required Future<void> Function() onRefresh,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          AppText.bodyMedium(
            message,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          AppSolidButton(
            onPressed: onRefresh,
            text: "Load Forwarded Files",
            width: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
