import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
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

class DaakDetailsInfo {
  DaakModel daak;
  bool? openPDF;
  DaakStatus status;

  DaakDetailsInfo(
      {required this.daak, this.openPDF = false, required this.status});
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
  DaakModel? daakDetails;

  DepartmentUser? forwardTo;

  openPDFSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PDF Sheet",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.86,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: PdfViewer(
                url: daakDetails?.incomingScanUrl,
                title: "Daak PDF title",
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AppTextLinkButton(
                      onPressed: () {
                        RouteHelper.pop();
                      },
                      text: "Process",
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
    );
  }

  Future<void> fetchDetails() async {
    DaakModel? model = await ref.read(daakController.notifier).fetchDaakDetails(
        daakId: widget.daakId, status: widget.daakDetailsInfo.status);
    setState(() {
      daakDetails = model;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        daakDetails = widget.daakDetailsInfo.daak;
      });
      fetchDetails();
      if (widget.daakDetailsInfo.openPDF == true) {
        openPDFSheet();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text('${widget.daakDetailsInfo.daak.diaryNo}'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            color: AppColors.appBarColor,
            // height: 120,
            child: collapsedPDFViewer(),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //const SizedBox(height: 108),
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
                        AppDropDownField<DepartmentUser>(
                          items: ref
                                  .read(daakController)
                                  .daakMeta
                                  ?.departmentUsers ??
                              [],
                          onChanged: (item) async {
                            forwardTo = item;
                            setState(() {});
                          },
                          labelText: "Forward this file to",
                          hintText: "Forward To",

                          //buttonHeight: forwardTo == null ? null : 57,
                          itemBuilder: (item) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.titleMedium(item?.name ?? ''),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[400],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          Colors.yellow[600]!.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: AppText.labelSmall(
                                    item?.designation ?? '',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10, // Smaller font
                                  ),
                                )
                              ],
                            );
                          },

                          validator: (item) {
                            if (forwardTo == null || item == null) {
                              return 'Please select a value';
                            }
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
                            final files = await FilePickerService().pickFiles(
                              allowedExtensions: [
                                'pdf',
                                'docx',
                                'jpg',
                                'jpeg',
                                'png',
                              ],
                            );
                            attachment = files.isNotEmpty ? files.first : null;
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
              Container(
                height: 300,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: daakDetails?.movements?.length ?? 0,
                  itemBuilder: (context, index) => DaakCorrespondenceCard(
                    movement: daakDetails?.movements?[index],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget collapsedPDFViewer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.appBarColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: .2),
            blurRadius: 2,
            offset: const Offset(0, 2.5),
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
            daakDetails?.subject ?? "Daak PDF title",
            fontWeight: FontWeight.w600,
          ),
          subtitle: daakDetails?.status == DaakStatus.forwarded
              ? AppText.labelLarge(
                  'Received at: ${DateTimeHelper.dateFormatSlashWithTime(daakDetails?.forwardDetails?.lastForward?.forwardedAt)}',
                )
              : AppText.labelLarge(
                  'Letter date: ${DateTimeHelper.dateFormatSlashWithTime(daakDetails?.letterDate)}',
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
