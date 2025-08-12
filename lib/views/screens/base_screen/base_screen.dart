import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/views/screens/base_screen/nav_drawer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showUserDetails;
  const BaseScreen(
      {super.key, required this.body, this.title, this.showUserDetails = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: title != null ? AppText.headlineSmall(title!) : null,
        titleSpacing: 0,
        actions: showUserDetails
            ? [
                Row(
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
                    AppText.titleMedium(
                      "User Name",
                      fontSize: 15,
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              ]
            : null,
      ),
      drawer: const NavDrawer(),
      body: body,
    );
  }
}
