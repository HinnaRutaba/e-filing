import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/cm_app/cm_approval_desk.dart';
import 'package:efiling_balochistan/views/screens/cm_app/cm_bottom_nav_bar.dart';
import 'package:efiling_balochistan/views/screens/cm_app/cm_dashboard_screen.dart';
import 'package:efiling_balochistan/views/screens/cm_app/cm_summaries_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMShell extends ConsumerWidget {
  const CMShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(cmNavController);
    final isOnDashboard = activeTab == CMNavTab.dashboard;

    return PopScope(
      canPop: isOnDashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(cmNavController.notifier).select(CMNavTab.dashboard);
        }
      },
      child: GradientScaffold(
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            bottomNavigationBar: const CMBottomNavBar(),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: IndexedStack(
                index: activeTab.index,
                children: const [
                  CMDashboardScreen(),
                  CMSummariesListScreen(),
                  CMApprovalDesk(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
