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

  static const fontFamily = 'Mako';

  // Dark-mode surface palette (scoped to the theme so AppColors stays untouched).
  static const Color _darkBackground = Color(0xFF0F1216);
  static const Color _darkSurface = Color(0xFF161A20);
  static const Color _darkCard = Color(0xFF1E232A);
  static const Color _darkBorder = Color(0xFF2A303A);
  static const Color _darkTextPrimary = Color(0xFFE5E7EB);
  static const Color _darkTextSecondary = Color(0xFF9CA3AF);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.accent,
      onSecondary: AppColors.accent,
      onSurface: AppColors.textPrimary,
      onError: AppColors.accent,
      inversePrimary: AppColors.accent,
    ),
    primaryColorDark: AppColors.primaryDark,
    cardColor: AppColors.cardColor,
    dividerColor: AppColors.secondaryLight,
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
    scaffoldBackgroundColor: _darkBackground,
    canvasColor: _darkBackground,
    dialogTheme: const DialogThemeData(backgroundColor: _darkSurface),
    cardColor: _darkCard,
    dividerColor: _darkBorder,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondaryLight,
      surface: _darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _darkTextPrimary,
      onError: Colors.white,
      outline: _darkBorder,
    ),
    primaryColorDark: AppColors.primaryDark,
    textTheme: AppTextTheme.darkTextTheme.apply(
      bodyColor: _darkTextPrimary,
      displayColor: _darkTextPrimary,
    ),
    iconTheme: const IconThemeData(color: _darkTextPrimary),
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme: AppTextButtonTheme.darkTextButtonTheme,
    appBarTheme: AppAppBarTheme.darkAppBarTheme.copyWith(
      backgroundColor: _darkBackground,
      foregroundColor: _darkTextPrimary,
      iconTheme: const IconThemeData(color: _darkTextPrimary, size: 24),
      actionsIconTheme:
          const IconThemeData(color: _darkTextPrimary, size: 24),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
      ),
      toolbarTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
      ),
    ),
    checkboxTheme: AppCheckBoxTheme.darkCheckboxTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    inputDecorationTheme:
        AppTextFieldTheme.inputDecorationThemeDark.copyWith(
      filled: true,
      fillColor: _darkSurface,
      hintStyle: const TextStyle(color: _darkTextSecondary),
      labelStyle: const TextStyle(color: _darkTextSecondary),
    ),
    bottomNavigationBarTheme:
        BottomNavBarTheme.darkNavbarTheme.copyWith(
      backgroundColor: _darkBackground,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: _darkSurface,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _darkTextSecondary,
      textColor: _darkTextPrimary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}
