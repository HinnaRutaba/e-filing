import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SummaryTab {
  myInbox('My Inbox', Icons.inbox_rounded),
  pendingAction('Pending Action', Icons.notifications_none_rounded),
  internalForwarded('Internal Forwarded', Icons.forward_to_inbox_rounded),
  draftFromSections('Draft from Sections', Icons.edit_note_rounded),
  sentSummaries('Sent Summaries', Icons.send_rounded);

  final String label;
  final IconData icon;
  const SummaryTab(this.label, this.icon);
}

/// Status chip color + label for a summary row.
enum SummaryStatus {
  remarksDrafted('REMARKS DRAFTED', Color(0xFF6C4BE3), Color(0xFFEFEAFE)),
  pendingReview('PENDING REVIEW', Color(0xFFD97706), Color(0xFFFFF4E0)),
  forwarded('FORWARDED', Color(0xFF2563EB), Color(0xFFE4EDFD)),
  sent('SENT', Color(0xFF059669), Color(0xFFE1F6EE));

  final String label;
  final Color fg;
  final Color bg;
  const SummaryStatus(this.label, this.fg, this.bg);
}

/// View model for a single summary row shown in the list.
class SummaryListItem {
  final String reference; // e.g. SUM/D/2026/000001
  final SummaryStatus status;
  final String title;
  final String? remarksBy;
  final String? draftedBy;
  final String? draftedByRole;
  final String? section;
  final String? target;
  final DateTime createdAt;
  final String relativeTime;
  final SummaryTab tab;

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

class SummariesListScreen extends ConsumerStatefulWidget {
  const SummariesListScreen({super.key});

  @override
  ConsumerState<SummariesListScreen> createState() =>
      _SummariesListScreenState();
}

class _SummariesListScreenState extends ConsumerState<SummariesListScreen> {
  late SummaryTab _selected;
  final ScrollController _tabScrollController = ScrollController();
  final Map<SummaryTab, GlobalKey> _tabKeys = {
    for (final t in SummaryTab.values) t: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _selected = SummaryTab.values.firstWhere(
      (t) => _countFor(t) > 0,
      orElse: () => SummaryTab.myInbox,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollSelectedIntoView(),
    );
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollSelectedIntoView() {
    final ctx = _tabKeys[_selected]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  final List<SummaryListItem> _items = [
    SummaryListItem(
      reference: 'SUM/D/2026/000001',
      status: SummaryStatus.remarksDrafted,
      title: 'Summary Tests',
      remarksBy: 'Haroon Khan',
      draftedBy: 'Haroon Khan',
      draftedByRole: 'Programmer',
      section: 'CMDU',
      target: 'BEEF',
      createdAt: DateTime(2026, 4, 9, 20, 37),
      relativeTime: '1d ago',
      tab: SummaryTab.draftFromSections,
    ),
    SummaryListItem(
      reference: 'SUM/I/2026/000004',
      status: SummaryStatus.forwarded,
      title: 'Quarterly budget review',
      remarksBy: 'Ali Raza',
      draftedBy: 'Fatima Noor',
      draftedByRole: 'Section Officer',
      section: 'FIN',
      target: 'CMDU',
      createdAt: DateTime(2026, 4, 8, 14, 10),
      relativeTime: '2d ago',
      tab: SummaryTab.internalForwarded,
    ),
    SummaryListItem(
      reference: 'SUM/S/2026/000007',
      status: SummaryStatus.sent,
      title: 'Procurement approval',
      remarksBy: 'Sara Ahmed',
      draftedBy: 'Sara Ahmed',
      draftedByRole: 'Deputy Director',
      section: 'CMDU',
      target: 'EDU',
      createdAt: DateTime(2026, 4, 6, 11, 5),
      relativeTime: '4d ago',
      tab: SummaryTab.sentSummaries,
    ),
  ];

  int _countFor(SummaryTab tab) => _items.where((e) => e.tab == tab).length;

  List<SummaryListItem> get _visibleItems =>
      _items.where((e) => e.tab == _selected).toList();

  String? _helperBannerText() {
    switch (_selected) {
      case SummaryTab.myInbox:
        return 'Summaries received by you and awaiting your action.';
      case SummaryTab.pendingAction:
        return 'Summaries that require your decision or signature.';
      case SummaryTab.internalForwarded:
        return 'Internal remarks forwarded within your section.';
      case SummaryTab.draftFromSections:
        return 'Section drafts and internal remarks pending your review, signature, and forwarding.';
      case SummaryTab.sentSummaries:
        return 'Summaries you have already dispatched.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      isdash: false,
      title: 'Summaries',
      actions: [
        AppOutlineButton(
          onPressed: () {
            RouteHelper.push(Routes.createSummary);
          },
          text: "New Summary",
          icon: Icons.add,
        ),
      ],
      body: Column(
        children: [
          _tabBar(),
          if (_helperBannerText() != null) _helperBanner(_helperBannerText()!),
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
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: _visibleItems.length,
                      itemBuilder: (ctx, i) =>
                          SummaryCard(item: _visibleItems[i])
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
                              ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: SummaryTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = SummaryTab.values[index];
          return KeyedSubtree(
            key: _tabKeys[tab],
            child: _SummaryFilterTile(
              label: tab.label,
              icon: tab.icon,
              count: _countFor(tab),
              selected: _selected == tab,
              onTap: () {
                setState(() => _selected = tab);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollSelectedIntoView(),
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

// -----------------------------------------------------------------------------
// Summary card moved to components/summary_card.dart

class _SummaryFilterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SummaryFilterTile({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              _buildContent(filled: false),
              if (selected)
                _buildContent(filled: true).animate().custom(
                  duration: 200.ms,
                  curve: Curves.easeInOutSine,
                  builder: (context, value, child) => ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) {
                      const softness = 0.4;
                      final t = value * (1 + softness);
                      final s1 = (t - softness).clamp(0.0, 0.999);
                      final s2 = t.clamp(s1 + 0.001, 1.0);
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [s1, s2],
                        colors: const [Colors.white, Colors.transparent],
                      ).createShader(rect);
                    },
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? null : AppColors.cardColorLight,
        gradient: filled
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.75),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled ? Colors.transparent : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: filled ? Colors.white : Colors.black54, size: 18),
          const SizedBox(width: 8),
          AppText.bodySmall(
            label,
            color: filled ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: count == 0
                  ? (filled ? Colors.white24 : Colors.grey.shade300)
                  : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: count == 0 && !filled ? Colors.black54 : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
