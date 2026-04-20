import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/summaries/summary_local_link_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InternalFilesSection extends StatefulWidget {
  final List<SummaryLocalLinkModel> links;
  final ValueChanged<SummaryLocalLinkModel>? onViewLink;

  const InternalFilesSection({super.key, required this.links, this.onViewLink});

  @override
  State<InternalFilesSection> createState() => _InternalFilesSectionState();
}

class _InternalFilesSectionState extends State<InternalFilesSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final daakLinks = widget.links
        .where((l) => (l.linkType ?? '').toLowerCase() == 'daak')
        .toList(growable: false);
    final fileLinks = widget.links
        .where((l) => (l.linkType ?? '').toLowerCase() == 'file')
        .toList(growable: false);
    final isEmpty = daakLinks.isEmpty && fileLinks.isEmpty;

    return _sidebarShell(
      context: context,
      header: 'Internal Files (Daak / E-Files)',
      headerColor: appColors.primaryDark,
      trailing: _countBadge(context, daakLinks.length, fileLinks.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEmpty)
            AppText.bodySmall(
              'No local correspondence linked.',
              color: appColors.textSecondary,
              fontSize: 12,
            ),
          if (daakLinks.isNotEmpty) ...[
            _groupLabel(context, 'Linked Daak', daakLinks.length),
            const SizedBox(height: 6),
            for (int i = 0; i < daakLinks.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _daakTile(context, daakLinks[i])
                  .animate()
                  .fadeIn(
                    delay: (80 * i).ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: -0.15,
                    end: 0,
                    delay: (80 * i).ms,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ],
          if (daakLinks.isNotEmpty && fileLinks.isNotEmpty)
            const SizedBox(height: 12),
          if (fileLinks.isNotEmpty) ...[
            _groupLabel(context, 'Linked Files', fileLinks.length),
            const SizedBox(height: 6),
            for (int i = 0; i < fileLinks.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _fileTile(context, fileLinks[i])
                  .animate()
                  .fadeIn(
                    delay: (80 * (daakLinks.length + i)).ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: -0.15,
                    end: 0,
                    delay: (80 * (daakLinks.length + i)).ms,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _countBadge(BuildContext context, int daakCount, int fileCount) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.primaryDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: AppText.bodySmall(
        '$daakCount daak, $fileCount file(s)',
        color: appColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _groupLabel(BuildContext context, String label, int count) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        AppText.bodySmall(
          label.toUpperCase(),
          color: appColors.secondaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
        const SizedBox(width: 6),
        AppText.bodySmall(
          '($count)',
          color: appColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _daakTile(BuildContext context, SummaryLocalLinkModel link) {
    final title = link.file?.referenceNo ?? '—';
    final subject = link.file?.subject ?? '';
    return _linkedTile(
      context: context,
      icon: Icons.mail_outline_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: title,
      subtitle: subject,
      linkedBy: link.linkedBy,
      onView: widget.onViewLink == null ? null : () => widget.onViewLink!(link),
    );
  }

  Widget _fileTile(BuildContext context, SummaryLocalLinkModel link) {
    final title = link.file?.referenceNo ?? 'File';
    final subject = link.file?.subject ?? '';
    return _linkedTile(
      context: context,
      icon: Icons.folder_outlined,
      linkedBy: link.linkedBy,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: title,
      subtitle: subject,
      onView: widget.onViewLink == null ? null : () => widget.onViewLink!(link),
    );
  }

  Widget _linkedTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String? linkedBy,
    VoidCallback? onView,
  }) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: iconColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.bodySmall(
                        title,
                        color: appColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (linkedBy != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.secondaryLight.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: appColors.secondaryLight.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: AppText.labelSmall(
                          linkedBy,
                          color: appColors.secondaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (subtitle.isNotEmpty)
                  AppText.bodySmall(
                    subtitle,
                    color: appColors.textSecondary,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          if (onView != null) ...[
            const SizedBox(width: 8),
            _viewButton(context: context, onTap: onView),
          ],
        ],
      ),
    );
  }

  Widget _viewButton({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final appColors = context.appColors;
    return Material(
      color: appColors.primaryDark,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_red_eye_outlined,
                size: 13,
                color: appColors.accent,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: appColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sidebarShell({
    required BuildContext context,
    required String header,
    required Color headerColor,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: headerColor.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.bodyMedium(
                      header,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                  ),
                  if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: headerColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
