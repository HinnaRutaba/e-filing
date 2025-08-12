import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData lightChipTheme = const ChipThemeData(
    disabledColor: AppColors.disabled,
    labelStyle: TextStyle(color: Colors.black),
    selectedColor: AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: null, // You need to provide the color for checkmark
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: AppColors.disabled,
    labelStyle: TextStyle(color: Colors.white),
    selectedColor: AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: null, // You need to provide the color for checkmark
  );
}
