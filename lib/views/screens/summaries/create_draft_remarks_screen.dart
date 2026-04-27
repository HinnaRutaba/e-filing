import 'dart:async';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_daak_model.dart';
import 'package:efiling_balochistan/models/summaries/draft_remarks_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_file_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_local_link_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_preview_sheet.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/gradient_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/html_editor.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateDraftRemarksScreen extends ConsumerStatefulWidget {
  final SummaryModel summary;

  const CreateDraftRemarksScreen({super.key, required this.summary});

  @override
  ConsumerState<CreateDraftRemarksScreen> createState() =>
      _CreateDraftRemarksScreenState();
}

class _CreateDraftRemarksScreenState
    extends ConsumerState<CreateDraftRemarksScreen> {
  final HtmlEditorController _remarksController = HtmlEditorController();
  final TextEditingController _briefsController = TextEditingController();

  List<FlagModel> _allFlags = [];
  List<FlagAndAttachmentModel> _attachments = [FlagAndAttachmentModel()];
  List<SummaryDaakModel> _linkedDaak = [];
  List<SummaryFileModel> _linkedFiles = [];
  final Set<int?> _preloadedDaakIds = {};
  final Set<int?> _preloadedFileIds = {};
  int? _internalForwardId;

  final Set<int> _openSections = {0, 1, 2, 3};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    _allFlags = await ref.read(filesController.notifier).getFlags();
    if (!mounted) return;

    final summaryId = widget.summary.id;
    if (summaryId == null) return;

    final details = await ref
        .read(summariesController.notifier)
        .fetchSummaryDetails(summaryId: summaryId);
    if (!mounted || details == null) return;

    setState(() {
      _internalForwardId = details.actions?.myInternalForwardId;
      _populateFlags(details);
      _populateLocalLinks(details);
    });
  }

  void _populateFlags(SummaryDetailsModel details) {
    final supporting = details.attachments
        .where((a) => a.isSupporting)
        .toList();
    if (supporting.isEmpty) return;

    final matched = supporting.map((a) {
      final name = _parseFlagName(a.originalName);
      return _allFlags.firstWhere(
        (f) => f.title?.trim().toLowerCase() == name?.trim().toLowerCase(),
        orElse: () => FlagModel(title: name),
      );
    }).toList();

    _attachments = List.generate(supporting.length, (i) {
      return FlagAndAttachmentModel(
        flagType: matched[i],
        existingAttachment: supporting[i],
        usedFlags: [
          for (int j = 0; j < matched.length; j++)
            if (j != i) matched[j],
        ],
      );
    });
  }

  void _populateLocalLinks(SummaryDetailsModel details) {
    _linkedDaak = details.localLinks
        .where((l) => l.linkType == SummaryLinkType.daak)
        .map((l) => (l.attachment as SummaryLocalLinkDaakAttachment).daak)
        .toList();

    _linkedFiles = details.localLinks
        .where((l) => l.linkType == SummaryLinkType.file)
        .map((l) => (l.attachment as SummaryLocalLinkFileAttachment).file)
        .toList();

    _preloadedDaakIds.addAll(_linkedDaak.map((d) => d.id));
    _preloadedFileIds.addAll(_linkedFiles.map((f) => f.id));
  }

  String? _parseFlagName(String? originalName) {
    if (originalName == null) return null;
    final match = RegExp(r'^\[Flag:\s*(.+?)\]').firstMatch(originalName.trim());
    return match?.group(1)?.trim();
  }

  @override
  void dispose() {
    _briefsController.dispose();
    super.dispose();
  }

  SummaryModel get _s => widget.summary;

  void _addAttachment() {
    setState(() {
      _attachments.add(
        FlagAndAttachmentModel(
          usedFlags: [..._attachments.map((e) => e.flagType ?? FlagModel())],
        ),
      );
    });
  }

  void _onPreview() {
    HelperUtils.hideKeyboard(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      builder: (ctx) => SummaryPreviewSheet(
        content: _s.body ?? '',
        department: _s.draftTargetDepartment,
        summaryDate: _s.summaryDate ?? DateTime.now(),
        subject: _s.subject ?? '',
        mainPdf: null,
        attachments: const [],
        linkedDaak: const [],
        linkedFiles: const [],
        onSubmit: null,
      ),
    );
  }

  Future<void> _openDaakPicker() async {
    HelperUtils.hideKeyboard(context);
    final result = await showModalBottomSheet<List<SummaryDaakModel>>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        minHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => _SearchPickerSheet<SummaryDaakModel>(
        title: 'Link Daak Letters',
        searcher: (q) =>
            ref.read(summariesController.notifier).searchDaaks(query: q),
        alreadyLinked: List.of(_linkedDaak),
        keyOf: (d) => d.id,
        tileBuilder: (ctx, d, selected) => _pickerTile(
          icon: Icons.mail_outline_rounded,
          primary: d.diaryNo ?? d.letterNo ?? '—',
          secondary: d.subject ?? '',
          tertiary: d.source,
          selected: selected,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _linkedDaak
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _openFilePicker() async {
    HelperUtils.hideKeyboard(context);
    final result = await showModalBottomSheet<List<SummaryFileModel>>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => _SearchPickerSheet<SummaryFileModel>(
        title: 'Link Files',
        searcher: (q) =>
            ref.read(summariesController.notifier).searchFiles(query: q),
        alreadyLinked: List.of(_linkedFiles),
        keyOf: (f) => f.id,
        tileBuilder: (ctx, f, selected) => _pickerTile(
          icon: Icons.folder_outlined,
          primary: f.referenceNo ?? f.barcode ?? '—',
          secondary: f.subject ?? '',
          selected: selected,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _linkedFiles
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _onSubmit() async {
    final desId = ref.read(summariesController).meta?.activeUserDesg?.id;
    if (desId == null) return;

    final body = await _remarksController.getText();
    final briefNote = _briefsController.text.trim();

    final newFlags = _attachments
        .where((a) => a.existingAttachment == null)
        .toList();

    final incompleteFlags = newFlags.where(
      (f) => f.flagType != null && !f.hasAttachment,
    );
    if (incompleteFlags.isNotEmpty) {
      Toast.error(
        message:
            'One or more flags are missing attachments. Add a file and try again.',
      );
      return;
    }

    final model = DraftRemarksModel(
      summaryId: _s.id!,
      userDesgId: desId,
      internalForwardId: _internalForwardId,
      body: body,
      briefNote: briefNote,
      newFlags: newFlags,
      linkedDaak: _linkedDaak,
      linkedFiles: _linkedFiles,
    );

    await ref
        .read(summariesController.notifier)
        .submitDraftRemarks(model: model);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AppText.headlineSmall('Draft Remarks'),
          scrolledUnderElevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summaryInfoCard(),
                    const SizedBox(height: 4),
                    _remarksSection(),
                    _briefsSection(),
                    _flagsSection(),
                    _filesSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  Widget _summaryInfoCard() {
    final dateStr = _s.summaryDate != null
        ? DateTimeHelper.datFormatSlash(_s.summaryDate)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.appColors.secondaryLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((_s.summaryNo ?? '').isNotEmpty)
                  AppText.labelSmall(
                    _s.summaryNo!,
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                AppText.titleMedium(
                  _s.subject ?? '—',
                  fontWeight: FontWeight.w700,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: context.appColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      AppText.bodySmall(
                        dateStr,
                        color: context.appColors.textSecondary,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_s.summaryStatus != null) ...[
                _statusBadge(_s.summaryStatus!),
                const SizedBox(height: 8),
              ],
              InkWell(
                onTap: _onPreview,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _remarksSection() {
    return _expandableSection(
      index: 0,
      icon: Icons.edit_note_rounded,
      title: 'Remarks',
      subtitle: 'Write your remarks for this summary',
      child: _htmlEditorBox(
        controller: _remarksController,
        hint: 'Enter remarks…',
      ),
    );
  }

  Widget _briefsSection() {
    return _expandableSection(
      index: 1,
      icon: Icons.notes_rounded,
      title: 'Add Briefs',
      subtitle: 'Optional brief note',
      highlightColor: const Color(0xFFE6B84D),
      cardColor: const Color(0xFFFEF9EC),
      child: AppTextField(
        controller: _briefsController,
        labelText: 'Brief Note',
        showLabel: false,
        hintText: 'Add a brief note…',
        maxLines: 5,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFFE6B84D).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _flagsSection() {
    final newFlags = _attachments
        .where((a) => a.existingAttachment == null)
        .toList();

    return _expandableSection(
      index: 2,
      icon: Icons.flag_outlined,
      title: 'Flags',
      subtitle: 'Attach supporting flags',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.separated(
            itemCount: _attachments.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => Divider(
              height: 32,
              color: context.appColors.secondaryLight.withValues(alpha: 0.5),
            ),
            itemBuilder: (ctx, i) {
              final model = _attachments[i];
              final isPreexisting = model.existingAttachment == null
                  ? false
                  : true;
              final isLastNew = !isPreexisting && model == newFlags.last;
              return AddFlagAndAttachment(
                key: ValueKey(model),
                model: model,
                isReadOnly: isPreexisting,
                onDelete: isPreexisting
                    ? null
                    : () => setState(() => _attachments.removeAt(i)),
                onAdd: isLastNew ? _addAttachment : null,
              );
            },
          ),
          if (newFlags.isEmpty) ...[
            if (_attachments.isNotEmpty)
              Divider(
                height: 32,
                color: context.appColors.secondaryLight.withValues(alpha: 0.5),
              ),
            InkWell(
              onTap: _addAttachment,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.appColors.primaryDark),
                ),
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: context.appColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    AppText.bodySmall(
                      'Add Flag',
                      color: context.appColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filesSection() {
    return _expandableSection(
      index: 3,
      icon: Icons.folder_shared_outlined,
      title: 'Local Correspondence',
      subtitle: 'Link daak letters and files',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodySmall(
            'Link any earlier correspondence received locally that relates to this summary.',
            color: context.appColors.textSecondary,
          ),
          const SizedBox(height: 8),
          _linkSubsectionHeader(
            icon: Icons.mail_outline_rounded,
            title: 'Link Daak Letters',
            actionLabel: 'Add Daak',
            onAdd: _openDaakPicker,
          ),
          const SizedBox(height: 8),
          if (_linkedDaak.isEmpty)
            _emptyLinkPlaceholder('No daak linked yet')
          else
            _linkedItemsLayout(
              items: [for (final d in _linkedDaak) _linkedDaakTile(d)],
            ),
          const SizedBox(height: 12),
          _linkSubsectionHeader(
            icon: Icons.folder_outlined,
            title: 'Link Files',
            actionLabel: 'Add File',
            onAdd: _openFilePicker,
          ),
          const SizedBox(height: 8),
          if (_linkedFiles.isEmpty)
            _emptyLinkPlaceholder('No files linked yet')
          else
            _linkedItemsLayout(
              items: [for (final f in _linkedFiles) _linkedFileTile(f)],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------------

  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.secondaryLight.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Cancel',
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppSolidButton(
                  onPressed: _onSubmit,
                  text: 'Submit',
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _expandableSection({
    required int index,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
    Color? highlightColor,
    Color? cardColor,
  }) {
    final isOpen = _openSections.contains(index);
    final accent = highlightColor ?? Theme.of(context).colorScheme.secondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen
              ? accent.withValues(alpha: 0.4)
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
            onTap: () => setState(
              () => isOpen
                  ? _openSections.remove(index)
                  : _openSections.add(index),
            ),
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
                      child: Icon(icon, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleMedium(title, fontWeight: FontWeight.w600),
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

  Widget _linkSubsectionHeader({
    required IconData icon,
    required String title,
    required String actionLabel,
    required VoidCallback onAdd,
  }) {
    return Row(
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

  Widget _linkedItemsLayout({required List<Widget> items}) {
    if (context.isMobile) return Column(children: items);
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

  Widget _linkedDaakTile(SummaryDaakModel daak) {
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
          if (!_preloadedDaakIds.contains(daak.id))
            IconButton(
              tooltip: 'Remove',
              onPressed: () => setState(() => _linkedDaak.remove(daak)),
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

  Widget _linkedFileTile(SummaryFileModel file) {
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
          if (!_preloadedFileIds.contains(file.id))
            IconButton(
              tooltip: 'Remove',
              onPressed: () => setState(() => _linkedFiles.remove(file)),
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

  Widget _statusBadge(SummaryStatus status) {
    final color = status.getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _htmlEditorBox({
    required HtmlEditorController controller,
    required String hint,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.appColors.secondaryLight.withValues(alpha: 0.5),
          ),
        ),
        child: HtmlEditor(controller: controller, hint: hint, height: 280),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic search picker sheet (shared between daak and file pickers)
// ---------------------------------------------------------------------------

class _SearchPickerSheet<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function(String? query) searcher;
  final List<T> alreadyLinked;
  final Object? Function(T item) keyOf;
  final Widget Function(BuildContext context, T item, bool selected)
  tileBuilder;

  const _SearchPickerSheet({
    required this.title,
    required this.searcher,
    required this.alreadyLinked,
    required this.keyOf,
    required this.tileBuilder,
  });

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<Object?> _selectedKeys;
  List<T> _items = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedKeys = widget.alreadyLinked.map(widget.keyOf).toSet();
    _search(null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String? query) async {
    setState(() => _isLoading = true);
    try {
      final items = await widget.searcher(
        query == null || query.isEmpty ? null : query,
      );
      if (mounted)
        setState(() {
          _items = items;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _search(v.trim().isEmpty ? null : v.trim()),
    );
  }

  bool _isSelected(T item) => _selectedKeys.contains(widget.keyOf(item));

  @override
  Widget build(BuildContext context) {
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
              labelText: 'Search',
              hintText: 'Search…',
              showLabel: false,
              autoFocus: true,
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onChanged: _onQueryChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading && _items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: AppText.bodyMedium(
                        'No results',
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final item = _items[i];
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
                      if (_isLoading)
                        const Positioned(
                          top: 8,
                          right: 16,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
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
                      for (final i in _items) widget.keyOf(i): i,
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
                      ? 'Done'
                      : 'Link ${_selectedKeys.length} item${_selectedKeys.length == 1 ? '' : 's'}',
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
