import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_correspondence_card.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slide_up_panel/slide_up_panel.dart';

class DaakDetailsInfo {
  DaakModel? daak;
  bool? openPDF;

  DaakDetailsInfo({this.daak, this.openPDF});
}

class DaakDetailsScreen extends ConsumerStatefulWidget {
  final int? daakId;
  final DaakDetailsInfo daakDetailsInfo;
  const DaakDetailsScreen(
      {super.key, required this.daakDetailsInfo, required this.daakId});

  @override
  ConsumerState<DaakDetailsScreen> createState() => _DaakDetailsScreenState();
}

class _DaakDetailsScreenState extends ConsumerState<DaakDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController remarksController = TextEditingController();
  XFile? attachment;

  openPDFSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.86,
          child: const ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: PdfViewer(
              url: "https://icseindia.org/document/sample.pdf",
              title: "Daak PDF title",
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    if (widget.daakDetailsInfo.openPDF == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openPDFSheet();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideUpPanel(
      overLay: false,
      rounded: true,
      backGroundWidget: Scaffold(
        appBar: AppBar(
          title: Text('Daak Details - ID: ${widget.daakId}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.headlineSmall(
                'Next Actions',
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.all(0),
                elevation: 3,
                shadowColor: AppColors.secondaryDark.withValues(alpha: .1),
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Expanded(
                            //   child:
                            //       AppSolidButton(onPressed: () {}, text: "Forward"),
                            // ),
                            // const SizedBox(width: 8),
                            Expanded(
                              child: AppOutlineButton(
                                onPressed: () {},
                                text: "Mark NFA",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppOutlineButton(
                                  onPressed: () {}, text: "Create File"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppText.titleMedium(
                          'Forward Letter',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        AppDropDownField<String>(
                          items: const [
                            "Section A",
                            "Section B",
                            "Section C",
                            "Section D",
                          ],
                          onChanged: (item) async {},
                          labelText: "Forward this file to",
                          hintText: "Forward To",

                          //buttonHeight: forwardTo == null ? null : 57,
                          itemBuilder: (item) {
                            return AppText.titleMedium(
                              item ?? '',
                              fontWeight: FontWeight.w600,
                            );
                            // return Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     AppText.titleMedium(item?.userTitle ?? ''),

                            //     Container(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 6, vertical: 1),
                            //       decoration: BoxDecoration(
                            //         color: Colors.yellow[400],
                            //         borderRadius: BorderRadius.circular(8),
                            //         border: Border.all(
                            //           color: Colors.yellow[600]!.withOpacity(0.3),
                            //           width: 0.5,
                            //         ),
                            //       ),
                            //       child: AppText.labelSmall(
                            //         item?.designationTitle ?? '',
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.w500,
                            //         fontSize: 10, // Smaller font
                            //       ),
                            //     )
                            //   ],
                            // );
                          },

                          validator: (item) {
                            // if (forwardTo == null || item == null) {
                            //   return 'Please select a value';
                            // }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: remarksController,
                          labelText: "Remarks",
                          hintText: "Optional forwarding remarks",
                          maxLines: 3,
                          suffixIcon: IconButton(
                            onPressed: () {
                              remarksController.clear();
                            },
                            icon: const Icon(
                              Icons.mic,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppText.labelLarge(
                          "Attachment",
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            attachment = await FilePickerService().pickPdf();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.appBarColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attach_file_outlined,
                                  color: AppColors.primaryDark,
                                  size: 28,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: AppText.titleSmall(
                                  attachment != null
                                      ? attachment!.name
                                      : 'Select file to attach',
                                ))
                              ],
                            ),
                          ),
                        ),
                        AppText.labelSmall(
                          "pdf, docx, jpg, jpeg, png. Max size: 10MB",
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 6),
                        AppSolidButton(
                          onPressed: () {},
                          text: "Forward",
                          width: double.infinity,
                          backgroundColor: AppColors.primaryDark,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppText.headlineSmall(
                'Previous Correspondences',
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(height: 4),
              ...List.generate(
                2,
                (index) => DaakCorrespondenceCard(
                  status: index % 2 == 0 ? "Forwarded" : "Received",
                  statusColor: index % 2 == 0 ? Colors.orange : Colors.green,
                  dateTime: '2024-06-15 10:00 AM',
                  sender: 'Sender ${index + 1}',
                  department: 'Department ${index + 1}',
                  message: 'This is a message for correspondence ${index + 1}.',
                  isBold: index % 2 == 0,
                ),
              ),
              const SizedBox(height: 116),
            ],
          ),
        ),
      ),
      sliderWidget: collapsedPDFViewer(),
      maxHeight: 108,
      minHeight: 108,
      collapseOnBackgroundTap: true,
    );
  }

  Widget collapsedPDFViewer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.appBarColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: .2),
            blurRadius: 8,
            offset: const Offset(0, -2.5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: openPDFSheet,
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.red[700],
              size: 32,
            ),
          ),
          horizontalTitleGap: 12,
          titleAlignment: ListTileTitleAlignment.top,
          title: AppText.titleMedium(
            'Daak PDF title',
            fontWeight: FontWeight.w600,
          ),
          subtitle: AppText.labelLarge(
            'Received on: 2024-06-15',
          ),
          trailing: AppTextLinkButton(
            onPressed: openPDFSheet,
            text: "Open",
          ),
        ),
      ),
    );
  }
}
