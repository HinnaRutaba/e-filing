import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 1234567 -> "1,234,567"
String formatCount(num n) => n.round().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// Chart colors taken from the app theme so the dashboard reads as part of the
/// app. Assigned by entity, never by rank, so the same thing is the same color
/// everywhere: blue = done / archived / disposed, amber = pending,
/// green = forwarded / sent, navy = secondary series.
class SecretaryVizColors {
  const SecretaryVizColors._({
    required this.blue,
    required this.amber,
    required this.green,
    required this.navy,
    required this.sky,
    required this.teal,
  });

  final Color blue;
  final Color amber;
  final Color green;
  final Color navy;

  /// Lighter tint of the theme blue, and a blue-green midway between the
  /// theme's blue and green: extra in-theme hues for charts with many slices.
  final Color sky;
  final Color teal;

  factory SecretaryVizColors.of(BuildContext context) {
    final colors = context.appColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SecretaryVizColors._(
      sky: Color.lerp(colors.secondaryLight, Colors.white, 0.5)!,
      teal: Color.lerp(colors.secondaryLight, colors.success, 0.5)!,
      blue: colors.secondaryLight,
      amber: colors.warning,
      green: colors.success,
      // The theme's deep navy disappears on dark cards, so lift it there.
      navy: dark
          ? Color.lerp(colors.secondaryLight, Colors.white, 0.45)!
          : colors.secondaryDark,
    );
  }
}

/// Number that counts up from 0 on first build and tweens between values on
/// refresh.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  });

  final num value;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('${formatCount(v)}$suffix', style: style),
    );
  }
}

/// Horizontal bar that grows from the left to [fraction] of its width.
class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 8,
  });

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = context.appColors.border.withValues(alpha: 0.35);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Stack(
          children: [
            Container(height: height, color: track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(height: height, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card shell used by every section: gradient icon chip, title, optional
/// trailing widget, and a staggered entrance.
class SecretaryPanel extends StatelessWidget {
  const SecretaryPanel({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.headerBottomGap = 12,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  /// Space between the header row and [child].
  final double headerBottomGap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, headerBottomGap),
                child: Row(
                  children: [
                    SecretaryIconChip(icon: icon, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
              child,
            ],
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 450.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Rounded gradient square with a white icon: the leading mark of every
/// section header.
class SecretaryIconChip extends StatelessWidget {
  const SecretaryIconChip({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }
}

class SecretaryEmptyState extends StatelessWidget {
  const SecretaryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Center(
        child: Text(
          'No data available.',
          style: TextStyle(
            fontSize: 13,
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
