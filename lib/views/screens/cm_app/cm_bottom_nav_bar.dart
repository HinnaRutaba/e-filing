import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
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

    return AnimatedBottomNavigationBar.builder(
      itemCount: 2,
      tabBuilder: (index, isActive) {
        final items = [
          (icon: Icons.dashboard_rounded, label: 'Dashboard'),
          (icon: Icons.summarize_rounded, label: 'Summaries'),
        ];
        final item = items[index];
        final color = isActive ? Colors.white : Colors.white54;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      },
      activeIndex: activeIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      backgroundColor: AppColors.secondaryDark,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      height: 64,
      onTap: (index) {
        final tab = CMNavTab.values[index];
        ref.read(cmNavController.notifier).select(tab);
        if (index == 0) RouteHelper.push(Routes.cmDashboard);
        if (index == 1) RouteHelper.push(Routes.cmSummaries);
      },
    );
  }
}

/// The FAB used as the center Pending Approvals button.
/// Use with [FloatingActionButtonLocation.centerDocked].
class CMPendingApprovalsFAB extends StatelessWidget {
  const CMPendingApprovalsFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.secondaryDark;
    return FloatingActionButton(
      backgroundColor: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      onPressed: () => RouteHelper.push(Routes.cmApprovalDesk),
      child: const Icon(Icons.pending_actions, color: Colors.white, size: 28),
    );
  }
}
