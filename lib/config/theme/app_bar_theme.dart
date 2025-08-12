import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppAppBarTheme {
  AppAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    toolbarTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black),
    backgroundColor: AppColors.background,
    iconTheme: IconThemeData(color: Colors.black, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    titleTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    toolbarTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
    backgroundColor: AppColors.background,
    iconTheme: IconThemeData(color: Colors.white, size: 24),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    titleTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
  );
}
