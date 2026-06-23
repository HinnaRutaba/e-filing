import 'package:efiling_balochistan/config/theme/text_theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextFieldTheme {
  AppTextFieldTheme._();

  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.secondaryLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppColors.secondaryLight.withValues(alpha: 0.5),
      ),
    ),
    labelStyle: const TextStyle(color: AppTextTheme.lightTextPrimary),
    hintStyle: const TextStyle(
      color: AppTextTheme.lightTextSecondary,
      fontSize: 12,
    ),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    prefixIconColor: AppColors.secondaryDark,
    suffixIconColor: AppColors.primaryLight,
  );

  static final InputDecorationTheme inputDecorationThemeDark =
      InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.secondaryLight.withValues(alpha: 0.45),
          ),
        ),
        labelStyle: const TextStyle(color: AppTextTheme.darkTextPrimary),
        hintStyle: const TextStyle(
          color: AppTextTheme.darkTextSecondary,
          fontSize: 12,
        ),
        filled: true,
        // fillColor is set by theme.dart to _darkSurface.
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        prefixIconColor: AppColors.secondaryLight,
        suffixIconColor: AppColors.primaryLight,
      );
}
