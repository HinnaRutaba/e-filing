import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/gradient_tab_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Main tabs
// ---------------------------------------------------------------------------

enum SummaryMainTab {
  actionRequired('Action Required', Icons.notifications_none_rounded),
  sentTracked('Sent & Tracked', Icons.check_circle_outline_rounded),
  archive('Archive', Icons.archive_outlined);

  final String label;
  final IconData icon;
  const SummaryMainTab(this.label, this.icon);
}

// ---------------------------------------------------------------------------
// Sub-tabs (grouped by parent main tab)
// ---------------------------------------------------------------------------

enum SummarySubTab {
  // Action Required
  inbox('Inbox', SummaryMainTab.actionRequired, 'inbox'),
  sharedToMe('Shared to me', SummaryMainTab.actionRequired, 'internal'),
  drafts('Drafts', SummaryMainTab.actionRequired, 'my_drafts'),
  disposal('Disposal', SummaryMainTab.actionRequired, 'pending_disposal'),

  // Sent & Tracked
  sentOut('Sent Out', SummaryMainTab.sentTracked, 'sent'),
  sharedInternally(
    'Shared Internally',
    SummaryMainTab.sentTracked,
    'internal_forwarded',
  );

  final String label;
  final SummaryMainTab parent;
  final String filterName;
  const SummarySubTab(this.label, this.parent, this.filterName);
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

enum SummaryStatus {
  remarksDrafted('REMARKS DRAFTED', Color(0xFF6C4BE3), Color(0xFFEFEAFE)),
  pendingReview('PENDING REVIEW', Color(0xFFD97706), Color(0xFFFFF4E0)),
  forwarded('FORWARDED', Color(0xFF2563EB), Color(0xFFE4EDFD)),
  sent('SENT', Color(0xFF059669), Color(0xFFE1F6EE)),
  sectionDraft('SECTION DRAFT', Color(0xFFD97706), Color(0xFFFFF4E0)),
  pendingWithSecretary(
    'Pending with Secretary',
    Color(0xFF059669),
    Color(0xFFE1F6EE),
  );

  final String label;
  final Color fg;
  final Color bg;
  const SummaryStatus(this.label, this.fg, this.bg);
}

// ---------------------------------------------------------------------------
// View-model for a single summary row
// ---------------------------------------------------------------------------

class SummaryListItem {
  final String reference;
  final SummaryStatus status;
  final String title;
  final String? remarksBy;
  final String? draftedBy;
  final String? draftedByRole;
  final String? section;
  final String? target;
  final DateTime createdAt;
  final String relativeTime;
  final SummarySubTab tab;

  const SummaryListItem({
    required this.reference,
    required this.status,
    required this.title,
    this.remarksBy,
    this.draftedBy,
    this.draftedByRole,
    this.section,
    this.target,
    required this.createdAt,
    required this.relativeTime,
    required this.tab,
  });
}

// ===========================================================================
// Screen
// ===========================================================================

class SummariesListScreen extends ConsumerStatefulWidget {
  const SummariesListScreen({super.key});

  @override
  ConsumerState<SummariesListScreen> createState() =>
      _SummariesListScreenState();
}

class _SummariesListScreenState extends ConsumerState<SummariesListScreen> {
  SummaryMainTab _mainTab = SummaryMainTab.actionRequired;
  late SummarySubTab _subTab;

  final ScrollController _mainTabScrollController = ScrollController();
  final ScrollController _subTabScrollController = ScrollController();
  final Map<SummaryMainTab, GlobalKey> _mainTabKeys = {
    for (final t in SummaryMainTab.values) t: GlobalKey(),
  };
  final Map<SummarySubTab, GlobalKey> _subTabKeys = {
    for (final t in SummarySubTab.values) t: GlobalKey(),
  };

  // ---- Mock data ----

