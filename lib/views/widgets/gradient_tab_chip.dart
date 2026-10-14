import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GradientTabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  final bool expand;

  const GradientTabChip({
    super.key,
    required this.label,
    this.icon,
    this.count,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              _buildContent(context, filled: false),
              if (selected)
                _buildContent(context, filled: true).animate().custom(
                  duration: 200.ms,
                  curve: Curves.easeInOutSine,
                  builder: (context, value, child) => ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) {
                      const softness = 0.4;
                      final t = value * (1 + softness);
                      final s1 = (t - softness).clamp(0.0, 0.999);
                      final s2 = t.clamp(s1 + 0.001, 1.0);
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [s1, s2],
                        colors: const [Colors.white, Colors.transparent],
                      ).createShader(rect);
                    },
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool filled}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appColors = context.appColors;
    final idleBg = isDark ? appColors.cardColorLight : AppColors.cardColorLight;
    final idleBorder = isDark ? appColors.border : Colors.grey.shade300;
    final idleText = isDark ? appColors.textPrimary : Colors.black87;
    final idleIcon = isDark ? appColors.textSecondary : Colors.black54;
    final container = Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? null : idleBg,
        gradient: filled
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.75),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled ? Colors.transparent : idleBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: expand
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: filled ? Colors.white : idleIcon, size: 18),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: AppText.bodySmall(
              label,
              color: filled ? Colors.white : idleText,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: count == 0
                    ? (filled ? Colors.white24 : idleBorder)
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: count == 0 && !filled ? idleIcon : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return container;
  }
}
