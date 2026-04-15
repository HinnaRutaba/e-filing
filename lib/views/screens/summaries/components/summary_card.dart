import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/views/screens/summaries/summaries_list_screen.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final SummaryListItem item;
  const SummaryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status.fg;
    final statusBg = item.status.bg;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            RouteHelper.push(Routes.summaryDetails, extra: item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Accent header strip --------
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Status dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.relativeTime,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // -------- Body --------
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference label
                    Row(
                      children: [
                        Text(
                          item.reference,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateTimeHelper.datFormatSlash(item.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: Colors.grey.shade600),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.section != null)
                          _InfoChip(
                            icon: Icons.account_tree_outlined,
                            label: 'Section',
                            value: item.section!,
                            color: const Color(0xFF2563EB),
                          ),
                        if (item.target != null)
                          _InfoChip(
                            icon: Icons.gps_fixed_rounded,
                            label: 'Target',
                            value: item.target!,
                            color: const Color(0xFF0891B2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (item.remarksBy != null || item.draftedBy != null)
                      _PeopleRow(item: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact two-column row showing Remarks by / Drafted by with avatar initials.
class _PeopleRow extends StatelessWidget {
  final SummaryListItem item;
  const _PeopleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final people = <Widget>[];
    if (item.remarksBy != null) {
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Remarks by',
            name: item.remarksBy!,
            color: const Color(0xFF7C3AED),
          ),
        ),
      );
    }
    if (item.draftedBy != null) {
      if (people.isNotEmpty) people.add(const SizedBox(width: 10));
      people.add(
        Expanded(
          child: _PersonTile(
            label: 'Drafted by',
            name: item.draftedBy!,
            sub: item.draftedByRole,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: people);
  }
}

class _PersonTile extends StatelessWidget {
  final String label;
  final String name;
  final String? sub;
  final Color color;

  const _PersonTile({
    required this.label,
    required this.name,
    required this.color,
    this.sub,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tinted chip used for Section / Target metadata.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
