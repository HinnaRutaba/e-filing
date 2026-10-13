import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/secretary_dashboard_controller.dart';
import 'package:efiling_balochistan/models/secretary_dashboard_model.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:efiling_balochistan/views/screens/dashboard/dashboard_card.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(secretaryDashboardController.notifier).initData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double headerHeight = isMobile ? 180.0 : 164.0;
    final double cardsOverlap = isMobile ? 130.0 : 60.0;
    final double statsCardTop = isMobile ? 144.0 : 132.0;
    final SecretaryDashboardState state = ref.watch(
      secretaryDashboardController,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(secretaryDashboardController.notifier).initData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: headerHeight + cardsOverlap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: _buildHeader(context, headerHeight, state),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      top: statsCardTop,
                      child: _buildKpiCards(context, state),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSections(context, state, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headerHeight,
    SecretaryDashboardState state,
  ) {
    final ctx = state.data?.context;
    final subtitle = [
      ctx?.designation,
      ctx?.department?.title,
    ].whereType<String>().join(' • ');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: headerHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              AssetsConstants.dashboardBG,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryDark.withValues(alpha: 0.8),
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryDark,
                    AppColors.secondaryLight.withValues(alpha: 0.7),
                    AppColors.accent.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 20),
                            children: [
                              const TextSpan(
                                text: 'Welcome, ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(text: ctx?.userTitle ?? 'Secretary'),
                            ],
                          ),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(8),
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        ref.read(authController.notifier).logout(context),
                    icon: Icon(
                      Icons.power_settings_new,
                      color: Colors.amber[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCards(BuildContext context, SecretaryDashboardState state) {
    Widget animated(Widget child, int index) {
      final delay = (index * 120).ms;
      return child
          .animate()
          .scale(
            delay: delay,
            duration: 400.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
          )
          .fadeIn(delay: delay, duration: 300.ms);
    }

    final kpis = state.data?.myKpis;

    final cards = [
      DashboardCard(
        cardColor: context.appColors.warning,
        iconColor: Colors.yellow[900]!,
        title: 'Action Required',
        value: '${kpis?.actionRequired ?? 0}',
        onTap: null,
        loading: state.loading,
        icon: Icons.pending_actions,
        showSmallCard: false,
      ),
      DashboardCard(
        cardColor: Theme.of(context).colorScheme.error,
        iconColor: Colors.red[900]!,
        title: 'Pending',
        value: '${kpis?.pending ?? 0}',
        onTap: null,
        loading: state.loading,
        icon: Icons.autorenew,
        showSmallCard: false,
      ),
      DashboardCard(
        cardColor: context.appColors.secondaryLight,
        iconColor: context.appColors.secondaryDark,
        title: 'My Files',
        value: '${kpis?.myFiles ?? 0}',
        onTap: null,
        loading: state.loading,
        icon: Icons.folder_copy_outlined,
        showSmallCard: false,
      ),
      DashboardCard(
        cardColor: Colors.green[200]!,
        iconColor: Colors.green[800]!,
        title: 'Archived',
        value: '${kpis?.archived ?? 0}',
        onTap: null,
        loading: state.loading,
        icon: Icons.inventory_2_outlined,
        showSmallCard: false,
      ),
    ];

    if (context.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: animated(cards[0], 0)),
              const SizedBox(width: 12),
              Expanded(child: animated(cards[1], 1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: animated(cards[2], 2)),
              const SizedBox(width: 12),
              Expanded(child: animated(cards[3], 3)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: animated(cards[i], i)),
          if (i != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildSections(
    BuildContext context,
    SecretaryDashboardState state,
    bool isMobile,
  ) {
    if (state.error != null && state.data == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.textSecondary),
          ),
        ),
      );
    }

    final data = state.data;
    final activity = _StatsSection(
      icon: Icons.swap_horiz_rounded,
      iconBgColor: const Color(0xFF3949AB),
      title: 'My Activity',
      badgeLabel: 'Personal',
      badgeColor: const Color(0xFFE8EAF6),
      badgeTextColor: const Color(0xFF3949AB),
      stats: [
        _Stat('Files Sent', data?.myKpis?.filesSent),
        _Stat('Files Received', data?.myKpis?.filesReceived),
        _Stat('Processed', data?.myKpis?.processed),
        _Stat('Daak Inbox', data?.myKpis?.daakInbox),
        _Stat('Daak Returned', data?.myKpis?.daakReturned),
      ],
    );
    final deptFiles = _StatsSection(
      icon: Icons.folder_open_rounded,
      iconBgColor: const Color(0xFF00897B),
      title: 'Department Files',
      badgeLabel: data?.context?.department?.title ?? 'Department',
      badgeColor: const Color(0xFFE0F2F1),
      badgeTextColor: const Color(0xFF00695C),
      stats: [
        _Stat('Created', data?.departmentFiles?.totalCreated),
        _Stat('Pending', data?.departmentFiles?.totalPending),
        _Stat('Disposed', data?.departmentFiles?.totalDisposed),
        _Stat('Forwarded', data?.departmentFiles?.totalForwarded),
      ],
    );
    final deptDaak = _StatsSection(
      icon: Icons.mail_outline_rounded,
      iconBgColor: const Color(0xFFEF6C00),
      title: 'Department Daak',
      badgeLabel: 'Daak',
      badgeColor: const Color(0xFFFFF3E0),
      badgeTextColor: const Color(0xFFE65100),
      stats: [
        _Stat('Received', data?.departmentDaak?.totalReceived),
        _Stat('Pending', data?.departmentDaak?.totalPending),
        _Stat('Forwarded', data?.departmentDaak?.totalForwarded),
        _Stat('Converted', data?.departmentDaak?.totalConverted),
        _Stat('NFA', data?.departmentDaak?.totalNfa),
        _Stat('Disposed', data?.departmentDaak?.totalDisposed),
      ],
    );
    final topPutup = _TopUsersSection(
      icon: Icons.upload_file_rounded,
      color: const Color(0xFF5C35B0),
      title: 'Top File Put-up',
      items: data?.charts?.topFilePutup ?? [],
    );
    final topPending = _TopUsersSection(
      icon: Icons.hourglass_bottom_rounded,
      color: const Color(0xFFD84315),
      title: 'Most Pending',
      items: data?.charts?.topPending ?? [],
    );
    final topForwarded = _TopUsersSection(
      icon: Icons.forward_to_inbox_rounded,
      color: const Color(0xFF00897B),
      title: 'Most Forwarded',
      items: data?.charts?.topForwarded ?? [],
    );
    final sections = _SectionStatsSection(
      items: data?.sectionStats ?? [],
      activeUsers: data?.activeUsers,
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            activity,
            const SizedBox(height: 16),
            deptFiles,
            const SizedBox(height: 16),
            deptDaak,
            const SizedBox(height: 16),
            topPutup,
            const SizedBox(height: 16),
            topPending,
            const SizedBox(height: 16),
            topForwarded,
            const SizedBox(height: 16),
            sections,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                activity,
                const SizedBox(height: 16),
                deptFiles,
                const SizedBox(height: 16),
                deptDaak,
                const SizedBox(height: 16),
                sections,
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                topPutup,
                const SizedBox(height: 16),
                topPending,
                const SizedBox(height: 16),
                topForwarded,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value);
  final String label;
  final int? value;
}

/// A card showing a set of labelled counts in a wrapping grid.
class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.stats,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: icon,
      iconBgColor: iconBgColor,
      title: title,
      badgeLabel: badgeLabel,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final tileWidth = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final stat in stats)
                  SizedBox(
                    width: tileWidth,
                    child: _StatTile(stat: stat, color: iconBgColor),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.color});

  final _Stat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${stat.value ?? 0}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ranked list of users with their counts.
