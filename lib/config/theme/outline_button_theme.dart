import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppOutlineButtonTheme {
  AppOutlineButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      textStyle: const TextStyle(
          fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      side: const BorderSide(color: AppColors.primary),
      textStyle: const TextStyle(
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardColor, width: 1.5),
      ),
    ),
  );
}
