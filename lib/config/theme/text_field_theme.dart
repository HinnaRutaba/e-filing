import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextFieldTheme {
  AppTextFieldTheme._();

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.secondaryLight,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.secondaryLight.withOpacity(0.5),
      ),
    ),
    labelStyle: const TextStyle(
      color: AppColors.textPrimary,
    ),
    hintStyle: const TextStyle(
      color: AppColors.secondaryDark,
      fontSize: 12,
    ),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 8,
    ),
    prefixIconColor: AppColors.secondaryDark,
    suffixIconColor: AppColors.primaryLight,
  );

  static InputDecorationTheme inputDecorationThemeDark = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.background,
      ),
    ),
    labelStyle: const TextStyle(
      color: AppColors.background,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.accent,
      ),
    ),
    filled: true,
    fillColor: AppColors.white,
    prefixIconColor: AppColors.primary,
    suffixIconColor: AppColors.secondary,
  );
}
