import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CMDashboardScreen extends StatelessWidget {
  const CMDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const headerHeight = 208.0;

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: headerHeight,
              collapsedHeight: kToolbarHeight,
              backgroundColor: AppColors.secondaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text("CM Dashboard"),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
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
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              AppColors.secondaryDark,
                              AppColors.secondaryLight.withValues(alpha: 0.7),
                              AppColors.accent.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
