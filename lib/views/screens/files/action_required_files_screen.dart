import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/not_found.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionRequiredFilesScreen extends ConsumerStatefulWidget {
  const ActionRequiredFilesScreen({super.key});

  @override
  ConsumerState<ActionRequiredFilesScreen> createState() =>
      _ActionRequiredFilesScreenState();
}

class _ActionRequiredFilesScreenState
    extends ConsumerState<ActionRequiredFilesScreen> {
  final TextEditingController searchController = TextEditingController();
  Future<void> fetchData() async {
    await ref
        .read(filesController.notifier)
        .fetchFiles(FileType.actionRequired);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesController).filteredFiles;
    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        isdash: false,
        title: "Action Required",
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: AppColors.cardColor),
                  ),
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
                                    fileType: FileType.actionRequired,
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
                                      mainAxisExtent: 160,
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
