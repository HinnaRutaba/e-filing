import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CMDashboardScreen extends ConsumerWidget {
  const CMDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const headerHeight = 208.0;
    final dashboardState = ref.watch(dashboardController);

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: headerHeight,
              collapsedHeight: kToolbarHeight,
              backgroundColor: AppColors.secondaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              title: AppText.headlineSmall("CM Dashboard", color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
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
                                      begin: 100,
                                      end: 0,
                                      builder: (context, value, child) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              value * 30,
                                            ),
                                            bottomLeft: Radius.circular(
                                              value * 30,
                                            ),
                                            topRight: Radius.circular(
                                              value * 30,
                                            ),
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
                                height: headerHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryDark.withValues(
                                    alpha: 0.8,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondaryDark,
                                      AppColors.secondaryLight.withValues(
                                        alpha: 0.7,
                                      ),
                                      AppColors.accent.withValues(alpha: 0.2),
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
                    ),
                  ],
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
