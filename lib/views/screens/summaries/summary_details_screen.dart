import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/internal_user_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_brief_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/gallery/gallery_view.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/attachments_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/internal_forward_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/internal_files_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/movement_timeline_section.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_brief.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efiling_balochistan/views/widgets/html_editor.dart';

enum SummaryAction {
  returnToSection(
    label: 'Return to Section',
    icon: Icons.undo_rounded,
    color: AppColors.error,
    filled: false,
  ),
  editRemarks(
    label: 'Edit Drafted Remarks',
    icon: Icons.edit_outlined,
    color: AppColors.secondary,
    filled: true,
  ),
  shareInternally(
    label: 'Share Internally',
    icon: Icons.group_rounded,
    color: Color(0xFFF0A63A),
    filled: false,
  ),
  signForward(
    label: 'Sign & Forward',
    icon: Icons.arrow_forward_rounded,
    color: Colors.deepPurpleAccent,
    filled: true,
  );

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;

  const SummaryAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
  });
}

class SummaryDetailsScreen extends ConsumerStatefulWidget {
  final SummaryModel? summary;

  const SummaryDetailsScreen({super.key, required this.summary});

  @override
  ConsumerState<SummaryDetailsScreen> createState() =>
      _SummaryDetailsScreenState();
}

const String _kFallbackHtml = '''
<p>nb cdcbdnmcbdchndmc dscdbcnscbnmsdc sccscvbnsdc dm cmdvchncvnmdc nsc snmcv dnsmc dmnc dmn cdns cds</p>
''';

class _SummaryDetailsScreenState extends ConsumerState<SummaryDetailsScreen> {
  SummaryAction? _selectedAction;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _shareSearchController = TextEditingController();
  final HtmlEditorController _editDraftController = HtmlEditorController();
  late String _currentHtml;
  InternalUserModel? _shareTarget;

  final SignaturePadController _signaturePadController =
      SignaturePadController();

