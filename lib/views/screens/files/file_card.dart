import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/file_model.dart';
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
  final FileModel? data;
  const FileCard({super.key, required this.fileType, this.data});

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
          RouteHelper.push(Routes.fileDetails(data?.fileId), extra: fileType);
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
                              data?.barcode ?? '',
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Visibility(
                            visible: data?.tag != null,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: data?.tag?.color,
                              ),
                              margin: const EdgeInsets.only(right: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: AppText.labelLarge(
                                data?.tag?.title ?? '',
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: AppText.labelLarge(
                              data?.status?.label ?? '',
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
                          data?.fileType != null
                              ? Expanded(
                                  child:
                                      AppText.titleLarge(data?.fileType ?? ''),
                                )
                              : const SizedBox(height: 4),
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
                      AppText.bodySmall(data?.subject ?? '---'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (data?.sender != null)
                            Expanded(
                              child: infoTile(
                                title: "Sender",
                                value: data?.sender ?? "N/A",
                              ),
                            ),
                          if (data?.receiver != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: infoTile(
                                  title: "Receiver",
                                  value: data?.receiver ?? '---'),
                            ),
                          ],
                          const SizedBox(width: 16),
                          Expanded(
                            child: fileType == FileType.pending ||
                                    fileType == FileType.actionRequired
                                ? infoTile(
                                    title: "Received on",
                                    value: DateTimeHelper.datFormatSlashShort(
                                        data?.receivedAt),
                                    icon: Icons.calendar_month,
                                  )
                                : fileType == FileType.archived
                                    ? infoTile(
                                        title: "Archived on",
                                        value:
                                            DateTimeHelper.datFormatSlashShort(
                                                data?.createdAt),
                                        icon: Icons.calendar_month,
                                      )
                                    : infoTile(
                                        title: "Created on",
                                        value:
                                            DateTimeHelper.datFormatSlashShort(
                                                data?.createdAt),
                                        icon: Icons.calendar_month,
                                      ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (data?.referenceNo != null)
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
                        AppText.titleMedium(
                          data?.referenceNo ?? "Reference No. Not Available",
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
