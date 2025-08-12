import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class CustomAppChip extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? chipColor;
  final Color? borderColor;
  final double minWidth;
  const CustomAppChip({
    super.key,
    required this.label,
    this.onDelete,
    this.onTap,
    this.leadingIcon,
    this.padding,
    this.chipColor,
    this.borderColor,
    this.minWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final labelText = AppText.bodyMedium(
      label,
      color: borderColor ?? theme.primaryColorDark,
      textAlign: TextAlign.center,
    );
    return IconTheme(
      data: IconThemeData(color: borderColor ?? theme.primaryColorDark),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Chip(
          label: Container(
            constraints: BoxConstraints(minWidth: minWidth),
            child: leadingIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      leadingIcon!,
                      const SizedBox(width: 4),
                      labelText,
                    ],
                  )
                : labelText,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
              color: borderColor ?? theme.primaryColorDark,
            ),
          ),
          color: WidgetStateColor.resolveWith(
            (states) => chipColor ?? AppColors.white,
          ),
          deleteIcon: const Icon(Icons.close),
          onDeleted: onDelete,
          padding: padding,
        ),
      ),
    );
  }
}
