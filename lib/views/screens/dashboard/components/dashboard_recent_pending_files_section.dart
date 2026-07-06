import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardRecentPendingFilesSection extends StatelessWidget {
  const DashboardRecentPendingFilesSection({
    super.key,
    required this.files,
    required this.loading,
  });

  final List<FileModel> files;
  final bool loading;

  static const _accentColor = Color(0xFFFFB74D);

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.timelapse_rounded,
      iconBgColor: _accentColor,
      title: 'Pending Files',
      badgeLabel: loading ? '...' : '${files.length} files',
      badgeColor: _accentColor.withValues(alpha: 0.15),
      badgeTextColor: _accentColor,
      body: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : files.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No pending files.',
          style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final displayFiles = files.take(5).toList();
    final hasMore = files.length > 5;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemCount: displayFiles.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: context.appColors.textSecondary.withValues(alpha: 0.1),
          ),
          itemBuilder: (context, index) {
            final file = displayFiles[index];

            return InkWell(
                  onTap: () => RouteHelper.push(
                    Routes.fileDetails(file.fileId),
                    extra: file,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.folder_outlined,
                            size: 18,
                            color: _accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (file.referenceNo != null)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        file.referenceNo!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _accentColor,
                                        ),
                                      ),
                                    ),
                                    if (file.receivedAt != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        DateTimeHelper.datFormatSlash(
                                          file.receivedAt,
                                        ),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: context.appColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              const SizedBox(height: 3),
                              Text(
                                file.subject ?? 'No Subject',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (file.sender != null)
                                Text(
                                  'From: ${file.sender}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.appColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: context.appColors.textSecondary
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                )
                .animate(delay: (index * 60).ms)
                .fadeIn(duration: 280.ms)
                .slideX(
                  begin: -0.05,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => RouteHelper.push(Routes.pendingFiles),
              icon: const Icon(Icons.timelapse_rounded, size: 16),
              label: Text(
                hasMore
                    ? 'View all ${files.length} pending files'
                    : 'View All Pending Files',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentColor,
                side: const BorderSide(color: _accentColor, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