  static const List<String> _demoDepartments = [
    'Agriculture Department',
    'Home Department',
    'Finance Department',
    'Education Department',
    'Health Department',
  ];
  final TextEditingController _destDeptController = TextEditingController(
    text: 'Agriculture Department',
  );
  final TextEditingController _destOfficerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentHtml = widget.summary?.body ?? _kFallbackHtml;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    final details = await ref
        .read(summariesController.notifier)
        .fetchSummaryDetails(summaryId: widget.summary?.id);
    if (!mounted) return;
    final body = details?.summary?.body;
    if (body != null && body.isNotEmpty) {
      setState(() => _currentHtml = body);
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _shareSearchController.dispose();
    _destDeptController.dispose();
    _destOfficerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrlState = ref.watch(summariesController);
    final details = ctrlState.details;
    final isLoading = ctrlState.isLoadingDetails && details == null;
    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AppText.headlineSmall("Summary Details"),
          actions: [
            AppOutlineButton(
              onPressed: _onPrint,
              text: 'Print Summary',
              icon: Icons.print_outlined,
              color: AppColors.primaryDark,
              width: 160,
            ),
            const SizedBox(width: 12),
          ],
        ),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: StickyTagDrawer(
                      panelWidth: MediaQuery.sizeOf(context).width * 0.85,
                      tagsAlignment: const Alignment(0.0, -0.5),
                      mainContent: RefreshIndicator(
                        onRefresh: _loadDetails,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(context.isMobile ? 12 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _documentCard(),
                              const SizedBox(height: 16),
                              _sidebar(),
                            ],
                          ),
                        ),
                      ),
                      tags: [
                        _buildAttachmentsTag(details),
                        _buildBriefsTag(details),
                      ],
                    ),
                  ),
                  _actionBar(),
                ],
              ),
      ),
    );
  }

  void _onActionTap(SummaryAction action) {
    setState(() {
      if (_selectedAction == action) {
        _selectedAction = null;
        _remarksController.clear();
      } else {
        _selectedAction = action;
      }
    });
  }

  Future<void> _onSubmitAction() async {
    final action = _selectedAction;
    if (action == null) return;

    if (action == SummaryAction.editRemarks) {
      final newHtml = await _editDraftController.getText();
      if (!mounted) return;
      setState(() {
        _currentHtml = newHtml;
        _selectedAction = null;
        _remarksController.clear();
      });
      return;
    }

    setState(() {
      _selectedAction = null;
      _remarksController.clear();
    });
  }

  Widget _actionBar() {
    final expanded = _selectedAction != null;
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
            color: AppColors.secondaryDark.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // _sectionDraftBanner(),
              // const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: expanded
                    ? _expandedHeader(key: const ValueKey('header'))
                    : KeyedSubtree(
                        key: const ValueKey('buttons'),
                        child: _actionButtonRow(),
                      ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded
                    ? _expandedRemarks()
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtonRow() {
    final isMobile = context.isMobile;
    final buttons = SummaryAction.values
        .map((a) => _actionButton(a, expand: !isMobile))
        .toList(growable: false);
    if (!isMobile) {
      return Row(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: buttons[i]),
          ],
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: buttons
              .map(
                (b) =>
                    SizedBox(width: (constraints.maxWidth - 10) / 2, child: b),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _actionButton(
    SummaryAction action, {
    required bool expand,
    VoidCallback? onTapOverride,
    double? width,
  }) {
    final bool selected = _selectedAction == action;
    return SizedBox(
      width: width,
      child: Material(
        color: action.filled
            ? action.color
            : (selected
                  ? action.color.withValues(alpha: 0.08)
                  : action.color.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTapOverride ?? () => _onActionTap(action),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: action.color,
                width: selected ? 2 : 1.4,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  action.icon,
                  size: 16,
                  color: action.filled ? AppColors.white : action.color,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    action.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: action.filled ? AppColors.white : action.color,
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

  Widget _expandedHeader({Key? key}) {
    final action = _selectedAction!;
    return SizedBox(
      key: key,
      height: 44,
      child: Row(
        children: [
          Material(
            color: AppColors.cardColorLight,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _onActionTap(action),
              child: Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondaryLight.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(action.icon, size: 18, color: action.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: action.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedRemarks() {
    final action = _selectedAction!;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (action == SummaryAction.editRemarks)
                    _draftEditor(action)
                  else if (action == SummaryAction.returnToSection)
                    _returnToSectionBody(action)
                  else if (action == SummaryAction.shareInternally)
                    _shareInternallyBody(action)
                  else if (action == SummaryAction.signForward)
                    _signForwardBody(action)
                  else
                    AppTextField(
                      controller: _remarksController,
                      labelText: "Remarks / Instructions",
                      isMandatory: true,
                      hintText: "Please specify what ammendments are needed",
                      maxLines: 5,
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _actionButton(
                      action,
                      expand: false,
                      width: double.infinity,
                      onTapOverride: _onSubmitAction,
                    ),
                  ),
                ],
              )
              .animate(key: ValueKey(action))
              .fadeIn(duration: 220.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.08,
                end: 0,
                duration: 220.ms,
                curve: Curves.easeOut,
              ),
    );
  }

  Widget _returnToSectionBody(SummaryAction action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE6B84D).withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_rounded,
                  size: 16,
                  color: Color(0xFF8A6A12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF7A5A10),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'This will return the draft to '),
                      TextSpan(
                        text: 'Mr. Section officer',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text:
                            ' for amendments. Provide clear instructions on what needs to be changed.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _remarksController,
          labelText: "Remarks / Instructions",
          isMandatory: true,
          hintText: "Please specify what ammendments are needed",
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _shareInternallyBody(SummaryAction action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.secondaryDark.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.group_rounded,
                  size: 16,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodySmall(
                  'Share this summary with a department member for review. They will receive a read-only copy along with your optional instructions.',
                  color: AppColors.secondaryLight,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SearchDropDownField<InternalUserModel>(
          controller: _shareSearchController,
          labelText: 'Select Department Members',
          hintText: 'Search users…',

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
            ),
          ),
          suggestionsCallback: (pattern) {
            final q = pattern.toLowerCase();
            final users =
                ref.read(summariesController).meta?.internalUsers ??
                const <InternalUserModel>[];
            return users.where((u) {
              return (u.name ?? '').toLowerCase().contains(q) ||
                  (u.designation ?? '').toLowerCase().contains(q);
            }).toList();
          },
          itemBuilder: (context, item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyMedium(
                    item.name ?? '',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText.bodySmall(
                    item.designation ?? '',
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ],
              ),
            );
          },
          onSelected: (item) {
            setState(() {
              _shareTarget = item;
              _shareSearchController.text = item.name ?? '';
            });
          },
        ),
        if (_shareTarget != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bodySmall(
                        _shareTarget!.name ?? '',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      AppText.bodySmall(
                        _shareTarget!.designation ?? '',
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _shareTarget = null;
                      _shareSearchController.clear();
                    });
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        AppTextField(
          controller: _remarksController,
          labelText: 'Instruction (Optional)',
          hintText: '',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _signForwardBody(SummaryAction action) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepCard(
            stepLabel: 'STEP 1',
            title: 'Signature',
            child: SignaturePad(controller: _signaturePadController),
          ),
          const SizedBox(height: 12),
          _stepCard(
            stepLabel: 'STEP 2',
            title: 'Forwarding',
            child: _forwardingStep(action),
          ),
        ],
      ),
    );
  }

  Widget _stepCard({
    required String stepLabel,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.secondaryLight.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText.labelSmall(
                  stepLabel,
                  color: context.appColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 10),
              AppText.titleMedium(title),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _forwardingStep(SummaryAction action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _forwardingLabel('DESTINATION DEPARTMENT'),
        const SizedBox(height: 6),
        _departmentDropdown(),
        const SizedBox(height: 4),
        Text(
          'Pre-filled from section draft. You may change if needed.',
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.secondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        _forwardingLabel('DESTINATION OFFICER'),
        const SizedBox(height: 6),
        _officerDropdown(),
        const SizedBox(height: 4),
        Text(
          'No user found for selected department (required role_id: 4 or 5).',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _forwardingLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _departmentDropdown() {
    return SearchDropDownField<String>(
      controller: _destDeptController,
      labelText: 'Destination Department',
      hintText: 'Select department',
      showLabel: false,

      border: _forwardingBorder(),
      suggestionsCallback: (pattern) {
        final q = pattern.toLowerCase();
        return _demoDepartments
            .where((d) => d.toLowerCase().contains(q))
            .toList(growable: false);
      },
      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: AppText.bodyMedium(
            item,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      },
      onSelected: (item) {
        setState(() {
          _destDeptController.text = item;
          _destOfficerController.clear();
        });
      },
    );
  }

  Widget _officerDropdown() {
    return SearchDropDownField<String>(
      controller: _destOfficerController,
      labelText: 'Destination Officer',
      hintText: 'Select officer',
      showLabel: false,
      enabled: false,

      border: _forwardingBorder(),
      suggestionsCallback: (pattern) async => const <String>[],

      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: AppText.bodyMedium(item, color: AppColors.textPrimary),
        );
      },
      onSelected: (item) {
        setState(() => _destOfficerController.text = item);
      },
    );
  }

  OutlineInputBorder _forwardingBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.secondaryLight.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _draftEditor(SummaryAction action) {
    final mq = MediaQuery.of(context);
    final keyboardInset = mq.viewInsets.bottom;
    final available = mq.size.height - keyboardInset;
    final editorHeight = keyboardInset > 0
        ? (available * 0.30).clamp(140.0, 260.0)
        : (mq.size.height * 0.32).clamp(200.0, 360.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.secondaryLight.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodySmall(
                  'You can modify the draft content before signing and forwarding.',
                  color: AppColors.secondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppText.labelLarge('Summary Body', fontWeight: FontWeight.w700),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              height: editorHeight.toDouble(),
              child: HtmlEditor(
                controller: _editDraftController,
                initialHtml: _currentHtml,
                hint: 'Edit draft content…',
                height: editorHeight.toDouble(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print Summary — not wired up yet')),
    );
  }

  Widget _documentCard() {
    final details = ref.read(summariesController).details;
    final baseSummary = details?.summary ?? widget.summary ?? SummaryModel();
    final summary = baseSummary.copyWith(body: _currentHtml);
    return SummaryDocumentCard(
      summary: summary,
      remarkTrack: details?.remarkTrack ?? const [],
      actions: details?.actions,
    );
  }

  StickyTag _buildAttachmentsTag(dynamic details) {
    final attachments = AttachmentsSection(
      mainPdf: null,
      attachments: details?.attachments ?? const [],
      onViewAttachment: (attachment) {
        if (attachment.fileUrl == null) {
          Toast.error(message: 'No file URL found for this attachment.');
          return;
        }
        FileCategory category = HelperUtils.getFileCategoryFromUrl(
          attachment.fileUrl!,
        );
        if (category == FileCategory.pdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewer(
                url: attachment.fileUrl,
                title: attachment.originalName ?? 'Attachment',
              ),
            ),
          );
          return;
        }

        if (category == FileCategory.image) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GalleryView(
                imageUrls: [attachment.fileUrl!],
                initialIndex: 0,
              ),
            ),
          );
          return;
        }

        FilePickerService().downloadFile(
          context,
          attachment.fileUrl!,
          attachment.originalName ?? 'Attachment',
        );
      },
      onDeleteAttachment: (_) {},
      onAddAttachment: (_) {},
    );

    return StickyTag(
      text: "Attachments",
      backgroundColor: AppColors.primaryDark,
      panelContent: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: attachments,
        ),
      ),
    );
  }

  StickyTag _buildBriefsTag(dynamic details) {
    final briefs = details?.briefs ?? const <SummaryBriefModel>[];

    return StickyTag(
      text: "Briefs",
      backgroundColor: Colors.orange,
      panelContent: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        child: briefs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppText.bodyMedium(
                    "No briefs added yet.",
                    color: context.appColors.textSecondary,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < briefs.length; i++) ...[
                    SummaryBrief(
                      note:
                          briefs[i].briefNote != null &&
                              briefs[i].briefNote!.isNotEmpty
                          ? null
                          : null,
                      paragraphs: [
                        if (briefs[i].briefNote != null &&
                            briefs[i].briefNote!.isNotEmpty)
                          briefs[i].briefNote!,
                      ],
                      authorName: briefs[i].actor ?? 'Unknown',
                      authorDesignation: '',
                      timestamp: briefs[i].actedAt ?? DateTime.now(),
                    ),
                    if (i < briefs.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _sidebar() {
    final movement = MovementTimelineSection(
      movements: ref.read(summariesController).details?.movements ?? const [],
      currentHolderName: ref
          .read(summariesController)
          .details
          ?.summary
          ?.currentHolder,
    );

    final internal = InternalForwardSection(
      forwards:
          ref.read(summariesController).details?.internalForwards ?? const [],
    );
    final files = InternalFilesSection(
      links: ref.read(summariesController).details?.localLinks ?? const [],
    );

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          internal,
          const SizedBox(height: 16),
          files,
          const SizedBox(height: 16),
          movement,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sidebarRow(internal, files),
        const SizedBox(height: 16),
        _sidebarRow(movement, const SizedBox.shrink()),
      ],
    );
  }

  Widget _sidebarRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}
