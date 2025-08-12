import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Toast {
  static void show(
      {required String message,
      Color color = AppColors.secondary,
      Widget? detail}) {
    toastification.show(
      title: AppText.titleLarge(
        message,
        color: AppColors.white,
      ),
      description: detail,
      direction: TextDirection.ltr,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.info_outline, color: AppColors.white),
      autoCloseDuration: const Duration(seconds: 5),
      backgroundColor: color.withOpacity(0.9),
      borderSide: BorderSide(color: color),
      showProgressBar: false,
      style: ToastificationStyle.flatColored,
    );
  }

  static void success({String? message}) {
    toastification.show(
      title: AppText.titleLarge(
        message ?? 'Operation Successful!',
        color: AppColors.white,
        maxLines: 3,
      ),
      direction: TextDirection.ltr,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(16),
      icon: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 4,
        child: const Icon(
          Icons.check_circle_outline,
          color: AppColors.white,
        ),
      ),
      autoCloseDuration: const Duration(seconds: 5),
      backgroundColor: AppColors.primary,
      borderSide: const BorderSide(color: Colors.green),
      showProgressBar: false,
      style: ToastificationStyle.flatColored,
    );
  }

  static void error({String? message}) {
    toastification.show(
      title: AppText.titleLarge(
        message ?? 'Whoops! Something went wrong.',
        color: AppColors.white,
        maxLines: 5,
      ),
      direction: TextDirection.ltr,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(16),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.white,
      ),
      autoCloseDuration: const Duration(seconds: 5),
      backgroundColor: AppColors.error.withOpacity(0.9),
      borderSide: const BorderSide(color: AppColors.error),
      showProgressBar: false,
      style: ToastificationStyle.flatColored,
    );
  }
}
