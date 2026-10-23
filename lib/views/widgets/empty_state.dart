import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? title;

  /// When null, the refresh button is not shown.
  final VoidCallback? onRefresh;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBadge(icon: icon),
              const SizedBox(height: 8),
              if (title != null) ...[
                AppText.titleLarge(
                  title!,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              AppText.bodyMedium(
                message,
                height: 1.5,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: 24),
                AppSolidButton(
                  onPressed: onRefresh,
                  text: 'Refresh',
                  backgroundColor: AppColors.secondaryLight,
                  icon: Icons.refresh_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon on a gradient disc, wrapped in two soft halo rings.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryLight.withValues(alpha: 0.10),
      ),
      child: Container(
        width: 104,
        height: 104,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondaryLight.withValues(alpha: 0.18),
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.secondaryLight, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLight.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 36, color: AppColors.white),
        ),
      ),
    );
  }
}