  final List<SummaryListItem> _items = [
    // -------- Drafts (Action Required) --------
    SummaryListItem(
      reference: 'SUR/ID/2026/000001',
      status: SummaryStatus.sectionDraft,
      title: 'Subject TI0022',
      draftedBy: 'Mr. Section officer',
      draftedByRole: 'Additional Secretary-II',
      section: 'Additional Secretary-II',
      target: 'Agriculture Department',
      createdAt: DateTime(2026, 4, 11),
      relativeTime: '4d ago',
      tab: SummarySubTab.drafts,
    ),
    SummaryListItem(
      reference: 'SUR/ID/2026/000002',
      status: SummaryStatus.sectionDraft,
      title: 'Subj8888',
      draftedBy: 'Mr. Section officer',
      draftedByRole: 'Additional Secretary-II',
      section: 'Additional Secretary-II',
      target: 'Governor House',
      createdAt: DateTime(2026, 4, 12),
      relativeTime: '3d ago',
      tab: SummarySubTab.drafts,
    ),
    SummaryListItem(
      reference: 'SUR/ID/2026/000005',
      status: SummaryStatus.sectionDraft,
      title: 'Budget allocation for Q3',
      draftedBy: 'Ms. Deputy Director',
      draftedByRole: 'Additional Secretary-I',
      section: 'Additional Secretary-I',
      target: 'Finance Department',
      createdAt: DateTime(2026, 4, 13),
      relativeTime: '2d ago',
      tab: SummarySubTab.drafts,
    ),
    // -------- Sent Out (Sent & Tracked) --------
    SummaryListItem(
      reference: 'SUR/ID/2026/000003',
      status: SummaryStatus.pendingWithSecretary,
      title: 'Summary to Test Hand Notes',
      section: 'Information Department',
      remarksBy: 'Imran Khan',
      draftedBy: 'Imran Khan',
      draftedByRole: 'Secretary Information',
      createdAt: DateTime(2026, 4, 14),
      relativeTime: '1d ago',
      tab: SummarySubTab.sentOut,
    ),
    SummaryListItem(
      reference: 'SUR/ID/2026/000004',
      status: SummaryStatus.pendingWithSecretary,
      title: 'Test summary',
      section: 'Chief Minister Secretariat',
      remarksBy: 'Mr. PSTOCM',
      draftedBy: 'Mr. PSTOCM',
      draftedByRole: 'Principal Secretary IPS CMS',
      createdAt: DateTime(2026, 4, 14),
      relativeTime: '1d ago',
      tab: SummarySubTab.sentOut,
    ),
  ];

  List<SummarySubTab> get _currentSubTabs =>
      SummarySubTab.values.where((s) => s.parent == _mainTab).toList();

  int _countForMain(SummaryMainTab m) =>
      _items.where((e) => e.tab.parent == m).length;

  int _countForSub(SummarySubTab s) => _items.where((e) => e.tab == s).length;

  List<SummaryListItem> get _visibleItems {
    if (_currentSubTabs.isEmpty) {
      return _items.where((e) => e.tab.parent == _mainTab).toList();
    }
    return _items.where((e) => e.tab == _subTab).toList();
  }

  @override
  void initState() {
    super.initState();
    // Auto-select the first main tab that has data.
    _mainTab = SummaryMainTab.values.firstWhere(
      (m) => _countForMain(m) > 0,
      orElse: () => SummaryMainTab.actionRequired,
    );
    // Auto-select the first sub-tab with data under that main tab.
    final subs = _currentSubTabs;
    if (subs.isNotEmpty) {
      _subTab = subs.firstWhere(
        (s) => _countForSub(s) > 0,
        orElse: () => subs.first,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollMainTabIntoView();
      if (_currentSubTabs.isNotEmpty) _scrollSubTabIntoView();
    });
  }

  @override
  void dispose() {
    _mainTabScrollController.dispose();
    _subTabScrollController.dispose();
    super.dispose();
  }

