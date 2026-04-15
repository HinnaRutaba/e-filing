import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/utils/typing_detector.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaakListViewScreen extends ConsumerStatefulWidget {
  const DaakListViewScreen({super.key});

  @override
  ConsumerState<DaakListViewScreen> createState() => _DaakListViewScreenState();
}

class _DaakListViewScreenState extends ConsumerState<DaakListViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TypingDetector _typingDetector = TypingDetector(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(daakController.notifier).loadData(isInitailLoad: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(daakController);
    final menuStatuses = DaakStatus.values.where((status) {
      final sameLabelStatuses = DaakStatus.values.where(
        (s) => s.label == status.label,
      );
      final lowestValue = sameLabelStatuses
          .map((s) => s.value)
          .reduce((a, b) => a < b ? a : b);
      return status.value == lowestValue;
    }).toList();

    final filteredDaak = ref.watch(
      daakController.select((state) => state.filteredDaak),
    );
    return BaseScreen(
      title: "Daak Inbox",
      isdash: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _FilterTile(
                    label: 'Inbox',
                    icon: Icons.inbox_rounded,
                    selected: controller.selectedFilter == DaakViewFilter.inbox,
                    onTap: () {
                      ref
                          .read(daakController.notifier)
                          .setViewFilter(DaakViewFilter.inbox);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterTile(
                    label: 'My NFA',
                    icon: Icons.folder_open_rounded,
                    selected: controller.selectedFilter == DaakViewFilter.nfa,
                    onTap: () {
                      ref
                          .read(daakController.notifier)
                          .setViewFilter(DaakViewFilter.nfa);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterTile(
                    label: 'Forwarded',
                    icon: Icons.forward_to_inbox_rounded,
                    selected:
                        controller.selectedFilter == DaakViewFilter.forwarded,
                    onTap: () {
                      ref
                          .read(daakController.notifier)
                          .setViewFilter(DaakViewFilter.forwarded);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    hintText: 'Search daak...',
                    labelText: '',
                    showLabel: false,
                    onChanged: (value) {
                      setState(() {});
                      _typingDetector.run(() {
                        ref.read(daakController.notifier).setSearchText(value);
                      });
                    },
                    prefix: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              _searchController.clear();
                              ref
                                  .read(daakController.notifier)
                                  .setSearchText('');
                            },
                            child: const Icon(Icons.close_rounded),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: AppColors.cardColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<DaakStatus?>(
                  tooltip: 'Filter by status',
                  onSelected: (status) {
                    if (status == DaakStatus.inProgress3) {
                      status = null;
                    }
                    ref.read(daakController.notifier).applyStatusFilter(status);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<DaakStatus?>(
                      value: DaakStatus.inProgress3,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 8),
                          AppText.titleSmall('All Statuses'),
                        ],
                      ),
                    ),
                    ...menuStatuses.map(
                      (status) => PopupMenuItem<DaakStatus?>(
                        value: status,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: status.color),
                            const SizedBox(width: 8),
                            AppText.titleSmall(status.label),
                          ],
                        ),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.selectedStatus == null
                            ? Colors.grey[300]!
                            : controller.selectedStatus!.color,
                      ),
                      color: controller.selectedStatus == null
                          ? Colors.white
                          : controller.selectedStatus!.color.withValues(
                              alpha: 0.12,
                            ),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: controller.selectedStatus?.color ?? Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.read(daakController.notifier).loadData();
                          },
                          child: filteredDaak.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('No daak found.'),
                                      AppTextLinkButton(
                                        onPressed: () {
                                          ref
                                              .read(daakController.notifier)
                                              .loadData();
                                        },
                                        text: 'Retry',
                                        icon: Icons.refresh,
                                      ),
                                    ],
                                  ),
                                )
                              : Builder(
                                  builder: (context) {
                                    Widget buildAnimated(int index) {
                                      return DaakCard(
                                            daak: filteredDaak[index],
                                            onStatusChange: (status) {
                                              ref
                                                  .read(daakController.notifier)
                                                  .setViewFilter(status);
                                            },
                                          )
                                          .animate()
                                          .fadeIn(
                                            delay: (80 * index).ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOut,
                                          )
                                          .slideX(
                                            begin: -0.15,
                                            end: 0,
                                            delay: (80 * index).ms,
                                            duration: 350.ms,
                                            curve: Curves.easeOutCubic,
                                          );
                                    }

                                    if (!context.isMobile) {
                                      return GridView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: filteredDaak.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: context.isDesktop
                                                  ? 3
                                                  : 2,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 0,
                                              mainAxisExtent: 190,
                                            ),
                                        itemBuilder: (context, index) =>
                                            buildAnimated(index),
                                      );
                                    }
                                    return ListView.builder(
                                      itemCount: filteredDaak.length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: buildAnimated(index),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          color: filled ? Colors.transparent : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: filled ? Colors.white : Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: AppText.bodySmall(
              label,
              color: filled ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
