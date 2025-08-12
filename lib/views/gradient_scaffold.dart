import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.3),
                  AppColors.secondaryLight.withOpacity(0.3),
                  AppColors.accent.withOpacity(0.3),
                  AppColors.appBarColor,
                  AppColors.white,
                  AppColors.white,
                  Colors.transparent,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          BlurryContainer.expand(
            blur: 190,
            elevation: 0,
            color: Colors.white38,
            padding: const EdgeInsets.all(0),
            child: child,
          ),
        ],
      ),
    );
  }
}
