import 'package:curved_navigation_bar_pro/curved_navigation_bar_pro.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMBottomNavBar extends ConsumerWidget {
  const CMBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(cmNavController);
    final activeIndex = activeTab.index; // 0=dashboard, 1=summaries
    final bool isMobile = context.isMobile;

    return Container(
      margin: isMobile ? null : const EdgeInsets.fromLTRB(60, 0, 60, 16),
      child: ClipRRect(
        borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(32),
        child: CurvedNavigationBarPro(
          backgroundColor: const Color.fromARGB(255, 167, 201, 231),
          activeColor: AppColors.secondaryDark,
          activeIconColor: Colors.white,
          inactiveColor: AppColors.secondaryDark,
          fabColor: AppColors.secondaryDark,
          barHeight: 110,
          fabRadius: 28,
          fabGap: 12,
          fabSink: 22,
          notchShoulderRadius: 40,
          cornerRadius: 40,
          elevation: 5,
          shadowColor: AppColors.secondaryDark.withValues(alpha: 0.25),
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
            final tab = CMNavTab.values[index];
            ref.read(cmNavController.notifier).select(tab);
          },
        ),
      ),
    );
  }
}