class _TopUsersSection extends StatelessWidget {
  const _TopUsersSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<SecretaryTopUserModel> items;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: icon,
      iconBgColor: color,
      title: title,
      badgeLabel: 'Top ${items.length}',
      badgeColor: color.withValues(alpha: 0.12),
      badgeTextColor: color,
      body: items.isEmpty
          ? const _EmptyState()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _TopUserRow(item: items[i], rank: i + 1, color: color)
                        .animate(delay: (i * 100).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    if (i < items.length - 1)
                      const Divider(height: 16, thickness: 0.5),
                  ],
                ],
              ),
            ),
    );
  }
}

class _TopUserRow extends StatelessWidget {
  const _TopUserRow({
    required this.item,
    required this.rank,
    required this.color,
  });

  final SecretaryTopUserModel item;
  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.userTitle ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                ),
              ),
              Text(
                [item.designation, item.section]
                    .whereType<String>()
                    .join(' • '),
                style: TextStyle(fontSize: 11, color: appColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${item.count ?? 0}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Per-section totals with a stacked archived / pending progress bar.
class _SectionStatsSection extends StatelessWidget {
  const _SectionStatsSection({required this.items, required this.activeUsers});

  final List<SecretarySectionStatModel> items;
  final int? activeUsers;

  @override
  Widget build(BuildContext context) {
    // Sections with no files add noise; keep the busiest first.
    final visible = items.where((e) => (e.total ?? 0) > 0).toList()
      ..sort((a, b) => (b.total ?? 0).compareTo(a.total ?? 0));

    return DashboardSectionCard(
      icon: Icons.account_tree_outlined,
      iconBgColor: const Color(0xFF1E88E5),
      title: 'Section Overview',
      badgeLabel: '${activeUsers ?? 0} active users',
      badgeColor: const Color(0xFFE3F2FD),
      badgeTextColor: const Color(0xFF1565C0),
      body: visible.isEmpty
          ? const _EmptyState()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < visible.length; i++) ...[
                    _SectionRow(item: visible[i]),
                    if (i < visible.length - 1)
                      const Divider(height: 16, thickness: 0.5),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.item});

  final SecretarySectionStatModel item;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final total = item.total ?? 0;
    final archived = item.archived ?? 0;
    final pending = item.pending ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.section ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: appColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                if (archived > 0)
                  Expanded(
                    flex: archived,
                    child: Container(color: Colors.green[400]),
                  ),
                if (pending > 0)
                  Expanded(
                    flex: pending,
                    child: Container(color: Colors.orange[400]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Archived $archived  •  Pending $pending',
          style: TextStyle(fontSize: 11, color: appColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No data available.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }
}
