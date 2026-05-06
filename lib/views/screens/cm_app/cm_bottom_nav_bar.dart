import 'package:curved_navigation_bar_pro/curved_navigation_bar_pro.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMBottomNavBar extends ConsumerWidget {
  const CMBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(cmNavController);
    final activeIndex = activeTab.index; // 0=dashboard, 1=summaries

    return CurvedNavigationBarPro(
      backgroundColor: AppColors.secondary,
      activeColor: AppColors.white,
      activeIconColor: Colors.white,
      inactiveColor: Colors.white70,
      fabColor: AppColors.secondaryDark,
      barHeight: 110,
      fabRadius: 28,
      fabGap: 10,
      fabSink: 22,
      notchShoulderRadius: 50,
      cornerRadius: 40,
      elevation: 14,
      shadowColor: Colors.black12,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 400),
      activeTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
      inactiveTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      inactiveIconSize: 24,
      activeIconSize: 22,
      currentIndex: activeIndex,
      items: const [
        CurvedNavigationItemPro(
          inactiveIcon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Dashboard',
        ),
        CurvedNavigationItemPro(
          inactiveIcon: Icons.summarize_outlined,
          activeIcon: Icons.summarize_rounded,
          label: 'Summaries',
        ),
        CurvedNavigationItemPro(
          inactiveIcon: Icons.pending_actions_outlined,
          activeIcon: Icons.pending_actions,
          label: 'Approvals',
        ),
      ],
      onTap: (index) {
        if (index == 2) {
          RouteHelper.push(Routes.cmApprovalDesk);
          return;
        }
        final tab = CMNavTab.values[index];
        ref.read(cmNavController.notifier).select(tab);
        if (index == 0) RouteHelper.push(Routes.cmDashboard);
        if (index == 1) RouteHelper.push(Routes.cmSummaries);
      },
    );
  }
}
