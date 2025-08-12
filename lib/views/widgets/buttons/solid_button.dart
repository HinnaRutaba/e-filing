import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppSolidButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final double? fontSize;
  const AppSolidButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 180,
    this.height,
    this.padding,
    this.backgroundColor = AppColors.primary,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: backgroundColor,
          side: BorderSide(color: backgroundColor),
          elevation: 3,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
