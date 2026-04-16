import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
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
  final bool isdash;
  final Color? bgColor;
  const BaseScreen({
    super.key,
    required this.body,
    required this.isdash,
    this.title,
    this.showUserDetails = false,
    this.enableBackButton = true,
    this.actions,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isMobile) {
      return Scaffold(
        backgroundColor: bgColor ?? AppColors.background,
        extendBodyBehindAppBar: isdash,
        appBar: _buildAppBar(context, ref, showMenuButton: true),
        drawer: const NavDrawer(alwaysExpanded: true),
        body: body,
      );
    }

    final bool expanded = ref.watch(navDrawerExpandedProvider) ?? false;

    final appBar = _buildAppBar(context, ref, showMenuButton: false);
    final double topInset = MediaQuery.of(context).padding.top;
    final double appBarHeight = appBar.preferredSize.height + topInset;

    final Widget rightPane = isdash
        ? Stack(
            children: [
              Positioned.fill(child: body),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(height: appBarHeight, child: appBar),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(height: appBarHeight, child: appBar),
              Expanded(child: body),
            ],
          );

    void collapse() =>
        ref.read(navDrawerExpandedProvider.notifier).state = false;
    void expand() => ref.read(navDrawerExpandedProvider.notifier).state = true;

    return Scaffold(
      backgroundColor: bgColor ?? AppColors.background,
      body: Stack(
        children: [
          Row(
            children: [
              NavDrawer(expanded: false, onToggle: expand),
              Expanded(child: rightPane),
            ],
          ),
          IgnorePointer(
            ignoring: !expanded,
            child: AnimatedOpacity(
              opacity: expanded ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: collapse,
                child: Container(color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            left: expanded ? 0 : -240,
            width: 240,
            child: NavDrawer(expanded: true, onToggle: collapse),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref, {
    required bool showMenuButton,
  }) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: bgColor,
      title: showUserDetails
          ? Container(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authController);
                  bool multiDesignations = user.designations.length > 1;
                  final DesignationModel? selectedDesignation =
                      user.currentDesignation;
                  return InkWell(
                    onTap: !multiDesignations ? null : () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: HeroTags.profile,
                              child: CircleAvatar(
                                backgroundColor: AppColors.secondaryLight
                                    .withValues(alpha: 0.2),
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
                                      .map(
                                        (des) =>
                                            PopupMenuItem<DesignationModel>(
                                              value: des,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: AppText.labelLarge(
                                                      des.designation ?? '---',
                                                    ),
                                                  ),
                                                  if (des.userDesgId ==
                                                      selectedDesignation
                                                          ?.userDesgId)
                                                    const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    ),
                                                ],
                                              ),
                                            ),
                                      )
                                      .toList();
                                },
                                onSelected: (DesignationModel des) async {
                                  await ref
                                      .read(authController.notifier)
                                      .setDesignation(des);
                                  ref
                                      .read(dashboardController.notifier)
                                      .initData();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          : title != null
          ? AppText.headlineSmall(title!, textAlign: TextAlign.left)
          : const SizedBox(),
      titleSpacing: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showMenuButton
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: !isdash ? AppColors.textPrimary : AppColors.cardColor,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      actions: [
        if (isdash && context.isMobile)
          IconButton(
            onPressed: () {
              ref.read(authController.notifier).logout(context);
            },
            icon: Icon(Icons.power_settings_new, color: Colors.orange[300]),
          ),
        const SizedBox(width: 16),
        ...actions ?? [],
        if (enableBackButton)
          IconButton(
            onPressed: () => RouteHelper.navigateTo(Routes.dashboard),
            icon: const Icon(Icons.clear, color: Colors.black87),
          ),
      ],
    );
  }
}
