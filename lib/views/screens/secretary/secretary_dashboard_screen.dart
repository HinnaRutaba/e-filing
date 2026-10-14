import 'dart:math' as math;

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/secretary_dashboard_controller.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_header_actions.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_charts.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_lists.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_summary_card.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecretaryDashboardScreen extends ConsumerStatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  ConsumerState<SecretaryDashboardScreen> createState() =>
      _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState
    extends ConsumerState<SecretaryDashboardScreen> {
  static const double _maxContentWidth = 1200;
  static const double _tabletBreakpoint = 600;
  static const double _twoColumnBreakpoint = 800;
  static const double _threeColumnBreakpoint = 1000;

  /// Space between the user row and the top of the KPI cards.
  static const double _headerCardsGap = 18;

  /// True once the user scrolls down: the KPI cards shrink to a one-row strip
  /// and the header drops its secondary lines. Resets at the top.
  final ValueNotifier<bool> _compact = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(secretaryDashboardController.notifier).initData(),
    );
  }

  @override
  void dispose() {
    _compact.dispose();
    super.dispose();
  }

  Future<void> _refresh() =>
      ref.read(secretaryDashboardController.notifier).initData();

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels <= 0 && _compact.value) {
      _compact.value = false;
      return false;
    }
    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.reverse &&
        !_compact.value) {
      _compact.value = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(secretaryDashboardController);
    // Must be read here: inside BaseScreen's body, MediaQuery's top padding
    // already includes the app bar, which would count that space twice.
    final topInset = MediaQuery.of(context).padding.top;

    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        showUserDetails: false,
        isdash: true,
        enableBackButton: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final gutter = width >= _tabletBreakpoint ? 16.0 : 10.0;

            return NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _compact,
                    builder: (context, compact, _) =>
                        _buildTop(context, state, gutter, topInset, compact),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _maxContentWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                16,
                                gutter,
                                32,
                              ),
                              child: _buildBody(state, width),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- header + KPIs ---------------------------------------------------------

  Widget _buildTop(
    BuildContext context,
    SecretaryDashboardState state,
    double gutter,
    double topInset,
    bool compact,
  ) {
    const duration = Duration(milliseconds: 320);
    const curve = Curves.easeOutCubic;
    // How far the KPI cards reach up into the header.
    // The header's bottom edge cuts through the middle of the first card row,
    // so this is about half a card's height (~86px expanded, ~68px collapsed).
    final overlap = compact ? 34.0 : 44.0;

    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, state, gutter, topInset, compact, overlap),
          _PullUp(
            amount: overlap,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: curve,
                    switchOutCurve: curve,
                    child: KeyedSubtree(
                      key: ValueKey(compact),
                      child: _buildKpis(context, state, compact),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SecretaryDashboardState state,
    double gutter,
    double topInset,
    bool compact,
    double overlap,
  ) {
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              AssetsConstants.dashboardBG,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.secondaryDark,
                    colors.secondaryLight.withValues(alpha: 0.75),
                    colors.accent.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Padding(
                // Clears the app bar (menu / logout) that BaseScreen draws over
                // the top of this screen, same offsets as the main dashboard.
                // The bottom padding is the strip the KPI cards sit over.
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  topInset + (context.isMobile ? 54 : 28),
                  gutter,
                  overlap + _headerCardsGap,
                ),
                child: _buildUserRow(context, state, compact),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(
    BuildContext context,
    SecretaryDashboardState state,
    bool compact,
  ) {
    final colors = context.appColors;
    final ctx = state.data?.context;
    final designation = ctx?.designation ?? '';

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colors.accent.withValues(alpha: 0.25),
          radius: 20,
          child: Icon(Icons.person, color: colors.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctx?.userTitle ?? '---',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colors.accent,
                ),
              ),
              if (designation.isNotEmpty && !compact)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    designation,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: colors.accent.withValues(alpha: 0.9),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const DashboardHeaderActions(),
      ],
    );
  }

  Widget _buildKpis(
    BuildContext context,
    SecretaryDashboardState state,
    bool compact,
  ) {
    final kpis = state.data?.myKpis;
    final loading = state.loading;

    DashboardCard card({
      required String title,
      required int? value,
      required Color cardColor,
      required Color iconColor,
      required IconData icon,
      String? route,
    }) {
      return DashboardCard(
        cardColor: cardColor,
        iconColor: iconColor,
        title: title,
        value: '${value ?? 0}',
        onTap: route == null ? null : () => RouteHelper.push(route),
        loading: loading,
        icon: icon,
        showSmallCard: compact,
        stacked: true,
      );
    }

    // One soft tint of the app's own blue for every card, so the row reads as
    // a set and sits quietly on the header instead of competing with it.
    final colors = context.appColors;
    final cardColor = Color.lerp(colors.secondaryLight, Colors.white, 0.6)!;
    // Same card tint for the whole row, but each icon gets its own accent for
    // a splash of color, all drawn from the theme-based chart palette.
    final viz = SecretaryVizColors.of(context);

    final cards = [
      card(
        title: 'Action Required',
        value: kpis?.actionRequired,
        cardColor: cardColor,
        iconColor: Theme.of(context).colorScheme.error,
        icon: Icons.info_outline,
        route: Routes.actionRequiredFiles,
      ),
      card(
        title: 'Pending Files',
        value: kpis?.pending,
        cardColor: cardColor,
        iconColor: viz.amber,
        icon: Icons.timelapse,
        route: Routes.pendingFiles,
      ),
      card(
        title: 'Files Sent',
        value: kpis?.filesSent,
        cardColor: cardColor,
        iconColor: viz.blue,
        icon: Icons.send_rounded,
        route: Routes.forwarded,
      ),
      card(
        title: 'Processed Files',
        value: kpis?.processed,
        cardColor: cardColor,
        iconColor: viz.navy,
        icon: Icons.task_alt_rounded,
        route: Routes.forwarded,
      ),
      card(
        title: 'Daak Letters',
        value: kpis?.daakInbox,
        cardColor: cardColor,
        iconColor: viz.green,
        icon: Icons.mark_email_unread_rounded,
        route: Routes.daak,
      ),
      card(
        title: 'Returned Daak',
        value: kpis?.daakReturned,
        cardColor: cardColor,
        iconColor: Color.lerp(viz.blue, viz.green, 0.5)!,
        icon: Icons.undo_rounded,
        route: Routes.daak,
      ),
    ];

    const gap = 10.0;

    // Collapsed: all six as icon + value cards in one row. Falls back to a
    // sideways scroll if the screen is too narrow to fit them.
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

  // --- body ------------------------------------------------------------------

  Widget _buildBody(SecretaryDashboardState state, double width) {
    final data = state.data;
    final twoColumns = width >= _twoColumnBreakpoint;
    final threeColumns = width >= _threeColumnBreakpoint;

    if (data == null) {
      if (state.error != null) {
        return _ErrorView(message: state.error!, onRetry: _refresh);
      }
      return _buildSkeletons(twoColumns);
    }

    final viz = SecretaryVizColors.of(context);
    final kpis = data.myKpis;
    final files = data.departmentFiles;
    final daak = data.departmentDaak;
    final charts = data.charts;

    // 2. Files and Daak overview cards.
    final colors = context.appColors;

    final created = files?.totalCreated ?? 0;
    final disposed = files?.totalDisposed ?? 0;
    final filesPending = files?.totalPending ?? 0;
    final forwarded = files?.totalForwarded ?? 0;
    final disposedPct = created == 0 ? 0 : (disposed / created * 100).round();
    final filesSection = SecretarySummaryCard(
      icon: Icons.folder_open_rounded,
      iconColor: viz.blue,
      title: 'Files overview',
      delay: 250.ms,
      onOpen: () => RouteHelper.push(Routes.pendingFiles),
      children: [
        SecretaryStatColumns(
          stats: [
            SecretarySummaryStat('Created', created),
            SecretarySummaryStat('Pending', filesPending, color: viz.amber),
            SecretarySummaryStat('Disposed', disposed, color: viz.blue),
            SecretarySummaryStat('Forwarded', forwarded, color: viz.green),
          ],
        ),
        const SizedBox(height: 16),
        // Every stat except Created, which is just pending + disposed.
        SecretarySegmentedBar(
          segments: [
            SecretaryBarSegment(filesPending, viz.amber),
            SecretaryBarSegment(disposed, viz.blue),
            SecretaryBarSegment(forwarded, viz.green),
          ],
        ),
        const SizedBox(height: 10),
        SecretaryStatusLine(
          icon: disposedPct >= 50
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_top_rounded,
          text: created == 0
              ? 'No files created yet'
              : '$disposedPct% of files disposed',
          color: disposedPct >= 50 ? colors.success : colors.warning,
        ),
      ],
    );

    final received = daak?.totalReceived ?? 0;
    final daakPending = daak?.totalPending ?? 0;
    final daakSection = SecretarySummaryCard(
      icon: Icons.mail_outline_rounded,
      iconColor: viz.teal,
      title: 'Daak overview',
      delay: 350.ms,
      onOpen: () => RouteHelper.push(Routes.daak),
      children: [
        SecretaryDonutWithLegend(
          centerLabel: 'Received',
          centerValue: received,
          // Pending keeps the theme's warning color (amber) as everywhere else;
          // the rest come from the theme's blue-to-green family.
          slices: [
            SecretaryDonutSlice('Pending', daakPending, viz.amber),
            SecretaryDonutSlice(
              'Forwarded',
              daak?.totalForwarded ?? 0,
              viz.green,
            ),
            SecretaryDonutSlice(
              'Converted',
              daak?.totalConverted ?? 0,
              viz.navy,
            ),
            SecretaryDonutSlice('NFA', daak?.totalNfa ?? 0, viz.sky),
            SecretaryDonutSlice('Disposed', daak?.totalDisposed ?? 0, viz.teal),
          ],
        ),
        const SizedBox(height: 14),
        SecretaryStatusLine(
          icon: daakPending == 0
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_top_rounded,
          text: received == 0
              ? 'No daak received yet'
              : daakPending == 0
              ? 'No daak pending'
              : '$daakPending of $received daak pending',
          color: daakPending == 0 ? colors.success : colors.warning,
        ),
      ],
    );

    // 3. Charts, one after the other.
    final chartPanels = [
      SecretaryWorkloadPanel(kpis: kpis, delay: 150.ms),
      SecretarySectionsPanel(sections: data.sectionStats, delay: 150.ms),
    ];

    // 4. Top lists.
    final lists = [
      SecretaryTopUsersPanel(
        title: 'Top File Put-up',
        subtitle: 'Files created by user',
        icon: Icons.upload_file_rounded,
        color: viz.navy,
        items: charts?.topFilePutup ?? const [],
      ),
      SecretaryTopUsersPanel(
        title: 'Top Pending',
        subtitle: 'Most files waiting',
        icon: Icons.hourglass_bottom_rounded,
        color: viz.amber,
        items: charts?.topPending ?? const [],
      ),
      SecretaryTopUsersPanel(
        title: 'Top Forwarded',
        subtitle: 'Most files forwarded',
        icon: Icons.forward_to_inbox_rounded,
        color: viz.green,
        items: charts?.topForwarded ?? const [],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sideBySide([filesSection, daakSection], twoColumns),
        const SizedBox(height: 16),
        _spaced(chartPanels),
        const _GroupTitle('Top Performers'),
        _sideBySide(lists, threeColumns),
      ],
    );
  }

  /// Equal-width columns when [sideBySide], otherwise stacked.
  Widget _sideBySide(List<Widget> children, bool sideBySide) {
    if (!sideBySide) return _spaced(children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _spaced(List<Widget> children) => Column(
    children: [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1) const SizedBox(height: 16),
      ],
    ],
  );

  Widget _buildSkeletons(bool twoColumns) {
    return Column(
      children: [
        const _SkeletonCard(height: 190),
        const SizedBox(height: 16),
        _sideBySide(const [
          _SkeletonCard(height: 200),
          _SkeletonCard(height: 200),
        ], twoColumns),
        const SizedBox(height: 16),
        const _SkeletonCard(height: 300),
        const SizedBox(height: 16),
        const _SkeletonCard(height: 300),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: context.appColors.textPrimary,
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
          height: height,
          decoration: BoxDecoration(
            color: colors.border.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1400.ms,
          color: colors.cardColor.withValues(alpha: 0.7),
        );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}

/// Lays [child] out normally but reports a height [amount] smaller and shifts
/// it up by that much, so the child paints over whatever sits above it. Used
/// to let the KPI cards straddle the header's bottom edge without having to
/// know the header's or the cards' height up front.
class _PullUp extends SingleChildRenderObjectWidget {
  const _PullUp({required this.amount, required super.child});

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
