import 'dart:convert';

import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/summaries_controller.dart';
import 'package:efiling_balochistan/models/summaries/summary_model.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_desk_pager.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/remarks_sign_panel.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CMApprovalDesk extends ConsumerStatefulWidget {
  const CMApprovalDesk({super.key});

  @override
  ConsumerState<CMApprovalDesk> createState() => _CMApprovalDeskState();
}

class _CMApprovalDeskState extends ConsumerState<CMApprovalDesk> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final RemarksSignPanelController _remarksPanelCtrl =
      RemarksSignPanelController();
  final ScrollController _mainScrollController = ScrollController();

  /// Local copy of the summaries list — managed independently so we can
  /// remove items on success without waiting for a full controller re-fetch.
  List<SummaryModel> _localSummaries = [];
  bool _initialized = false;
  bool _allCaughtUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(summariesController.notifier).setSubTab(SummarySubTab.inbox);
    });
  }

  Future<void> _submitFromRemarksPanel() async {
    // 1 – Validate remarks
    final String typedRemarks;
    if (_remarksPanelCtrl.mode == RemarksPanelMode.type) {
      typedRemarks = (await _remarksPanelCtrl.getTypedRemarks()).trim();
      if (!mounted) return;
      if (typedRemarks.isEmpty) {
        Toast.error(message: 'Please type your remarks before approving');
        return;
      }
    } else {
      typedRemarks = '';
      if (_remarksPanelCtrl.isWrittenEmpty) {
        Toast.error(message: 'Please write your remarks before approving');
        return;
      }
    }

    // 2 – Validate signature
    final signatureBytes = await _remarksPanelCtrl.getSignatureBytes();
    if (!mounted) return;
    if (signatureBytes == null || signatureBytes.isEmpty) {
      Toast.error(message: 'Please sign before approving');
      return;
    }

    final summaryId = _localSummaries[_currentPage].id;
    final notifier = ref.read(summariesController.notifier);

    bool success;
    if (_remarksPanelCtrl.mode == RemarksPanelMode.write) {
      final strokesJson = _remarksPanelCtrl.getStrokesJson();
      final handwrittenPng = await _remarksPanelCtrl.getWrittenPngBytes();
      if (!mounted) return;
      final handwrittenBase64 = handwrittenPng != null
          ? 'data:image/png;base64,${base64Encode(handwrittenPng)}'
          : '';
      success = await notifier.signAndReturnCMDesk(
        summaryId: summaryId,
        signatureBytes: signatureBytes,
        handwrittenStrokesJson: strokesJson,
        handwrittenPngBase64: handwrittenBase64,
        handwrittenWidth: _remarksPanelCtrl.canvasWidth.toInt(),
        handwrittenHeight: _remarksPanelCtrl.canvasHeight.toInt(),
        handwrittenPenColor: _remarksPanelCtrl.penColorHex,
      );
    } else {
      success = await notifier.signAndReturnCMDesk(
        summaryId: summaryId,
        signatureBytes: signatureBytes,
        body: typedRemarks,
      );
    }

    if (!mounted) return;
    if (!success) return;

    Toast.success(message: 'Summary signed and returned successfully');

    setState(() {
      _localSummaries.removeAt(_currentPage);
      if (_localSummaries.isEmpty) {
        _allCaughtUp = true;
      } else if (_currentPage >= _localSummaries.length) {
        // Was on the last page — stay on the new last
        _currentPage = _localSummaries.length - 1;
        _pageController.jumpToPage(_currentPage);
      }
      // Otherwise the PageView naturally shows the next summary at the same index
    });
  }

  void _goNext() {
    final total = _localSummaries.length;
    if (_currentPage < total - 1) {
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
    final ctrlState = ref.watch(summariesController);
    final isLoading = ctrlState.isLoading;

    // Populate local list once the first fetch completes
    ref.listen<SummariesState>(summariesController, (prev, next) {
      if (!_initialized && !next.isLoading) {
        setState(() {
          _localSummaries = List.of(next.allSummaries);
          _initialized = true;
        });
      }
    });

    final bool canBack = _currentPage > 0;
    const bool canNext = true;

    Widget body;
    if (isLoading && !_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_allCaughtUp || _localSummaries.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            AppText.headlineSmall("You're all caught up!"),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              'No summaries are pending your approval.',
              color: AppColors.secondaryDark,
            ),
            const SizedBox(height: 16),
            AppOutlineButton(
              onPressed: () {
                ref.read(cmNavController.notifier).select(CMNavTab.dashboard);
              },
              text: "Open Dashboard",
            ),
          ],
        ),
      );
    } else if (!_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Padding(
        padding: const EdgeInsets.only(bottom: 52.0),
        child: Column(
          children: [
            _buildPager(
              canBack: canBack,
              canNext: canNext,
              total: _localSummaries.length,
            ),
            Expanded(
              child: SummaryDeskPager(
                summaries: _localSummaries,
                pageController: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                remarksPanelController: _remarksPanelCtrl,
                mainScrollController: _mainScrollController,
                bottomContent: _submitButton(),
                initialRemarksMode: RemarksPanelMode.write,
                initialPenColor: SignatureColor.darkGreen,
              ),
            ),
          ],
        ),
      );
    }

    return body;
  }

  Widget _buildPager({
    required bool canBack,
    required bool canNext,
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppOutlineButton(
            onPressed: canBack ? _goBack : null,
            text: 'Back',
            icon: Icons.arrow_back_rounded,
            color: canBack ? AppColors.secondaryDark : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          AppText.labelLarge(
            '${_currentPage + 1} / $total',
            color: context.appColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          AppSolidButton(
            onPressed: canNext ? _goNext : null,
            text: 'Skip',
            icon: Icons.arrow_forward_rounded,
            backgroundColor: AppColors.secondaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            width: null,
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return AppSolidButton(
      onPressed: _submitFromRemarksPanel,
      text: 'Sign and Return',
      icon: Icons.check_rounded,
      width: double.infinity,
    );
  }
}
