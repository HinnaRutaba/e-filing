import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/models/file/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/summaries/create_summary_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_preview_sheet.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/gradient_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efiling_balochistan/views/widgets/html_editor.dart';

class CreateSummaryScreen extends ConsumerStatefulWidget {
  final int? summaryId;
  const CreateSummaryScreen({super.key, this.summaryId});

  @override
  ConsumerState<CreateSummaryScreen> createState() =>
      _CreateSummaryScreenState();
}

class _CreateSummaryScreenState extends ConsumerState<CreateSummaryScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController departmentSearchController =
      TextEditingController();

  final HtmlEditorController quillEditorController = HtmlEditorController();

  final CreateSummaryModel _model = CreateSummaryModel();

  List<FlagModel> allFlags = [];

  int _openSection = 0;
  bool _secretaryRemarksExpanded = true;

  Future fetchData() async {
    final controller = ref.read(filesController.notifier);

    allFlags = await controller.getFlags();
  }

  @override
  void initState() {
    super.initState();
    subjectController.text = _model.subject;
    subjectController.addListener(() {
      _model.subject = subjectController.text;
    });
    dateController.text = DateTimeHelper.datFormatSlash(_model.summaryDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  void dispose() {
    subjectController.dispose();
    dateController.dispose();
    departmentSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.summaryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _model.summaryDate = picked;
        dateController.text = DateTimeHelper.datFormatSlash(picked);
      });
    }
  }

  addAttachement() {
    setState(() {
      _model.attachments.add(
        FlagAndAttachmentModel(
          usedFlags: [
            ..._model.attachments.map((e) => e.flagType ?? FlagModel()),
          ],
        ),
      );
    });
  }

  Future<void> _pickMainPdf() async {
    final files = await FilePickerService().pickFiles();
    if (files.isNotEmpty) {
      setState(() => _model.mainPdf = files.first);
    }
  }

  Future<String> _currentSummaryHtml() async {
    if (_openSection == 0) {
      _model.summaryHtml = await quillEditorController.getText();
    }
    return _model.summaryHtml;
  }

  Future<void> _changeSection(int newSection) async {
    if (_openSection == 0 && newSection != 0) {
      _model.summaryHtml = await quillEditorController.getText();
    }
    if (!mounted) return;
    setState(() => _openSection = newSection);
  }

  Future<void> _onSend() async {
    HelperUtils.hideKeyboard(context);
    if (!formKey.currentState!.validate()) return;
    if (_model.department == null) {
      Toast.error(message: "Please select a target department");
      return;
    }
    if (_model.mainPdf == null) {
      Toast.error(message: "Please attach the Main Summary PDF");
      return;
    }
    final content = await _currentSummaryHtml();
    if (content.trim().isEmpty) {
      Toast.error(message: "Please write the summary content");
      return;
    }
    if (isSecretary) {
      if (_model.creatorSignatureData == null ||
          _model.creatorSignatureData!.isEmpty) {
        final signature = await _captureSignature();
        if (!mounted) return;
        if (signature == null) return;
        _model.creatorSignatureData = signature;
      }
    }

    final incompleteFlags = _model.attachments.where(
      (e) => e.flagType != null && e.attachment == null,
    );
    if (incompleteFlags.isNotEmpty) {
      Toast.error(
        message:
            "One or more flags are missing attachments. Add a file and try again.",
      );
      return;
    }
    final confirmed = await _confirmSend();
    if (!confirmed || !mounted) return;
    Toast.show(message: "Summary ready to send");
  }

  Future<String?> _captureSignature() async {
    final padController = SignaturePadController();
    final bytes = await showModalBottomSheet<Uint8List>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final appColors = ctx.appColors;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.headlineSmall("Add your signature"),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText.bodySmall(
                  "Sign in the box below to authorize this summary.",
                  color: appColors.textSecondary,
                ),
                const SizedBox(height: 12),
                SignaturePad(controller: padController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlineButton(
                        text: "Cancel",
                        onPressed: () => Navigator.of(ctx).pop(),
                        color: appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppSolidButton(
                        text: "Save",
                        onPressed: () async {
                          final result = await padController.toPngBytes();
                          if (!ctx.mounted) return;
                          if (result == null) {
                            Toast.error(message: "Please sign before saving");
                            return;
                          }
                          Navigator.of(ctx).pop(result);
                        },
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (bytes == null) return null;
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }

  int get _addedFlagsCount => _model.addedFlagsCount;

  int get _correspondenceCount => _model.correspondenceCount;

  bool get _step0Complete => _model.isSummaryDetailsComplete;

  bool get _step1Complete => _model.isFlagsStepComplete;

  bool get _step2Complete => _model.isCorrespondenceStepComplete;

  bool get _hasUnsavedChanges => _model.hasAnyInput;

  bool get isSecretary {
    final role = ref.read(summariesController).meta?.activeUserDesg?.roleEnum;
    return role == ActiveUserDesgRole.secretary;
  }

  Future<void> _handleBack(bool didPop) async {
    if (didPop) return;

    if (!isSecretary || !_hasUnsavedChanges) {
      if (mounted) RouteHelper.pop();
      return;
    }
    final save = await _confirmSaveDraft();
    if (!mounted) return;
    if (save == null) return;
    if (save) {
      _model.summaryHtml = await quillEditorController.getText();
      if (!mounted) return;
      await ref
          .read(summariesController.notifier)
          .secretaryStoreSummary(createSummaryModel: _model, isDraft: true);
      return;
    }
    RouteHelper.pop();
  }

  Future<bool?> _confirmSaveDraft() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final appColors = ctx.appColors;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: appColors.textSecondary,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.12,
                      ),
                    ),
                    child: Icon(
                      Icons.save_outlined,
                      size: 30,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AppText.headlineSmall(
                  "Save as draft?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppText.bodyMedium(
                  "You have unsaved changes. Would you like to save this summary as a draft so you can continue later?",
                  textAlign: TextAlign.center,
                  color: appColors.textSecondary,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlineButton(
                        text: "Cancel",
                        onPressed: () => Navigator.of(ctx).pop(false),
                        color: appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppSolidButton(
                        text: "Save",
                        onPressed: () => Navigator.of(ctx).pop(true),
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmSend() async {
    final flagsCount = _addedFlagsCount;
    final correspondenceCount = _correspondenceCount;
    final missing = <String>[];
    if (flagsCount == 0) missing.add('Flags');
    if (correspondenceCount == 0) missing.add('Local Correspondence');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: AppText.headlineSmall("Send Summary?")),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      RouteHelper.pop();
                    },
                    child: Icon(
                      Icons.clear,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),

              Divider(color: context.appColors.border, height: 40),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _confirmRow(
                icon: Icons.flag_outlined,
                label: 'Flags',
                value: flagsCount == 0 ? 'None added' : '$flagsCount added',
                muted: flagsCount == 0,
              ),
              const SizedBox(height: 12),
              _confirmRow(
                icon: Icons.folder_shared_outlined,
                label: 'Local Correspondence',
                value: correspondenceCount == 0
                    ? 'None added'
                    : '$correspondenceCount added '
                          '(${_model.linkedDaak.length} daak, ${_model.linkedFiles.length} files)',
                muted: correspondenceCount == 0,
              ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 14),
                AppText.bodyMedium(
                  missing.length == 2
                      ? 'You have not added any Flags or Local Correspondence. Do you still want to send this summary?'
                      : 'You have not added any ${missing.first}. Do you still want to send this summary?',
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            AppOutlineButton(
              onPressed: () {
                RouteHelper.pop();
              },
              text: "Cancel",
              color: context.appColors.textSecondary,
            ),

            AppSolidButton(
              onPressed: () {
                RouteHelper.pop();
                final controller = ref.read(summariesController.notifier);
                if (isSecretary) {
                  controller.secretaryStoreSummary(
                    createSummaryModel: _model,
                    isDraft: false,
                  );
                } else {
                  controller.deoStoreDraftSummary(createSummaryModel: _model);
                }
              },
              text: "Send",
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _confirmRow({
    required IconData icon,
    required String label,
    required String value,
    bool muted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.4),
        ),
        color: context.appColors.secondaryLight.withValues(alpha: 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: muted ? Colors.grey[600] : context.appColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleSmall(label),
                AppText.bodySmall(
                  value,
                  color: muted
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey[800],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPreview() async {
    HelperUtils.hideKeyboard(context);
    final content = await _currentSummaryHtml();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      builder: (ctx) => SummaryPreviewSheet(
        content: content,
        department: _model.department?.title,
        summaryDate: _model.summaryDate,
        subject: subjectController.text.trim(),
        mainPdf: _model.mainPdf,
        attachments: _model.attachments,
        linkedDaak: _model.linkedDaak,
        linkedFiles: _model.linkedFiles,
        onSubmit: _onSend,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handleBack(didPop),
      child: GradientScaffold(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: AppText.headlineSmall(
              "Create Summary",
              textAlign: TextAlign.left,
            ),
            scrolledUnderElevation: 0,
          ),

          body: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: _secretaryRemarksAlert(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _expandableSection(
                          index: 0,
                          icon: Icons.description_outlined,
                          title: "Summary Details",
                          subtitle: "Subject, date, department and content",
                          child: _summaryDetailsBody(),
                        ),
                        _expandableSection(
                          index: 1,
                          icon: Icons.flag_outlined,
                          title: "Flags",
                          subtitle: "Attach supporting flags for this summary",
                          child: _flagsBody(),
                        ),
                        _expandableSection(
                          index: 2,
                          icon: Icons.folder_shared_outlined,
                          title: "Local Correspondence",
                          subtitle:
                              "Link references from earlier correspondence",
                          child: _localCorrespondenceBody(),
                        ),
                        if (_openSection == -1) ...[
                          const SizedBox(height: 4),
                          _stepperOverview(),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _secretaryRemarksAlert() {
    return Visibility(
      visible: false,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: context.appColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.appColors.warning.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(
                () => _secretaryRemarksExpanded = !_secretaryRemarksExpanded,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: context.appColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText.titleMedium(
                        "Secretary Remarks",
                        color: context.appColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _secretaryRemarksExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.appColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _secretaryRemarksExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.titleSmall(
                                      "Secretary Name",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    AppText.bodySmall("(Home Departmentt)"),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: context.appColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  AppText.labelSmall(
                                    DateTimeHelper.datFormatSlash(
                                      DateTime.now(),
                                    ),
                                    color: context.appColors.textSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Remarks added by secretary",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 4),
                          AppText.labelMedium(
                            "Make the ammendments suggested by secreatry and resend",
                            color: context.appColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainPdfPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.labelLarge(
              "Main Summary PDF",
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            AppText.headlineSmall(
              ' *',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: _pickMainPdf,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.appColors.secondaryLight.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(10),
              color: context.appColors.surfaceMuted,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  color: _model.mainPdf != null
                      ? Colors.red[400]
                      : context.appColors.secondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText.bodyMedium(
                    _model.mainPdf?.name ?? "Choose file",
                    color: _model.mainPdf != null
                        ? context.appColors.secondaryLight
                        : context.appColors.secondaryLight,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (_model.mainPdf != null)
                  InkWell(
                    onTap: () => setState(() => _model.mainPdf = null),
                    child: Icon(
                      Icons.cancel,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.upload_file,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _richTextEditor() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.appColors.secondaryLight.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: HtmlEditor(
          controller: quillEditorController,
          initialHtml: _model.summaryHtml,
          hint: "Write summary content here…",
          height: 400,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expandable section shell + bodies
  // ---------------------------------------------------------------------------

  Widget _expandableSection({
    required int index,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final isOpen = _openSection == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)
              : context.appColors.secondaryLight.withValues(alpha: 0.4),
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
            onTap: () => _changeSection(isOpen ? -1 : index),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        icon,
                        size: 20,
                        // color: context.appColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleMedium(
                          title,
                          //color: context.appColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          AppText.bodySmall(
                            subtitle,
                            color: context.appColors.textSecondary,
                            fontSize: 11,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText.bodySmall(
                      'Step ${index + 1}',
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(
                          height: 1,
                          color: context.appColors.secondaryLight.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        child,
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _summaryDetailsBody() {
    final dateField = AppTextField(
      controller: dateController,
      labelText: "Summary Date",
      hintText: "Select date",
      readOnly: true,
      isMandatory: true,
      suffixIcon: const Icon(Icons.calendar_month_sharp),
      onTap: _pickDate,
      validator: Validators.dateValidator,
    );

    final departments =
        ref.watch(summariesController).meta?.departments ?? const [];
    final departmentField = SearchDropDownField<DepartmentModel>(
      controller: departmentSearchController,
      labelText: "Target Department",
      hintText: "Search department",
      isMandatory: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: context.appColors.secondaryLight.withValues(alpha: 0.5),
        ),
      ),
      suggestionsCallback: (pattern) {
        final q = pattern.toLowerCase();
        return departments
            .where((d) => (d.title ?? '').toLowerCase().contains(q))
            .toList();
      },
      itemBuilder: (context, item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: AppText.titleMedium(item.title ?? ''),
      ),
      onSelected: (item) {
        setState(() {
          _model.department = item;
          departmentSearchController.text = item.title ?? '';
        });
      },
      validator: (_) {
        if (_model.department == null) {
          return 'Please select a department';
        }
        return null;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: subjectController,
          labelText: "Summary Subject",
          hintText: "Enter subject",
          isMandatory: true,
          validator: Validators.notEmptyValidator,
        ),
        const SizedBox(height: 12),
        if (context.isMobile) ...[
          dateField,
          const SizedBox(height: 12),
          departmentField,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: departmentField),
              const SizedBox(width: 12),
              Expanded(child: dateField),
            ],
          ),
        const SizedBox(height: 12),
        _mainPdfPicker(),
        const SizedBox(height: 16),
        AppText.labelLarge(
          "Content",
          color: context.appColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        const SizedBox(height: 6),
        _richTextEditor(),
        const SizedBox(height: 16),
        _sectionActions(nextStep: 1, continueLabel: "Add Flags"),
      ],
    );
  }

  Widget _flagsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          itemCount: _model.attachments.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Divider(
            height: 32,
            color: context.appColors.secondaryLight.withValues(alpha: .5),
          ),
          itemBuilder: (ctx, i) {
            final model = _model.attachments[i];
            return AddFlagAndAttachment(
              key: ValueKey(model),
              model: model,
              onDelete: _model.attachments.length > 1
                  ? () => setState(() => _model.attachments.removeAt(i))
                  : null,
              onAdd: addAttachement,
            );
          },
        ),
        if (_model.attachments.isEmpty)
          Row(
            children: [
              InkWell(
                onTap: addAttachement,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.appColors.primaryDark),
                  ),
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.add,
                        color: context.appColors.primaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      AppText.bodySmall(
                        "Add More",
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        _sectionActions(
          previousStep: 0,
          nextStep: 2,
          continueLabel: "Add Correspondence",
        ),
      ],
    );
  }

  Widget _localCorrespondenceBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.bodySmall(
          "Link any earlier correspondence received locally that relates to this summary.",
          color: context.appColors.textSecondary,
        ),
        const SizedBox(height: 8),
        _linkSubsectionHeader(
          icon: Icons.mail_outline_rounded,
          title: "Link Daak Letters",
          actionLabel: "Add Daak",
          onAdd: _openDaakPicker,
        ),
        const SizedBox(height: 8),
        if (_model.linkedDaak.isEmpty)
          _emptyLinkPlaceholder("No daak linked yet")
        else
          _linkedItemsLayout(
            items: [for (final d in _model.linkedDaak) _linkedDaakTile(d)],
          ),
        const SizedBox(height: 12),
        _linkSubsectionHeader(
          icon: Icons.folder_outlined,
          title: "Link Files",
          actionLabel: "Add File",
          onAdd: _openFilePicker,
        ),
        const SizedBox(height: 8),
        if (_model.linkedFiles.isEmpty)
          _emptyLinkPlaceholder("No files linked yet")
        else
          _linkedItemsLayout(
            items: [for (final f in _model.linkedFiles) _linkedFileTile(f)],
          ),
        const SizedBox(height: 16),
        _sectionActions(previousStep: 1),
      ],
    );
  }

  Widget _linkSubsectionHeader({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: context.appColors.secondaryLight),
        const SizedBox(width: 6),
        Expanded(
          child: AppText.titleSmall(
            title,
            color: context.appColors.secondaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppOutlineButton(
          onPressed: onAdd,
          text: actionLabel,
          icon: Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ],
    );
  }

  Widget _linkedItemsLayout({required List<Widget> items}) {
    if (context.isMobile) {
      return Column(children: items);
    }
    const spacing = 8.0;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 0,
          children: [
            for (final item in items) SizedBox(width: itemWidth, child: item),
          ],
        );
      },
    );
  }

  Widget _emptyLinkPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.4),
        ),
        color: context.appColors.cardColorLight,
      ),
      alignment: Alignment.center,
      child: AppText.bodySmall(text, color: context.appColors.textSecondary),
    );
  }

  Widget _linkedDaakTile(DaakModel daak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.5),
        ),
        color: context.appColors.secondaryLight.withValues(alpha: 0.02),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.mail_outline_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  daak.diaryNo ?? daak.letterNo ?? '—',
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
                if ((daak.subject ?? '').isNotEmpty)
                  AppText.bodySmall(
                    daak.subject!,
                    color: context.appColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => setState(() => _model.linkedDaak.remove(daak)),
            icon: Icon(
              Icons.cancel,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkedFileTile(FileModel file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.5),
        ),
        color: context.appColors.secondaryLight.withValues(alpha: 0.02),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.folder_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  file.referenceNo ?? file.barcode ?? '—',
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
                if ((file.subject ?? '').isNotEmpty)
                  AppText.bodySmall(
                    file.subject!,
                    color: context.appColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => setState(() => _model.linkedFiles.remove(file)),
            icon: Icon(
              Icons.cancel,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDaakPicker() async {
    HelperUtils.hideKeyboard(context);
    ref.read(daakController.notifier).loadData(isInitailLoad: true);
    final result = await showModalBottomSheet<List<DaakModel>>(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => _LinkPickerSheet<DaakModel>(
        title: "Link Daak Letters",
        itemsBuilder: (ref) => ref.watch(daakController).allDaak,
        isLoadingBuilder: (ref) => ref.watch(daakController).isLoading,
        alreadyLinked: List.of(_model.linkedDaak),
        keyOf: (d) => d.id,
        match: (d, q) =>
            (d.diaryNo ?? '').toLowerCase().contains(q) ||
            (d.letterNo ?? '').toLowerCase().contains(q) ||
            (d.subject ?? '').toLowerCase().contains(q) ||
            (d.sourceDepartment ?? '').toLowerCase().contains(q),
        tileBuilder: (ctx, d, selected) => _pickerTile(
          icon: Icons.mail_outline_rounded,
          primary: d.diaryNo ?? d.letterNo ?? '—',
          secondary: d.subject ?? '',
          tertiary: d.sourceDepartment,
          selected: selected,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _model.linkedDaak
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _openFilePicker() async {
    HelperUtils.hideKeyboard(context);
    ref
        .read(filesController.notifier)
        .fetchFiles(FileType.my, showLoader: false);
    final result = await showModalBottomSheet<List<FileModel>>(
      context: context,
      isScrollControlled: true,
      //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => _LinkPickerSheet<FileModel>(
        title: "Link Files",
        itemsBuilder: (ref) => ref.watch(filesController).files,
        isLoadingBuilder: (ref) => ref.watch(filesController).loadingFiles,
        alreadyLinked: List.of(_model.linkedFiles),
        keyOf: (f) => f.fileId,
        match: (f, q) =>
            (f.referenceNo ?? '').toLowerCase().contains(q) ||
            (f.barcode ?? '').toLowerCase().contains(q) ||
            (f.subject ?? '').toLowerCase().contains(q) ||
            (f.sender ?? '').toLowerCase().contains(q),
        tileBuilder: (ctx, f, selected) => _pickerTile(
          icon: Icons.folder_outlined,
          primary: f.referenceNo ?? f.barcode ?? '—',
          secondary: f.subject ?? '',
          tertiary: f.sender,
          selected: selected,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _model.linkedFiles
          ..clear()
          ..addAll(result);
      });
    }
  }

  Widget _pickerTile({
    required IconData icon,
    required String primary,
    required String secondary,
    String? tertiary,
    required bool selected,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.secondary
              : context.appColors.secondaryLight.withValues(alpha: 0.4),
          width: selected ? 1.6 : 1,
        ),
        color: selected
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06)
            : Theme.of(context).cardColor,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  primary,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primaryDark,
                ),
                if (secondary.isNotEmpty)
                  AppText.bodySmall(
                    secondary,
                    color: context.appColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (tertiary != null && tertiary.isNotEmpty)
                  AppText.bodySmall(
                    tertiary,
                    color: context.appColors.textSecondary.withValues(
                      alpha: 0.7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.secondary
                    : context.appColors.secondaryLight,
                width: 1.6,
              ),
            ),
            child: selected
                ? Icon(Icons.check, size: 14, color: context.appColors.accent)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperOverview() {
    final steps = <_StepProgress>[
      _StepProgress(
        title: 'Details',
        icon: Icons.description_outlined,
        complete: _step0Complete,
        index: 0,
      ),
      _StepProgress(
        title: 'Flags',
        icon: Icons.flag_outlined,
        complete: _step1Complete,
        index: 1,
      ),
      _StepProgress(
        title: 'Correspondence',
        icon: Icons.folder_shared_outlined,
        complete: _step2Complete,
        index: 2,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.headlineSmall("Steps To Complete"),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    Expanded(child: _stepCircle(steps[i])),
                    if (i < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 21),
                        child: Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: steps[i].complete && steps[i + 1].complete
                                ? context.appColors.success
                                : context.appColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _sectionActions(),
        ],
      ),
    );
  }

  Widget _stepCircle(_StepProgress step) {
    final color = step.complete
        ? context.appColors.success
        : context.appColors.warning;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _changeSection(step.index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.complete ? color : Theme.of(context).cardColor,
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                step.complete ? Icons.check_rounded : step.icon,
                color: step.complete ? context.appColors.accent : color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              step.complete ? 'Completed' : 'Incomplete',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionActions({
    int? nextStep,
    String? continueLabel,
    int? previousStep,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (previousStep != null) ...[
              InkWell(
                onTap: () => _changeSection(previousStep),

                child: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: AppOutlineButton(
                onPressed: _onPreview,
                text: "Preview Summary",
                color: context.appColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            if (nextStep != null && continueLabel != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: AppOutlineButton(
                  onPressed: () => _changeSection(nextStep),
                  text: continueLabel,
                  color: context.appColors.secondaryLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            onPressed: _onSend,
            text: isSecretary ? "Send Summary" : "Send to Secretary for Review",
            width: double.infinity,
            icon: Icons.send,
            // height: 52,
          ),
        ),
      ],
    );
  }
}

class _StepProgress {
  final String title;
  final IconData icon;
  final bool complete;
  final int index;

  const _StepProgress({
    required this.title,
    required this.icon,
    required this.complete,
    required this.index,
  });
}

class _LinkPickerSheet<T> extends ConsumerStatefulWidget {
  final String title;
  final List<T> Function(WidgetRef ref) itemsBuilder;
  final bool Function(WidgetRef ref) isLoadingBuilder;
  final List<T> alreadyLinked;
  final Object? Function(T item) keyOf;
  final bool Function(T item, String query) match;
  final Widget Function(BuildContext context, T item, bool selected)
  tileBuilder;

  const _LinkPickerSheet({
    required this.title,
    required this.itemsBuilder,
    required this.isLoadingBuilder,
    required this.alreadyLinked,
    required this.keyOf,
    required this.match,
    required this.tileBuilder,
  });

  @override
  ConsumerState<_LinkPickerSheet<T>> createState() =>
      _LinkPickerSheetState<T>();
}

class _LinkPickerSheetState<T> extends ConsumerState<_LinkPickerSheet<T>> {
  String _query = '';
  late final Set<Object?> _selectedKeys;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedKeys = widget.alreadyLinked.map(widget.keyOf).toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(T item) => _selectedKeys.contains(widget.keyOf(item));

  @override
  Widget build(BuildContext context) {
    final items = widget.itemsBuilder(ref);
    final isLoading = widget.isLoadingBuilder(ref);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((e) => widget.match(e, q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => RouteHelper.pop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: context.appColors.textPrimary,
                  ),
                ),
                Expanded(child: AppText.headlineSmall(widget.title)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: _searchController,
              labelText: "Search",
              hintText: "Search by reference, subject…",
              showLabel: false,
              autoFocus: true,
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: isLoading && items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: AppText.bodyMedium(
                        "No results",
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final selected = _isSelected(item);
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() {
                          final k = widget.keyOf(item);
                          if (selected) {
                            _selectedKeys.remove(k);
                          } else {
                            _selectedKeys.add(k);
                          }
                        }),
                        child: widget.tileBuilder(ctx, item, selected),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {
                    final byKey = <Object?, T>{
                      for (final i in items) widget.keyOf(i): i,
                    };
                    for (final i in widget.alreadyLinked) {
                      byKey.putIfAbsent(widget.keyOf(i), () => i);
                    }
                    final selectedItems = _selectedKeys
                        .map((k) => byKey[k])
                        .whereType<T>()
                        .toList();
                    RouteHelper.pop(selectedItems);
                  },
                  text: _selectedKeys.isEmpty
                      ? "Done"
                      : "Link ${_selectedKeys.length} item${_selectedKeys.length == 1 ? '' : 's'}",
                  width: double.infinity,
                  height: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
