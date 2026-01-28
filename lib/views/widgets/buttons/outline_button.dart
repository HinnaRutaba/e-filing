import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppOutlineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? backgroundColor;

  final IconData? icon;
  const AppOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: padding == null && color == null && backgroundColor == null
            ? null
            : OutlinedButton.styleFrom(
                backgroundColor: backgroundColor,
                padding: padding,
                side: BorderSide(
                  color: color ?? AppColors.secondaryLight,
                  width: 1.5,
                ),
              ),
        icon: icon != null
            ? Icon(
                icon,
                color: color,
              )
            : null,
        label: Text(
          text,
          style: TextStyle(
            color: color ?? AppColors.primaryDark,
            //fontSize: textSize ?? 14,
          ),
        ),
      ),
    );
  }
}
