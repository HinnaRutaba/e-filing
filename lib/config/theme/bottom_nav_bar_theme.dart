import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBarTheme {
  BottomNavBarTheme._();

  static BottomNavigationBarThemeData lightNavbarTheme =
      const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.secondary,
    unselectedItemColor: AppColors.primary,
    selectedIconTheme: IconThemeData(size: 28),
    unselectedIconTheme: IconThemeData(size: 22),
    enableFeedback: false,
    elevation: 0,
  );

  static BottomNavigationBarThemeData darkNavbarTheme =
      const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.secondary,
    unselectedItemColor: AppColors.cardColor,
    selectedIconTheme: IconThemeData(size: 28),
    unselectedIconTheme: IconThemeData(size: 22),
    enableFeedback: false,
    elevation: 0,
  );
}
