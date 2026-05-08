import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_detals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class DashboardRecentDaakSection extends StatelessWidget {
  const DashboardRecentDaakSection({
    super.key,
    required this.items,
    required this.loading,
  });

  final List<DaakModel> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.mark_email_unread_rounded,
      iconBgColor: const Color(0xFF2E9E6B),
      title: 'Recent Daak',
      badgeLabel: loading ? '...' : '${items.length} letters',
      badgeColor: const Color(0xFF2E9E6B).withValues(alpha: 0.15),
      badgeTextColor: const Color(0xFF2E9E6B),
      body: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : items.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No recent daak letters.',
          style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
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
        final dateStr = item.letterDate != null
            ? DateFormat('dd MMM yyyy').format(item.letterDate!)
            : null;

        return InkWell(
              onTap: () => RouteHelper.push(
                Routes.daakDetails(item.id),
                extra: DaakDetailsInfo(
                  daak: item,
                  openPDF: true,
                  status: item.status ?? DaakStatus.inProgress1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E9E6B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mail_rounded,
                        size: 20,
                        color: Color(0xFF2E9E6B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (item.diaryNo != null)
                                Text(
                                  item.diaryNo!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              if (item.diaryNo != null && dateStr != null)
                                Text(
                                  ' · ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.appColors.disabled,
                                  ),
                                ),
                              if (dateStr != null)
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            item.subject ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.sourceDepartment != null)
                            Text(
                              item.sourceDepartment!,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: context.appColors.disabled,
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideX(
              begin: 0.08,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
