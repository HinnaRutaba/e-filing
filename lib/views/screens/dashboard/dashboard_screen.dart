import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/dashboard_controller.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_report_screen.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_efile_kpis_section.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_header_actions.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_daak_overview_section.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_recent_daak_section.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_recent_files_section.dart';
import 'package:efiling_balochistan/views/screens/secretary/secretary_dashboard_view.dart';
import 'package:efiling_balochistan/views/widgets/achievement_dialog.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
part 'bar_chart.dart';
part 'pie_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final RefreshController _refreshController = RefreshController();
  final ValueNotifier<bool> _compactNotifier = ValueNotifier<bool>(false);

  /// Only shown to the secretary: Department, My Stats and Daak Overview.
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService().initNotification(
      ref.read(authController).currentDesignation?.userDesgId,
    );
    NotificationService().clearBadge();
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshController.dispose();
    _compactNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await ref.read(dashboardController.notifier).initData();
      await _showDaakAchievementDialogIfNeeded();
    } catch (error) {}
  }

  Future<void> _showDaakAchievementDialogIfNeeded() async {
    final localStorageCtrl = ref.read(localStorageController);
    final isDaakShown = await localStorageCtrl.isDaakDialogShown();

    if (!isDaakShown && mounted) {
      localStorageCtrl.daakDialogShown();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AchievementDialog(
              title: "Daak Letters has been added",
              message:
                  "You can now receive and manage Daak letters directly in your inbox. Keep track of all incoming official correspondence in one place.",
              icon: Icons.mail_outline,
              iconColor: context.appColors.success,
            ),
          ),
        ),
      );
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!mounted || !context.isMobile) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels <= 0 && _compactNotifier.value) {
      _compactNotifier.value = false;
      return false;
    }

    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.reverse &&
        !_compactNotifier.value) {
      _compactNotifier.value = true;
    }
    return false;
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(dashboardController.notifier).initData();
      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService().clearBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashboardModel dashboardState = ref.watch(dashboardController);
    UserModel currentUser = ref.read(authController);
    final bool isSecretary =
        ref.watch(authController.select((u) => u.userDesgRole)) ==
        ActiveUserDesgRole.secretary;
    if (isSecretary) {
      return _buildSecretaryDashboard(context, dashboardState, currentUser);
    }
    final topPadding = MediaQuery.of(context).padding.top;
    final bool hasAppBarIcons = context.isMobile;
    final double userHeaderTop = topPadding + (hasAppBarIcons ? 54 : 28);
    const headerHeight = 212.0;
    final bool isMobile = context.isMobile;

    final Widget headerBackground = Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SizedBox(
        height: headerHeight,
        width: double.infinity,
        child: _buildHeaderBackdrop(dashboardState),
      ),
    );

    final Widget userHeaderPositioned = Positioned(
      top: userHeaderTop,
      left: 20,
      right: 20,
      child: _buildUserHeader(currentUser),
    );

    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        showUserDetails: false,
        isdash: true,
        enableBackButton: false,
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _compactNotifier,
                builder: (context, _) {
                  final bool mobileCompact = isMobile && _compactNotifier.value;
                  final double cardsOverlap = mobileCompact
                      ? 78.0
                      : isMobile
                      ? 126.0
                      : 16;
                  final double statsCardTop = isMobile
                      ? (mobileCompact ? 188.0 : 180.0)
                      : 124.0;
                  const Duration animDuration = Duration(milliseconds: 320);
                  const Curve animCurve = Curves.easeOutCubic;
                  return AnimatedContainer(
                    duration: animDuration,
                    curve: animCurve,
                    height: headerHeight + cardsOverlap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        headerBackground,
                        userHeaderPositioned,
                        AnimatedPositioned(
                          duration: animDuration,
                          curve: animCurve,
                          left: 16,
                          right: 16,
                          top: statsCardTop,
                          child: AnimatedSize(
                            duration: animDuration,
                            curve: animCurve,
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            child: _buildStatsCard(
                              context,
                              dashboardState,
                              mobileCompact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildSections(context, dashboardState, isMobile),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The secretary's dashboard: the usual header (without the stats card),
  /// then three tabs. My Stats is the standard dashboard; Department and
  /// Daak Overview are the secretary's own screens.
  Widget _buildSecretaryDashboard(
    BuildContext context,
    DashboardModel dashboardState,
    UserModel currentUser,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final double userHeaderTop = topPadding + (context.isMobile ? 54 : 28);

    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        showUserDetails: false,
        isdash: true,
        enableBackButton: false,
        body: Column(
          children: [
            Stack(
              children: [
                Positioned.fill(child: _buildHeaderBackdrop(dashboardState)),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, userHeaderTop, 20, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildUserHeader(currentUser),
                      const SizedBox(height: 14),
                      _buildSecretaryTabBar(),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const SecretaryDashboardView(),
                  _buildMyStatsTab(context, dashboardState),
                  const DaakReportView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretaryTabBar() {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(19),
        ),
        splashBorderRadius: BorderRadius.circular(19),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelColor: colors.secondaryDark,
        unselectedLabelColor: colors.accent,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(height: 34, text: 'Department'),
          Tab(height: 34, text: 'My Stats'),
          Tab(height: 34, text: 'E-Daak Overview'),
        ],
      ),
    );
  }

  /// The standard dashboard (the user's own stats) as a tab: stats cards, then the sections.
  Widget _buildMyStatsTab(BuildContext context, DashboardModel dashboardState) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsCard(context, dashboardState, false),
            ),
            const SizedBox(height: 24),
            _buildSections(context, dashboardState, context.isMobile),
          ],
        ),
      ),
    );
  }

  /// The dashboard artwork behind the user header: the animated SVG under a
  /// brand gradient, with rounded bottom corners. Fills whatever size it gets.
  Widget _buildHeaderBackdrop(DashboardModel dashboardState) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (dashboardState.animated)
            SvgPicture.asset(
              AssetsConstants.dashboardBG,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            )
          else
            SvgPicture.asset(
                  AssetsConstants.dashboardBG,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                )
                .animate(
                  delay: 800.ms,
                  onComplete: (_) {
                    ref
                        .read(dashboardController.notifier)
                        .markBackdropAnimated();
                  },
                )
                .custom(
                  duration: 600.ms,
                  curve: Curves.easeInOutCirc,
                  begin: 40,
                  end: 0,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(value * 30),
                        bottomLeft: Radius.circular(value * 30),
                        topRight: Radius.circular(value * 30),
                      ),
                      child: child,
                    );
                  },
                )
                .scale(
                  alignment: Alignment.bottomRight,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(duration: 400.ms),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.appColors.secondaryDark.withValues(alpha: 0.8),
              gradient: LinearGradient(
                colors: [
                  context.appColors.secondaryDark,
                  context.appColors.secondaryLight.withValues(alpha: 0.7),
                  context.appColors.accent.withValues(alpha: 0.2),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserModel currentUser) {
    return Row(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: CircleAvatar(
            backgroundColor: context.appColors.accent.withValues(alpha: 0.25),
            radius: 20,
            child: Icon(
              Icons.person,
              color: context.appColors.accent,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.headlineSmall(
                currentUser.userTitle ?? '---',
                fontWeight: FontWeight.w600,
                color: context.appColors.accent,
              ),
              const SizedBox(height: 0.5),
              AppText.bodySmall(
                currentUser.currentDesignation?.designation ?? '',
                color: context.appColors.accent.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
        const DashboardHeaderActions(),
      ],
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    DashboardModel dashboardState,
    bool compact,
  ) {
    final bool isMobile = context.isMobile;
    final bool smallCard = isMobile && compact;
    final kpis = dashboardState.stats?.efileKpis;

    Widget animated(Widget child, int index) {
      final delay = (index * 120).ms;
      return child
          .animate(delay: dashboardState.animated ? 20.ms : 1400.ms)
          .scale(
            delay: delay,
            duration: 400.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
          )
          .fadeIn(delay: delay, duration: 300.ms);
    }

    final forwardedCard = DashboardCard(
      cardColor: Colors.blue[200]!,
      iconColor: context.appColors.secondaryDark,
      title: "Forwarded E-files",
      value: '${dashboardState.forwardedFiles.length}',
      onTap: () => RouteHelper.push(Routes.forwarded),
      loading: dashboardState.loadingForwardedFiles,
      icon: Icons.forward_to_inbox_rounded,
      showSmallCard: smallCard,
    );

    final daakCard = DashboardCard(
      cardColor: Colors.green[200]!,
      iconColor: Colors.green[800]!,
      title: "E-Daak Letters",
      value: "${dashboardState.daakLetters.length}",
      onTap: () => RouteHelper.push(Routes.daak),
      loading: dashboardState.loadingDaakLetters,
      icon: Icons.mark_email_unread_rounded,
      showSmallCard: smallCard,
    );

    final pendingCard = DashboardCard(
      cardColor: context.appColors.warning,
      iconColor: Colors.yellow[900]!,
      title: "Pending E-files",
      value: "${kpis?.pending ?? 0}",
      onTap: () => RouteHelper.push(Routes.pendingFiles),
      loading: dashboardState.loadingStats,
      icon: Icons.timelapse,
      showSmallCard: smallCard,
    );

    final actionRequiredCard = DashboardCard(
      cardColor: Theme.of(context).colorScheme.error,
      iconColor: Colors.red[900]!,
      title: "Action Required",
      value: "${kpis?.filesActionRequired ?? 0}",
      onTap: () => RouteHelper.push(Routes.actionRequiredFiles),
      loading: dashboardState.loadingStats,
      icon: Icons.info_outline,
      showSmallCard: smallCard,
    );

    final cards = [pendingCard, actionRequiredCard, forwardedCard, daakCard];

    if (!isMobile || compact) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: animated(cards[i], i)),
            if (i != cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: animated(cards[0], 0)),
            const SizedBox(width: 12),
            Expanded(child: animated(cards[1], 1)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: animated(cards[2], 2)),
            const SizedBox(width: 12),
            Expanded(child: animated(cards[3], 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppText.headlineSmall(
        title,
        fontWeight: FontWeight.w700,
        color: context.appColors.textPrimary,
      ),
    );
  }

  Widget _buildSections(
    BuildContext context,
    DashboardModel dashboardState,
    bool isMobile,
  ) {
    final stats = dashboardState.stats;

    final recentPendingFilesSection = DashboardRecentFilesSection(
      kpis: stats?.efileKpis,
      loading: dashboardState.loadingStats,
    );
    final recentDaakSection = DashboardRecentDaakSection(
      items: dashboardState.daakLetters,
      loading: dashboardState.loadingDaakLetters,
    );
    final daakOverviewSection = DashboardDaakOverviewSection(
      items: dashboardState.daakLetters,
      loading: dashboardState.loadingDaakLetters,
    );
    final efileKpisSection = DashboardEfileKpisSection(kpis: stats?.efileKpis);
    const gap = SizedBox(height: 16);
    const hGap = SizedBox(width: 16);
    const sectionGap = SizedBox(height: 28);
    const bottomPadding = SizedBox(height: 100);

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeading('E-files'),
            efileKpisSection,
            gap,
            recentPendingFilesSection,
            sectionGap,
            _buildSectionHeading('E-Daak'),
            daakOverviewSection,

            gap,
            recentDaakSection,
            bottomPadding,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading('E-files'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [efileKpisSection])),
              hGap,
              Expanded(child: Column(children: [recentPendingFilesSection])),
            ],
          ),
          sectionGap,
          _buildSectionHeading('E-Daak'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: daakOverviewSection),
              hGap,
              Expanded(child: recentDaakSection),
            ],
          ),
        ],
      ),
    );
  }
}
