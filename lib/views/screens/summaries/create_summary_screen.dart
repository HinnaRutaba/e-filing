import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/gradient_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quill_html_editor_v2/quill_html_editor_v2.dart';

class DepartmentModel {
  final int id;
  final String title;
  const DepartmentModel({required this.id, required this.title});
}

class CreateSummaryScreen extends ConsumerStatefulWidget {
  const CreateSummaryScreen({super.key});

  @override
  ConsumerState<CreateSummaryScreen> createState() =>
      _CreateSummaryScreenState();
}

class _CreateSummaryScreenState extends ConsumerState<CreateSummaryScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final QuillEditorController quillEditorController = QuillEditorController();

  DateTime summaryDate = DateTime.now();
  DepartmentModel? selectedDepartment;
  XFile? mainPdf;

  final List<DepartmentModel> departments = const [
    DepartmentModel(id: 1, title: 'Finance Department'),
    DepartmentModel(id: 2, title: 'Education Department'),
    DepartmentModel(id: 3, title: 'Health Department'),
    DepartmentModel(id: 4, title: 'Home Department'),
  ];

  final List<FlagAndAttachmentModel> attachments = [FlagAndAttachmentModel()];

  bool get allAttachmentsValid => attachments.every((e) => e.isValid);

  final List<DaakModel> linkedDaak = [];
  final List<FileModel> linkedFiles = [];

  int _openSection = 0;

  @override
  void initState() {
    super.initState();
    dateController.text = DateTimeHelper.datFormatSlash(summaryDate);
  }

  @override
  void dispose() {
    subjectController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: summaryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        summaryDate = picked;
        dateController.text = DateTimeHelper.datFormatSlash(picked);
      });
    }
  }

  addAttachement() {
    setState(() {
      attachments.add(FlagAndAttachmentModel());
    });
  }

  Future<void> _pickMainPdf() async {
    final files = await FilePickerService().pickFiles();
    if (files.isNotEmpty) {
      setState(() => mainPdf = files.first);
    }
  }

  Future<void> _onSend() async {
    HelperUtils.hideKeyboard(context);
    if (!formKey.currentState!.validate()) return;
    if (mainPdf == null) {
      Toast.error(message: "Please attach the Main Summary PDF");
      return;
    }
    final content = await quillEditorController.getText();
    if (content.trim().isEmpty) {
      Toast.error(message: "Please write the summary content");
      return;
    }
    if (!allAttachmentsValid) {
      Toast.error(
        message:
            "One or more flags are missing attachments. Add a file and try again.",
      );
      return;
    }
    Toast.show(message: "Summary ready to send");
  }

  Future<void> _onPreview() async {
    HelperUtils.hideKeyboard(context);
    final content = await quillEditorController.getText();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: AppText.headlineSmall("Summary Preview")),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _previewRow(
                  "Subject",
                  subjectController.text.isEmpty ? '-' : subjectController.text,
                ),
                _previewRow("Date", dateController.text),
                _previewRow(
                  "Target Department",
                  selectedDepartment?.title ?? '-',
                ),
                _previewRow("Main PDF", mainPdf?.name ?? '-'),
                const SizedBox(height: 12),
                AppText.titleMedium(
                  "Content",
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondaryLight.withOpacity(0.5),
                    ),
                  ),
                  child: AppText.bodyMedium(
                    content.trim().isEmpty ? '—' : content,
                  ),
                ),
                const SizedBox(height: 16),
                AppOutlineButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  text: "Close",
                  color: AppColors.primaryDark,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: BaseScreen(
        isdash: false,
        bgColor: Colors.transparent,
        title: "Create Summary",
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 40),
          child: Form(
            key: formKey,
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
                  subtitle: "Link references from earlier correspondence",
                  child: _localCorrespondenceBody(),
                ),
                const SizedBox(height: 24),
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

  Widget _mainPdfPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.labelLarge(
              "Main Summary PDF",
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            AppText.headlineSmall(' *', color: Colors.red),
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
                  child: AppText.bodyMedium(
                    mainPdf?.name ?? "Choose file",
                    color: mainPdf != null
                        ? AppColors.secondaryDark
                        : AppColors.secondaryLight,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (mainPdf != null)
                  InkWell(
                    onTap: () => setState(() => mainPdf = null),
                    child: Icon(Icons.cancel, color: Colors.red[800], size: 18),
                  )
                else
                  const Icon(
                    Icons.upload_file,
                    color: AppColors.secondary,
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
          border: Border.all(color: AppColors.secondaryLight.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            ToolBar(
              activeIconColor: Colors.blue,
              padding: const EdgeInsets.all(6),
              iconSize: 22,
              controller: quillEditorController,
              toolBarConfig: const [
                ToolBarStyle.bold,
                ToolBarStyle.italic,
                ToolBarStyle.underline,
                ToolBarStyle.listOrdered,
                ToolBarStyle.size,
                ToolBarStyle.headerOne,
                ToolBarStyle.headerTwo,
                ToolBarStyle.link,
                ToolBarStyle.align,
                ToolBarStyle.color,
                ToolBarStyle.blockQuote,
              ],
            ),
            Divider(color: Colors.grey[300]!),
            const SizedBox(height: 4),
            QuillHtmlEditor(
              text: '',
              hintText: "Write summary content here…",
              controller: quillEditorController,
              minHeight: 220,
              textStyle: const TextStyle(fontSize: 16, color: Colors.black),
              hintTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen
              ? AppColors.secondary.withValues(alpha: 0.4)
              : AppColors.secondaryLight.withValues(alpha: 0.4),
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
            onTap: () => setState(() => _openSection = isOpen ? -1 : index),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: AppColors.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleMedium(
                          title,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          AppText.bodySmall(
                            subtitle,
                            color: Colors.grey[600],
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
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText.bodySmall(
                      'Step ${index + 1}',
                      color: AppColors.secondary,
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
                      color: Colors.grey[700],
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
                          color: AppColors.secondaryLight.withValues(
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
        AppTextField(
          controller: dateController,
          labelText: "Summary Date",
          hintText: "Select date",
          readOnly: true,
          isMandatory: true,
          suffixIcon: const Icon(Icons.calendar_month_sharp),
          onTap: _pickDate,
          validator: Validators.dateValidator,
        ),
        const SizedBox(height: 12),
        AppDropDownField<DepartmentModel>(
          items: departments,
          labelText: "Target Department",
          hintText: "Select department",
          isMandatory: true,
          itemBuilder: (item) => AppText.titleMedium(item?.title ?? ''),
          onChanged: (item) {
            setState(() => selectedDepartment = item);
          },
          validator: (item) {
            if (selectedDepartment == null || item == null) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _mainPdfPicker(),
        const SizedBox(height: 16),
        AppText.labelLarge(
          "Content",
          color: Colors.grey[800],
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
          itemCount: attachments.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Divider(
            height: 32,
            color: AppColors.secondaryLight.withValues(alpha: .5),
          ),
          itemBuilder: (ctx, i) {
            final model = attachments[i];
            return AddFlagAndAttachment(
              key: ValueKey(model),
              model: model,
              onDelete: attachments.length > 1
                  ? () => setState(() => attachments.removeAt(i))
                  : null,
              onAdd: addAttachement,
            );
          },
        ),
        if (attachments.isEmpty)
          Row(
            children: [
              InkWell(
                onTap: addAttachement,
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
          color: Colors.grey[700],
        ),
        const SizedBox(height: 8),
        _linkSubsectionHeader(
          icon: Icons.mail_outline_rounded,
          title: "Link Daak Letters",
          actionLabel: "Add Daak",
          onAdd: _openDaakPicker,
        ),
        const SizedBox(height: 8),
        if (linkedDaak.isEmpty)
          _emptyLinkPlaceholder("No daak linked yet")
        else
          Column(children: [for (final d in linkedDaak) _linkedDaakTile(d)]),
        const SizedBox(height: 20),
        _linkSubsectionHeader(
          icon: Icons.folder_outlined,
          title: "Link Files",
          actionLabel: "Add File",
          onAdd: _openFilePicker,
        ),
        const SizedBox(height: 8),
        if (linkedFiles.isEmpty)
          _emptyLinkPlaceholder("No files linked yet")
        else
          Column(children: [for (final f in linkedFiles) _linkedFileTile(f)]),
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
        Icon(icon, size: 20, color: AppColors.secondaryDark),
        const SizedBox(width: 6),
        Expanded(
          child: AppText.titleSmall(
            title,
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppOutlineButton(
          onPressed: onAdd,
          text: actionLabel,
          icon: Icons.add,
          color: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ],
    );
  }

  Widget _emptyLinkPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.4),
        ),
        color: AppColors.cardColorLight,
      ),
      alignment: Alignment.center,
      child: AppText.bodySmall(text, color: Colors.grey[600]),
    );
  }

  Widget _linkedDaakTile(DaakModel daak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.5),
        ),
        color: AppColors.secondaryLight.withValues(alpha: 0.02),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size: 16,
              color: AppColors.secondary,
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
                  color: AppColors.textPrimary,
                ),
                if ((daak.subject ?? '').isNotEmpty)
                  AppText.bodySmall(
                    daak.subject!,
                    color: Colors.grey[700],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => setState(() => linkedDaak.remove(daak)),
            icon: Icon(Icons.cancel, color: Colors.red[700], size: 20),
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
          color: AppColors.secondaryLight.withValues(alpha: 0.5),
        ),
        color: AppColors.secondaryLight.withValues(alpha: 0.02),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder_outlined,
              size: 16,
              color: AppColors.secondary,
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
                  color: AppColors.textPrimary,
                ),
                if ((file.subject ?? '').isNotEmpty)
                  AppText.bodySmall(
                    file.subject!,
                    color: Colors.grey[700],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => setState(() => linkedFiles.remove(file)),
            icon: Icon(Icons.cancel, color: Colors.red[700], size: 20),
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
      backgroundColor: AppColors.background,
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
        alreadyLinked: List.of(linkedDaak),
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
        linkedDaak
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
      backgroundColor: AppColors.background,
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
        alreadyLinked: List.of(linkedFiles),
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
        linkedFiles
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
              ? AppColors.secondary
              : AppColors.secondaryLight.withValues(alpha: 0.4),
          width: selected ? 1.6 : 1,
        ),
        color: selected
            ? AppColors.secondary.withValues(alpha: 0.06)
            : AppColors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  primary,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
                if (secondary.isNotEmpty)
                  AppText.bodySmall(
                    secondary,
                    color: Colors.grey[700],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (tertiary != null && tertiary.isNotEmpty)
                  AppText.bodySmall(
                    tertiary,
                    color: Colors.grey[500],
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
              color: selected ? AppColors.secondary : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.secondary
                    : AppColors.secondaryLight,
                width: 1.6,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ],
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
                onTap: () => setState(() => _openSection = previousStep),

                child: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: AppOutlineButton(
                onPressed: _onPreview,
                text: "Preview Summary",
                color: AppColors.primaryDark,
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
                  onPressed: () => setState(() => _openSection = nextStep),
                  text: continueLabel,
                  color: AppColors.secondaryDark,
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
            text: "Send to Secretary for Review",
            width: double.infinity,
            icon: Icons.send,
            // height: 52,
          ),
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: AppText.labelLarge(
              label,
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(child: AppText.bodyMedium(value)),
        ],
      ),
    );
  }
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
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.black,
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
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search, color: AppColors.secondary),
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
                        color: Colors.grey[600],
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
                    Navigator.of(context).pop(selectedItems);
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
