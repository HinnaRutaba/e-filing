import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quill_html_editor_v2/quill_html_editor_v2.dart';

enum SummaryAction {
  editRemarks(
    label: 'Edit Drafted Remarks',
    icon: Icons.edit_outlined,
    color: AppColors.secondary,
    filled: false,
  ),
  signForward(
    label: 'Sign & Forward',
    icon: Icons.arrow_forward_rounded,
    color: Color(0xFFF0A63A),
    filled: true,
  ),
  shareInternally(
    label: 'Share Internally',
    icon: Icons.group_rounded,
    color: AppColors.secondaryDark,
    filled: true,
  ),
  returnToSection(
    label: 'Return to Section',
    icon: Icons.undo_rounded,
    color: AppColors.error,
    filled: false,
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

class SummaryMovementEntry {
  final String status;
  final String stage;
  final String department;
  final String user;
  final bool current;
  const SummaryMovementEntry({
    required this.status,
    required this.stage,
    required this.department,
    required this.user,
    this.current = false,
  });
}

class SummaryDetailsScreen extends ConsumerStatefulWidget {
  final String barcode;
  final String summaryNumber;
  final DateTime summaryDate;
  final String department;
  final String subject;
  final String htmlContent;
  final String recipientTitle;
  final String recipientDesignation;
  final String recipientDepartment;
  final DateTime recipientTimestamp;
  final String destination;
  final XFile? mainPdf;
  final List<FlagAndAttachmentModel> attachments;
  final List<SummaryMovementEntry> movementHistory;

  SummaryDetailsScreen({
    super.key,
    this.barcode = 'SUM/HD/2026/000002',
    this.summaryNumber = 'SUB38888',
    DateTime? summaryDate,
    this.department = 'Home Department',
    this.subject = 'SUB38888',
    this.htmlContent = _kFallbackHtml,
    this.recipientTitle = 'Mr. Secretary',
    this.recipientDesignation = 'Additional Chief Secretary (Home)',
    this.recipientDepartment = 'Home Department',
    DateTime? recipientTimestamp,
    this.destination = 'Governor House',
    XFile? mainPdf,
    List<FlagAndAttachmentModel>? attachments,
    this.movementHistory = const [
      SummaryMovementEntry(
        status: 'Current Pending',
        stage: 'Draft from Section',
        department: 'Home Department',
        user: 'Mr. Secretary',
        current: true,
      ),
    ],
  }) : summaryDate = summaryDate ?? _kDemoDate,
       recipientTimestamp = recipientTimestamp ?? _kDemoTimestamp,
       mainPdf = mainPdf ?? XFile('main_summary.pdf'),
       attachments = attachments ?? _demoAttachments();

  @override
  ConsumerState<SummaryDetailsScreen> createState() =>
      _SummaryDetailsScreenState();
}

final DateTime _kDemoDate = DateTime(2026, 4, 14);
final DateTime _kDemoTimestamp = DateTime(2026, 4, 14, 0, 0);

const String _kFallbackHtml = '''
<p>nb cdcbdnmcbdchndmc dscdbcnscbnmsdc sccscvbnsdc dm cmdvchncvnmdc nsc snmcv dnsmc dmnc dmn cdns cds</p>
''';

List<FlagAndAttachmentModel> _demoAttachments() => [
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 1, title: 'A'),
    attachment: XFile('annexure_a.pdf'),
  ),
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 2, title: 'B'),
    attachment: XFile('annexure_b.pdf'),
  ),
  FlagAndAttachmentModel(
    flagType: FlagModel(id: 3, title: 'C'),
    attachment: XFile('annexure_c.pdf'),
  ),
];

class _SummaryDetailsScreenState extends ConsumerState<SummaryDetailsScreen> {
  SummaryAction? _selectedAction;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _shareSearchController = TextEditingController();
  final QuillEditorController _editDraftController = QuillEditorController();
  late String _currentHtml;
  ChatParticipantModel? _shareTarget;

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

