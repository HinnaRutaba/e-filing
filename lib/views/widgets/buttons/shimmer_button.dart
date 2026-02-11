import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AppShimmerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final List<Color> gradientColors;
  final double? fontSize;
  final IconData? icon;

  const AppShimmerButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 180,
    this.height,
    this.padding,
    this.gradientColors = const [Colors.deepPurple, AppColors.secondary],
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(seconds: 3),
      color: Colors.white,
      colorOpacity: 0.2,
      enabled: false, // Disable continuous shimmer to prevent GPU spam
      direction: const ShimmerDirection.fromLTRB(),
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            elevation: 3,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ).copyWith(
            side: WidgetStateProperty.all(BorderSide.none),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              alignment: Alignment.center,
              // padding: padding ??
              //     const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppColors.white,
                      size: fontSize != null ? fontSize! + 3 : 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 20,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
