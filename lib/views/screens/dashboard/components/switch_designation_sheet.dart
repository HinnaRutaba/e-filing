import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists the signed-in user's designations and switches to the one picked.
/// Picking the current designation just closes the sheet.
Future<void> showSwitchDesignationSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final selected = await showModalBottomSheet<DesignationModel>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _SwitchDesignationSheet(),
  );
  if (selected == null) return;

  final current = ref.read(authController).currentDesignation;
  if (selected.userDesgId == current?.userDesgId) return;
  await ref.read(dashboardController.notifier).switchDesignation(selected);
}

class _SwitchDesignationSheet extends ConsumerWidget {
  const _SwitchDesignationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authController);
    final currentId = user.currentDesignation?.userDesgId;
    final colors = context.appColors;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.secondaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppText.titleLarge(
                      'Switch Designation',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colors.textPrimary),
                  ),
                ],
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  children: [
                    for (final des in user.designations)
                      _DesignationTile(
                        designation: des,
                        selected: des.userDesgId == currentId,
                        onTap: () => Navigator.pop(context, des),
                      ),
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

class _DesignationTile extends StatelessWidget {
  final DesignationModel designation;
  final bool selected;
  final VoidCallback onTap;

  const _DesignationTile({
    required this.designation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = [
      designation.section,
      designation.department,
    ].where((s) => s != null && s.trim().isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? colors.secondaryLight.withValues(alpha: 0.12)
            : colors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? colors.secondaryDark : colors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.secondaryLight.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: colors.secondaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleMedium(
                        designation.designation ?? '---',
                        fontWeight: FontWeight.w600,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AppText.bodySmall(
                          subtitle,
                          color: colors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: colors.success)
                else
                  Icon(Icons.chevron_right, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
