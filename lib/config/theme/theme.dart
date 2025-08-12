import 'package:efiling_balochistan/config/theme/app_bar_theme.dart';
import 'package:efiling_balochistan/config/theme/bottom_nav_bar_theme.dart';
import 'package:efiling_balochistan/config/theme/chip_theme.dart';
import 'package:efiling_balochistan/config/theme/elevated_button_theme.dart';
import 'package:efiling_balochistan/config/theme/outline_button_theme.dart';
import 'package:efiling_balochistan/config/theme/text_button_theme.dart';
import 'package:efiling_balochistan/config/theme/text_field_theme.dart';
import 'package:efiling_balochistan/config/theme/text_theme.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'check_box_theme.dart';

class AppTheme {
  AppTheme._();

  static const fontFamily = 'Sura';

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.accent,
      onSecondary: AppColors.secondary,
      onSurface: AppColors.accent,
      onError: AppColors.accent,
      inversePrimary: AppColors.accent,
    ),
    primaryColorDark: AppColors.primaryDark,
    cardColor: AppColors.cardColor,
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme: AppTextButtonTheme.lightTextButtonTheme,
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    checkboxTheme: AppCheckBoxTheme.lightCheckboxTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    inputDecorationTheme: AppTextFieldTheme.inputDecorationTheme,
    bottomNavigationBarTheme: BottomNavBarTheme.lightNavbarTheme,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryDark,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.accent,
      onSecondary: AppColors.secondary,
      onSurface: AppColors.accent,
      onError: AppColors.accent,
      inversePrimary: AppColors.accent,
    ),
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardColor,
    textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme: AppTextButtonTheme.darkTextButtonTheme,
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    checkboxTheme: AppCheckBoxTheme.darkCheckboxTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    inputDecorationTheme: AppTextFieldTheme.inputDecorationThemeDark,
    bottomNavigationBarTheme: BottomNavBarTheme.darkNavbarTheme,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.secondary,
    ),
  );
}
