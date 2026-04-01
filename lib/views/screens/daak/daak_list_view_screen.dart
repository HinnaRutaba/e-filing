import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaakListViewScreen extends ConsumerStatefulWidget {
  const DaakListViewScreen({super.key});

  @override
  ConsumerState<DaakListViewScreen> createState() => _DaakListViewScreenState();
}

class _DaakListViewScreenState extends ConsumerState<DaakListViewScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(daakController.notifier).loadData(isInitailLoad: true);
      _searchController.addListener(() {
        ref.read(daakController.notifier).searchText = _searchController.text;
        setState(() {});
      });
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
    final filteredDaak =
        ref.watch(daakController.select((state) => state.filteredDaak));
    return BaseScreen(
      title: "Daak Inbox",
      isdash: false,
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _searchController,
                          hintText: 'Search daak...',
                          labelText: '',
                          showLabel: false,
                          onChanged: (value) {
                            ref.read(daakController.notifier).searchText =
                                value;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<DaakStatus?>(
                        tooltip: 'Filter by status',
                        onSelected: (status) {
                          ref
                              .read(daakController.notifier)
                              .applyStatusFilter(status);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<DaakStatus?>(
                            value: null,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 8),
                                AppText.titleSmall(
                                  'All Statuses',
                                )
                              ],
                            ),
                          ),
                          ...DaakStatus.values.map(
                            (status) => PopupMenuItem<DaakStatus?>(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: status.color,
                                  ),
                                  const SizedBox(width: 8),
                                  AppText.titleSmall(
                                    status.label,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: controller.selectedStatus == null
                                ? Colors.white
                                : controller.selectedStatus!.color
                                    .withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.filter_list_rounded,
                            color: controller.selectedStatus?.color ??
                                Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.read(daakController.notifier).loadData();
                    },
                    child: filteredDaak.isEmpty
                        ? const Center(child: Text('No daak found.'))
                        : ListView.builder(
                            itemCount: filteredDaak.length,
                            itemBuilder: (context, index) {
                              return DaakCard(daak: filteredDaak[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
