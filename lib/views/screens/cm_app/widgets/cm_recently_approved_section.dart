import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shows summaries recently approved by the CM.
class CMRecentlyApprovedSection extends StatelessWidget {
  const CMRecentlyApprovedSection({super.key, required this.items});

  final List<CMRecentlyApprovedModel> items;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.verified_rounded,
      iconBgColor: const Color(0xFF2E9E6B),
      title: 'Recently Approved by You',
      badgeLabel: '${items.length} recent',
      badgeColor: const Color(0xFFDFF5EC),
      badgeTextColor: const Color(0xFF1E7A50),
      body: items.isEmpty ? _buildEmptyState() : _buildList(items),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No recent approvals.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _buildList(List<CMRecentlyApprovedModel> items) {
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
                Routes.summaryDetails,
                extra: SummaryModel(id: item.id),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E9E6B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E9E6B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.summaryNo ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  item.originDept ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 18,
                      color: Colors.indigo[300],
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
