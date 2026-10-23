import 'dart:math' as math;

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/secretary_dashboard_controller.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The secretary's six KPI cards. Shown once above the dashboard tabs so the
/// numbers stay the same whichever tab is open. [compact] collapses them into
/// a single row of icon + value cards.
class SecretaryKpiCards extends ConsumerWidget {
  const SecretaryKpiCards({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(secretaryDashboardController);
    final kpis = state.data?.myKpis;
    final loading = state.loading;
    final viz = SecretaryVizColors.of(context);

    // Each card gets its own hue so the row is easy to tell apart at a glance.
    // The icon is a deeper shade of the card's own tint so it reads on the
    // white badge.
    DashboardCard card({
      required String title,
      required int? value,
      required Color color,
      required IconData icon,
      String? route,
    }) {
      final tint = kpiTint(context, color);
      return DashboardCard(
        cardColor: tint,
        iconColor: Color.lerp(tint, Colors.black, 0.5)!,
        title: title,
        value: '${value ?? 0}',
        onTap: route == null ? null : () => RouteHelper.push(route),
        loading: loading,
        icon: icon,
        showSmallCard: compact,
        stacked: true,
        fill: true,
      );
    }

    final cards = [
      card(
        title: 'Action Required',
        value: kpis?.actionRequired,
        color: Theme.of(context).colorScheme.error,
        icon: Icons.info_outline,
        route: Routes.actionRequiredFiles,
      ),
      card(
        title: 'Pending E-files',
        value: kpis?.pending,
        color: viz.amber,
        icon: Icons.timelapse,
        route: Routes.pendingFiles,
      ),
      card(
        title: 'E-files Sent',
        value: kpis?.filesSent,
        color: viz.blue,
        icon: Icons.send_rounded,
        route: Routes.forwarded,
      ),
      card(
        title: 'Processed E-files',
        value: kpis?.processed,
        color: kpiPurple,
        icon: Icons.task_alt_rounded,
        route: Routes.forwarded,
      ),
      card(
        title: 'E-Daak Letters',
        value: kpis?.daakInbox,
        color: viz.green,
        icon: Icons.mark_email_unread_rounded,
        route: Routes.daak,
      ),
      card(
        title: 'Returned E-Daak',
        value: kpis?.daakReturned,
        color: viz.teal,
        icon: Icons.undo_rounded,
        route: Routes.daak,
      ),
    ];

    const gap = 10.0;

    // Collapsed: all six in one row. Falls back to a sideways scroll if the
    // screen is too narrow to fit them.
    if (compact) {
      return LayoutBuilder(
        builder: (context, c) {
          const minWidth = 54.0;
          final fit = (c.maxWidth - gap * (cards.length - 1)) / cards.length;
          final itemWidth = fit < minWidth ? minWidth : fit;
          return SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: fit < minWidth
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: gap),
              itemBuilder: (_, i) =>
                  SizedBox(width: itemWidth, child: cards[i]),
            ),
          );
        },
      );
    }

    // Expanded: two rows of three.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < 2; r++) ...[
          if (r > 0) const SizedBox(height: gap),
          Row(
            children: [
              for (var c = 0; c < 3; c++) ...[
                if (c > 0) const SizedBox(width: gap),
                Expanded(child: cards[r * 3 + c]),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Lays [child] out normally but reports a height [amount] smaller and shifts
/// it up by that much, so the child paints over whatever sits above it. Used
/// to let the KPI cards straddle the header's bottom edge without having to
/// know the header's or the cards' height up front.
class PullUp extends SingleChildRenderObjectWidget {
  const PullUp({super.key, required this.amount, required super.child});

  final double amount;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPullUp(amount);

  @override
  void updateRenderObject(BuildContext context, _RenderPullUp renderObject) {
    renderObject.amount = amount;
  }
}

class _RenderPullUp extends RenderShiftedBox {
  _RenderPullUp(this._amount) : super(null);

  double _amount;

  set amount(double value) {
    if (_amount == value) return;
    _amount = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, math.max(0, child.size.height - _amount)),
    );
    (child.parentData! as BoxParentData).offset = Offset(
      0,
      size.height - child.size.height,
    );
  }

  // The child extends above our bounds, so hit-test it directly instead of
  // bailing out when the touch is outside `size`.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    final offset = (child.parentData! as BoxParentData).offset;
    final hit = result.addWithPaintOffset(
      offset: offset,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
    if (hit) result.add(BoxHitTestEntry(this, position));
    return hit;
  }
}
