import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_desk_pager.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/remarks_sign_panel.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final RemarksSignPanelController _remarksPanelCtrl =
      RemarksSignPanelController();
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _remarksPanelKey = GlobalKey();

  Future<void> _submitFromRemarksPanel() async {
    if (_remarksPanelCtrl.mode == RemarksPanelMode.type) {
      final text = (await _remarksPanelCtrl.getTypedRemarks()).trim();
      if (!mounted) return;
      if (text.isEmpty) {
        Toast.error(message: 'Please type your remarks before approving');
        return;
      }
    } else {
      if (_remarksPanelCtrl.isWrittenEmpty) {
        Toast.error(message: 'Please write your remarks before approving');
        return;
      }
    }

    final signatureBytes = await _remarksPanelCtrl.getSignatureBytes();
    if (!mounted) return;
    if (signatureBytes == null || signatureBytes.isEmpty) {
      Toast.error(message: 'Please sign before approving');
      return;
    }

    // TODO: call the CM approve API with signatureBytes, remarks/strokes
    Toast.success(message: 'Approved successfully');
  }

  final List<SummaryModel> _summaries = [
    SummaryModel(
      summaryNo: 'No. 01/CM/2026',
      summaryDate: DateTime.now(),
      originatingDepartment: 'Home Department',
      subject: 'Sample Summary Subject One',
      body:
          '<p>This is a placeholder summary document content for item one.</p>',
      currentHolder: 'Mr. Chief Minister',
      currentHolderDesignation: 'Chief Minister',
      currentDepartment: 'Chief Minister Secretariat',
      draftTargetDepartment: 'Quetta',
      updatedAt: DateTime.now(),
    ),
    SummaryModel(
      summaryNo: 'No. 02/CM/2026',
      summaryDate: DateTime.now(),
      originatingDepartment: 'Finance Department',
      subject: 'Sample Summary Subject Two',
      body:
          '<p>This is a placeholder summary document content for item two.</p>',
      currentHolder: 'Mr. Chief Minister',
      currentHolderDesignation: 'Chief Minister',
      currentDepartment: 'Chief Minister Secretariat',
      draftTargetDepartment: 'Quetta',
      updatedAt: DateTime.now(),
    ),
    SummaryModel(
      summaryNo: 'No. 03/CM/2026',
      summaryDate: DateTime.now(),
      originatingDepartment: 'Education Department',
      subject: 'Sample Summary Subject Three',
      body:
          '<p>This is a placeholder summary document content for item three.</p>',
      currentHolder: 'Mr. Chief Minister',
      currentHolderDesignation: 'Chief Minister',
      currentDepartment: 'Chief Minister Secretariat',
      draftTargetDepartment: 'Quetta',
      updatedAt: DateTime.now(),
    ),
  ];

  void _goNext() {
    if (_currentPage < _summaries.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainScrollController.dispose();
    _remarksPanelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canBack = _currentPage > 0;
    const bool canNext = true;

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: SummaryDeskPager(
                summaries: _summaries,
                pageController: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                remarksPanelController: _remarksPanelCtrl,
                mainScrollController: _mainScrollController,
                remarksPanelKey: _remarksPanelKey,
                bottomContent: _submitButton(),
                initialRemarksMode: RemarksPanelMode.write,
              ),
            ),
            _buildPager(canBack: canBack, canNext: canNext),
          ],
        ),
      ),
    );
  }

  Widget _buildPager({required bool canBack, required bool canNext}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navButton(
            icon: Icons.arrow_back_rounded,
            label: 'Back',
            enabled: canBack,
            onTap: _goBack,
          ),
          AppText.labelLarge(
            '${_currentPage + 1} / ${_summaries.length}',
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          _navButton(
            icon: Icons.arrow_forward_rounded,
            label: 'Next',
            enabled: canNext,
            onTap: _goNext,
            iconTrailing: true,
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool iconTrailing = false,
  }) {
    final color = enabled
        ? context.appColors.textPrimary
        : context.appColors.textPrimary.withValues(alpha: 0.35);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!iconTrailing) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              AppText.labelLarge(
                label,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              if (iconTrailing) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _submitFromRemarksPanel,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text(
          'Approve & Sign',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
