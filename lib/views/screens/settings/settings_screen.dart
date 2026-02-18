import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      isdash: false,
      title: "Settings",
      showUserDetails: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: HeroTags.profile,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    radius: 30,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppText.bodyLarge("User Name", fontSize: 20),
                const SizedBox(height: 32),
                _menuTile('Users', Icons.supervised_user_circle_outlined, () {
                  RouteHelper.push(Routes.users);
                }),
                _menuTile('Sections', Icons.file_copy_outlined, () {
                  RouteHelper.push(Routes.sections);
                }),
                _menuTile('Designations', Icons.work_outline, () {
                  RouteHelper.push(Routes.designations);
                }),
                _menuTile('Change Password', Icons.lock_outlined, () {
                  RouteHelper.push(Routes.changePassword);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuTile(String title, IconData icon, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: AppText.titleMedium(title),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondaryLight.withOpacity(0.2),
          radius: 18,
          child: Icon(
            icon,
            color: AppColors.secondaryDark,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_right,
          color: AppColors.textPrimary,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}
