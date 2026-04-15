import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentsSection extends StatefulWidget {
  final XFile? mainPdf;
  final List<FlagAndAttachmentModel> attachments;
  final VoidCallback onViewMainPdf;
  final ValueChanged<FlagAndAttachmentModel> onViewAttachment;
  final ValueChanged<FlagAndAttachmentModel> onDeleteAttachment;

  const AttachmentsSection({
    super.key,
    required this.mainPdf,
    required this.attachments,
    required this.onViewMainPdf,
    required this.onViewAttachment,
    required this.onDeleteAttachment,
  });

  @override
  State<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<AttachmentsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final flagAttachments = widget.attachments
        .where((e) => e.flagType != null || e.attachment != null)
        .toList(growable: false);
    final hasMain = widget.mainPdf != null;
    final isEmpty = !hasMain && flagAttachments.isEmpty;

    return _sidebarShell(
      header: 'Attachments',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMain) ...[
            _attachmentRow(
              label: 'Main Summary PDF',
              fileName: widget.mainPdf!.name,
              isMain: true,
              onView: widget.onViewMainPdf,
            ),
            if (flagAttachments.isNotEmpty) const SizedBox(height: 8),
          ],
          for (int i = 0; i < flagAttachments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _attachmentRow(
              label: flagAttachments[i].flagType?.title ?? '?',
              fileName: flagAttachments[i].attachment?.name,
              onView: () => widget.onViewAttachment(flagAttachments[i]),
              onDelete: () => _confirmDeleteAttachment(
                context,
                flagAttachments[i],
              ),
            ),
          ],
          if (isEmpty)
            AppText.bodySmall(
              'No attachments.',
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _attachmentRow({
    required String label,
    String? fileName,
    bool isMain = false,
    required VoidCallback onView,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 18,
              color: AppColors.error,
            )
          else
            Container(
              width: 26,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: AppText.bodySmall(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryDark,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.bodySmall(
              isMain ? label : (fileName ?? label),
              color: AppColors.textPrimary,
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
                color: Colors.red[700],
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
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 13,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAttachment(
    BuildContext context,
    FlagAndAttachmentModel item,
  ) async {
    final name =
        item.attachment?.name ?? item.flagType?.title ?? 'this attachment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red[700]),
              const SizedBox(width: 10),
              const Expanded(child: Text('Delete attachment?')),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
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
              color: Colors.grey[700],
            ),
            AppOutlineButton(
              width: 120,
              onPressed: () => Navigator.of(ctx).pop(true),
              text: "Delete",
              color: Colors.red[500]!,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
