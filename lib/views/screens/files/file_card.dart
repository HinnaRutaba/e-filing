import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

enum FileType { pending, my, actionRequired, archived, forwarded }

class FileCard extends StatelessWidget {
  final FileType fileType;
  final FileModel? data;
  const FileCard({super.key, required this.fileType, this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: AppColors.secondaryLight.withValues(alpha: 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          RouteHelper.push(Routes.fileDetails(data?.fileId), extra: fileType);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: (data?.tag?.color ?? AppColors.primary).withValues(
              alpha: 0.4,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.25),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppText.labelLarge(
                            data?.barcode ?? '',
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                          if (fileType == FileType.forwarded) ...[
                            const SizedBox(width: 6),
                            _forwardedCountChip(4),
                          ],
                          const Spacer(),
                          if (data?.tag != null) ...[
                            _tagPill(data!.tag!.title ?? '', data!.tag!.color),
                            const SizedBox(width: 4),
                          ],
                          if (fileType == FileType.forwarded ||
                              data?.status != null)
                            _statusPill(
                              fileType == FileType.forwarded
                                  ? "Forwarded"
                                  : data?.status?.label ?? '',
                            ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.secondaryDark,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppText.bodyMedium(
                        data?.subject ?? '---',
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data?.sender != null)
                            Expanded(
                              child: infoTile(
                                title: "Sender",
                                value: data?.sender ?? "N/A",
                              ),
                            ),
                          if (data?.receiver != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: infoTile(
                                title: "Receiver",
                                value: data?.receiver ?? '---',
                              ),
                            ),
                          ],
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                fileType == FileType.pending ||
                                    fileType == FileType.actionRequired
                                ? infoTile(
                                    title: "Received on",
                                    value: DateTimeHelper.datFormatSlashShort(
                                      data?.receivedAt,
                                    ),
                                    icon: Icons.calendar_month,
                                  )
                                : fileType == FileType.archived
                                ? infoTile(
                                    title: "Archived on",
                                    value: DateTimeHelper.datFormatSlashShort(
                                      data?.archivedAt,
                                    ),
                                    icon: Icons.calendar_month,
                                  )
                                : fileType == FileType.forwarded
                                ? infoTile(
                                    title: "Forwarded on",
                                    value: DateTimeHelper.datFormatSlashShort(
                                      data?.latestDate,
                                    ),
                                    icon: Icons.calendar_month,
                                  )
                                : infoTile(
                                    title: "Created on",
                                    value: DateTimeHelper.datFormatSlashShort(
                                      data?.createdAt,
                                    ),
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.12),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.secondaryLight.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.secondary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        AppText.bodySmall(
                          data?.referenceNo ?? "Reference No. Not Available",
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
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

  Widget _tagPill(String label, Color? color) {
    final base = color ?? AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: base.withValues(alpha: 0.45)),
      ),
      child: AppText.labelSmall(
        label,
        color: base,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  Widget _statusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.45)),
      ),
      child: AppText.labelSmall(
        label,
        color: AppColors.secondaryDark,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  Widget _forwardedCountChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.forward_rounded,
            size: 10,
            color: AppColors.secondaryDark,
          ),
          const SizedBox(width: 3),
          AppText.labelSmall(
            '$count×',
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required String title,
    required String value,
    IconData icon = Icons.person,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.secondaryDark, size: 11),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.labelSmall(
                title,
                color: AppColors.secondaryDark,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              AppText.bodySmall(
                value,
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
