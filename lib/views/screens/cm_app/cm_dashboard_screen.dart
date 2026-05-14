import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/cm_dashboard_controller.dart';
import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/cm_department_distribution_section.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/cm_recently_approved_section.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/cm_top_departments_section.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/cm_awaiting_approval_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CMDashboardScreen extends ConsumerStatefulWidget {
  const CMDashboardScreen({super.key});

  @override
  ConsumerState<CMDashboardScreen> createState() => _CMDashboardScreenState();
}

class _CMDashboardScreenState extends ConsumerState<CMDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initAndMaybeNavigate);
  }

  Future<void> _initAndMaybeNavigate() async {
    // Reset so every fresh mount (app start / login) is treated as an initial load.
    ref.read(cmAutoNavConsumedProvider.notifier).state = false;
    await ref.read(cmDashboardController.notifier).initData();
    if (!mounted) return;
    // If the user tapped the nav bar while data was loading, the flag is already
    // true and we skip. Otherwise, auto-navigate if there are pending approvals.
    if (!ref.read(cmAutoNavConsumedProvider)) {
      ref.read(cmAutoNavConsumedProvider.notifier).state = true;
      final pending =
          ref.read(cmDashboardController).data?.kpis?.pendingMyApproval ?? 0;
      if (pending > 0) {
        ref.read(cmNavController.notifier).select(CMNavTab.approvals);
        ref.read(cmApprovalDeskRefreshProvider.notifier).update((v) => v + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double headerHeight = isMobile ? 180.0 : 164.0;
    final double cardsOverlap = isMobile ? 130.0 : 60.0;
    final CMDashboardState dashboardState = ref.watch(cmDashboardController);

    final statsCardTop = isMobile ? 154.0 : 132.0;

    final Widget headerBackground = Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: _buildHeader(context, headerHeight),
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(cmDashboardController.notifier).initData(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: headerHeight + cardsOverlap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  headerBackground,
                  Positioned(
                    left: 16,
                    right: 16,
                    top: statsCardTop,
                    child: _buildStatsCard(context, dashboardState),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildDashboardSections(context, dashboardState, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double headerHeight) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: headerHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              AssetsConstants.dashboardBG,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryDark.withValues(alpha: 0.8),
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryDark,
                    AppColors.secondaryLight.withValues(alpha: 0.7),
                    AppColors.accent.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              const TextSpan(
                                style: TextStyle(fontSize: 20),
                                children: [
                                  TextSpan(
                                    text: 'Welcome, ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Mr, Chief Minister'),
                                ],
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              ref.read(authController.notifier).logout(context);
                            },
                            icon: Icon(
                              Icons.power_settings_new,
                              color: Colors.amber[400],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      GestureDetector(
                            onTap: () => ref
                                .read(cmNavController.notifier)
                                .select(CMNavTab.approvals),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.approval_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Open Approval Desk',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 350.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      // Row(
                      //   children: [
                      //     if (!context.isMobile) ...[
                      //       Container(
                      //             decoration: BoxDecoration(
                      //               color: Colors.white.withValues(alpha: 0.7),
                      //               borderRadius: BorderRadius.circular(100),
                      //             ),
                      //             padding: const EdgeInsets.all(10),
                      //             child: Row(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 const Icon(
                      //                   Icons.summarize,
                      //                   color: AppColors.secondaryDark,
                      //                   size: 22,
                      //                 ),
                      //                 ClipRect(
                      //                   child: Padding(
                      //                     padding: const EdgeInsets.only(
                      //                       left: 8,
                      //                     ),
                      //                     child: RichText(
                      //                       text: const TextSpan(
                      //                         style: TextStyle(
                      //                           color: AppColors.secondaryDark,
                      //                           fontSize: 14,
                      //                         ),
                      //                         children: [
                      //                           TextSpan(text: 'You have '),
                      //                           TextSpan(
                      //                             text:
                      //                                 '${dashboardState.data?.kpis?.pendingMyApproval ?? 0} ',
                      //                             style: TextStyle(
                      //                               fontWeight: FontWeight.w800,
                      //                             ),
                      //                           ),
                      //                           TextSpan(
                      //                             text: "summaries to review",
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           )
                      //           .animate(delay: 300.ms)
                      //           .scale(
                      //             alignment: Alignment.centerLeft,
                      //             begin: const Offset(0, 1),
                      //             end: const Offset(1, 1),
                      //             duration: 450.ms,
                      //             curve: Curves.easeOutCubic,
                      //           )
                      //           .fadeIn(duration: 250.ms),
                      //       ClipPath(
                      //             clipper: _ConcaveConnectorClipper(),
                      //             child: Container(
                      //               width: 20,
                      //               height: 24,
                      //               color: Colors.white.withValues(alpha: 0.7),
                      //             ),
                      //           )
                      //           .animate(delay: 300.ms)
                      //           .scale(
                      //             delay: 450.ms,
                      //             alignment: Alignment.centerLeft,
                      //             begin: const Offset(0, 1),
                      //             end: const Offset(1, 1),
                      //             duration: 250.ms,
                      //             curve: Curves.easeOutCubic,
                      //           )
                      //           .fadeIn(delay: 450.ms, duration: 150.ms),
                      //     ],
                      //     InkWell(
                      //           onTap: () {
                      //             ref
                      //                 .read(cmNavController.notifier)
                      //                 .select(CMNavTab.approvals);
                      //           },
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               color: Colors.white.withValues(alpha: 0.7),
                      //               borderRadius: BorderRadius.circular(100),
                      //             ),
                      //             padding: const EdgeInsets.all(8),
                      //             child: AppText.titleSmall(
                      //               "Open Pending Approvals",
                      //               color: AppColors.secondaryDark,
                      //               fontSize: 14,
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //           ),
                      //         )
                      //         .animate(delay: 300.ms)
                      //         .scale(
                      //           delay: 700.ms,
                      //           alignment: Alignment.centerLeft,
                      //           begin: const Offset(0, 0),
                      //           end: const Offset(1, 1),
                      //           duration: 550.ms,
                      //           curve: Curves.easeInOutBack,
                      //         )
                      //         .fadeIn(delay: 700.ms, duration: 200.ms),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    CMDashboardState dashboardState,
  ) {
    Widget animated(Widget child, int index) {
      final delay = (index * 120).ms;
      return child
          .animate()
          .scale(
            delay: delay,
            duration: 400.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
          )
          .fadeIn(delay: delay, duration: 300.ms);
    }

    final kpis = dashboardState.data?.kpis;

    final awaitingCard = DashboardCard(
      cardColor: context.appColors.warning,
      iconColor: Colors.yellowAccent,
      title: "Awaiting Approval",
      value: "${kpis?.pendingMyApproval ?? 0}",
      onTap: null,
      loading: dashboardState.loading,
      icon: Icons.pending_actions,
      showSmallCard: false,
    );

    final activeCard = DashboardCard(
      cardColor: Theme.of(context).colorScheme.error,
      iconColor: Colors.red[900]!,
      title: "Active In Progress",
      value: "${kpis?.inProgress ?? 0}",
      onTap: null,
      loading: dashboardState.loading,
      icon: Icons.autorenew,
      showSmallCard: false,
    );

    final summariesCard = DashboardCard(
      cardColor: context.appColors.secondaryLight,
      iconColor: context.appColors.secondaryDark,
      title: "Total Summaries",
      value: "${kpis?.totalSummaries ?? 0}",
      onTap: null,
      loading: dashboardState.loading,
      icon: Icons.summarize,
      showSmallCard: false,
    );

    final closedCard = DashboardCard(
      cardColor: Colors.green[200]!,
      iconColor: Colors.green[800]!,
      title: "Closed / Disposed",
      value: "${kpis?.closedDisposed ?? 0}",
      onTap: null,
      loading: dashboardState.loading,
      icon: Icons.check_circle_outline,
      showSmallCard: false,
    );

    final cards = [awaitingCard, activeCard, summariesCard, closedCard];

    if (context.isMobile) {
      return Column(
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

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: animated(cards[i], i)),
          if (i != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildDashboardSections(
    BuildContext context,
    CMDashboardState state,
    bool isMobile,
  ) {
    final data = state.data;
    final awaitingSection = CMAwaitingApprovalSection(
      items: data?.pendingForCm ?? [],
    );
    final deptSection = CMDepartmentDistributionSection(
      depts: data?.departmentStats ?? [],
    );
    final recentSection = CMRecentlyApprovedSection(
      items: data?.recentlyApproved ?? [],
    );
    final topDeptsSection = CMTopDepartmentsSection(
      items: data?.topOriginating ?? [],
    );

    // Bottom padding accounts for the floating bottom nav bar
    const bottomPadding = SizedBox(height: 100);

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            awaitingSection,
            const SizedBox(height: 16),
            recentSection,
            const SizedBox(height: 16),
            deptSection,
            const SizedBox(height: 16),
            topDeptsSection,
            bottomPadding,
          ],
        ),
      );
    }

    // Tablet / Desktop: two-column layout
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                awaitingSection,
                const SizedBox(height: 16),
                deptSection,
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                recentSection,
                const SizedBox(height: 16),
                topDeptsSection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcaveConnectorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const double vDip = 0.75; // top/bottom: deep concave
    const double hDip = 0.2; // left/right: very subtle concave
    // Top edge: curves downward toward center (deep concave)
    path.moveTo(0, 0);
    path.quadraticBezierTo(w / 2, h * vDip, w, 0);
    // Right edge: curves leftward very slightly (subtle concave)
    path.quadraticBezierTo(w - w * hDip, h / 2, w, h);
    // Bottom edge: curves upward toward center (deep concave)
    path.quadraticBezierTo(w / 2, h - h * vDip, 0, h);
    // Left edge: curves rightward very slightly (subtle concave)
    path.quadraticBezierTo(w * hDip, h / 2, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
