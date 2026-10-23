import 'dart:math' as math;

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// One labelled number in [SecretaryStatColumns]. A null [color] uses the
/// primary text color.
class SecretarySummaryStat {
  const SecretarySummaryStat(this.label, this.value, {this.color});

  final String label;
  final int value;
  final Color? color;
}

/// One filled part of a [SecretarySegmentedBar].
class SecretaryBarSegment {
  const SecretaryBarSegment(this.value, this.color);

  final int value;
  final Color color;
}

/// "Overview" card shell: icon + title with an optional round open button, a divider,
/// then whatever [children] the section needs (stats, bar, chart, status).
class SecretarySummaryCard extends StatelessWidget {
  const SecretarySummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
    this.onOpen,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;
  final VoidCallback? onOpen;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
            children: [
              Row(
                children: [
                  SecretaryIconChip(icon: icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (onOpen != null) _OpenButton(onTap: onOpen!),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: colors.border.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 14),
              ...children,
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

/// Icon + one line of text, e.g. "53% of files disposed".
class SecretaryStatusLine extends StatelessWidget {
  const SecretaryStatusLine({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.border.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Stats in equal columns: all in one row when each gets at least
/// [_minColumnWidth], otherwise wrapped three to a row.
class SecretaryStatColumns extends StatelessWidget {
  const SecretaryStatColumns({super.key, required this.stats});

  final List<SecretarySummaryStat> stats;

  static const double _minColumnWidth = 64;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = stats.length;
        final cols = c.maxWidth / n >= _minColumnWidth ? n : math.min(3, n);
        final rows = (n / cols).ceil();

        return Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cols; i++)
                    Expanded(
                      child: r * cols + i < n
                          ? _StatColumn(stat: stats[r * cols + i])
                                .animate(delay: ((r * cols + i) * 80 + 200).ms)
                                .fadeIn(duration: 350.ms)
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});

  final SecretarySummaryStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedCount(
            value: stat.value,
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: stat.color ?? colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded bar whose segments grow from the left, with a 2px gap between them.
///
/// With a [total] the segments fill only their share of it and the rest stays
/// empty track; without one they fill the whole bar in proportion to each
/// other. Every non-zero segment gets at least [_minShare] of the bar so a tiny
/// value is still visible next to a huge one.
class SecretarySegmentedBar extends StatelessWidget {
  const SecretarySegmentedBar({super.key, required this.segments, this.total});

  final List<SecretaryBarSegment> segments;
  final int? total;

  static const double _height = 10;
  static const double _gap = 2;
  static const double _minShare = 0.04;

  @override
  Widget build(BuildContext context) {
    final track = context.appColors.border.withValues(alpha: 0.5);
    final drawn = segments.where((s) => s.value > 0).toList();
    final sum = drawn.fold<int>(0, (a, b) => a + b.value);
    final filled = total == null
        ? 1.0
        : (total! <= 0 ? 0.0 : (sum / total!).clamp(0.0, 1.0));

    // Proportional shares with a floor, renormalised to 1.
    final raw = [for (final s in drawn) math.max(s.value / sum, _minShare)];
    final rawSum = raw.fold<double>(0, (a, b) => a + b);
    final shares = [for (final r in raw) r / rawSum];

    return ClipRRect(
      borderRadius: BorderRadius.circular(_height),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            if (drawn.isNotEmpty)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, _) {
                        final gaps = _gap * (drawn.length - 1);
                        final usable = math.max(
                          0.0,
                          c.maxWidth * filled * t - gaps,
                        );
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < drawn.length; i++) ...[
                                if (i > 0) const SizedBox(width: _gap),
                                SizedBox(
                                  width: usable * shares[i],
                                  height: _height,
                                  child: ColoredBox(color: drawn[i].color),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
