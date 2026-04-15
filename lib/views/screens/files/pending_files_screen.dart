import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/not_found.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingFilesScreen extends ConsumerStatefulWidget {
  const PendingFilesScreen({super.key});

  @override
  ConsumerState<PendingFilesScreen> createState() => _PendingFilesScreenState();
}

class _PendingFilesScreenState extends ConsumerState<PendingFilesScreen> {
  final TextEditingController searchController = TextEditingController();
  Future<void> fetchData() async {
    await ref.read(filesController.notifier).fetchFiles(FileType.pending);
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesController).filteredFiles;
    return RefreshIndicator(
      onRefresh: fetchData,
      child: BaseScreen(
        isdash: false,
        title: "Pending Files",
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                AppTextField(
                  controller: searchController,
                  labelText: "Search",
                  hintText: "Search by file name or number",
                  prefix: const Icon(
                    Icons.search,
                    color: AppColors.secondaryDark,
                  ),
                  onChanged: (String value) {
                    ref.read(filesController.notifier).filterFiles(value);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: files.isEmpty
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const NotFound(),
                              AppSolidButton(
                                onPressed: fetchData,
                                text: "Reload",
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            Widget buildAnimated(int i) {
                              return FileCard(
                                    fileType: FileType.pending,
                                    data: files[i],
                                  )
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
                            }

                            if (!context.isMobile) {
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: files.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: context.isDesktop ? 3 : 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 140,
                                    ),
                                itemBuilder: (ctx, i) => buildAnimated(i),
                              );
                            }
                            return ListView.builder(
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: buildAnimated(i),
                              ),
                              itemCount: files.length,
                              physics: const BouncingScrollPhysics(),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
