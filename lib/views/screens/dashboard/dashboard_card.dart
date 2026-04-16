part of 'dashboard_screen.dart';

class DashboardCard extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback onTap;
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
                                  horizontal: 10,
                                  vertical: 4,
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
                                color: cardColor.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: iconColor.withValues(alpha: 0.08),
                                blurRadius: 6,
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
                      )
                      .animate()
                      .shimmer(
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
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    // Frosted-glass gloss is bright in light mode; in dark mode we soften the
    // white overlays so the colored card face stays saturated.
    final double glossHigh = isDark ? 0.12 : 0.22;
    final double glossMid = isDark ? 0.06 : 0.08;
    final double glossTop = isDark ? 0.18 : 0.32;
    // Card-color saturation for the body gradient. Higher = more vivid face.
    final double faceHigh = isDark ? 0.9 : 0.8;
    final double faceMid = isDark ? 0.55 : 0.4;
    final double faceOuter = isDark ? 0.45 : 0.35;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.35),
            offset: const Offset(-4, 4),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              appColors.accent.withValues(alpha: glossHigh),
              appColors.accent.withValues(alpha: glossMid),
              cardColor.withValues(alpha: faceOuter),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.8),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            cardColor.withValues(alpha: faceHigh),
                            cardColor.withValues(alpha: faceMid),
                            appColors.accent.withValues(alpha: glossMid),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            appColors.accent.withValues(alpha: glossTop),
                            appColors.accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: showSmallCard ? cardSmall(context) : cardBody(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardBody(BuildContext context) {
    final appColors = context.appColors;
    final onCardText = Colors.grey[900];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyLarge(
                title,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onCardText,
              ),
              loading && (value == null || value!.isEmpty || value == '0')
                  ? Row(
                      children: [
                        SpinKitThreeBounce(color: appColors.accent, size: 16),
                      ],
                    )
                  : AppText.headlineMedium(
                      value ?? '',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: onCardText,
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
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          if (value != null)
            AppText.headlineMedium(
              value!,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: onCardText,
            ),
        ],
      ),
    );
  }
}
