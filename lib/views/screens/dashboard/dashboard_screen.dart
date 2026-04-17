import 'dart:ui';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/dashboard_controller.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/services/notification_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_card.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/achievement_dialog.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/not_found.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final ValueNotifier<bool> _compactNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: 400.ms,
    );
    NotificationService().initNotification();
    _loadInitialData();

    _tabController.addListener(() {
      if (!mounted) return;
      _loadDataForCurrentTab();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _compactNotifier.dispose();
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

  Future<void> _loadDataForCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await ref.read(dashboardController.notifier).fetchPendingFiles();
        break;
      case 1:
        await ref.read(dashboardController.notifier).fetchDaakLetters();
        break;
      case 2:
        await ref.read(dashboardController.notifier).fetchForwardedFiles();
        break;
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

      await _loadDataForCurrentTab();

      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashboardModel dashboardState = ref.watch(dashboardController);
    UserModel currentUser = ref.read(authController);
    final topPadding = MediaQuery.of(context).padding.top;
    final bool hasAppBarIcons = context.isMobile;
    final double userHeaderTop = topPadding + (hasAppBarIcons ? 54 : 28);
    const headerHeight = 212.0;
    final bool isMobile = context.isMobile;

    final Widget headerBackground = Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: SizedBox(
          height: headerHeight,
          width: double.infinity,
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
        ),
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
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _compactNotifier,
                builder: (context, _) {
                  final bool mobileCompact = isMobile && _compactNotifier.value;
                  final double cardsOverlap = mobileCompact
                      ? 42.0
                      : isMobile
                      ? 110.0
                      : 16;
                  final double statsCardTop = isMobile
                      ? (mobileCompact ? 172.0 : 160.0)
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
              Container(
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.appColors.secondaryLight.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.secondaryDark.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.appColors.secondaryDark,
                        context.appColors.secondaryLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.secondaryDark.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  labelColor: context.appColors.accent,
                  unselectedLabelColor: context.appColors.textSecondary,
                  labelPadding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  splashBorderRadius: BorderRadius.circular(999),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: 'Pending Files', height: 30),
                    Tab(text: 'Daak Letters', height: 30),
                    Tab(text: 'Processed Files', height: 30),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: TabBarView(
                    controller: _tabController,

                    children: [
                      _buildFileList(
                        files: dashboardState.pendingFiles,
                        fileType: FileType.pending,
                        loading:
                            dashboardState.loadingPendingFiles &&
                            dashboardState.pendingFiles.isEmpty,
                        onRefresh: () => ref
                            .read(dashboardController.notifier)
                            .fetchPendingFiles(),
                      ),
                      _buildDaakList(
                        daakLetters: dashboardState.daakLetters,
                        loading:
                            dashboardState.loadingDaakLetters &&
                            dashboardState.daakLetters.isEmpty,
                        onRefresh: () => ref
                            .read(dashboardController.notifier)
                            .fetchDaakLetters(),
                      ),
                      _buildFileList(
                        files: dashboardState.forwardedFiles,
                        fileType: FileType.forwarded,
                        loading:
                            dashboardState.loadingForwardedFiles &&
                            dashboardState.forwardedFiles.isEmpty,
                        onRefresh: () => ref
                            .read(dashboardController.notifier)
                            .fetchForwardedFiles(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            radius: 22,
            child: Icon(
              Icons.person,
              color: context.appColors.accent,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              AppText.bodySmall(
                currentUser.currentDesignation?.designation ?? '',

                color: context.appColors.accent.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
        _ThemeToggleButton(
          onTap: () => ref.read(themeController.notifier).toggle(),
          isDark: ref.watch(themeController) == ThemeMode.dark,
        ),
        const SizedBox(width: 8),
        StreamBuilder<int>(
          stream: chatService.getUnreadChatsCountStream(
            userDesignationId: currentUser.currentDesignation?.userDesgId,
            userId: currentUser.id!,
          ),
          builder: (context, ss) {
            final unread = ss.hasData ? (ss.data ?? 0) : 0;
            if (context.isMobile) {
              return InkWell(
                customBorder: const CircleBorder(),
                onTap: () => RouteHelper.push(Routes.chats),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.appColors.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 99 ? '99+' : '$unread'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    textColor: context.appColors.accent,
                    child: Icon(
                      Icons.chat_rounded,
                      color: context.appColors.accent,
                      size: 22,
                    ),
                  ),
                ),
              );
            }
            return _UnreadMessagesPill(
              unread: unread,
              onTap: () => RouteHelper.push(Routes.chats),
            );
          },
        ),
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

    final pendingCard = DashboardCard(
      cardColor: context.appColors.warning,
      iconColor: Colors.yellowAccent,
      title: "Pending Files",
      value: "${dashboardState.pendingFilesCount}",
      onTap: () {
        RouteHelper.push(Routes.pendingFiles);
      },
      loading: dashboardState.loading,
      icon: Icons.timelapse,
      showSmallCard: smallCard,
    );

    final actionRequiredCard = DashboardCard(
      cardColor: Theme.of(context).colorScheme.error,
      iconColor: Colors.red[900]!,
      title: "Action Required",
      value: "${dashboardState.actionRequiredCount}",
      onTap: () {
        RouteHelper.push(Routes.actionRequiredFiles);
      },
      loading: dashboardState.loading,
      icon: Icons.info_outline,
      showSmallCard: smallCard,
    );

    final myFilesCard = DashboardCard(
      cardColor: context.appColors.secondaryLight,
      iconColor: context.appColors.secondaryDark,
      title: "My Files",
      value: "${dashboardState.myFilesCount}",
      onTap: () {
        RouteHelper.push(Routes.myFiles);
      },
      loading: dashboardState.loading,
      icon: Icons.file_copy,
      showSmallCard: smallCard,
    );

    final daakCard = Badge(
      label: AppText.labelSmall(
        "New",
        color: context.appColors.accent,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      backgroundColor: context.appColors.success,
      alignment: Alignment.topLeft,
      offset: const Offset(-2, -6),
      child: DashboardCard(
        cardColor: Colors.green[200]!,
        iconColor: Colors.green[800]!,
        title: "Daak Letters",
        value: null,
        onTap: () {
          _tabController.animateTo(1);
        },
        loading: false,
        icon: Icons.mark_email_unread,
        showSmallCard: smallCard,
      ),
    );

    final cards = [pendingCard, actionRequiredCard, myFilesCard, daakCard];

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
            AppSolidButton(onPressed: onRefresh, text: "Reload", width: 120),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FileCard(fileType: fileType, data: files[i])
            .animate()
            .fadeIn(delay: (60 * i).ms, duration: 300.ms, curve: Curves.easeOut)
            .slideX(
              begin: -0.12,
              end: 0,
              delay: (60 * i).ms,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }

  Widget _buildDaakList({
    required List<DaakModel> daakLetters,
    required bool loading,
    required Future<void> Function() onRefresh,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (daakLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NotFound(),
            const SizedBox(height: 16),
            AppText.bodyMedium('No Daak letters found'),
            const SizedBox(height: 16),
            AppSolidButton(onPressed: onRefresh, text: "Reload", width: 120),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      itemCount: daakLetters.length,
      itemBuilder: (ctx, i) => DaakCard(daak: daakLetters[i]),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeToggleButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.accent.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              RotationTransition(turns: animation, child: child),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey<bool>(isDark),
            color: context.appColors.accent,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _UnreadMessagesPill extends StatefulWidget {
  final int unread;
  final VoidCallback onTap;

  const _UnreadMessagesPill({required this.unread, required this.onTap});

  @override
  State<_UnreadMessagesPill> createState() => _UnreadMessagesPillState();
}

class _UnreadMessagesPillState extends State<_UnreadMessagesPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconIn;
  late final Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _iconIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
    );
    _textReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.unread;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(10),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final revealValue = _textReveal.value.clamp(0.0, 1.0);
            final iconValue = _iconIn.value.clamp(0.0, 1.0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: revealValue,
                    child: Opacity(
                      opacity: revealValue,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: context.appColors.accent,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'You have '),
                              TextSpan(
                                text: '$unread',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: unread == 1
                                    ? ' new message'
                                    : ' new messages',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: iconValue,
                  child: Opacity(
                    opacity: iconValue,
                    child: Icon(
                      Icons.chat_rounded,
                      color: context.appColors.accent,
                      size: 22,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
