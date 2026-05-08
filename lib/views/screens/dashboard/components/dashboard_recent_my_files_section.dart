import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardRecentMyFilesSection extends StatelessWidget {
  const DashboardRecentMyFilesSection({super.key, required this.items});

  final List<FileModel> items;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.file_copy_rounded,
      iconBgColor: const Color(0xFF5C6BC0),
      title: 'Recent Filed',
      badgeLabel: '${items.length} files',
      badgeColor: const Color(0xFFEDE7F6),
      badgeTextColor: const Color(0xFF5C35B0),
      body: items.isEmpty ? _buildEmptyState() : _buildList(context),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No recent filed files.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
              onTap: () => RouteHelper.push(
                Routes.fileDetails(item.fileId),
                extra: FileType.my,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_copy,
                        size: 20,
                        color: Color(0xFF5C6BC0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.referenceNo ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF254A73),
                            ),
                          ),
                          Text(
                            item.subject ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D2D2D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.receiver != null)
                            Text(
                              'To: ${item.receiver}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF757575),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFBDBDBD),
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideX(
              begin: -0.08,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
