import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_card.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
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

    _searchController.addListener(() {
      ref.read(daakController.notifier).searchText = _searchController.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDaak = ref.watch(daakController.select((state) => state.filteredDaak));
    return BaseScreen(
      title: "Daak Inbox",
      isdash: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AppTextField(
              controller: _searchController,
              hintText: 'Search daak...',
              labelText: '',
              showLabel: false,
              onChanged: (value) {
                ref.read(daakController.notifier).searchText = value;
              },
            ),
          ),
          Expanded(
            child: filteredDaak.isEmpty
                ? const Center(child: Text('No daak found.'))
                : ListView.builder(
                    itemCount: filteredDaak.length,
                    itemBuilder: (context, index) {
                      return DaakCard(daak: filteredDaak[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
