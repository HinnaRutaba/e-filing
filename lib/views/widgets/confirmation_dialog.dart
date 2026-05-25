import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool destructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.help_outline_rounded,
    this.iconColor = AppColors.secondaryDark,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        confirmColor ??
        (destructive ? AppColors.error : AppColors.secondaryDark);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [iconColor.withAlpha(40), iconColor.withAlpha(15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 20),
            AppText.headlineSmall(title, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            AppText.bodyMedium(
              message,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    text: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSolidButton(
                    text: confirmText,
                    onPressed: () => Navigator.of(context).pop(true),
                    backgroundColor: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.easeOutBack,
    );
  }
}
