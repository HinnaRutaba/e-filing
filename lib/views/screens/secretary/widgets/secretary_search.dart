import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => AppTextField(
        controller: controller,
        onChanged: onChanged,
        labelText: 'Search',
        hintText: 'Search by user or department',
        showLabel: false,
        prefix: Icon(Icons.search_rounded, color: colors.textSecondary),
        suffixIcon: value.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, size: 20),
                color: colors.textSecondary,
                onPressed: onClear,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

/// One-line summary under the search field while a search is active.
class SecretarySearchSummary extends StatelessWidget {
  const SecretarySearchSummary({
    super.key,
    required this.users,
    required this.sections,
  });

  final int users;
  final int sections;

  @override
  Widget build(BuildContext context) {
    String count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Text(
        'Showing ${count(users, 'user', 'users')} and '
        '${count(sections, 'section', 'sections')}',
        style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
      ),
    );
  }
}

/// Shown when a search matches nothing: says what happened and what to try.
class SecretarySearchEmptyState extends StatelessWidget {
  const SecretarySearchEmptyState({
    super.key,
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  static const _steps = [
    (
      Icons.spellcheck_rounded,
      'Check the spelling',
      'Make sure the name or department is typed correctly.',
    ),
    (
      Icons.short_text_rounded,
      'Try fewer letters',
      'A first name or a single word matches more than a full title.',
    ),
    (
      Icons.account_tree_outlined,
      'Search by department instead',
      'Use a section or department name to see everyone in it.',
    ),
    (
      Icons.leaderboard_rounded,
      'Only ranked users are listed',
      'Users appear once they are in Top File Put-up, Pending or Forwarded.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viz = SecretaryVizColors.of(context);

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: viz.blue.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: viz.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Nothing matches '),
                    TextSpan(
                      text: '"$query"',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: ' in any user or department.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WHAT YOU CAN DO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < _steps.length; i++) ...[
                _Step(
                  number: i + 1,
                  icon: _steps[i].$1,
                  title: _steps[i].$2,
                  body: _steps[i].$3,
                  color: viz.blue,
                ),
                if (i < _steps.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear search'),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final int number;
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}
