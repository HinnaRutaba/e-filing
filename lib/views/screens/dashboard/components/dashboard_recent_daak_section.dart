import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_detals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : items.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No daak letters available.',
          style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final displayItems = items.take(5).toList();
    final hasMore = items.length > 5;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemCount: displayItems.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: context.appColors.textSecondary.withValues(alpha: 0.1),
          ),
          itemBuilder: (context, index) {
            final daak = displayItems[index];
            final statusColor = daak.status?.color ?? const Color(0xFF5C6BC0);
            final bool noDetails = daak.status == DaakStatus.disposedOff ||
                daak.status == DaakStatus.nfa;

            return InkWell(
                  onTap: noDetails
                      ? null
                      : () => RouteHelper.push(
                            Routes.daakDetails(daak.id),
                            extra: DaakDetailsInfo(
                              daak: daak,
                              openPDF: false,
                              status: daak.status ?? DaakStatus.inProgress1,
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
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.mail_outline_rounded,
                            size: 18,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      daak.diaryNo ?? '—',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (daak.letterDate != null)
                                    Text(
                                      DateTimeHelper.datFormatSlash(
                                        daak.letterDate,
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.appColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                daak.subject ?? 'No Subject',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                daak.sourceDepartment ?? 'Unknown Department',
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
                        if (!noDetails)
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
        if (hasMore)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => RouteHelper.push(Routes.daak),
                icon: const Icon(Icons.mail_outline_rounded, size: 16),
                label: Text('View all ${items.length} letters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E9E6B),
                  side: const BorderSide(
                    color: Color(0xFF2E9E6B),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => RouteHelper.push(Routes.daak),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('View All Daak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E9E6B),
                  side: const BorderSide(
                    color: Color(0xFF2E9E6B),
                    width: 1,
                  ),
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
