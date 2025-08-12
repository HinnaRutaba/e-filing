import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      elevation: 3.5,
      shadowColor: AppColors.secondaryLight.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primaryDark,
          gradient: const LinearGradient(
            colors: [
              AppColors.secondaryDark,
              AppColors.secondaryLight,
            ],
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Card(
          margin: EdgeInsets.zero,
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondaryDark,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.titleLarge("Name"),
                              const SizedBox(height: 4),
                              AppText.bodySmall("username"),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: AppColors.secondary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: AppText.labelLarge(
                            "Status",
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  color: AppColors.secondaryLight.withOpacity(0.15),
                ),
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    AppText.titleMedium(
                      "EDIT",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTile(
      {required String title,
      required String value,
      IconData icon = Icons.person}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: AppColors.secondary,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.labelSmall(
                title,
                color: AppColors.secondaryDark,
              ),
              AppText.bodySmall(
                value,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