  void _onMainTabChanged(SummaryMainTab tab) {
    if (tab == _mainTab) return;
    setState(() {
      _mainTab = tab;
      final subs = _currentSubTabs;
      if (subs.isNotEmpty) {
        _subTab = subs.firstWhere(
          (s) => _countForSub(s) > 0,
          orElse: () => subs.first,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollMainTabIntoView(),
    );
  }

  void _scrollMainTabIntoView() {
    final ctx = _mainTabKeys[_mainTab]?.currentContext;
    if (ctx == null) return;
    final rb = ctx.findRenderObject();
    if (rb is! RenderBox || !rb.hasSize) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _scrollSubTabIntoView() {
    final ctx = _subTabKeys[_subTab]?.currentContext;
    if (ctx == null) return;
    final rb = ctx.findRenderObject();
    if (rb is! RenderBox || !rb.hasSize) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  String? _helperBannerText() {
    switch (_subTab) {
      case SummarySubTab.inbox:
        return 'Summaries received by you and awaiting your action.';
      case SummarySubTab.sharedToMe:
        return 'Summaries shared with you by colleagues.';
      case SummarySubTab.drafts:
        return 'Section drafts and internal remarks pending your review, signature, and forwarding.';
      case SummarySubTab.disposal:
        return 'Summaries that have been disposed off.';
      case SummarySubTab.sentOut:
        return 'Summaries you have already dispatched.';
      case SummarySubTab.sharedInternally:
        return 'Summaries shared internally within your section.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        isdash: false,
        title: 'Summaries',
        actions: [
          AppOutlineButton(
            onPressed: () {
              RouteHelper.push(Routes.createSummary);
            },
            text: "Draft Summary",
            icon: Icons.edit_outlined,
          ),
        ],
        body: Column(
          children: [
            _mainTabBar(),
            const SizedBox(height: 2),
            // Sub-tabs
            if (_currentSubTabs.isNotEmpty) _subTabBar(),
            // Helper banner
            if (_helperBannerText() != null)
              _helperBanner(_helperBannerText()!),
            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // TODO: reload from controller.
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: _visibleItems.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Icon(
                            Icons.inbox_outlined,
                            size: 56,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 12),
                          Center(child: Text('No summaries yet')),
                        ],
                      )
                    : Builder(
                        builder: (context) {
                          final perRow = context.isMobile ? 1 : 2;
                          final rowCount = (_visibleItems.length / perRow)
                              .ceil();
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            itemCount: rowCount,
                            itemBuilder: (ctx, rowIndex) {
                              final children = <Widget>[];
                              for (var c = 0; c < perRow; c++) {
                                final i = rowIndex * perRow + c;
                                if (i >= _visibleItems.length) {
                                  children.add(
                                    const Expanded(child: SizedBox.shrink()),
                                  );
                                  continue;
                                }
                                final card = SummaryCard(item: _visibleItems[i])
                                    .animate()
                                    .fadeIn(
                                      delay: (80 * i).ms,
                                      duration: 300.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideX(
                                      begin: -0.15,
                                      end: 0,
                                      delay: (80 * i).ms,
                                      duration: 350.ms,
                                      curve: Curves.easeOutCubic,
                                    );
                                if (c > 0) {
                                  children.add(const SizedBox(width: 12));
                                }
                                children.add(Expanded(child: card));
                              }
                              if (perRow == 1) {
                                return children.first is Expanded
                                    ? (children.first as Expanded).child
                                    : children.first;
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: children,
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Main tab bar ----------

  Widget _mainTabBar() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        controller: _mainTabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: SummaryMainTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = SummaryMainTab.values[index];
          return KeyedSubtree(
            key: _mainTabKeys[tab],
            child: GradientTabChip(
              label: tab.label,
              icon: tab.icon,
              count: _countForMain(tab),
              selected: _mainTab == tab,
              onTap: () => _onMainTabChanged(tab),
            ),
          );
        },
      ),
    );
  }

  // ---------- Sub-tab bar ----------

  Widget _subTabBar() {
    final subs = _currentSubTabs;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _subTabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: subs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sub = subs[index];
          return KeyedSubtree(
            key: _subTabKeys[sub],
            child: _SubTabChip(
              label: sub.label,
              count: _countForSub(sub),
              selected: _subTab == sub,
              onTap: () {
                setState(() => _subTab = sub);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollSubTabIntoView(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _helperBanner(String text) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1C99A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: AppText.bodySmall(text, color: const Color(0xFF8A4B08)),
          ),
        ],
      ),
    );
  }
}

class _SubTabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SubTabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
