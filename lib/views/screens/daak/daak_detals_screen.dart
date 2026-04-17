import 'dart:developer';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_attachment_card.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_correspondence_card.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum DaakAction {
  forward("Forward"),
  markNfa("Mark NFA"),
  disposeOff("Dispose Off");
  // createFile ("Create File");

  final String label;

  const DaakAction(this.label);
}

class DaakDetailsInfo {
  DaakModel daak;
  bool? openPDF;
  DaakStatus status;

  DaakDetailsInfo({
    required this.daak,
    this.openPDF = false,
    required this.status,
  });
}

class DaakDetailsScreen extends ConsumerStatefulWidget {
  final int? daakId;
  final DaakDetailsInfo daakDetailsInfo;
  const DaakDetailsScreen({
    super.key,
    required this.daakDetailsInfo,
    required this.daakId,
  });

  @override
  ConsumerState<DaakDetailsScreen> createState() => _DaakDetailsScreenState();
}

class _DaakDetailsScreenState extends ConsumerState<DaakDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController remarksController = TextEditingController();
  List<ChatParticipantModel> usersForChat = [];
  String _speechBaseText = '';
  XFile? attachment;
  DaakModel? daakDetails;
  XFile? disposeOffLetter;

  ChatParticipantModel? forwardTo;
  final TextEditingController forwardToController = TextEditingController();
  DaakAction selectedAction = DaakAction.forward;

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
                    child: OutlinedButton(
                      onPressed: () {
                        RouteHelper.pop();
                      },
                      child: const Text("Process"),
                    ),
                  ),
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
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  Future<void> fetchDetails() async {
    int? desgId = ref.read(authController).currentDesignation?.userDesgId;
    List<ChatParticipantModel> users = await ref
        .read(chatRepo)
        .getUsersForChat(desgId);
    users.removeWhere((element) => element.userDesignationId == desgId);
    setState(() {
      usersForChat = users;
    });
    DaakModel? model = await ref
        .read(daakController.notifier)
        .fetchDaakDetails(
          daakId: widget.daakId,
          status: widget.daakDetailsInfo.status,
        );
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
      if (widget.daakDetailsInfo.openPDF == true &&
          daakDetails?.incomingScanUrl != null &&
          daakDetails?.status != DaakStatus.disposedOff &&
          daakDetails?.status != DaakStatus.nfa &&
          daakDetails?.status != DaakStatus.forwarded) {
        openPDFSheet();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    ref.read(speechToTextController.notifier).stopListening();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sttState = ref.watch(speechToTextController);
    DaakMeta? meta = ref.watch(daakController).daakMeta;
    final bool showOtherAction = meta?.activeUserDesg?.role == 'deo';
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.daakDetailsInfo.daak.diaryNo}'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: collapsedPDFViewer(),
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
              AppText.headlineSmall(
                'Next Actions',
                fontWeight: FontWeight.w600,
                color: appColors.secondaryLight,
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.all(0),
                elevation: 3,
                shadowColor: appColors.shadow,
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (showOtherAction)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: DaakAction.values.map((action) {
                              final isSelected = selectedAction == action;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedAction = action);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInSine,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? appColors.primaryDark.withValues(
                                            alpha: 0.2,
                                          )
                                        : appColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? appColors.primaryDark
                                          : appColors.border,
                                    ),
                                  ),
                                  child: AppText.bodySmall(
                                    action.label,
                                    color: isSelected
                                        ? appColors.primaryDark
                                        : appColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 6),
                        AppText.titleMedium(
                          selectedAction == DaakAction.forward
                              ? 'Forward Letter'
                              : selectedAction == DaakAction.markNfa
                              ? "Mark as NFA"
                              : selectedAction == DaakAction.disposeOff
                              ? "Dispose Off Letter"
                              : "",
                          fontWeight: FontWeight.w600,
                          color: appColors.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        if (selectedAction == DaakAction.forward) ...[
                          SearchDropDownField<ChatParticipantModel>(
                            suggestionsCallback: (pattern) {
                              return usersForChat
                                  .where(
                                    (user) => (user.userTitle ?? '')
                                        .toLowerCase()
                                        .contains(pattern.toLowerCase()),
                                  )
                                  .toList();
                            },
                            onSelected: (item) {
                              forwardTo = item;
                              forwardToController.text = item.userTitle ?? '';
                              setState(() {});
                            },
                            labelText: "Forward this file to",
                            hintText: "Forward To",
                            itemBuilder: (context, item) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.titleMedium(item.userTitle ?? ''),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[400],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.yellow[600]!
                                              .withOpacity(0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: AppText.labelSmall(
                                        item.designation ?? '',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            validator: (value) {
                              if (forwardTo == null) {
                                return 'Forward to user is required';
                              }
                              return null;
                            },
                            value: forwardTo,
                            controller: forwardToController,
                            suffixIcon:
                                (forwardTo != null &&
                                    (forwardTo!.designation ?? '').isNotEmpty)
                                ? Container(
                                    width: 120,
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow[400],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.yellow[600]!
                                                  .withOpacity(0.3),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: AppText.labelSmall(
                                            forwardTo!.designation ?? '',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                        ],

                        AppTextField(
                          controller: remarksController,
                          labelText: "Remarks",
                          hintText: selectedAction == DaakAction.forward
                              ? 'Optional forwarding remarks'
                              : selectedAction == DaakAction.markNfa
                              ? "Optional closing remarks"
                              : selectedAction == DaakAction.disposeOff
                              ? "Optional disposal remarks"
                              : "Optional Remarks",
                          maxLines: 3,
                          suffixIcon: IconButton(
                            onPressed: () {
                              final notifier = ref.read(
                                speechToTextController.notifier,
                              );
                              if (sttState.isListening) {
                                notifier.stopListening();
                              } else {
                                _speechBaseText = remarksController.text.trim();
                                notifier.startListening(
                                  onWordsRecognized: (words) {
                                    if (!mounted) return;
                                    final prefix = _speechBaseText.isEmpty
                                        ? ''
                                        : '$_speechBaseText ';
                                    remarksController.text = '$prefix$words';
                                    remarksController.selection =
                                        TextSelection.collapsed(
                                          offset: remarksController.text.length,
                                        );
                                  },
                                  onError: (message) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.red[700],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            icon: Icon(
                              sttState.isListening ? Icons.mic : Icons.mic_none,
                              color: sttState.isListening
                                  ? Colors.red
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                        if (selectedAction == DaakAction.disposeOff) ...[
                          const SizedBox(height: 12),
                          attachmentCard(
                            title: "Issued Letter (Correspondence)",
                            attachment: disposeOffLetter,
                            onAttachmentChanged: (file) {
                              setState(() {
                                disposeOffLetter = file;
                              });
                            },
                            onAttachmentRemoved: () {
                              setState(() {
                                disposeOffLetter = null;
                              });
                            },
                          ),
                          AppText.labelSmall(
                            "This is optional",
                            color: appColors.textSecondary,
                          ),
                        ],
                        const SizedBox(height: 8),
                        attachmentCard(
                          title: "Attachment",
                          attachment: attachment,
                          onAttachmentChanged: (file) {
                            setState(() {
                              attachment = file;
                            });
                          },
                          onAttachmentRemoved: () {
                            setState(() {
                              attachment = null;
                            });
                          },
                        ),
                        AppText.labelSmall(
                          "pdf, docx, jpg, jpeg, png. Max size: 10MB",
                          color: appColors.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        selectedAction == DaakAction.forward
                            ? actionButton(
                                text: "Forward",
                                onPressed: () async {
                                  ref
                                      .read(speechToTextController.notifier)
                                      .stopListening();
                                  if (formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }
                                  if (forwardTo == null) {
                                    Toast.error(
                                      message: "Forward to user is required",
                                    );
                                    return;
                                  }
                                  await ref
                                      .read(daakController.notifier)
                                      .forwardDaak(
                                        daakId: widget.daakId,
                                        fwdToDesId:
                                            forwardTo?.userDesignationId,
                                        remarks:
                                            remarksController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : remarksController.text.trim(),
                                        supportingAttachment: attachment,
                                      );
                                },
                              )
                            : selectedAction == DaakAction.markNfa
                            ? actionButton(
                                text: "NFA / Archive",
                                onPressed: () async {
                                  ref
                                      .read(speechToTextController.notifier)
                                      .stopListening();

                                  await ref
                                      .read(daakController.notifier)
                                      .markNFA(
                                        daakId: widget.daakId,
                                        remarks:
                                            remarksController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : remarksController.text.trim(),
                                        supportingAttachment: attachment,
                                      );
                                },
                              )
                            : selectedAction == DaakAction.disposeOff
                            ? actionButton(
                                text: "Dispose Off",
                                color: AppColors.error,
                                onPressed: () async {
                                  ref
                                      .read(speechToTextController.notifier)
                                      .stopListening();

                                  await ref
                                      .read(daakController.notifier)
                                      .disposeOff(
                                        daakId: widget.daakId,
                                        remarks:
                                            remarksController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : remarksController.text.trim(),
                                        supportingAttachment: attachment,
                                        issuedLetter: disposeOffLetter,
                                      );
                                },
                              )
                            : const SizedBox.shrink(),
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
                color: appColors.secondaryLight,
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: daakDetails?.movements?.length ?? 0,
                  itemBuilder: (context, index) => DaakCorrespondenceCard(
                    movement: daakDetails?.movements?[index],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppText.headlineSmall(
                'Attachments',
                fontWeight: FontWeight.w600,
                color: appColors.secondaryLight,
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: daakDetails?.attachments?.length ?? 0,
                  itemBuilder: (context, index) => DaakAttachmentCard(
                    attachment: daakDetails?.attachments?[index],
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
    final appColors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appColors.surfaceMuted,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
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
            child: Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 32),
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
          trailing: AppTextLinkButton(onPressed: openPDFSheet, text: "Open"),
        ),
      ),
    );
  }

  Widget attachmentCard({
    required String title,
    required XFile? attachment,
    required Function(XFile? file) onAttachmentChanged,
    required Function() onAttachmentRemoved,
    List<String> allowedExtensions = const [
      'pdf',
      'docx',
      'jpg',
      'jpeg',
      'png',
    ],
  }) {
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.labelLarge(
          title,
          color: appColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final files = await FilePickerService().pickFiles(
              allowedExtensions: allowedExtensions,
            );
            attachment = files.isNotEmpty ? files.first : null;
            onAttachmentChanged(attachment);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: appColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: attachment != null
                    ? appColors.primaryDark
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_outlined,
                  color: appColors.primaryDark,
                  size: 28,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText.titleSmall(
                    attachment != null
                        ? attachment!.name
                        : 'Select file to attach',
                  ),
                ),
                if (attachment != null)
                  GestureDetector(
                    onTap: () {
                      attachment = null;
                      onAttachmentRemoved();
                    },
                    child: const Icon(Icons.close, size: 20, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget actionButton({
    required String text,
    required VoidCallback onPressed,
    Color color = AppColors.primaryDark,
  }) {
    return AppSolidButton(
      onPressed: onPressed,
      text: text,
      width: double.infinity,
      backgroundColor: color,
    );
  }
}
