import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/attachment_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/attachment_picker_sheet.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddFlagAndAttachment extends ConsumerStatefulWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onAdd;
  final FlagAndAttachmentModel model;
  final bool isReadOnly;
  const AddFlagAndAttachment({
    super.key,
    this.onDelete,
    required this.model,
    this.onAdd,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<AddFlagAndAttachment> createState() =>
      _AddFlagAndAttachmentState();
}

class _AddFlagAndAttachmentState extends ConsumerState<AddFlagAndAttachment> {
  FlagAndAttachmentModel get m => widget.model;

  final Widget fieldLoader = Container(
    width: 6,
    height: 6,
    padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
    child: const CircularProgressIndicator(strokeWidth: 2),
  );

  final TextEditingController flagSearchController = TextEditingController();

  bool _isPickingAttachment = false;

  @override
  void initState() {
    super.initState();
    flagSearchController.text = m.flagType?.title ?? '';
  }

  @override
  void dispose() {
    flagSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    if (_isPickingAttachment) return;
    setState(() => _isPickingAttachment = true);

    final picked = await showAttachmentPickerSheet(context);
    if (!mounted) return;

    if (picked != null) {
      m.attachment = picked;
      m.existingAttachment = null;
    }
    setState(() => _isPickingAttachment = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(filesController);
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag Type Dropdown - Expanded
                Flexible(
                  flex: 3,
                  child: SearchDropDownField<FlagModel>(
                    controller: flagSearchController,
                    enabled: !widget.isReadOnly,
                    labelText: "Flag Type",
                    hintText: "Select flag type",
                    prefix: state.loadingFlag ? fieldLoader : null,
                    suggestionsCallback: (pattern) {
                      final available = m.usedFlags == null
                          ? state.flags
                          : state.flags
                                .where(
                                  (e) => !m.usedFlags!.any(
                                    (f) => f.id != null && f.id == e.id,
                                  ),
                                )
                                .toList();
                      final q = pattern.toLowerCase();
                      return available
                          .where(
                            (e) => (e.title ?? '').toLowerCase().contains(q),
                          )
                          .toList();
                    },
                    itemBuilder: (context, item) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: AppText.titleMedium(item.title ?? ''),
                    ),
                    onSelected: widget.isReadOnly
                        ? (item) {}
                        : (item) {
                            setState(() {
                              m.flagType = item;
                              flagSearchController.text = item.title ?? '';
                            });
                          },
                  ),
                ),

                const SizedBox(width: 8),

                // Attachment Button - Expanded
                if (!widget.isReadOnly)
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText.labelSmall(
                            "Attachment",
                            color: context.appColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: _isPickingAttachment ? null : _pickAttachment,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.secondaryLight.withValues(
                                  alpha: .5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.secondaryLight.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: Row(
                              children: [
                                _isPickingAttachment
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.secondaryDark,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.attachment,
                                        color: AppColors.secondaryDark,
                                        size: 20,
                                      ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.bodyMedium(
                                        _isPickingAttachment
                                            ? "Processing..."
                                            : "Add attachment",
                                        color: m.attachment != null
                                            ? AppColors.secondaryDark
                                            : AppColors.secondaryLight,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (m.hasAttachment)
              InkWell(
                onTap:
                    (widget.isReadOnly ||
                        !m.canDeleteExisting ||
                        _isPickingAttachment)
                    ? null
                    : _pickAttachment,
                child: Container(
                  height: 50, // Match dropdown height
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryLight.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.secondaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            AppText.bodyMedium(
                              m.attachmentDisplayName ?? "Click to add",
                              color: AppColors.secondaryDark,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isReadOnly && m.canDeleteExisting)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () {
                              m.attachment = null;
                              m.existingAttachment = null;
                              setState(() {});
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.red[800],
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!widget.isReadOnly)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.onDelete != null)
                InkWell(
                  onTap: widget.onDelete,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[800]!),
                    ),
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red[800],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        AppText.bodySmall(
                          "Remove",
                          color: Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              if (widget.onAdd != null)
                InkWell(
                  onTap: widget.onAdd,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryDark),
                    ),
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.add,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        AppText.bodySmall(
                          "Add More",
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class FlagAndAttachmentModel {
  FlagModel? flagType;
  XFile? attachment;
  AttachmentModel? existingAttachment;
  List<FlagModel>? usedFlags;

  /// Whether the existing server-side attachment may be deleted/replaced.
  /// Callers compute this from [AttachmentModel.canDelete] and pass the
  /// result in — keeping domain logic out of this generic widget model.
  bool canDeleteExisting;

  FlagAndAttachmentModel({
    this.flagType,
    this.attachment,
    this.existingAttachment,
    this.usedFlags,
    this.canDeleteExisting = true,
  });

  bool get hasAttachment => attachment != null || existingAttachment != null;

  String? get attachmentDisplayName =>
      attachment?.name ?? existingAttachment?.originalName;

  bool get isValid {
    if (flagType == null) return true;
    if (flagType != null && !hasAttachment) return false;
    return true;
  }
}
