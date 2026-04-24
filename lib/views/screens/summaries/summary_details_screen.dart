import 'dart:convert';

import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/internal_user_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_brief_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/utils/file_picker_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/gallery/gallery_view.dart';
import 'package:efiling_balochistan/views/screens/pdf_viewer.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
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
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efiling_balochistan/views/widgets/html_editor.dart';

enum _RemarksMode { type, write }

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
  bool _loadingAction = false;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _shareSearchController = TextEditingController();
  final HtmlEditorController _editDraftController = HtmlEditorController();
  late String _currentHtml;
  final List<InternalUserModel> _shareTargets = [];
  final List<FlagAndAttachmentModel> _pendingAttachments = [];

  final SignaturePadController _signaturePadController =
      SignaturePadController();

  // Handwritten remarks
  _RemarksMode _remarksMode = _RemarksMode.type;
  bool _remarksPanelExpanded = true;
  final HtmlEditorController _remarksHtmlCtrl = HtmlEditorController();
  final SignaturePadController _remarksPadCtrl = SignaturePadController();
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _remarksPanelKey = GlobalKey();
  double _remarksPadWidth = 0;

  final TextEditingController _destDeptController = TextEditingController();
  final TextEditingController _destOfficerController = TextEditingController();

  DepartmentModel? _selectedDestDept;
  DepartmentSecretariesModel? _selectedDestOfficer;
  int? _officerCacheDeptId;
  List<DepartmentSecretariesModel> _officerCache = const [];
  Uint8List? _cardSignatureBytes;

  Future<void> _fetchOfficersForCurrentDept() async {
    final deptId = _selectedDestDept?.id;
    if (deptId == null) {
      if (mounted) {
        setState(() {
          _officerCache = const [];
          _officerCacheDeptId = null;
        });
      }
      return;
    }
    if (_officerCacheDeptId == deptId) return;
    final list = await ref
        .read(summariesController.notifier)
        .fetchDepartmentSecretaries(deptId: deptId);
    if (!mounted) return;
    setState(() {
      _officerCache = list;
      _officerCacheDeptId = deptId;
      if (list.length == 1) {
        _selectedDestOfficer = list.first;
        _destOfficerController.text = list.first.name ?? '';
      }
    });
  }

  DepartmentModel? _matchDepartment(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final departments =
        ref.read(summariesController).meta?.departments ??
        const <DepartmentModel>[];
    final normalized = name.trim().toLowerCase();
    for (final d in departments) {
      if ((d.title ?? '').trim().toLowerCase() == normalized) return d;
    }
    return null;
  }

  ActiveUserDesg? get userDesg {
    return ref.read(summariesController).meta?.activeUserDesg;
  }

  bool get actionsAvailable {
    final ActiveUserDesg? activeUser = userDesg;
    SummaryDetailsModel? details = ref.read(summariesController).details;
    if (activeUser?.roleEnum == ActiveUserDesgRole.deo &&
        details?.summary?.summaryStatus == SummaryStatus.draftFromSection) {
      return false;
    }
    if (activeUser?.roleEnum == ActiveUserDesgRole.secretary &&
        details?.summary?.currentHolder != activeUser?.name) {
      return false;
    }
    return true;
  }

  bool get showHandWrittedRemarksSection {
    SummaryDetailsModel? details = ref.read(summariesController).details;
    return details?.hasForwardedBefore == true &&
        details?.isLatestRemarksAdded != true;
  }

  @override
  void initState() {
    super.initState();
    _currentHtml = widget.summary?.body ?? _kFallbackHtml;
    final initialTarget = widget.summary?.draftTargetDepartment;
    if (initialTarget != null && initialTarget.isNotEmpty) {
      _destDeptController.text = initialTarget;
      _selectedDestDept = _matchDepartment(initialTarget);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
      _fetchOfficersForCurrentDept();
    });
  }

  Future<void> _loadDetails() async {
    final details = await ref
        .read(summariesController.notifier)
        .fetchSummaryDetails(summaryId: widget.summary?.id);
    ref.read(filesController.notifier).getFlags();
    if (!mounted) return;
    final body = details?.summary?.body;
    if (body != null && body.isNotEmpty) {
      setState(() => _currentHtml = body);
    }
    final target = details?.summary?.draftTargetDepartment;
    if (target != null && target.isNotEmpty) {
      setState(() {
        _destDeptController.text = target;
        _selectedDestDept = _matchDepartment(target);
      });
      _fetchOfficersForCurrentDept();
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _shareSearchController.dispose();
    _destDeptController.dispose();
    _destOfficerController.dispose();
    _mainScrollController.dispose();
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
                          controller: _mainScrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(context.isMobile ? 12 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _documentCard(),
                              if (actionsAvailable &&
                                  showHandWrittedRemarksSection) ...[
                                _remarksPanel(),
                              ],
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
    if (action == SummaryAction.signForward && showHandWrittedRemarksSection) {
      setState(() => _remarksPanelExpanded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _remarksPanelKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            alignment: 0.05,
          );
        }
        _submitFromRemarksPanel();
      });
      return;
    }

    if (action == SummaryAction.signForward) {
      final hasSigned =
          _cardSignatureBytes != null && _cardSignatureBytes!.isNotEmpty;
      final hasDept = _selectedDestDept?.id != null;
      final hasOfficer =
          _selectedDestOfficer?.userDesgId != null ||
          (_officerCacheDeptId == _selectedDestDept?.id &&
              _officerCache.isEmpty);
      if (hasSigned && hasDept && hasOfficer) {
        _submitSignForward();
        return;
      }
    }

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

    final summaryId =
        ref.read(summariesController).details?.summary?.id ??
        widget.summary?.id;
    final notifier = ref.read(summariesController.notifier);
    bool success = true;

    if (action == SummaryAction.editRemarks) {
      final newHtml = await _editDraftController.getText();
      if (!mounted) return;
      setState(() {
        _loadingAction = true;
      });
      success = await notifier.updateDraftContent(
        summaryId: summaryId,
        body: newHtml,
      );
      if (!mounted) return;
      if (success) {
        setState(() {
          _loadingAction = false;
          _currentHtml = newHtml;
        });
      }
    } else if (action == SummaryAction.returnToSection) {
      final remark = _remarksController.text.trim();
      if (remark.isEmpty) {
        Toast.error(message: 'Please enter remarks for the section');
        return;
      }
      setState(() {
        _loadingAction = true;
      });
      success = await notifier.returnToSection(
        summaryId: summaryId,
        remark: remark,
      );
      setState(() {
        _loadingAction = true;
      });
    } else if (action == SummaryAction.shareInternally) {
      final recipientIds = _shareTargets
          .map((u) => u.userDesgId)
          .whereType<int>()
          .toList();
      if (recipientIds.isEmpty) {
        Toast.error(message: 'Please select at least one department member');
        return;
      }
      setState(() {
        _loadingAction = true;
      });
      success = await notifier.shareInternally(
        summaryId: summaryId,
        instruction: _remarksController.text.trim(),
        recipientDesIds: recipientIds,
      );
      if (!mounted) return;

      if (success) {
        _shareTargets.clear();
        _shareSearchController.clear();
      }
      setState(() {
        _loadingAction = false;
      });
    }

    if (!mounted) return;
    if (success) {
      setState(() {
        _selectedAction = null;
        _remarksController.clear();
      });
    }
  }

  Widget _actionBar() {
    if (!actionsAvailable) {
      return const SizedBox.shrink();
    }
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
    final bool isSignedAndForwarded =
        ref
            .read(summariesController)
            .details
            ?.isLatestMovementSignedAndForwarded ==
        true;
    final allowedActions = isSignedAndForwarded
        ? [SummaryAction.shareInternally, SummaryAction.signForward]
        : SummaryAction.values;
    final isMobile = context.isMobile;
    final buttons = allowedActions
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
    if (_loadingAction) {
      return SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: action.color,
            ),
          ),
        ),
      );
    }
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
            final selectedIds = _shareTargets
                .map((u) => u.userDesgId)
                .whereType<int>()
                .toSet();
            return users.where((u) {
              if (u.userDesgId != null && selectedIds.contains(u.userDesgId)) {
                return false;
              }
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
              final alreadyPicked =
                  item.userDesgId != null &&
                  _shareTargets.any((u) => u.userDesgId == item.userDesgId);
              if (!alreadyPicked) {
                _shareTargets.add(item);
              }
              _shareSearchController.clear();
            });
          },
        ),
        if (_shareTargets.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (int i = 0; i < _shareTargets.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _shareTargetCard(_shareTargets[i]),
          ],
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

  Widget _shareTargetCard(InternalUserModel user) {
    return Container(
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
                  user.name ?? '',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                AppText.bodySmall(
                  user.designation ?? '',
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _shareTargets.removeWhere(
                  (u) => u.userDesgId == user.userDesgId,
                );
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

  Widget _remarksPanel() {
    return Container(
      key: _remarksPanelKey,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible
          InkWell(
            onTap: () =>
                setState(() => _remarksPanelExpanded = !_remarksPanelExpanded),
            borderRadius: _remarksPanelExpanded
                ? const BorderRadius.vertical(top: Radius.circular(4))
                : BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(child: AppText.titleLarge("Add your remarks")),
                  AnimatedRotation(
                    turns: _remarksPanelExpanded ? 0 : -0.5,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body — animated open/close
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _remarksPanelExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _remarksModeToggle(),
                        const SizedBox(height: 4),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Type your remark or switch to Write and use your tablet pen. '
                                'Your handwriting will appear on the printed summary as proof of authorship.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _remarksMode == _RemarksMode.type
                              ? _typedRemarksField()
                              : _handwrittenRemarksCanvas(),
                        ),
                        const Divider(height: 24),
                        AppText.titleLarge("Sign here"),
                        const SizedBox(height: 16),
                        SignaturePad(controller: _signaturePadController),
                        const SizedBox(height: 16),
                        _forwardingFields(),
                        const SizedBox(height: 16),
                        _actionButton(
                          SummaryAction.signForward,
                          expand: false,
                          width: double.infinity,
                          onTapOverride: _submitFromRemarksPanel,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _remarksModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _remarksModeOption(
            'Type',
            _RemarksMode.type,
            Icons.keyboard_alt_outlined,
          ),
          _remarksModeOption('Write', _RemarksMode.write, Icons.draw_outlined),
        ],
      ),
    );
  }

  Widget _remarksModeOption(String label, _RemarksMode mode, IconData icon) {
    final isSelected = _remarksMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _remarksMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              AppText.labelMedium(
                label,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typedRemarksField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        key: const ValueKey('remarks_typed'),
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondaryLight.withValues(alpha: 0.4),
          ),
        ),
        child: HtmlEditor(
          controller: _remarksHtmlCtrl,
          hint: 'Type your remarks here…',
          height: 240,
        ),
      ),
    );
  }

  Widget _handwrittenRemarksCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Capture the available width so _submitFromRemarksPanel can encode strokes
        if (_remarksPadWidth != constraints.maxWidth) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _remarksPadWidth = constraints.maxWidth),
          );
        }
        return SignaturePad(
          key: const ValueKey('remarks_written'),
          controller: _remarksPadCtrl,
          showRuledLines: true,
          autoExpand: true,
          autoExpandStep: 120,
          showStrokeInfo: true,
          showCustomColorPicker: true,
          canvasHeight: 280,
          showDescription: false,
          canvasColor: Colors.grey.shade50,
          onExpand: () {
            if (!_mainScrollController.hasClients) return;
            final pos = _mainScrollController.position;
            final target = (pos.pixels + 120).clamp(0.0, pos.maxScrollExtent);
            _mainScrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        );
      },
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
    return _forwardingFields();
  }

  /// Submit from the remarks panel (used when [showHandWrittedRemarksSection]
  /// is true and the user taps Sign & Forward from the action bar).
  Future<void> _submitFromRemarksPanel() async {
    // 1 – Validate remarks
    final bool hasTyped;
    final String typedRemarks;
    if (_remarksMode == _RemarksMode.type) {
      typedRemarks = (await _remarksHtmlCtrl.getText()).trim();
      if (!mounted) return;
      hasTyped = typedRemarks.isNotEmpty;
      if (!hasTyped) {
        Toast.error(message: 'Please type your remarks before forwarding');
        return;
      }
    } else {
      typedRemarks = '';
      if (_remarksPadCtrl.isEmpty) {
        Toast.error(message: 'Please write your remarks before forwarding');
        return;
      }
    }

    // 2 – Validate signature
    final signatureBytes = await _signaturePadController.toPngBytes();
    if (!mounted) return;
    if (signatureBytes == null || signatureBytes.isEmpty) {
      Toast.error(message: 'Please sign in the "Sign here" section');
      return;
    }

    // 3 – Validate forwarding destination
    final deptId = _selectedDestDept?.id;
    if (deptId == null) {
      Toast.error(message: 'Please select a destination department');
      return;
    }
    final hasOfficers =
        _officerCacheDeptId == deptId && _officerCache.isNotEmpty;
    if (hasOfficers && _selectedDestOfficer?.userDesgId == null) {
      Toast.error(message: 'Please select a destination officer');
      return;
    }

    final summaryId =
        ref.read(summariesController).details?.summary?.id ??
        widget.summary?.id;
    final notifier = ref.read(summariesController.notifier);

    bool success;
    if (_remarksMode == _RemarksMode.write) {
      // Handwritten path
      final strokesJson = _remarksPadCtrl.toStrokesJson(
        canvasWidth: _remarksPadWidth > 0 ? _remarksPadWidth : 600,
      );
      final handwrittenPng = await _remarksPadCtrl.toPngBytes();
      if (!mounted) return;
      final handwrittenBase64 = handwrittenPng != null
          ? 'data:image/png;base64,${base64Encode(handwrittenPng)}'
          : '';
      final penHex = _remarksPadCtrl.penColorHex;
      success = await notifier.signAndForward(
        summaryId: summaryId,
        signatureBytes: signatureBytes,
        targetDepartmentId: deptId,
        targetUserDesgId: _selectedDestOfficer?.userDesgId,
        handwrittenStrokesJson: strokesJson,
        handwrittenPngBase64: handwrittenBase64,
        handwrittenWidth: _remarksPadWidth.toInt(),
        handwrittenHeight: _remarksPadCtrl.canvasHeight.toInt(),
        handwrittenPenColor: penHex,
      );
    } else {
      // Typed path
      success = await notifier.signAndForward(
        summaryId: summaryId,
        signatureBytes: signatureBytes,
        targetDepartmentId: deptId,
        targetUserDesgId: _selectedDestOfficer?.userDesgId,
        remarks: typedRemarks,
      );
    }

    if (!mounted) return;
    if (success) {
      setState(() {
        _selectedAction = null;
      });
    }
  }

  Future<void> _submitSignForward() async {
    if (_cardSignatureBytes == null || _cardSignatureBytes!.isEmpty) {
      Toast.error(message: 'Please sign before forwarding');
      return;
    }
    final deptId = _selectedDestDept?.id;
    if (deptId == null) {
      Toast.error(message: 'Please select a destination department');
      return;
    }
    final hasOfficers =
        _officerCacheDeptId == deptId && _officerCache.isNotEmpty;
    if (hasOfficers && _selectedDestOfficer?.id == null) {
      Toast.error(message: 'Please select a destination officer');
      return;
    }

    final summaryId =
        ref.read(summariesController).details?.summary?.id ??
        widget.summary?.id;
    final notifier = ref.read(summariesController.notifier);

    String remarks = '';
    if (_selectedAction == SummaryAction.signForward) {
      try {
        remarks = (await _remarksHtmlCtrl.getText()).trim();
      } catch (_) {
        remarks = '';
      }
    }
    if (!mounted) return;

    final success = await notifier.signAndForward(
      summaryId: summaryId,
      signatureBytes: _cardSignatureBytes!,
      targetDepartmentId: deptId,
      targetUserDesgId: _selectedDestOfficer?.userDesgId,
      remarks: remarks.trim(),
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _selectedAction = null;
        _cardSignatureBytes = null;
      });
    }
  }

  Widget _forwardingFields({bool showForwardButton = false}) {
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
        if (_selectedDestDept?.id != null &&
            _officerCacheDeptId == _selectedDestDept?.id &&
            _officerCache.isEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'No user found for selected department.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.red[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (showForwardButton) ...[
          const SizedBox(height: 14),
          _actionButton(
            SummaryAction.signForward,
            expand: false,
            width: double.infinity,
            onTapOverride: _submitSignForward,
          ),
        ],
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
    final departments =
        ref.watch(summariesController).meta?.departments ??
        const <DepartmentModel>[];
    return SearchDropDownField<DepartmentModel>(
      controller: _destDeptController,
      labelText: 'Destination Department',
      hintText: 'Select department',
      showLabel: false,

      border: _forwardingBorder(),
      suggestionsCallback: (pattern) {
        final q = pattern.toLowerCase();
        return departments
            .where((d) => (d.title ?? '').toLowerCase().contains(q))
            .toList(growable: false);
      },
      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: AppText.bodyMedium(
            item.title ?? '',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      },
      onSelected: (item) {
        setState(() {
          _selectedDestDept = item;
          _destDeptController.text = item.title ?? '';
          _selectedDestOfficer = null;
          _destOfficerController.clear();
          _officerCacheDeptId = null;
          _officerCache = const [];
        });
        _fetchOfficersForCurrentDept();
      },
    );
  }

  Widget _officerDropdown() {
    final dept = _selectedDestDept;
    return SearchDropDownField<DepartmentSecretariesModel>(
      controller: _destOfficerController,
      labelText: 'Destination Officer',
      hintText: 'Select officer',
      showLabel: false,
      enabled: dept?.id != null,
      border: _forwardingBorder(),
      suggestionsCallback: (pattern) {
        final q = pattern.toLowerCase();
        return _officerCache
            .where((o) {
              return (o.name ?? '').toLowerCase().contains(q) ||
                  (o.designation ?? '').toLowerCase().contains(q);
            })
            .toList(growable: false);
      },
      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMedium(
                item.name ?? '',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              if ((item.designation ?? '').isNotEmpty)
                AppText.bodySmall(
                  item.designation!,
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
            ],
          ),
        );
      },
      onSelected: (item) {
        setState(() {
          _selectedDestOfficer = item;
          _destOfficerController.text = item.name ?? '';
        });
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

  void _onPrint() {}

  Widget _documentCard() {
    final details = ref.read(summariesController).details;
    final baseSummary = details?.summary ?? widget.summary ?? SummaryModel();
    final summary = baseSummary.copyWith(body: _currentHtml);
    return SummaryDocumentCard(
      summary: summary,
      remarkTrack: details?.remarkTrack ?? const [],
      actions: details?.actions,
      forwardingSection: actionsAvailable
          ? _forwardingFields(showForwardButton: true)
          : null,
      onSignatureChanged: (bytes) {
        setState(() => _cardSignatureBytes = bytes);
      },
    );
  }

  StickyTag _buildAttachmentsTag(dynamic details) {
    final savedAttachments = details?.attachments ?? const [];
    final totalAttachments =
        (savedAttachments as List).length + _pendingAttachments.length;
    final attachments = AttachmentsSection(
      canAddMore:
          actionsAvailable && userDesg?.roleEnum == ActiveUserDesgRole.deo,
      canDelete: false, //actionsAvailable,
      mainPdf: null,
      attachments: details?.attachments ?? const [],
      pendingAttachments: _pendingAttachments,
      onRemovePendingAttachment: (index) {
        setState(() {
          _pendingAttachments.removeAt(index);
        });
      },
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
      onDeleteAttachment: (attachment) {
        ref.read(summariesController.notifier).deleteAttachment(attachment.id);
      },
      onAddAttachment: (model) {
        setState(() {
          _pendingAttachments.add(model);
        });
      },
    );

    return StickyTag(
      text: "Attachments ($totalAttachments)",
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
      text: "Briefs (${briefs.length})",
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
          files,
          const SizedBox(height: 16),
          movement,
          const SizedBox(height: 16),
          internal,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sidebarRow(files, movement),
        const SizedBox(height: 16),
        _sidebarRow(internal, const SizedBox.shrink()),
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
