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
  final FlagAndAttachmentModel model;
  const AddFlagAndAttachment({super.key, this.onDelete, required this.model});

  @override
  ConsumerState<AddFlagAndAttachment> createState() =>
      _AddFlagAndAttachmentState();
}

class _AddFlagAndAttachmentState extends ConsumerState<AddFlagAndAttachment> {
  FlagAndAttachmentModel get m => widget.model;

  final Widget fieldLoader = Container(
    width: 12,
    height: 12,
    margin: const EdgeInsets.only(right: 8),
    child: const CircularProgressIndicator(
      strokeWidth: 2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(filesController);
    return Column(
      children: [
        if (widget.onDelete != null)
          InkWell(
            onTap: widget.onDelete,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText.bodySmall(
                  "Remove",
                  color: Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.red[800],
                  size: 20,
                ),
              ],
            ),
          ),
        Column(
          children: [
            Container(
              child: AppDropDownField<FlagModel>(
                items: m.usedFlags == null
                    ? state.flags
                    : state.flags
                        .where((e) => !m.usedFlags!
                            .any((f) => f.id != null && f.id == e.id))
                        .toList(),
                onChanged: (item) {
                  setState(() {
                    m.flagType = item;
                  });
                },
                labelText: "Flag Type",
                hintText: "Select flag type",
                prefix: state.loadingFlag ? fieldLoader : null,
                itemBuilder: (item) {
                  return AppText.titleMedium(item?.title ?? '');
                },
                // validator: (item) {
                //   if (m.flagType == null || item == null) {
                //     return 'Please select a value';
                //   }
                //   return null;
                // },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelLarge(
                    "Attachment",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      m.attachment = await FilePickerService().pickPdf();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14.5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.secondaryLight.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.secondaryDark,
                          ),
                          const SizedBox(width: 8),
                          AppText.bodyLarge(
                            m.attachment?.name ?? "Attach File",
                            color: AppColors.secondaryLight,
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
      ],
    );
  }
}

class FlagAndAttachmentModel {
  FlagModel? flagType;
  XFile? attachment;
  List<FlagModel>? usedFlags;

  FlagAndAttachmentModel({
    this.flagType,
    this.attachment,
    this.usedFlags,
  });
}
