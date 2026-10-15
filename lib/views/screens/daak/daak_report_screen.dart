import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/daak_report_controller.dart';
import 'package:efiling_balochistan/models/daak/daak_report_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_charts.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/dashboard_search.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_summary_card.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:efiling_balochistan/views/widgets/chips/custom_app_chip.dart';
import 'package:efiling_balochistan/views/widgets/chips/selection_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The standalone report page (drawer entry). The same report also lives in a
/// tab of the secretary's dashboard as [DaakReportView].
class DaakReportScreen extends StatelessWidget {
  const DaakReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        title: 'Daak Reports',
        isdash: false,
        body: DaakReportView(),
      ),
    );
  }
}

/// The report itself, without a scaffold.
class DaakReportView extends ConsumerStatefulWidget {
  const DaakReportView({super.key});

  @override
  ConsumerState<DaakReportView> createState() => _DaakReportViewState();
}

class _DaakReportViewState extends ConsumerState<DaakReportView>
    with AutomaticKeepAliveClientMixin {
  static const double _maxContentWidth = 1200;
  static const double _twoColumnBreakpoint = 800;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(daakReportController.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _refresh() => ref.read(daakReportController.notifier).load();

  final GlobalKey _calendarKey = GlobalKey();

  /// Opens the date range as a popup menu under the calendar button.
  Future<void> _pickCustomRange() async {
    final state = ref.read(daakReportController);
    final button =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final anchor = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      button.size.width,
      button.size.height,
    );
    final range = await showMenu<DateTimeRange>(
      context: context,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      constraints: const BoxConstraints.tightFor(width: 300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<DateTimeRange>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _DateRangeMenu(from: state.from, to: state.to),
        ),
      ],
    );
    if (range == null || !mounted) return;
    ref
        .read(daakReportController.notifier)
        .setCustomRange(range.start, range.end);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(daakReportController);

    return GestureDetector(
      onTap: () {
        HelperUtils.hideKeyboard(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final gutter = width >= 600 ? 16.0 : 10.0;

          return Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardSearchBar(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _query = v),
                                onClear: _clearSearch,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              key: _calendarKey,
                              tooltip: 'Pick date range',
                              onPressed: _pickCustomRange,
                              isSelected:
                                  state.period == DaakReportPeriod.custom,
                              icon: const Icon(Icons.calendar_month_rounded),
                              selectedIcon: const Icon(
                                Icons.calendar_month_rounded,
                              ),
                              style: state.period == DaakReportPeriod.custom
                                  ? IconButton.styleFrom(
                                      backgroundColor: context
                                          .appColors
                                          .secondaryLight
                                          .withValues(alpha: 0.3),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _PeriodFilter(
                          state: state,
                          onSelect: (period) => ref
                              .read(daakReportController.notifier)
                              .setPeriod(period),
                          onCustomTap: _pickCustomRange,
                          onClear: () => ref
                              .read(daakReportController.notifier)
                              .clearCustomRange(),
                        ),
                        // From the response, so it always describes the data
                        // on screen, even while a new period is loading.
                        if (state.data?.period != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                            child: Text(
                              'Showing results for '
                              '${_resultsText(state.data!.period!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.loading && state.data != null)
                const LinearProgressIndicator(minHeight: 2),
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
                          padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
                          child: _buildBody(state, width),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(DaakReportState state, double width) {
    final data = state.data;
    final twoColumns = width >= _twoColumnBreakpoint;

    if (data == null) {
      if (state.error != null) {
        return _ErrorView(message: state.error!, onRetry: _refresh);
      }
      return Column(
        children: [
          const _SkeletonCard(height: 150),
          const SizedBox(height: 16),
          _sideBySide(const [
            _SkeletonCard(height: 260),
            _SkeletonCard(height: 260),
          ], twoColumns),
        ],
      );
    }

    final viz = SecretaryVizColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    final summary = data.summary;

    // Searching narrows the user and department lists. The overview panels
    // (summary, status, ageing, trend) are department-wide, so they are
    // hidden while a search is active.
    final query = _query.trim().toLowerCase();
    final searching = query.isNotEmpty;
    bool has(String? text) => text?.toLowerCase().contains(query) ?? false;
    final pendingItems = !searching
        ? data.pendingWith
        : data.pendingWith
              .where(
                (p) =>
                    has(p.name) ||
                    has(p.designation) ||
                    has(p.section) ||
                    has(p.department),
              )
              .toList();
    final receivedItems = !searching
        ? data.receivedFromDepartments
        : data.receivedFromDepartments.where((d) => has(d.department)).toList();
    final sentItems = !searching
        ? data.sentToDepartments
        : data.sentToDepartments.where((d) => has(d.department)).toList();
    final sourceItems = !searching
        ? data.sourceDepartmentStats
        : data.sourceDepartmentStats
              .where((d) => has(d.sourceDepartment))
              .toList();

    // Same colors as the dashboard's KPI row: each tile gets its own bright tint.
    final summaryTiles = _StatTiles(
      loading: state.loading,
      stats: [
        _Stat(
          'In progress',
          Icons.timelapse_rounded,
          summary?.inProgress,
          viz.amber,
        ),
        _Stat('Returned', Icons.undo_rounded, summary?.returned, viz.blue),
        _Stat(
          'E-file put-up',
          Icons.upload_file_rounded,
          summary?.filePutup,
          kpiPurple,
        ),
        _Stat('NFA', Icons.block_rounded, summary?.nfa, error),
        _Stat(
          'Disposed off',
          Icons.task_alt_rounded,
          summary?.disposedOff,
          viz.teal,
        ),
        _Stat('Closed', Icons.lock_outline_rounded, summary?.closed, viz.green),
      ],
    );

    // Colors are assigned by status, so a status keeps its color whatever the
    // order or the counts.
    final statusColors = <int, Color>{
      1: viz.sky,
      2: viz.blue,
      3: viz.amber,
      4: viz.green,
      5: error,
      6: viz.navy,
      7: viz.teal,
    };

    final statusPanel = SecretaryPanel(
      delay: 100.ms,
      icon: Icons.donut_large_rounded,
      color: viz.blue,
      title: 'By status',
      subtitle: 'Where the daak currently stands',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SecretaryDonutWithLegend(
          centerLabel: 'Total',
          centerValue: summary?.total ?? 0,
          blobs: true,
          slices: [
            for (final c in data.statusCards)
              SecretaryDonutSlice(
                c.label ?? '---',
                c.count ?? 0,
                statusColors[c.status] ?? viz.navy,
              ),
          ],
        ),
      ),
    );

    final ageingPanel = SecretaryPanel(
      delay: 150.ms,
      icon: Icons.hourglass_bottom_rounded,
      color: viz.amber,
      title: 'Ageing',
      subtitle: 'How long open daak has been waiting',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: data.ageing.every((a) => (a.count ?? 0) == 0)
            ? const SecretaryEmptyState()
            : SizedBox(
                height: 190,
                child: SecretaryColumnChart(
                  color: viz.amber,
                  tintedTrack: true,
                  data: [
                    for (final a in data.ageing)
                      SecretaryBarDatum(a.label ?? '---', a.count ?? 0),
                  ],
                ),
              ),
      ),
    );

    final trendPanel = SecretaryPanel(
      delay: 200.ms,
      icon: Icons.show_chart_rounded,
      color: viz.navy,
      title: 'Monthly trend',
      subtitle: 'Received and still open',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _TrendList(items: data.monthlyTrend, viz: viz),
      ),
    );

    final pendingPanel = SecretaryPanel(
      delay: 250.ms,
      icon: Icons.person_search_rounded,
      color: viz.amber,
      title: 'Pending with',
      subtitle: 'Who is holding open daak',
      child: _PendingWithList(items: pendingItems),
    );

    final receivedPanel = SecretaryPanel(
      delay: 300.ms,
      icon: Icons.move_to_inbox_rounded,
      color: viz.blue,
      title: 'Received from departments',
      child: _DepartmentFlowList(items: receivedItems, color: viz.blue),
    );

    final sentPanel = SecretaryPanel(
      delay: 350.ms,
      icon: Icons.outbox_rounded,
      color: viz.green,
      title: 'Sent to departments',
      child: _DepartmentFlowList(items: sentItems, color: viz.green),
    );

    final sourcePanel = SecretaryPanel(
      delay: 400.ms,
      icon: Icons.apartment_rounded,
      color: viz.teal,
      title: 'Source departments',
      subtitle: 'Where the daak came from',
      child: _SourceDepartmentList(
        items: sourceItems,
        viz: viz,
        errorColor: error,
      ),
    );

    if (searching) {
      final panels = [
        if (pendingItems.isNotEmpty) pendingPanel,
        if (receivedItems.isNotEmpty) receivedPanel,
        if (sentItems.isNotEmpty) sentPanel,
        if (sourceItems.isNotEmpty) sourcePanel,
      ];
      if (panels.isEmpty) {
        return _NoResults(query: _query.trim(), onClear: _clearSearch);
      }
      return Column(
        children: [_sideBySide(panels, twoColumns), _buildFooter(data)],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A failed refresh keeps the last data on screen; say so.
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              state.error!,
              style: TextStyle(color: error, fontSize: 12),
            ),
          ),
        summaryTiles,

        const SizedBox(height: 8),
        _sideBySide([statusPanel, ageingPanel], twoColumns),
        const SizedBox(height: 16),
        _sideBySide([trendPanel, pendingPanel], twoColumns),
        const SizedBox(height: 16),
        _sideBySide([receivedPanel, sentPanel], twoColumns),
        const SizedBox(height: 16),
        sourcePanel,
        _buildFooter(data),
      ],
    );
  }

  /// "Generated on 14/10/2026 01:09 PM", in the device's time zone.
  Widget _buildFooter(DaakReportModel data) {
    final generated = DateTime.tryParse(data.generatedAt ?? '')?.toLocal();
    if (generated == null) return const SizedBox.shrink();
    final color = context.appColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.update_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Generated on ${DateTimeHelper.dateFormatSlashWithTime(generated)}',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  /// What the server actually applied, e.g. "the last 30 days (from
  /// 15 Sep 2026)" or "15 Sep 2026 – 30 Sep 2026".
  String _resultsText(DaakReportPeriodInfo period) {
    final from = DateTime.tryParse(period.from ?? '');
    final to = DateTime.tryParse(period.to ?? '');
    String fmt(DateTime? d) => DateTimeHelper.dateDMYFormat(d);
    final range = from == null && to == null
        ? null
        : to == null
        ? 'from ${fmt(from)}'
        : from == null
        ? 'up to ${fmt(to)}'
        : '${fmt(from)} – ${fmt(to)}';

    final key = DaakReportPeriod.fromValue(period.key);
    final name = switch (key) {
      DaakReportPeriod.today => 'today',
      DaakReportPeriod.last7Days => 'the last 7 days',
      DaakReportPeriod.last30Days => 'the last 30 days',
      DaakReportPeriod.month => 'this month',
      DaakReportPeriod.year => 'this year',
      DaakReportPeriod.all => 'all time',
      DaakReportPeriod.custom => range ?? 'a custom range',
    };
    return key == DaakReportPeriod.custom || range == null
        ? name
        : '$name ($range)';
  }

  /// Equal-width columns when [sideBySide], otherwise stacked.
  Widget _sideBySide(List<Widget> children, bool sideBySide) {
    if (!sideBySide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }
    // Rows of two; a lone last panel keeps half the width.
    return Column(
      children: [
        for (var r = 0; r < children.length; r += 2) ...[
          if (r > 0) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[r]),
              const SizedBox(width: 16),
              Expanded(
                child: r + 1 < children.length
                    ? children[r + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Rounded period chips (the app's [SelectionChips]). A custom range, picked
/// with the calendar button, shows first as a selected chip with a cross that
/// clears it.
class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({
    required this.state,
    required this.onSelect,
    required this.onCustomTap,
    required this.onClear,
  });

  final DaakReportState state;
  final ValueChanged<DaakReportPeriod> onSelect;
  final VoidCallback onCustomTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final custom =
        state.period == DaakReportPeriod.custom &&
        state.from != null &&
        state.to != null;
    final menu = [
      for (final period in DaakReportPeriod.values)
        if (period != DaakReportPeriod.custom)
          SelectionChipMenuItem<DaakReportPeriod>(
            label: period.label,
            value: period,
          ),
    ];

    return SelectionChips<DaakReportPeriod>(
      singleLineScroll: true,
      compact: true,
      minMenuItemWidth: 0,
      chipColor: colors.secondaryDark,
      leading: custom
          ? CustomAppChip(
              compact: true,
              minWidth: 0,
              padding: EdgeInsets.zero,
              label:
                  '${DateTimeHelper.dateDMYFormat(state.from)} – '
                  '${DateTimeHelper.dateDMYFormat(state.to)}',
              leadingIcon: const Icon(Icons.date_range_rounded, size: 13),
              chipColor: colors.secondaryDark,
              borderColor: Colors.white,
              onTap: onCustomTap,
              onDelete: onClear,
            )
          : null,
      menu: menu,
      // No preset is selected while a custom range is active.
      initialSelected: menu.indexWhere((m) => m.value == state.period),
      onSelected: (_, period) {
        // SelectionChips also reports the initial selection.
        if (period == state.period) return;
        onSelect(period);
      },
    );
  }
}

/// Shown when a search matches nothing.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No users or departments match "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onClear, child: const Text('Clear search')),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.icon, this.value, this.color);

  final String label;
  final IconData icon;
  final int? value;
  final Color color;
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.stats, required this.loading});

  final List<_Stat> stats;
  final bool loading;

  static const double _gap = 8;

  static const double _tileHeight = 91;

  @override
  Widget build(BuildContext context) {
    // 3 per row on phones, one row of all of them otherwise.
    final columns = context.isMobile ? 3 : stats.length;
    // Capped so wide screens keep small tiles, left-aligned.
    return Align(
      alignment: Alignment.centerLeft,
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: _gap,
          mainAxisSpacing: _gap,
          mainAxisExtent: _tileHeight,
        ),
        itemBuilder: (context, i) {
          final s = stats[i];
          final tint = kpiTint(context, s.color);
          return DashboardCard(
            cardColor: tint,
            iconColor: Color.lerp(tint, Colors.black, 0.5)!,
            icon: s.icon,
            title: s.label,
            value: '${s.value ?? 0}',
            loading: loading,
            showSmallCard: false,
            stacked: true,
            onTap: null,
          );
        },
      ),
    );
  }
}

/// One row per month: received vs. still-open bars.
class _TrendList extends StatelessWidget {
  const _TrendList({required this.items, required this.viz});

  final List<DaakReportMonthlyTrend> items;
  final SecretaryVizColors viz;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SecretaryEmptyState();
    final colors = context.appColors;
    final max = items.fold<int>(
      1,
      (m, e) =>
          [m, e.received ?? 0, e.open ?? 0].reduce((a, b) => a > b ? a : b),
    );

    Widget bar(String label, int? value, Color color) => Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ),
        Expanded(
          child: AnimatedBar(fraction: (value ?? 0) / max, color: color),
        ),
        SizedBox(
          width: 36,
          child: Text(
            formatCount(value ?? 0),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        for (final m in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.label ?? m.month ?? '---',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                bar('Received', m.received, viz.blue),
                const SizedBox(height: 4),
                bar('Open', m.open, viz.amber),
              ],
            ),
          ),
      ],
    );
  }
}

