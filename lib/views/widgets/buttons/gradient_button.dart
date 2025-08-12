import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 180,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.all(Radius.circular(50)),
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
