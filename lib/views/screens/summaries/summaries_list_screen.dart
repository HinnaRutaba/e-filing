import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
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
                          _SummaryCard(item: _visibleItems[i]),
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
// Summary card
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final SummaryListItem item;
  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status.fg;
    final statusBg = item.status.bg;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            RouteHelper.push(Routes.summaryDetails, extra: item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Accent header strip --------
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  color: statusBg,
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.relativeTime,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // -------- Body --------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference label
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.reference,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    // People row (Remarks + Drafted by)
                    if (item.remarksBy != null || item.draftedBy != null)
                      _PeopleRow(item: item),
                    if (item.remarksBy != null || item.draftedBy != null)
                      const SizedBox(height: 12),
                    // Section / Target chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.section != null)
                          _InfoChip(
                            icon: Icons.account_tree_outlined,
                            label: 'Section',
                            value: item.section!,
                            color: const Color(0xFF2563EB),
                          ),
                        if (item.target != null)
                          _InfoChip(
                            icon: Icons.gps_fixed_rounded,
                            label: 'Target',
                            value: item.target!,
                            color: const Color(0xFF0891B2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // -------- Divider --------
              Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
              // -------- Footer (date + action) --------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateTimeHelper.datFormatSlash(item.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        RouteHelper.push(Routes.summaryDetails, extra: item);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Review'),
                      style: TextButton.styleFrom(
                        foregroundColor: statusColor,
                        backgroundColor: statusBg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact two-column row showing Remarks by / Drafted by with avatar initials.
class _PeopleRow extends StatelessWidget {
  final SummaryListItem item;
  const _PeopleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final people = <Widget>[];
    if (item.remarksBy != null) {
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Remarks by',
            name: item.remarksBy!,
            color: const Color(0xFF7C3AED),
          ),
        ),
      );
    }
    if (item.draftedBy != null) {
      if (people.isNotEmpty) people.add(const SizedBox(width: 10));
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Drafted by',
            name: item.draftedBy!,
            sub: item.draftedByRole,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: people);
  }
}

class _PersonTile extends StatelessWidget {
  final String label;
  final String name;
  final String? sub;
  final Color color;

  const _PersonTile({
    required this.label,
    required this.name,
    required this.color,
    this.sub,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tinted chip used for Section / Target metadata.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