class _PendingWithList extends StatelessWidget {
  const _PendingWithList({required this.items});

  final List<DaakReportPendingWith> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SecretaryEmptyState();
    final colors = context.appColors;
    final viz = SecretaryVizColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          for (final p in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name ?? '---',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          [
                            p.designation,
                            p.section,
                          ].where((e) => e != null && e.isNotEmpty).join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        if (p.oldest != null)
                          Text(
                            'Oldest: ${DateTimeHelper.timeAgo(p.oldest)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CountBadge(count: p.count ?? 0, color: viz.amber),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DepartmentFlowList extends StatelessWidget {
  const _DepartmentFlowList({required this.items, required this.color});

  final List<DaakReportDepartmentFlow> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SecretaryEmptyState();
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          for (final d in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.department ?? '---',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${d.open ?? 0} open',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CountBadge(count: d.total ?? 0, color: color),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceDepartmentList extends StatelessWidget {
  const _SourceDepartmentList({
    required this.items,
    required this.viz,
    required this.errorColor,
  });

  final List<DaakReportSourceDepartment> items;
  final SecretaryVizColors viz;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SecretaryEmptyState();
    final colors = context.appColors;

    Widget legend(String label, int? value, Color color) => Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label ${value ?? 0}',
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          for (final s in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.sourceDepartment ?? '---',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CountBadge(count: s.total ?? 0, color: viz.teal),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SecretarySegmentedBar(
                    segments: [
                      SecretaryBarSegment(s.inProgress ?? 0, viz.amber),
                      SecretaryBarSegment(s.filePutup ?? 0, viz.navy),
                      SecretaryBarSegment(s.nfa ?? 0, errorColor),
                      SecretaryBarSegment(s.disposedOff ?? 0, viz.teal),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    children: [
                      legend('In progress', s.inProgress, viz.amber),
                      legend('File put-up', s.filePutup, viz.navy),
                      legend('NFA', s.nfa, errorColor),
                      legend('Disposed', s.disposedOff, viz.teal),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        formatCount(count),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: context.appColors.textPrimary,
        ),
      ),
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

/// Content of the date range popup menu: From / To tabs over one inline
/// calendar, so nothing opens on top of the menu. To can't be before From, and
/// neither can be in the future. Pops a [DateTimeRange] on Apply.
class _DateRangeMenu extends StatefulWidget {
  const _DateRangeMenu({this.from, this.to});

  final DateTime? from;
  final DateTime? to;

  @override
  State<_DateRangeMenu> createState() => _DateRangeMenuState();
}

class _DateRangeMenuState extends State<_DateRangeMenu> {
  static final DateTime _today = DateUtils.dateOnly(DateTime.now());
  static final DateTime _earliest = DateTime(2020);

  late DateTime? _from = widget.from;
  late DateTime? _to = widget.to;
  bool _editingFrom = true;

  DateTime get _firstDate => _editingFrom ? _earliest : (_from ?? _earliest);
  DateTime get _lastDate => _editingFrom ? (_to ?? _today) : _today;

  DateTime get _initialDate {
    final value = _editingFrom ? _from : _to;
    final date = value ?? _today;
    if (date.isBefore(_firstDate)) return _firstDate;
    if (date.isAfter(_lastDate)) return _lastDate;
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ready = _from != null && _to != null;

    Widget tab(String label, DateTime? value, bool from) {
      final selected = _editingFrom == from;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _editingFrom = from),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selected
                  ? colors.secondaryLight.withValues(alpha: 0.25)
                  : null,
              border: Border.all(
                color: selected ? colors.secondaryDark : colors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
                Text(
                  value == null
                      ? 'Select'
                      : DateTimeHelper.dateDMYFormat(value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: value == null
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                tab('From', _from, true),
                const SizedBox(width: 8),
                tab('To', _to, false),
              ],
            ),
            CalendarDatePicker(
              key: ValueKey(_editingFrom),
              initialDate: _initialDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              onDateChanged: (date) => setState(() {
                if (_editingFrom) {
                  _from = date;
                  // Move on to the other end once From is chosen.
                  _editingFrom = false;
                } else {
                  _to = date;
                }
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: ready
                      ? () => Navigator.pop(
                          context,
                          DateTimeRange(start: _from!, end: _to!),
                        )
                      : null,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