  static final List<ChatParticipantModel> _demoDeptMembers = [
    ChatParticipantModel(
      userId: 101,
      userTitle: 'Ms. Ayesha Khan',
      designation: 'Deputy Secretary (Home)',
    ),
    ChatParticipantModel(
      userId: 102,
      userTitle: 'Mr. Bilal Ahmed',
      designation: 'Section Officer (Home-I)',
    ),
    ChatParticipantModel(
      userId: 103,
      userTitle: 'Ms. Fariha Malik',
      designation: 'Additional Secretary (Home)',
    ),
    ChatParticipantModel(
      userId: 104,
      userTitle: 'Mr. Usman Tariq',
      designation: 'Section Officer (Home-II)',
    ),
    ChatParticipantModel(
      userId: 105,
      userTitle: 'Ms. Sara Javed',
      designation: 'Deputy Secretary (Admin)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentHtml = widget.htmlContent;
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

        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide = constraints.maxWidth >= 900;
                  final content = _documentCard();
                  final sidebar = _sidebar();

                  if (wide) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: content),
                          const SizedBox(width: 16),
                          SizedBox(width: 280, child: sidebar),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [content, const SizedBox(height: 16), sidebar],
                    ),
                  );
                },
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
        color: AppColors.white,
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

  Widget _sectionDraftBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF0A63A).withValues(alpha: 0.35),
        ),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: Color(0xFF7A4A10),
            fontSize: 12.5,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: 'Section Draft',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text:
                  ' — drafted by Mr. Section officer. You can edit the drafted remarks, sign & forward, or return for amendments.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtonRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 720;
        final buttons = SummaryAction.values
            .map((a) => _actionButton(a, expand: wide))
            .toList(growable: false);
        if (wide) {
          return Row(
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: buttons[i]),
              ],
            ],
          );
        }
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
                  : AppColors.white),
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
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodySmall(
                  'Share this summary with a department member for review. They will receive a read-only copy along with your optional instructions.',
                  color: AppColors.secondaryDark,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SearchDropDownField<ChatParticipantModel>(
          controller: _shareSearchController,
          labelText: 'Select Department Members',
          hintText: 'Search users…',
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.secondaryLight.withValues(alpha: 0.5),
            ),
          ),
          suggestionsCallback: (pattern) {
            final q = pattern.toLowerCase();
            return _demoDeptMembers.where((u) {
              return (u.userTitle ?? '').toLowerCase().contains(q) ||
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
                    item.userTitle ?? '',
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
              _shareSearchController.text = item.userTitle ?? '';
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
                        _shareTarget!.userTitle ?? '',
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
    return Column(
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
        color: AppColors.white,
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
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText.labelSmall(
                  stepLabel,
                  color: AppColors.textPrimary,
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
            color: Colors.grey[600],
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
        color: AppColors.textPrimary,
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
      fillColor: AppColors.white,
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
      fillColor: AppColors.white,
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
        AppText.bodySmall(
          'Summary Body',
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToolBar(
                  activeIconColor: action.color,
                  padding: const EdgeInsets.all(4),
                  iconSize: 20,
                  controller: _editDraftController,
                  toolBarConfig: const [
                    ToolBarStyle.bold,
                    ToolBarStyle.italic,
                    ToolBarStyle.underline,
                    ToolBarStyle.listBullet,
                    ToolBarStyle.listOrdered,
                    ToolBarStyle.headerOne,
                    ToolBarStyle.headerTwo,
                    ToolBarStyle.link,
                    ToolBarStyle.align,
                    ToolBarStyle.color,
                    ToolBarStyle.undo,
                    ToolBarStyle.redo,
                    ToolBarStyle.clean,
                  ],
                ),
                Divider(
                  color: AppColors.secondaryLight.withValues(alpha: 0.35),
                  height: 1,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: editorHeight.toDouble(),
                  child: QuillHtmlEditor(
                    text: _currentHtml,
                    hintText: 'Edit draft content…',
                    controller: _editDraftController,
                    minHeight: 180,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    hintTextStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
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
    return SummaryDocumentCard(
      barcode: widget.barcode,
      summaryNumber: widget.summaryNumber,
      summaryDate: widget.summaryDate,
      department: widget.department,
      subject: widget.subject,
      htmlContent: _currentHtml,
      recipientTitle: widget.recipientTitle,
      recipientDesignation: widget.recipientDesignation,
      recipientDepartment: widget.recipientDepartment,
      recipientTimestamp: widget.recipientTimestamp,
      destination: widget.destination,
    );
  }

  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _attachmentsCard(),
        const SizedBox(height: 16),
        _movementCard(),
      ],
    );
  }

  Widget _attachmentsCard() {
    final flagAttachments = widget.attachments
        .where((e) => e.flagType != null || e.attachment != null)
        .toList(growable: false);
    final hasMain = widget.mainPdf != null;
    final isEmpty = !hasMain && flagAttachments.isEmpty;

    return _sidebarShell(
      header: 'Attachments',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMain) ...[
            _attachmentRow(
              label: 'Main Summary PDF',
              fileName: widget.mainPdf!.name,
              isMain: true,
              onView: () => _onViewMainPdf(),
            ),
            if (flagAttachments.isNotEmpty) const SizedBox(height: 8),
          ],
          for (int i = 0; i < flagAttachments.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _attachmentRow(
              label: flagAttachments[i].flagType?.title ?? '?',
              fileName: flagAttachments[i].attachment?.name,
              onView: () => _onViewAttachment(flagAttachments[i]),
              onDelete: () => _confirmDeleteAttachment(flagAttachments[i]),
            ),
          ],
          if (isEmpty)
            AppText.bodySmall(
              'No attachments.',
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _attachmentRow({
    required String label,
    String? fileName,
    bool isMain = false,
    required VoidCallback onView,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          if (isMain)
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 18,
              color: AppColors.error,
            )
          else
            Container(
              width: 26,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: AppText.bodySmall(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryDark,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.bodySmall(
              isMain ? label : (fileName ?? label),
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!isMain && onDelete != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              child: Icon(
                Icons.delete_forever,
                color: Colors.red[700],
                size: 24,
              ),
            ),
          ],
          const SizedBox(width: 8),
          _viewButton(onTap: onView),
        ],
      ),
    );
  }

  Widget _viewButton({required VoidCallback onTap}) {
    return Material(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 13,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onViewAttachment(FlagAndAttachmentModel item) {
    final name = item.attachment?.name ?? item.flagType?.title ?? 'attachment';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Viewing $name')));
  }

  void _onViewMainPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${widget.mainPdf?.name ?? 'Main Summary PDF'}'),
      ),
    );
  }

  Future<void> _confirmDeleteAttachment(FlagAndAttachmentModel item) async {
    final name =
        item.attachment?.name ?? item.flagType?.title ?? 'this attachment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red[700]),
              const SizedBox(width: 10),
              const Expanded(child: Text('Delete attachment?')),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$name"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '? This action cannot be undone.'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            AppTextLinkButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              text: "Cancel",
              color: Colors.grey[700],
            ),
            AppOutlineButton(
              width: 120,
              onPressed: () => Navigator.of(ctx).pop(true),
              text: "Delete",
              color: Colors.red[500]!,
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() => widget.attachments.remove(item));
  }

  Widget _movementCard() {
    final current = widget.movementHistory
        .where((e) => e.current)
        .toList(growable: false);
    final past = widget.movementHistory
        .where((e) => !e.current)
        .toList(growable: false);

    return _sidebarShell(
      header: 'Movement Timeline',
      headerColor: AppColors.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (past.isEmpty)
            AppText.bodySmall(
              'No movement history yet.',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          for (final entry in past) ...[
            _movementEntry(entry),
            const SizedBox(height: 8),
          ],
          if (current.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final entry in current) _movementEntry(entry),
          ],
        ],
      ),
    );
  }

  Widget _movementEntry(SummaryMovementEntry entry) {
    final accent = entry.current ? AppColors.primary : AppColors.secondaryLight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.current
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              AppText.bodySmall(
                entry.status,
                color: accent == AppColors.primary
                    ? AppColors.primaryDark
                    : AppColors.secondaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText.bodyMedium(
            entry.stage,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          const SizedBox(height: 4),
          AppText.bodySmall(
            'Department: ${entry.department}',
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          AppText.bodySmall(
            'User: ${entry.user}',
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _sidebarShell({
    required String header,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.2),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: headerColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                AppText.bodyMedium(
                  header,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
