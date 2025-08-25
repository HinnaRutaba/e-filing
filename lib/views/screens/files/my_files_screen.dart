import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/not_found.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyFilesScreen extends ConsumerStatefulWidget {
  const MyFilesScreen({super.key});

  @override
  ConsumerState<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends ConsumerState<MyFilesScreen> {
  final TextEditingController searchController = TextEditingController();
  Future<void> fetchData() async {
    await ref.read(filesController.notifier).fetchFiles(FileType.my);
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesController).filteredFiles;
    return BaseScreen(
      title: "My Files",
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            AppTextField(
              controller: searchController,
              labelText: "Search",
              hintText: "Search by file name or number",
              prefix: const Icon(Icons.search, color: AppColors.secondaryDark),
              onChanged: (String value) {
                ref.read(filesController.notifier).filterFiles(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: files.isEmpty
                  ? const Center(
                      child: NotFound(),
                    )
                  : ListView.builder(
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FileCard(
                          fileType: FileType.my,
                          data: files[i],
                        ),
                      ),
                      itemCount: files.length,
                      physics: const BouncingScrollPhysics(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
