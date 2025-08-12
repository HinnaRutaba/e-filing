import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_drop_down_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFlagAndAttachment extends StatefulWidget {
  final VoidCallback? onDelete;
  const AddFlagAndAttachment({super.key, this.onDelete});

  @override
  State<AddFlagAndAttachment> createState() => _AddFlagAndAttachmentState();
}

class _AddFlagAndAttachmentState extends State<AddFlagAndAttachment> {
  String? selectedSection;
  String? forwardTo;
  String? flagType;
  XFile? attachment;

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            Expanded(
              child: AppDropDownField(
                items: ['Section A', 'Section B', 'Section C'],
                onChanged: (item) {
                  setState(() {
                    selectedSection = item;
                  });
                },
                labelText: "File Type",
                hintText: "Select file type",
                itemBuilder: (item) {
                  return AppText.titleMedium(item ?? '');
                },
                validator: (item) {
                  if (selectedSection == null || item == null || item.isEmpty) {
                    return 'Please select a value';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppDropDownField(
                items: ['Person A', 'Person B', 'Person C'],
                onChanged: (item) {
                  setState(() {
                    forwardTo = item;
                  });
                },
                labelText: "Forward to",
                hintText: "Forward this file to",
                itemBuilder: (item) {
                  return AppText.titleMedium(item ?? '');
                },
                validator: (item) {
                  if (forwardTo == null || item == null || item.isEmpty) {
                    return 'Please select a value';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppDropDownField(
                items: ['A', 'B', 'C', 'D', 'E', 'F'],
                onChanged: (item) {
                  setState(() {
                    forwardTo = item;
                  });
                },
                labelText: "Flag Type",
                hintText: "Select flag type",
                itemBuilder: (item) {
                  return AppText.titleMedium(item ?? '');
                },
                validator: (item) {
                  if (forwardTo == null || item == null || item.isEmpty) {
                    return 'Please select a value';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                      attachment = await FilePickerService().pickPdf();
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
                            attachment?.name ?? "Attach File",
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
