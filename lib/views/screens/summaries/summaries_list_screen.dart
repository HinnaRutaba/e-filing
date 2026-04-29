import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_card.dart';
import 'package:efiling_balochistan/utils/typing_detector.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/gradient_tab_chip.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummariesListScreen extends ConsumerStatefulWidget {
  const SummariesListScreen({super.key});

  @override
  ConsumerState<SummariesListScreen> createState() =>
      _SummariesListScreenState();
}

class _SummariesListScreenState extends ConsumerState<SummariesListScreen> {
  final ScrollController _mainTabScrollController = ScrollController();
  final ScrollController _subTabScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TypingDetector _typingDetector = TypingDetector(milliseconds: 500);
  final Map<SummaryMainTab, GlobalKey> _mainTabKeys = {
    for (final t in SummaryMainTab.values) t: GlobalKey(),
  };

  final Map<SummarySubTab, GlobalKey> _subTabKeys = {
    for (final t in SummarySubTab.values) t: GlobalKey(),
  };

  List<SummarySubTab> _subTabsFor(SummaryMainTab mainTab) {
    final role = ref.read(summariesController).meta?.activeUserDesg?.roleEnum;
    return subTabsForRole(
      role,
    ).where((s) => s.configFor(role).parent == mainTab).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(summariesController.notifier).loadData(isInitialLoad: true);
      final s = ref.read(summariesController);
      _scrollMainTabIntoView(s.selectedMainTab);
      _scrollSubTabIntoView(s.selectedSubTab);
    });
  }

  @override
  void dispose() {
    _mainTabScrollController.dispose();
    _subTabScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMainTabChanged(SummaryMainTab tab) {
    ref.read(summariesController.notifier).setMainTab(tab);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollMainTabIntoView(tab),
    );
  }

  void _scrollMainTabIntoView(SummaryMainTab mainTab) {
    final ctx = _mainTabKeys[mainTab]?.currentContext;
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

  void _scrollSubTabIntoView(SummarySubTab subTab) {
    final ctx = _subTabKeys[subTab]?.currentContext;
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

  String? _helperBannerText(SummarySubTab subTab) {
    switch (subTab) {
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
    final ctrlState = ref.watch(summariesController);
    final mainTab = ctrlState.selectedMainTab;
    final subTab = ctrlState.selectedSubTab;
    final currentSubTabs = _subTabsFor(mainTab);
    final visibleItems = ctrlState.filteredSummaries;
    final bannerText = _helperBannerText(subTab);

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
            _mainTabBar(mainTab),
            const SizedBox(height: 2),
            // Sub-tabs
            if (currentSubTabs.isNotEmpty) _subTabBar(mainTab, subTab),
            // Search bar
            _searchBar(),
            // Helper banner
            if (bannerText != null) _helperBanner(bannerText),
            // List
            Expanded(
              child: ctrlState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(summariesController.notifier)
                          .loadData(isInitialLoad: true),
                      child: visibleItems.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 120),
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 56,
                                  color: context.appColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                const Center(child: Text('No summaries yet')),
                              ],
                            )
                          : Builder(
                              builder: (context) {
                                final perRow = context.isMobile ? 1 : 2;
                                final rowCount = (visibleItems.length / perRow)
                                    .ceil();
                                return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    24,
                                  ),
                                  itemCount: rowCount,
                                  itemBuilder: (ctx, rowIndex) {
                                    final children = <Widget>[];
                                    for (var c = 0; c < perRow; c++) {
                                      final i = rowIndex * perRow + c;
                                      if (i >= visibleItems.length) {
                                        children.add(
                                          const Expanded(
                                            child: SizedBox.shrink(),
                                          ),
                                        );
                                        continue;
                                      }
                                      final card =
                                          SummaryCard(item: visibleItems[i])
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

  Widget _mainTabBar(SummaryMainTab mainTab) {
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
              selected: mainTab == tab,
              onTap: () => _onMainTabChanged(tab),
            ),
          );
        },
      ),
    );
  }

  // ---------- Sub-tab bar ----------

  Widget _subTabBar(SummaryMainTab mainTab, SummarySubTab subTab) {
    final subs = _subTabsFor(mainTab);
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
          final role = ref
              .watch(summariesController)
              .meta
              ?.activeUserDesg
              ?.roleEnum;
          return KeyedSubtree(
            key: _subTabKeys[sub],
            child: _SubTabChip(
              label: sub.configFor(role).label,
              selected: subTab == sub,
              onTap: () {
                ref.read(summariesController.notifier).setSubTab(sub);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollSubTabIntoView(sub),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: AppTextField(
        controller: _searchController,
        hintText: 'Search summaries...',
        labelText: '',
        showLabel: false,
        onChanged: (value) {
          setState(() {});
          _typingDetector.run(() {
            ref.read(summariesController.notifier).setSearchText(value);
          });
        },
        prefix: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isNotEmpty
            ? InkWell(
                onTap: () {
                  _searchController.clear();
                  ref.read(summariesController.notifier).setSearchText('');
                },
                child: const Icon(Icons.close_rounded),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.cardColor),
        ),
      ),
    );
  }

  Widget _helperBanner(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF3B2A0E) : const Color(0xFFFFF7EC);
    final borderColor = isDark
        ? const Color(0xFF8A5A1A)
        : const Color(0xFFF1C99A);
    final textColor = isDark
        ? const Color(0xFFE8C07A)
        : const Color(0xFF8A4B08);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: AppText.bodySmall(text, color: textColor)),
        ],
      ),
    );
  }
}

class _SubTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : appColors.cardColorLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : appColors.secondaryLight.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : appColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
