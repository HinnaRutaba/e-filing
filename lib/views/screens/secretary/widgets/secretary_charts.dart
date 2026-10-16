import 'dart:math' as math;

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SecretaryDonutSlice {
  const SecretaryDonutSlice(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

/// Donut chart with its legend: sweeps in on build, a touched slice (or its
/// legend row) is pulled out and its value shown in the centre. Used for both
/// the Files status chart and the Daak overview so they look and behave alike.
class SecretaryDonutWithLegend extends StatefulWidget {
  const SecretaryDonutWithLegend({
    super.key,
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
    this.blobs = false,
  });

  final List<SecretaryDonutSlice> slices;

  /// Shown in the centre while nothing is touched, e.g. "Created".
  final String centerLabel;
  final int centerValue;

  /// Draw the ring as separate rounded blobs with the share written on each,
  /// instead of a plain donut.
  final bool blobs;

  @override
  State<SecretaryDonutWithLegend> createState() =>
      _SecretaryDonutWithLegendState();
}

class _SecretaryDonutWithLegendState extends State<SecretaryDonutWithLegend> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final slices = widget.slices;
    final sum = slices.fold<int>(0, (a, b) => a + b.value);
    if (sum == 0) return const SecretaryEmptyState();

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 380;
        final donut = SizedBox(
          width: 190,
          height: 190,
          child: _buildDonut(context, slices),
        );
        final legend = Column(
          children: [
            for (var i = 0; i < slices.length; i++)
              _LegendRow(
                    slice: slices[i],
                    total: sum,
                    highlighted: _touched == i,
                    onTap: slices[i].value == 0
                        ? null
                        : () =>
                              setState(() => _touched = _touched == i ? -1 : i),
                  )
                  .animate(delay: (300 + i * 100).ms)
                  .fadeIn()
                  .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          ],
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  donut,
                  const SizedBox(width: 20),
                  Expanded(child: legend),
                ],
              )
            : Column(children: [donut, const SizedBox(height: 12), legend]);
      },
    );
  }

  static const double _ringSize = 190;

  /// Rounded-blob ring. A tap picks the slice under the finger (tap it again,
  /// or the middle, to clear), same as touching the plain donut.
  Widget _blobRing(List<SecretaryDonutSlice> slices, double t) {
    final total = slices.fold<int>(0, (a, b) => a + b.value);
    return GestureDetector(
      onTapDown: (details) {
        if (total == 0) return;
        const center = Offset(_ringSize / 2, _ringSize / 2);
        final d = details.localPosition - center;
        final radius = d.distance;
        const ringRadius = (_ringSize - _BlobRingPainter.thickness) / 2;
        var next = -1;
        if ((radius - ringRadius).abs() <= _BlobRingPainter.thickness / 2 + 6) {
          // Angle from 12 o'clock, clockwise.
          var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
          if (angle < 0) angle += 2 * math.pi;
          final shares = _BlobRingPainter.shares(slices, total);
          var start = 0.0;
          for (var i = 0; i < slices.length; i++) {
            final sweep = shares[i] * 2 * math.pi;
            if (slices[i].value > 0 &&
                angle >= start &&
                angle < start + sweep) {
              next = i;
              break;
            }
            start += sweep;
          }
        }
        setState(() => _touched = next == _touched ? -1 : next);
      },
      child: CustomPaint(
        size: const Size(_ringSize, _ringSize),
        painter: _BlobRingPainter(
          slices: slices,
          total: total,
          progress: t,
          selected: _touched,
          track: context.appColors.border.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _buildDonut(BuildContext context, List<SecretaryDonutSlice> slices) {
    final colors = context.appColors;
    final touched = _touched >= 0 && _touched < slices.length
        ? slices[_touched]
        : null;
    // fl_chart reports touches by section index, so zero-value slices (which
    // are not drawn) must be mapped back to their legend position.
    final drawn = [
      for (var i = 0; i < slices.length; i++)
        if (slices[i].value > 0) i,
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.blobs)
              _blobRing(slices, t)
            else
              PieChart(
                duration: const Duration(milliseconds: 250),
                PieChartData(
                  startDegreeOffset: -90 + (1 - t) * 90,
                  sectionsSpace: 2,
                  centerSpaceRadius: 58,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final idx = response?.touchedSection?.touchedSectionIndex;
                      final next =
                          event.isInterestedForInteractions &&
                              idx != null &&
                              idx >= 0 &&
                              idx < drawn.length
                          ? drawn[idx]
                          : -1;
                      if (next != _touched) setState(() => _touched = next);
                    },
                  ),
                  sections: [
                    for (final i in drawn)
                      PieChartSectionData(
                        value: slices[i].value.toDouble(),
                        color: slices[i].color,
                        radius: (i == _touched ? 34.0 : 28.0) * t,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: 200.ms,
                    child: Text(
                      touched?.label ?? widget.centerLabel,
                      key: ValueKey(touched?.label ?? widget.centerLabel),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  touched == null
                      ? AnimatedCount(
                          value: widget.centerValue,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        )
                      : Text(
                          formatCount(touched.value),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Ring of separate rounded blobs, one per slice, with the share written on
/// every blob big enough to hold it (dark or white, whichever reads better). While one is selected the others fade.
class _BlobRingPainter extends CustomPainter {
  _BlobRingPainter({
    required this.slices,
    required this.total,
    required this.progress,
    required this.selected,
    required this.track,
  });

  final List<SecretaryDonutSlice> slices;
  final int total;
  final double progress;
  final int selected;
  final Color track;

  static const double thickness = 32;
  static const double _corner = 9;
  static const double _gap = 5;

  /// Smallest share of the ring a non-empty slice gets, so a tiny slice is
  /// still a visible blob instead of a sliver. The rest scale down to fit.
  static const double _minShare = 0.045;

  /// Each slice's share of the ring (0 for empty ones), summing to 1.
  static List<double> shares(List<SecretaryDonutSlice> slices, int total) {
    if (total <= 0) return List.filled(slices.length, 0);
    final raw = [
      for (final s in slices)
        s.value > 0 ? math.max(s.value / total, _minShare) : 0.0,
    ];
    final sum = raw.fold<double>(0, (a, b) => a + b);
    return [for (final r in raw) r / sum];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rc = (size.shortestSide - thickness) / 2;

    if (total == 0) {
      canvas.drawCircle(
        center,
        rc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..color = track,
      );
      return;
    }

    final fractions = shares(slices, total);
    Offset polar(double r, double a) =>
        center + Offset(math.cos(a) * r, math.sin(a) * r);

    var start = -math.pi / 2;
    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      if (slice.value <= 0) continue;
      final sweepFull = fractions[i] * 2 * math.pi * progress;
      // Visible width of the blob along the ring.
      final width = sweepFull * rc - _gap;
      if (width <= 0) {
        start += sweepFull;
        continue;
      }
      // Each blob is a smaller sector fattened by [corner] with a round-joined
      // stroke, which is what rounds its corners. The corner shrinks for a
      // narrow blob so it never grows past the space it was given.
      final corner = math.min(_corner, width / 2);
      final ri = rc - thickness / 2 + corner;
      final ro = rc + thickness / 2 - corner;
      final color = selected >= 0 && selected != i
          ? slice.color.withValues(alpha: 0.35)
          : slice.color;

      final inset = (_gap / 2 + corner) / rc;
      final a0 = start + inset;
      final a1 = math.max(a0, start + sweepFull - inset);
      final sweep = a1 - a0;

      final path = Path()
        ..moveTo(polar(ro, a0).dx, polar(ro, a0).dy)
        ..arcTo(Rect.fromCircle(center: center, radius: ro), a0, sweep, false)
        ..lineTo(polar(ri, a1).dx, polar(ri, a1).dy)
        ..arcTo(Rect.fromCircle(center: center, radius: ri), a1, -sweep, false)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = corner * 2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

      if (progress > 0.95 && width >= 22) {
        final painter = TextPainter(
          text: TextSpan(
            text: '${(slice.value / total * 100).round()}%',
            style: TextStyle(
              // Dark on the light tints, white on the rest.
              color: slice.color.computeLuminance() > 0.5
                  ? Colors.black87
                  : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final at = polar(rc, start + sweepFull / 2);
        painter.paint(
          canvas,
          at - Offset(painter.width / 2, painter.height / 2),
        );
      }
      start += sweepFull;
    }
  }

  @override
  bool shouldRepaint(_BlobRingPainter old) =>
      old.slices != slices ||
      old.total != total ||
      old.progress != progress ||
      old.selected != selected ||
      old.track != track;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.total,
    required this.highlighted,
    required this.onTap,
  });

  final SecretaryDonutSlice slice;
  final int total;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pct = total == 0 ? 0 : slice.value / total * 100;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlighted
              ? slice.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: slice.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                slice.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            AnimatedCount(
              value: slice.value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 42,
              child: Text(
                '${pct.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecretaryBarDatum {
  const SecretaryBarDatum(this.label, this.value, {this.color});
  final String label;
  final int value;

  /// Overrides the chart's base color, used to emphasise a single bar.
  final Color? color;
}

class SecretaryColumnChart extends StatelessWidget {
  const SecretaryColumnChart({
    super.key,
    required this.data,
    required this.color,
    this.tintedTrack = false,
  });

  final List<SecretaryBarDatum> data;
  final Color color;

  /// Draw the background behind each bar as a faint tint of the bar's own
  /// color instead of the neutral grey.
  final bool tintedTrack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxValue = data.fold<int>(0, (m, e) => math.max(m, e.value));
    final maxY = math.max(maxValue, 1) * 1.15;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => BarChart(
        duration: Duration.zero,
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final d = data[value.toInt()];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatCount(d.value * t),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colors.textPrimary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[group.x];
                return BarTooltipItem(
                  '${d.label}\n${formatCount(d.value)}',
                  TextStyle(
                    color: colors.cardColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value * t,
                    width: 18,
                    color: data[i].color ?? color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: tintedTrack
                          ? (data[i].color ?? color).withValues(alpha: 0.12)
                          : colors.border.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
