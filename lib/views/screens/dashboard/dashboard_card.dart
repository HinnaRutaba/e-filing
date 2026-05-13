import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool loading;
  final bool showSmallCard;
  final IconData icon;
  const DashboardCard({
    super.key,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    required this.icon,
    this.loading = false,
    this.showSmallCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return RepaintBoundary(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildCard(context),
              if (onTap != null)
                Positioned(
                  top: showSmallCard ? -8 : 6,
                  right: showSmallCard
                      ? value == null
                            ? -8
                            : 12
                      : 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child:
                        InkWell(
                          onTap: onTap,
                          child: Container(
                            padding: showSmallCard
                                ? const EdgeInsets.all(4)
                                : const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                            decoration: BoxDecoration(
                              color: appColors.accent.withValues(alpha: 0.38),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: appColors.accent,
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: iconColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: showSmallCard
                                ? Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: appColors.secondaryDark,
                                  )
                                : AppText.titleSmall(
                                    "Open",
                                    fontWeight: FontWeight.w700,
                                    color: appColors.secondaryDark,
                                    fontSize: 10,
                                  ),
                          ),
                        ).animate().shimmer(
                          duration: 1600.ms,
                          delay: 1200.ms,
                          colors: [
                            appColors.accent.withValues(alpha: 0.0),
                            appColors.accent.withValues(alpha: 0.9),
                            appColors.accent.withValues(alpha: 0.0),
                          ],
                        ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 420.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.18,
          end: 0,
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double faceHigh = isDark ? 0.88 : 0.82;
    final double faceMid = isDark ? 0.25 : 0.35;

    return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.55),
                offset: const Offset(0, 6),
                blurRadius: 18,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: cardColor.withValues(alpha: 0.22),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withValues(alpha: faceMid),
                        cardColor.withValues(alpha: faceHigh),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circle accent top-right
                      Positioned(
                        top: -18,
                        right: -18,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      // Thin gloss line at top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        child: showSmallCard
                            ? cardSmall(context)
                            : cardBody(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        // Periodic diagonal shimmer sweep every ~4 s
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          delay: 2800.ms,
          duration: 1200.ms,
          angle: 0.25,
          color: Colors.white.withValues(alpha: 0.18),
        );
  }

  Widget _buildIconBadge() {
    return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.45),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor),
        )
        // Gentle breathing pulse on the icon badge
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.1,
          duration: 1700.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.1,
          end: 1.0,
          duration: 1700.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget cardBody(BuildContext context) {
    final appColors = context.appColors;
    final onCardText = Colors.grey[900];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBadge(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyLarge(
                title,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onCardText,
              ),
              const SizedBox(height: 2),
              loading && (value == null || value!.isEmpty || value == '0')
                  ? Row(
                      children: [
                        SpinKitThreeBounce(color: appColors.accent, size: 14),
                      ],
                    )
                  : AppText.headlineMedium(
                      value ?? '',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: onCardText,
                    ).animate().scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      delay: 180.ms,
                      curve: Curves.elasticOut,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget cardSmall(BuildContext context) {
    final onCardText = Colors.grey[900];
    return Padding(
      padding: value == null
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconBadge(),
          if (value != null) ...[
            const SizedBox(height: 4),
            AppText.headlineMedium(
              value!,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: onCardText,
            ).animate().scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
              duration: 500.ms,
              delay: 180.ms,
              curve: Curves.elasticOut,
            ),
          ],
        ],
      ),
    );
  }
}
