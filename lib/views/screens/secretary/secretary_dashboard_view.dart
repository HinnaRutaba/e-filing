import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/secretary_dashboard_controller.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_charts.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_lists.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/dashboard_search.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_summary_card.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/masonry_layout.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretaryDashboardView extends ConsumerStatefulWidget {
  const SecretaryDashboardView({super.key});

  @override
  ConsumerState<SecretaryDashboardView> createState() =>
      _SecretaryDashboardViewState();
}

class _SecretaryDashboardViewState extends ConsumerState<SecretaryDashboardView>
    with AutomaticKeepAliveClientMixin {
  static const double _maxContentWidth = 1200;
  static const double _tabletBreakpoint = 600;
  static const double _twoColumnBreakpoint = 600;
  static const double _threeColumnBreakpoint = 1000;

  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // The query outlives the screen (the provider isn't auto-disposed), so
    // show it again in the field.
    _searchController.text = ref.read(secretaryDashboardController).query;
    Future.microtask(
      () => ref.read(secretaryDashboardController.notifier).initData(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) =>
      ref.read(secretaryDashboardController.notifier).setQuery(value);

  void _clearSearch() {
    _searchController.clear();
    ref.read(secretaryDashboardController.notifier).clearQuery();
  }

  Future<void> _refresh() =>
      ref.read(secretaryDashboardController.notifier).initData();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(secretaryDashboardController);

    return GestureDetector(
      onTap: () {
        HelperUtils.hideKeyboard(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final gutter = width >= _tabletBreakpoint ? 16.0 : 10.0;

          return Column(
            children: [
              // Outside the scroll view so it stays put while the list moves.
              if (state.data != null) _buildSearch(gutter),
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
                          padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 32),
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

  Widget _buildSearch(double gutter) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 7),
          child: DashboardSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
        ),
      ),
    );
  }

  // --- body ------------------------------------------------------------------

  Widget _buildBody(SecretaryDashboardState state, double width) {
    final data = state.data;
    final twoColumns = width >= _twoColumnBreakpoint;
    final listColumns = width >= _threeColumnBreakpoint
        ? 3
        : (twoColumns ? 2 : 1);

    if (data == null) {
      if (state.error != null) {
        return _ErrorView(message: state.error!, onRetry: _refresh);
      }
      return _buildSkeletons(twoColumns);
    }

    final viz = SecretaryVizColors.of(context);
    final files = data.departmentFiles;
    final daak = data.departmentDaak;
    final charts = data.charts;

    // Searching: the department-wide cards (overviews) can't be
    // narrowed to a user or section, so they are hidden; the user and section
    // cards keep only the matching rows and disappear when nothing matches.
    final filter = state.filter;
    final searching = filter != null;

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
      title: 'E-files overview',
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
      title: 'E-Daak overview',
      delay: 350.ms,
      onOpen: () => RouteHelper.push(Routes.daak),
      children: [
        SecretaryDonutWithLegend(
          centerLabel: 'Received',
          centerValue: received,
          blobs: true,
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
    final sections = filter?.sections ?? data.sectionStats;
    final chartPanels = [
      if (!searching || filter.sections.any((e) => (e.total ?? 0) > 0))
        SecretarySectionsPanel(sections: sections, delay: 150.ms),
    ];

    // 4. Top lists.
    final putup = filter?.topFilePutup ?? charts?.topFilePutup ?? const [];
    final pending = filter?.topPending ?? charts?.topPending ?? const [];
    final topForwarded =
        filter?.topForwarded ?? charts?.topForwarded ?? const [];
    final lists = [
      if (!searching || putup.isNotEmpty)
        SecretaryTopUsersPanel(
          key: const ValueKey('putup'),
          title: 'Top E-file Put-up',
          subtitle: 'Files created by user',
          icon: Icons.upload_file_rounded,
          color: viz.navy,
          items: putup,
        ),
      if (!searching || pending.isNotEmpty)
        SecretaryTopUsersPanel(
          key: const ValueKey('pending'),
          title: 'Top Pending',
          subtitle: 'Most files waiting',
          icon: Icons.hourglass_bottom_rounded,
          color: viz.amber,
          items: pending,
        ),
      if (!searching || topForwarded.isNotEmpty)
        SecretaryTopUsersPanel(
          key: const ValueKey('forwarded'),
          title: 'Top Forwarded',
          subtitle: 'Most files forwarded',
          icon: Icons.forward_to_inbox_rounded,
          color: viz.green,
          items: topForwarded,
        ),
    ];

    final footer = _DashboardFooter(
      activeUsers: data.activeUsers,
      generatedAt: DateTimeHelper.parseDate(data.generatedAt)?.toLocal(),
    );

    if (searching && chartPanels.isEmpty && lists.isEmpty) {
      return Column(
        children: [
          SecretarySearchEmptyState(
            query: state.query.trim(),
            onClear: _clearSearch,
          ),
          footer,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searching)
          SecretarySearchSummary(
            users: filter.userCount,
            sections: filter.sections.where((e) => (e.total ?? 0) > 0).length,
          ),
        if (searching) const SizedBox(height: 16),
        MasonryLayout(
          columns: listColumns,
          children: [
            if (!searching) ...[filesSection, daakSection],
            ...chartPanels,
            ...lists,
          ],
        ),
        footer,
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

/// Active user count and when the numbers were generated, under the panels.
class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter({this.activeUsers, this.generatedAt});

  final int? activeUsers;
  final DateTime? generatedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = TextStyle(fontSize: 12, color: colors.textSecondary);

    Widget item(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: style)),
      ],
    );

    final users = activeUsers;
    final generated = generatedAt;
    if (users == null && generated == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 6,
          children: [
            if (users != null)
              item(
                Icons.people_alt_outlined,
                '$users active ${users == 1 ? 'user' : 'users'}',
              ),
            if (generated != null)
              item(
                Icons.schedule_rounded,
                'Generated ${DateTimeHelper.dateFormatddMMYYWithTime(generated)}',
              ),
          ],
        ),
      ),
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
