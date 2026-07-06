import 'package:efiling_balochistan/models/summaries/cm_dashboard_model.dart';
import 'package:efiling_balochistan/views/screens/cm_app/widgets/dashboard_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shows how summaries are distributed across departments.
class CMDepartmentDistributionSection extends StatelessWidget {
  const CMDepartmentDistributionSection({super.key, required this.depts});

  final List<CMDepartmentStatModel> depts;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.insert_drive_file_outlined,
      iconBgColor: const Color(0xFF5C6BC0),
      title: 'Department-wise Distribution',
      badgeLabel: '${depts.length} depts',
      badgeColor: const Color(0xFFEDE7F6),
      badgeTextColor: const Color(0xFF5C35B0),
      body: depts.isEmpty ? _buildEmptyState() : _buildList(depts),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'No department data available.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _buildList(List<CMDepartmentStatModel> depts) {
    final maxTotal = depts.fold<int>(0, (m, d) => (d.total ?? 0) > m ? (d.total ?? 0) : m);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < depts.length; i++) ...[
            _DepartmentRow(stat: depts[i], maxTotal: maxTotal)
                .animate(delay: (i * 100).ms)
                .fadeIn(duration: 350.ms)
                .slideX(
                  begin: -0.08,
                  end: 0,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic,
                ),
            if (i < depts.length - 1) const Divider(height: 20, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({required this.stat, required this.maxTotal});

  final CMDepartmentStatModel stat;
  final int maxTotal;

  @override
  Widget build(BuildContext context) {
    final total = stat.total ?? 0;
    final fillFraction = maxTotal > 0 ? total / maxTotal : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                stat.title ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Text(
              '$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _StatChip(
              label: 'Total: $total',
              color: const Color(0xFFFFF3E0),
              textColor: const Color(0xFFE07B20),
            ),
            const SizedBox(width: 6),
            _StatChip(
              label: 'Active: ${stat.inProgress ?? 0}',
              color: const Color(0xFFFFF3E0),
              textColor: const Color(0xFFE07B20),
              icon: Icons.autorenew,
            ),
            const SizedBox(width: 6),
            _StatChip(
              label: 'Closed: ${stat.closed ?? 0}',
              color: const Color(0xFFE8F5E9),
              textColor: const Color(0xFF2E7D32),
              icon: Icons.check,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fillFraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
