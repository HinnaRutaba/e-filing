import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardCard extends StatefulWidget {
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool loading;
  final bool showSmallCard;

  /// Icon + value on one row with the title underneath. Fits narrow tiles
  /// (e.g. three per row) where the default side-by-side layout is too tight.
  final bool stacked;

  /// Stretch the card to the width it is given instead of shrinking to its
  /// content, so the corner arrow stays on the card's own corner.
  final bool fill;
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
    this.stacked = false,
    this.fill = false,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final content = RepaintBoundary(
      child: Stack(
        fit: widget.fill ? StackFit.passthrough : StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          _buildCard(context),
          if (widget.onTap != null)
            Positioned(
              // Stacked cards keep the small ↗ in the top-right corner in both
              // states; when collapsed it sits half over the card's corner so
              // it never covers the icon badge.
              top: widget.stacked
                  ? (widget.showSmallCard ? -6 : 6)
                  : (widget.showSmallCard ? -8 : 6),
              right: widget.stacked
                  ? (widget.showSmallCard ? -4 : 6)
                  : (widget.showSmallCard
                        ? widget.value == null
                              ? -8
                              : 12
                        : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child:
                    InkWell(
                      onTap: widget.onTap,
                      child: Container(
                        padding: widget.stacked
                            ? const EdgeInsets.all(3)
                            : widget.showSmallCard
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
                              color: widget.iconColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: widget.stacked
                            ? Icon(
                                Icons.north_east_rounded,
                                size: 12,
                                color: appColors.secondaryDark,
                              )
                            : widget.showSmallCard
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
    );

    return content
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
            color: widget.cardColor.withValues(alpha: 0.55),
            offset: const Offset(0, 6),
            blurRadius: 18,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: widget.cardColor.withValues(alpha: 0.22),
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
            onTap: widget.onTap,
            splashColor: Colors.white.withValues(alpha: 0.18),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.cardColor.withValues(alpha: faceMid),
                    widget.cardColor.withValues(alpha: faceHigh),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: widget.showSmallCard ? 6 : 12,
                    ),
                    child: widget.showSmallCard
                        ? cardSmall(context)
                        : widget.stacked
                        ? cardStacked(context)
                        : cardBody(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.iconColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.iconColor.withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(widget.icon, size: 16, color: widget.iconColor),
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
                widget.title,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onCardText,
              ),
              const SizedBox(height: 2),
              widget.loading &&
                      (widget.value == null ||
                          widget.value!.isEmpty ||
                          widget.value == '0')
                  ? Row(
                      children: [
                        SpinKitThreeBounce(color: appColors.accent, size: 14),
                      ],
                    )
                  : AppText.headlineMedium(
                      widget.value ?? '',
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

  Widget cardStacked(BuildContext context) {
    final appColors = context.appColors;
    final onCardText = Colors.grey[900];
    final showSpinner =
        widget.loading &&
        (widget.value == null || widget.value!.isEmpty || widget.value == '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The top 10px leave room for the corner arrow button so it never
        // touches the value.
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildIconBadge(),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: showSpinner
                      ? SpinKitThreeBounce(color: appColors.accent, size: 14)
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppText.headlineMedium(
                            widget.value ?? '',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: onCardText,
                          ),
                        ).animate().scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                          delay: 180.ms,
                          curve: Curves.elasticOut,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AppText.bodyLarge(
          widget.title,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: onCardText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget cardSmall(BuildContext context) {
    final onCardText = Colors.grey[900];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconBadge(),
        if (widget.value != null) ...[
          const SizedBox(height: 4),
          AppText.headlineMedium(
            widget.value!,
            fontSize: 16,
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
    );
  }
}
