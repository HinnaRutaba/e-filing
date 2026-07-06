import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: isDark
                    ? [
                        appColors.secondaryDark,
                        colorScheme.secondary.withValues(alpha: 0.6),
                        appColors.secondaryDark.withValues(alpha: 0.6),
                        colorScheme.surface,
                        colorScheme.surface,
                        Colors.transparent,
                      ]
                    : [
                        colorScheme.secondary.withValues(alpha: 0.3),
                        appColors.secondaryLight.withValues(alpha: 0.3),
                        appColors.accent.withValues(alpha: 0.3),
                        appColors.surfaceMuted,
                        colorScheme.surface,
                        colorScheme.surface,
                        Colors.transparent,
                      ],
              ),
            ),
          ),
          BlurryContainer.expand(
            blur: 190,
            elevation: 0,
            color: isDark
                ? colorScheme.surface.withValues(alpha: 0.25)
                : appColors.accent.withValues(alpha: 0.38),
            padding: const EdgeInsets.all(0),
            child: child,
          ),
        ],
      ),
    );
  }
}
