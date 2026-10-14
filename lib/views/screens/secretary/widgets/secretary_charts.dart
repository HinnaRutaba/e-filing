import 'dart:math' as math;

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
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
  });

  final List<SecretaryDonutSlice> slices;

  /// Shown in the centre while nothing is touched, e.g. "Created".
  final String centerLabel;
  final int centerValue;

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

// ---------------------------------------------------------------------------

/// "My workload": a completion ring (archived share of my files) next to a
/// column chart of my sent / received / processed / daak counts.
/// [n] shades of [base], darkest first. In dark mode the dark end stays lighter
/// so every step is still visible against a dark card.
List<Color> _shadesOf(Color base, int n, {required bool dark}) {
  final darkest = Color.lerp(base, Colors.black, dark ? 0.2 : 0.4)!;
  final lightest = Color.lerp(base, Colors.white, dark ? 0.55 : 0.3)!;
  return [
    for (var i = 0; i < n; i++)
      Color.lerp(darkest, lightest, n == 1 ? 0 : i / (n - 1))!,
  ];
}

class SecretaryWorkloadPanel extends StatelessWidget {
  const SecretaryWorkloadPanel({
    super.key,
    required this.kpis,
    this.delay = Duration.zero,
  });

  final SecretaryMyKpisModel? kpis;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final viz = SecretaryVizColors.of(context);
    final myFiles = kpis?.myFiles ?? 0;
    final archived = kpis?.archived ?? 0;
    final fraction = myFiles == 0 ? 0.0 : (archived / myFiles).clamp(0.0, 1.0);

    // Same blue throughout, stepped from dark to light so the bars read apart
    // without introducing another hue.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shades = _shadesOf(viz.blue, 5, dark: dark);
    final bars = <SecretaryBarDatum>[
      SecretaryBarDatum('Sent', kpis?.filesSent ?? 0, color: shades[0]),
      SecretaryBarDatum('Received', kpis?.filesReceived ?? 0, color: shades[1]),
      SecretaryBarDatum('Processed', kpis?.processed ?? 0, color: shades[2]),
      SecretaryBarDatum('Daak In', kpis?.daakInbox ?? 0, color: shades[3]),
      SecretaryBarDatum('Daak Ret.', kpis?.daakReturned ?? 0, color: shades[4]),
    ];

    return SecretaryPanel(
      delay: delay,
      icon: Icons.insights_rounded,
      color: viz.navy,
      title: 'My Workload',
      subtitle: 'Personal activity',
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 520;
          final ring = _CompletionRing(
            fraction: fraction,
            color: viz.blue,
            caption: '$archived of $myFiles files archived',
          );
          final chart = SizedBox(
            height: 190,
            child: SecretaryColumnChart(data: bars, color: viz.blue),
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 150, child: ring),
                      const SizedBox(width: 16),
                      Expanded(child: chart),
                    ],
                  )
                : Column(children: [ring, const SizedBox(height: 16), chart]),
          );
        },
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

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({
    required this.fraction,
    required this.color,
    required this.caption,
  });

  final double fraction;
  final Color color;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 124,
          height: 124,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction),
            duration: const Duration(milliseconds: 1300),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CustomPaint(
              painter: _RingPainter(
                progress: v,
                color: color,
                track: colors.border.withValues(alpha: 0.4),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(v * 100).round()}%',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'archived',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  static const double _stroke = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(_stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, base..color = track);
    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      base
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [color.withValues(alpha: 0.6), color],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
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
