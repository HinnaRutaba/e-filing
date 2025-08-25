import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavDrawer extends ConsumerWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DrawerMenu> menus = [
      DrawerMenu(
        title: "Dashboard",
        icon: Icons.dashboard,
        routeName: Routes.dashboard,
      ),
      DrawerMenu(
        title: "Create New File",
        icon: Icons.add_link,
        routeName: Routes.createFile,
      ),
      DrawerMenu(
        title: "Pending Files",
        icon: Icons.event_repeat_rounded,
        routeName: Routes.pendingFiles,
      ),
      DrawerMenu(
        title: "My Files",
        icon: Icons.receipt_long,
        routeName: Routes.myFiles,
      ),
      DrawerMenu(
        title: "Action Required",
        icon: Icons.file_open,
        routeName: Routes.actionRequiredFiles,
      ),
      DrawerMenu(
        title: "Archived",
        icon: Icons.archive_sharp,
        routeName: Routes.archived,
      ),
      DrawerMenu(
        title: "Forwarded Files",
        icon: Icons.send_time_extension_rounded,
        routeName: Routes.forwarded,
      ),
      DrawerMenu(
        title: "Settings",
        icon: Icons.settings,
        routeName: Routes.settings,
      ),
    ];
    return Drawer(
      width: 240,
      backgroundColor: AppColors.cardColor,
      elevation: 6,
      shadowColor: AppColors.secondaryDark,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset(AssetsConstants.logo, width: 100, height: 100),
          const SizedBox(height: 16),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                ...menus.map(
                  (e) {
                    bool isSelected =
                        e.routeName == RouteHelper.currentLocation;
                    return Container(
                      margin: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryLight.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        leading: Icon(
                          e.icon,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.secondaryDark,
                        ),
                        horizontalTitleGap: 12,
                        title: AppText.titleMedium(
                          e.title,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.secondaryDark,
                        ),
                        onTap: e.onTap ??
                            () {
                              RouteHelper.navigateTo(e.routeName);
                              // Navigate to Dashboard
                            },
                      ),
                    );
                  },
                ).toList(),
              ],
            ),
          )),
          const SizedBox(height: 16),
          AppTextLinkButton(
            onPressed: () {
              ref.read(authController).logout();
            },
            text: "Sign Out",
            icon: Icons.logout,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class DrawerMenu {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String routeName;

  DrawerMenu({
    required this.title,
    required this.icon,
    this.onTap,
    required this.routeName,
  });
}
