import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

enum FileType {
  pending,
  my,
  actionRequired,
  archived,
  forwarded,
}

class FileCard extends StatelessWidget {
  final FileType fileType;
  const FileCard({super.key, required this.fileType});

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
      child: InkWell(
        onTap: () {
          RouteHelper.push(Routes.fileDetails(1));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.primaryDark,
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryDark,
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
                          Expanded(
                            child: AppText.labelLarge(
                              "S.No: 00000",
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
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
                          const Icon(
                            Icons.arrow_right,
                            color: AppColors.secondaryDark,
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppText.titleLarge("File Type"),
                          ),
                          if (fileType == FileType.forwarded)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText.bodyMedium(
                                    "Forwarded ",
                                    fontSize: 13,
                                    color: AppColors.secondary,
                                  ),
                                  AppText.titleMedium(
                                    "4",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondaryDark,
                                  ),
                                  AppText.bodyMedium(
                                    " Times",
                                    fontSize: 13,
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText.bodySmall("Subject of the file will go here"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: infoTile(title: "Sender", value: "John Doe"),
                          ),
                          if (!(fileType == FileType.pending ||
                              fileType == FileType.actionRequired)) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: infoTile(
                                  title: "Receiver", value: "Jane Smith"),
                            ),
                          ],
                          const SizedBox(width: 16),
                          Expanded(
                            child: infoTile(
                              title: fileType == FileType.pending ||
                                      fileType == FileType.actionRequired
                                  ? "Received on"
                                  : fileType == FileType.my
                                      ? "Created on"
                                      : fileType == FileType.archived
                                          ? "Archived on"
                                          : "Date",
                              value: DateTimeHelper.datFormatSlashShort(
                                  DateTime.now()),
                              icon: Icons.calendar_month,
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
                        Icons.receipt_long,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      AppText.bodyMedium(
                        "Reference No: ",
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      AppText.titleMedium(
                        "345345",
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
