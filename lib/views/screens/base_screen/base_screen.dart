import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/views/screens/base_screen/nav_drawer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseScreen extends ConsumerWidget {
  final Widget body;
  final String? title;
  final bool showUserDetails;
  final bool enableBackButton;
  final List<Widget>? actions;
  const BaseScreen({
    super.key,
    required this.body,
    this.title,
    this.showUserDetails = false,
    this.enableBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            if (title != null)
              Expanded(
                child: AppText.headlineSmall(title!),
              ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          showUserDetails
              ? Consumer(
                  //future: ref.read(authRepo).fetchCurrentUserDetails(),
                  builder: (context, ref, child) {
                  final user = ref.watch(authController);
                  bool multiDesignations = user.designations.length > 1;
                  final DesignationModel? selectedDesignation =
                      user.currentDesignation;
                  return InkWell(
                    onTap: !multiDesignations ? null : () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: HeroTags.profile,
                          child: CircleAvatar(
                            backgroundColor:
                                AppColors.secondaryLight.withOpacity(0.2),
                            radius: 15,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AppText.titleMedium(
                              user.userTitle ?? '---',
                              fontSize: 15,
                            ),
                            AppText.bodySmall(
                              user.currentDesignation?.designation ?? '',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        if (user.designations.length > 1)
                          PopupMenuButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            itemBuilder: (context) {
                              return user.designations
                                  .map((des) => PopupMenuItem<DesignationModel>(
                                        value: des,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: AppText.labelLarge(
                                                des.designation ?? '---',
                                              ),
                                            ),
                                            if (des.userDesgId ==
                                                selectedDesignation?.userDesgId)
                                              const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )
                                          ],
                                        ),
                                      ))
                                  .toList();
                            },
                            onSelected: (DesignationModel des) async {
                              await ref
                                  .read(authController.notifier)
                                  .setDesignation(des);
                              ref.read(dashboardController.notifier).initData();
                            },
                          ),
                      ],
                    ),
                  );
                })
              : const SizedBox(),
          const SizedBox(width: 16),
          ...actions ?? [],
          if (enableBackButton)
            IconButton(
              onPressed: () => RouteHelper.navigateTo(Routes.dashboard),
              icon: const Icon(
                Icons.clear,
                color: Colors.black87,
              ),
            ),
        ],
      ),
      drawer: const NavDrawer(),
      body: body,
    );
  }
}
