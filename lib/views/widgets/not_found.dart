import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final Widget? child;
  const NotFound({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 48,
          color: AppColors.primary.withOpacity(0.6),
        ),
        AppText.bodyLarge(
          "Nothing to show",
          fontSize: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        child ?? const SizedBox.shrink(),
      ],
    );
  }
}
