import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final IconData? icon;
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 180,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: AppColors.white),
    );
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        backgroundColor: AppColors.secondary,
        side: const BorderSide(color: AppColors.secondary, width: 0),
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          gradient: LinearGradient(
            colors: [AppColors.secondaryDark, AppColors.secondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: icon == null
            ? title
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: AppColors.white),
                  const SizedBox(width: 8),
                  Flexible(child: title),
                ],
              ),
      ),
    );
  }
}
