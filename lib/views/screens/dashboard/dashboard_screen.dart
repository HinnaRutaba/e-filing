import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  late TabController _tabController;
  final ChatService chatService = ChatService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    NotificationService().initNotification();
    _loadInitialData();

    _tabController.addListener(() {
      if (!mounted) return;
      _loadDataForCurrentTab();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await ref.read(dashboardController.notifier).initData();

      await ref.read(dashboardController.notifier).fetchActionRequiredFiles();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataForCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await ref.read(dashboardController.notifier).fetchActionRequiredFiles();
        break;
      case 1:
        await ref.read(dashboardController.notifier).fetchPendingFiles();
        break;
      case 2:
        await ref.read(dashboardController.notifier).fetchForwardedFiles();
        break;
    }
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(dashboardController.notifier).initData();

      await _loadDataForCurrentTab();

      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardController);
    UserModel currentUser = ref.read(authController);

    return BaseScreen(
      showUserDetails: true,
      enableBackButton: false,
      body: _isLoading
          ? _buildLoadingState()
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SafeArea(
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: chatService.getUnreadChatsCountStream(
                        userDesignationId:
                            currentUser.currentDesignation?.userDesgId,
                        userId: currentUser.id!,
                      ),
                      builder: (context, ss) {
                        int unread = ss.hasData ? ss.data ?? 0 : 0;

                        return unread == 0
                            ? const SizedBox.shrink()
                            : Card(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: AppColors.secondary.withAlpha(30),
                                shadowColor: Colors.grey.withAlpha(80),
                                elevation: 0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  horizontalTitleGap: 8,
                                  leading: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    color: AppColors.white,
                                    elevation: 6,
                                    shadowColor: Colors.grey.withAlpha(50),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chat_rounded,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'You have ',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '$unread ',
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              'unread chat${unread > 1 ? 's' : ''}',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  onTap: () {
                                    RouteHelper.push(Routes.chats);
                                  },
                                ),
                              );
                      },
                    ),
                    Padding(
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
                                  value:
                                      "${dashboardState.actionRequiredCount}",
                                  onTap: () {
                                    RouteHelper.push(
                                        Routes.actionRequiredFiles);
                                  },
                                  loading: dashboardState.loading,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardCard(
                                  cardColor: AppColors.secondaryLight,
                                  iconColor: AppColors.secondaryDark,
                                  title: "My Files",
                                  value: "${dashboardState.myFilesCount}",
                                  onTap: () {
                                    RouteHelper.push(Routes.myFiles);
                                  },
                                  loading: dashboardState.loading,
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
                                  value: "${dashboardState.pendingFilesCount}",
                                  onTap: () {
                                    RouteHelper.push(Routes.pendingFiles);
                                  },
                                  loading: dashboardState.loading,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardCard(
                                  cardColor: Colors.teal[500]!,
                                  iconColor: Colors.teal[800]!,
                                  title: "Disposed Off",
                                  value: "${dashboardState.disposedOffCount}",
                                  onTap: () {
                                    RouteHelper.push(Routes.archived);
                                  },
                                  loading: dashboardState.loading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            color: AppColors.white,
                            child: TabBar(
                              controller: _tabController,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelStyle: TextStyle(fontSize: 12),
                              tabs: const [
                                Tab(text: 'Pending Files'),
                                Tab(text: 'Action Required'),
                                Tab(text: 'Forwarded Files'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildFileList(
                                  files: dashboardState.actionRequiredFiles,
                                  fileType: FileType.actionRequired,
                                  loading: dashboardState.loadingActionFiles,
                                  onRefresh: () => ref
                                      .read(dashboardController.notifier)
                                      .fetchActionRequiredFiles(),
                                ),
                                _buildFileList(
                                  files: dashboardState.pendingFiles,
                                  fileType: FileType.pending,
                                  loading: dashboardState.loadingPendingFiles,
                                  onRefresh: () => ref
                                      .read(dashboardController.notifier)
                                      .fetchPendingFiles(),
                                ),
                                _buildFileList(
                                  files: dashboardState.forwardedFiles,
                                  fileType: FileType.forwarded,
                                  loading: dashboardState.loadingForwardedFiles,
                                  onRefresh: () => ref
                                      .read(dashboardController.notifier)
                                      .fetchForwardedFiles(),
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

  Widget _buildFileList({
    required List<FileModel> files,
    required FileType fileType,
    required bool loading,
    required Future<void> Function() onRefresh,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NotFound(),
            const SizedBox(height: 16),
            AppText.bodyMedium('No files found'),
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
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FileCard(
          fileType: fileType,
          data: files[i],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
