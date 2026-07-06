import 'dart:async';

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DashboardCard extends StatefulWidget {
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
  State<DashboardCard> createState() => _DashboardCardState();
}

/// Drives a small parallax shift + sheen sweep from the accelerometer
/// instead of a timer-based loop: the effect only redraws a tiny, cheap
/// subtree (an icon offset and a plain gradient) when the phone actually
/// tilts, rather than repainting shadows/blurs on every frame forever.
class _DashboardCardState extends State<DashboardCard> {
  // Low so a gentle, everyday tilt already reaches the full effect range
  // (a real hard tilt can hit 8-9 m/s^2, but nobody holds their phone that
  // aggressively just looking at a dashboard).
  static const double _maxTiltAccel = 2.2;
  static const double _smoothing = 0.35; // quick to respond, still not jittery
  static const double _notifyEpsilon = 0.005;
  static const double _cardShiftPx = 6.0;
  static const double _iconShiftPx =
      3.0; // subtle — icon sits close to the badge edge

  final ValueNotifier<Offset> _tilt = ValueNotifier<Offset>(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _smoothX = 0;
  double _smoothY = 0;

  @override
  void initState() {
    super.initState();
    _accelSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(_onAccelerometerEvent, onError: (_) {});
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!mounted) return;

    _smoothX += (event.x - _smoothX) * _smoothing;
    _smoothY += (event.y - _smoothY) * _smoothing;

    final dx = (_smoothX / _maxTiltAccel).clamp(-1.0, 1.0);
    final dy = (-_smoothY / _maxTiltAccel).clamp(-1.0, 1.0);
    final next = Offset(dx, dy);

    if ((next - _tilt.value).distance > _notifyEpsilon) {
      _tilt.value = next;
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final content = RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildCard(context),
          if (widget.onTap != null)
            Positioned(
              top: widget.showSmallCard ? -8 : 6,
              right: widget.showSmallCard
                  ? widget.value == null
                        ? -8
                        : 12
                  : 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child:
                    InkWell(
                      onTap: widget.onTap,
                      child: Container(
                        padding: widget.showSmallCard
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
                        child: widget.showSmallCard
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

    // Whole card shifts a few px with device tilt. `content` is passed as
    // the `child` of ValueListenableBuilder so it's built once and reused —
    // a tilt update only ever repositions the already-cached RepaintBoundary
    // layer above, it never rebuilds/repaints the shadows or gradient.
    return ValueListenableBuilder<Offset>(
          valueListenable: _tilt,
          builder: (context, tilt, child) {
            return Transform.translate(
              offset: Offset(tilt.dx * _cardShiftPx, tilt.dy * _cardShiftPx),
              child: child,
            );
          },
          child: content,
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
                        : cardBody(context),
                  ),
                  // Sheen that slides across the card as the phone tilts.
                  // Cheap plain gradient, isolated in its own RepaintBoundary
                  // so tilt updates never touch the shadows/gradient above.
                  _buildTiltSheen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTiltSheen() {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: ValueListenableBuilder<Offset>(
            valueListenable: _tilt,
            builder: (context, tilt, _) {
              // AnimatedContainer smooths the gradient between sensor
              // samples (~15/s) so the sheen glides at 60fps instead of
              // stepping in visible jumps each time a new reading arrives.
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + tilt.dx * 2.2, -1 + tilt.dy * 2.2),
                    end: Alignment(1 + tilt.dx * 2.2, 1 + tilt.dy * 2.2),
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.35, 0.5, 0.65],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    final badge = Container(
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

    // Icon shifts a couple of pixels with device tilt for a subtle
    // parallax feel, instead of a "breathing" loop that never stops.
    return ValueListenableBuilder<Offset>(
      valueListenable: _tilt,
      builder: (context, tilt, child) {
        return Transform.translate(
          offset: Offset(tilt.dx * _iconShiftPx, tilt.dy * _iconShiftPx),
          child: child,
        );
      },
      child: badge,
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
