import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/secretary_users_controller.dart';
import 'package:efiling_balochistan/models/secretary_department_users_model.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/secretary_viz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Department users with their file counts, one page at a time. A filter bar
/// narrows them to a section and orders them by any count; the list ends in a
/// "Load more" button, or a note once the last page is in.
class SecretaryUsersPanel extends StatelessWidget {
  const SecretaryUsersPanel({
    super.key,
    required this.state,
    required this.onLoadMore,
    required this.onRetry,
    required this.onSectionChanged,
    required this.onSortChanged,
    required this.onDirectionToggled,
    required this.onResetFilters,
    this.delay = Duration.zero,
  });

  final SecretaryUsersState state;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final ValueChanged<int?> onSectionChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onDirectionToggled;
  final VoidCallback onResetFilters;
  final Duration delay;

  /// Panel width from which the counts sit beside the name instead of under it.
  static const double _inlineStatsWidth = 640;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viz = SecretaryVizColors.of(context);
    final items = state.items;
    final filters = state.filters;

    return SecretaryPanel(
      delay: delay,
      icon: Icons.groups_rounded,
      color: viz.navy,
      title: 'Department Users',
      subtitle:
          'Sorted by ${_sortLabel(state.sort)}, '
          '${_directionLabel(state.sort, state.descending)}',
      trailing: items.isEmpty
          ? null
          : Text(
              '${formatCount(state.total)} users',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The options come with the first response.
          if (filters != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _FilterBar(
                state: state,
                filters: filters,
                color: viz.navy,
                onSectionChanged: onSectionChanged,
                onSortChanged: onSortChanged,
                onDirectionToggled: onDirectionToggled,
                onResetFilters: onResetFilters,
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final inline = constraints.maxWidth >= _inlineStatsWidth;

              if (items.isEmpty) {
                if (state.loading) return const _Loading();
                if (state.error != null) {
                  return _Message(
                    text: state.error!,
                    action: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  );
                }
                if (state.filtered) {
                  return _Message(
                    text: 'No users match these filters.',
                    action: TextButton.icon(
                      onPressed: onResetFilters,
                      icon: const Icon(Icons.filter_alt_off_rounded),
                      label: const Text('Reset filters'),
                    ),
                  );
                }
                return const _Message(text: 'No users found.');
              }

              return AnimatedOpacity(
                // Dim the old list while a new search, filter or refresh
                // loads.
                opacity: state.loading ? 0.5 : 1,
                duration: 200.ms,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 20,
                            color: colors.border.withValues(alpha: 0.5),
                          ),
                        _UserRow(item: items[i], inline: inline, viz: viz)
                            // Stagger restarts each page so appended rows
                            // appear promptly.
                            .animate(
                              delay:
                                  ((i % SecretaryUsersController.perPage) * 40)
                                      .ms,
                            )
                            .fadeIn(duration: 300.ms),
                      ],
                      const SizedBox(height: 12),
                      _Footer(state: state, onLoadMore: onLoadMore),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Display name of a `sort` option. The API calls disposed files "archived".
String _sortLabel(String sort) => switch (sort) {
  'name' => 'Name',
  'section' => 'Section',
  'created' => 'Created',
  'pending' => 'Pending',
  'archived' => 'Disposed',
  'forwarded' => 'Forwarded',
  _ => sort.isEmpty ? sort : sort[0].toUpperCase() + sort.substring(1),
};

String _directionLabel(String sort, bool descending) {
  final alphabetical = sort == 'name' || sort == 'section';
  if (alphabetical) return descending ? 'Z to A' : 'A to Z';
  return descending ? 'high to low' : 'low to high';
}

/// Section and sort pickers, the direction toggle, and a reset once anything
/// differs from the default.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.state,
    required this.filters,
    required this.color,
    required this.onSectionChanged,
    required this.onSortChanged,
    required this.onDirectionToggled,
    required this.onResetFilters,
  });

  /// Menu value for "All sections"; a null value would read as a dismissal.
  static const int _allSections = -1;

  final SecretaryUsersState state;
  final SecretaryUsersFiltersModel filters;
  final Color color;
  final ValueChanged<int?> onSectionChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onDirectionToggled;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final sectionTitle = state.sectionId == null
        ? 'All sections'
        : filters.sections
                  .where((e) => e.id == state.sectionId)
                  .firstOrNull
                  ?.title ??
              'Section';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PopupMenuButton<int>(
          tooltip: 'Filter by section',
          initialValue: state.sectionId ?? _allSections,
          constraints: const BoxConstraints(minWidth: 200, maxHeight: 380),
          onSelected: (id) => onSectionChanged(id == _allSections ? null : id),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _allSections,
              child: Text('All sections'),
            ),
            const PopupMenuDivider(),
            for (final section in filters.sections)
              if (section.id != null)
                PopupMenuItem(
                  value: section.id!,
                  child: Text(section.title ?? ''),
                ),
          ],
          child: _FilterChip(
            icon: Icons.account_tree_outlined,
            label: sectionTitle,
            color: color,
            active: state.sectionId != null,
            showArrow: true,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Sort by',
          initialValue: state.sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            for (final option in filters.sortOptions)
              PopupMenuItem(value: option, child: Text(_sortLabel(option))),
          ],
          child: _FilterChip(
            icon: Icons.sort_rounded,
            label: _sortLabel(state.sort),
            color: color,
            active: state.sort != 'pending',
            showArrow: true,
          ),
        ),
        Tooltip(
          message: 'Reverse order',
          child: InkWell(
            onTap: onDirectionToggled,
            borderRadius: BorderRadius.circular(10),
            child: _FilterChip(
              icon: state.descending
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              label: _directionLabel(state.sort, state.descending),
              color: color,
              active: state.direction != 'desc',
            ),
          ),
        ),
        if (state.filtered)
          TextButton.icon(
            onPressed: onResetFilters,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 12),
            ),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Reset'),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    this.showArrow = false,
  });

  final IconData icon;
  final String label;
  final Color color;

  /// Set to something other than the default; drawn tinted.
  final bool active;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = active ? color : colors.textPrimary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.5)
              : colors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: foreground),
          ],
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.item, required this.inline, required this.viz});

  final SecretaryDepartmentUserModel item;
  final bool inline;
  final SecretaryVizColors viz;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = [
      item.designation,
      item.section,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' • ');

    final identity = Row(
      children: [
        _Avatar(name: item.userTitle ?? '', color: viz.navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.userTitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );

    final stats = [
      _Stat('Created', item.created ?? 0, colors.textPrimary),
      _Stat('Pending', item.pending ?? 0, viz.amber),
      _Stat('Disposed', item.disposedOff ?? 0, viz.blue),
      _Stat('Forwarded', item.forwarded ?? 0, viz.green),
    ];

    if (inline) {
      return Row(
        children: [
          Expanded(child: identity),
          const SizedBox(width: 12),
          for (final s in stats) SizedBox(width: 84, child: s),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        identity,
        const SizedBox(height: 10),
        Row(children: [for (final s in stats) Expanded(child: s)]),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formatCount(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// "Load more" while pages remain, otherwise the end-of-list note.
class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});

  final SecretaryUsersState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'No more users found',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        // Only a failed "load more" gets here; a failed first load has no rows.
        if (state.error != null && !state.loadingMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
        OutlinedButton.icon(
          onPressed: state.loadingMore || state.loading ? null : onLoadMore,
          icon: state.loadingMore
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.expand_more_rounded),
          label: Text(state.loadingMore ? 'Loading...' : 'Load more'),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Center(
        child: Column(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 8), action!],
          ],
        ),
      ),
    );
  }
}
