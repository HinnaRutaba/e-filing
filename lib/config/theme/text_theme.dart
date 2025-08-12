import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: AppColors.black),
    headlineMedium: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.black),
    headlineSmall: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.black),
    titleLarge: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.black),
    titleMedium: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w500, color: AppColors.black),
    titleSmall: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w400, color: AppColors.black),
    bodyLarge: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.w500, color: AppColors.black),
    bodyMedium: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: AppColors.black),
    bodySmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(0, 0, 0, 0.5)),
    labelLarge: TextStyle(
        fontSize: 12.0, fontWeight: FontWeight.normal, color: AppColors.black),
    labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Color.fromRGBO(0, 0, 0, 0.5)),
  );

  static TextTheme darkTextTheme = const TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: AppColors.white),
    headlineMedium: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.white),
    headlineSmall: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.white),
    titleLarge: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.white),
    titleMedium: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w500, color: AppColors.white),
    titleSmall: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w400, color: AppColors.white),
    bodyLarge: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.w500, color: AppColors.white),
    bodyMedium: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: AppColors.white),
    bodySmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(255, 255, 255, 0.5)),
    labelLarge: TextStyle(
        fontSize: 12.0, fontWeight: FontWeight.normal, color: AppColors.white),
    labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: Color.fromRGBO(255, 255, 255, 0.5)),
  );
}
