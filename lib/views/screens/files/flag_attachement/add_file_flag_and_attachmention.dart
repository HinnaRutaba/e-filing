import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_drop_down_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddFlagAndAttachment extends ConsumerStatefulWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onAdd;
  final FlagAndAttachmentModel model;
  const AddFlagAndAttachment({
    super.key,
    this.onDelete,
    required this.model,
    this.onAdd,
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
                  child: AppDropDownField<FlagModel>(
                    items: m.usedFlags == null
                        ? state.flags
                        : state.flags
                              .where(
                                (e) => !m.usedFlags!.any(
                                  (f) => f.id != null && f.id == e.id,
                                ),
                              )
                              .toList(),
                    onChanged: (item) {
                      setState(() {
                        m.flagType = item;
                      });
                    },
                    labelText: "Flag Type",
                    hintText: "Select flag type",
                    prefix: state.loadingFlag ? fieldLoader : null,
                    padding: const EdgeInsets.fromLTRB(-7, 0, 0, 0),
                    itemBuilder: (item) {
                      return AppText.titleMedium(item?.title ?? '');
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Attachment Button - Expanded
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
                        onTap: () async {
                          final files = await FilePickerService().pickFiles();
                          m.attachment = files.isNotEmpty ? files.first : null;
                          setState(() {});
                        },
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
                              const Icon(
                                Icons.attachment,
                                color: AppColors.secondaryDark,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodyMedium(
                                      "Add attachment",
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
            if (m.attachment != null)
              InkWell(
                onTap: () async {
                  final files = await FilePickerService().pickFiles();
                  m.attachment = files.isNotEmpty ? files.first : null;
                  setState(() {});
                },
                child: Container(
                  height: 50, // Match dropdown height
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.5),
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
                              m.attachment?.name ?? "Click to add",
                              color: m.attachment != null
                                  ? AppColors.secondaryDark
                                  : AppColors.secondaryLight,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      if (m.attachment != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () {
                              m.attachment = null;
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
  List<FlagModel>? usedFlags;

  FlagAndAttachmentModel({this.flagType, this.attachment, this.usedFlags});

  bool get isValid {
    if (flagType == null) return true;
    if (flagType != null && attachment == null) return false;
    return true;
  }
}
