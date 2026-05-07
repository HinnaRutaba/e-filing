import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shows the top originating departments ranked by summary volume.
class CMTopDepartmentsSection extends StatelessWidget {
  const CMTopDepartmentsSection({super.key, required this.items});

  final List<CMOriginatingDeptModel> items;

  static const _rankColors = [
    Color(0xFFFF8F00), // gold
    Color(0xFF90A4AE), // silver
    Color(0xFF8D6E63), // bronze
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.emoji_events_rounded,
      iconBgColor: const Color(0xFFFF8F00),
      title: 'Top Originating Departments',
      badgeLabel: 'Leaderboard',
      badgeColor: const Color(0xFFFFF8E1),
      badgeTextColor: const Color(0xFFB8860B),
      body: items.isEmpty ? _buildEmptyState() : _buildLeaderboard(items),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No data available.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(List<CMOriginatingDeptModel> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _LeaderboardRow(
                  item: items[i],
                  rank: i + 1,
                  rankColor: i < _rankColors.length
                      ? _rankColors[i]
                      : const Color(0xFF9E9E9E),
                )
                .animate(delay: (i * 100).ms)
                .fadeIn(duration: 300.ms)
                .slideX(
                  begin: 0.08,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
            if (i < items.length - 1) const Divider(height: 16, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.item,
    required this.rank,
    required this.rankColor,
  });

  final CMOriginatingDeptModel item;
  final int rank;
  final Color rankColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rankColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ).animate().scale(
          begin: const Offset(0, 0),
          duration: 350.ms,
          curve: Curves.easeOutBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.title ?? '',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${item.total ?? 0}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C35B0),
            ),
          ),
        ),
      ],
    );
  }
}
