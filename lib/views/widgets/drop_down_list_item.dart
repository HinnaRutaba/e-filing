import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DropDownListItem extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final EdgeInsets padding;
  const DropDownListItem({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Card(
            color: AppColors.primaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyLarge(label),
              if (subtitle != null) AppText.bodySmall(subtitle!),
            ],
          )
        ],
      ),
    );
  }
}
