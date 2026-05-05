import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/cm_app/cm_bottom_nav_bar.dart';
import 'package:efiling_balochistan/views/screens/summaries/summaries_list_screen.dart';
import 'package:flutter/material.dart';

class CMSummariesListScreen extends StatelessWidget {
  const CMSummariesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,

          floatingActionButton: CMPendingApprovalsFAB(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          extendBody: true,
          bottomNavigationBar: CMBottomNavBar(),
          body: Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: SummariesListScreen(),
          ),
        ),
      ),
    );
  }
}
