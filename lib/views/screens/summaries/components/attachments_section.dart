import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/attachment_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentsSection extends StatefulWidget {
  final XFile? mainPdf;
  final List<AttachmentModel> attachments;
  final ValueChanged<AttachmentModel> onViewAttachment;
  final ValueChanged<AttachmentModel> onDeleteAttachment;
  final ValueChanged<FlagAndAttachmentModel>? onAddAttachment;

  const AttachmentsSection({
    super.key,
    required this.mainPdf,
    required this.attachments,
    required this.onViewAttachment,
    required this.onDeleteAttachment,
    this.onAddAttachment,
  });

  @override
  State<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<AttachmentsSection> {
  bool _expanded = true;

  static final RegExp _flagPrefixRegex = RegExp(
    r'^\s*\[\s*Flag\s*:\s*([^\]]+)\]\s*',
    caseSensitive: false,
  );

  ({String? flag, String fileName}) _parseFlagAndName(
    AttachmentModel attachment,
  ) {
    final raw = attachment.originalName ?? '';
    final match = _flagPrefixRegex.firstMatch(raw);
    if (match != null) {
      final flag = match.group(1)?.trim();
      final rest = raw.substring(match.end).trim();
      return (
        flag: (flag == null || flag.isEmpty) ? null : flag,
        fileName: rest.isEmpty ? raw : rest,
      );
    }
    return (flag: null, fileName: raw);
  }

  @override
  Widget build(BuildContext context) {
    final hasMain = widget.mainPdf != null;
    final isEmpty = !hasMain && widget.attachments.isEmpty;

    return _sidebarShell(
      header: 'Attachments',
      headerColor: context.appColors.primaryDark,
      trailing: widget.onAddAttachment != null ? _addButton() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMain) ...[
            _attachmentRow(
                  label: 'Main Summary PDF',
                  fileName: widget.mainPdf!.name,
                  isMain: true,
                  onView: () {
                    //widget.onViewAttachment(widget.mainPdf!)
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                .slideX(
                  begin: -0.15,
                  end: 0,
                  duration: 350.ms,
                  curve: Curves.easeOutCubic,
                ),
            if (widget.attachments.isNotEmpty) const SizedBox(height: 8),
          ],
          for (int i = 0; i < widget.attachments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _buildAttachmentRow(widget.attachments[i], i, hasMain),
          ],
          if (isEmpty)
            AppText.bodySmall(
              'No attachments.',
              color: context.appColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentRow(AttachmentModel item, int index, bool hasMain) {
    final parsed = _parseFlagAndName(item);
    return _attachmentRow(
          label: parsed.flag ?? '',
          fileName: parsed.fileName,
          showFlag: parsed.flag != null,
          onView: () => widget.onViewAttachment(item),
          onDelete: () => _confirmDeleteAttachment(context, item),
        )
        .animate()
        .fadeIn(
          delay: (80 * (index + (hasMain ? 1 : 0))).ms,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: -0.15,
          end: 0,
          delay: (80 * (index + (hasMain ? 1 : 0))).ms,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _attachmentRow({
    required String label,
    String? fileName,
    bool isMain = false,
    bool showFlag = true,
    required VoidCallback onView,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            )
          else if (showFlag)
            Container(
              width: 26,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: AppText.bodySmall(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.appColors.secondaryDark,
              ),
            )
          else
            Icon(
              Icons.insert_drive_file_outlined,
              size: 18,
              color: context.appColors.secondaryDark,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.bodySmall(
              isMain ? label : (fileName ?? label),
              color: context.appColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!isMain && onDelete != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              child: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
            ),
          ],
          const SizedBox(width: 8),
          _viewButton(onTap: onView),
        ],
      ),
    );
  }

  Widget _viewButton({required VoidCallback onTap}) {
    return Material(
      color: context.appColors.primaryDark,
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
                color: context.appColors.accent,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: context.appColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return InkWell(
      onTap: _openAddAttachmentDialog,
      child: Row(
        children: [
          Icon(Icons.add, color: context.appColors.primaryDark, size: 20),
          const SizedBox(width: 4),
          AppText.titleMedium(
            "Add More",
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: context.appColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Future<void> _openAddAttachmentDialog() async {
    final usedFlags = <FlagModel>[];
    for (final a in widget.attachments) {
      final parsed = _parseFlagAndName(a);
      final flag = parsed.flag;
      if (flag != null && flag.isNotEmpty) {
        usedFlags.add(FlagModel(title: flag));
      }
    }
    final model = FlagAndAttachmentModel(usedFlags: usedFlags);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: context.appColors.primaryDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.bodyMedium(
                          'Add Attachment',
                          fontWeight: FontWeight.w700,
                          color: context.appColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AddFlagAndAttachment(model: model),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppTextLinkButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        text: 'Cancel',
                        color: context.appColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      AppOutlineButton(
                        width: 120,
                        onPressed: () {
                          if (model.flagType == null) return;
                          Navigator.of(ctx).pop(true);
                        },
                        text: 'Save',
                        color: context.appColors.primaryDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (saved == true && model.flagType != null) {
      widget.onAddAttachment?.call(model);
    }
  }

  Future<void> _confirmDeleteAttachment(
    BuildContext context,
    AttachmentModel item,
  ) async {
    final parsed = _parseFlagAndName(item);
    final name = parsed.fileName.isNotEmpty
        ? parsed.fileName
        : (item.originalName ?? 'this attachment');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Delete attachment?')),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$name"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '? This action cannot be undone.'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            AppTextLinkButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              text: "Cancel",
              color: context.appColors.textSecondary,
            ),
            AppOutlineButton(
              width: 120,
              onPressed: () => Navigator.of(ctx).pop(true),
              text: "Delete",
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    widget.onDeleteAttachment(item);
  }

  Widget _sidebarShell({
    required String header,
    required Color headerColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.08),
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
