import 'dart:convert';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/controllers/cm_nav_controller.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/models/department/department_secretaries_model.dart';
import 'package:efiling_balochistan/models/summaries/summary_details_model.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_desk_pager.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/remarks_sign_panel.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApprovalDesk extends ConsumerStatefulWidget {
  final ActiveUserDesgRole role;

  /// When true, skips the automatic load on [initState]. The parent is
  /// responsible for triggering loads (e.g. via [cmApprovalDeskRefreshProvider]).
  final bool skipInitialLoad;

  const ApprovalDesk({
    super.key,
    required this.role,
    this.skipInitialLoad = false,
  });

  @override
  ConsumerState<ApprovalDesk> createState() => _ApprovalDeskState();
}

class _ApprovalDeskState extends ConsumerState<ApprovalDesk> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final RemarksSignPanelController _remarksPanelCtrl =
      RemarksSignPanelController();

  List<SummaryDetailsModel> _localDetails = [];
  bool _initialized = false;
  bool _isLoading = false;
  bool _allCaughtUp = false;

  final ScrollController _stickyPanelScrollController = ScrollController();
  GlobalKey _remarksPanelKey = GlobalKey();
  ScrollController? _currentPageScrollController;

  // Secretary forwarding fields
  final TextEditingController _destDeptController = TextEditingController();
  final TextEditingController _destOfficerController = TextEditingController();
  DepartmentModel? _selectedDestDept;
  DepartmentSecretariesModel? _selectedDestOfficer;
  int? _officerCacheDeptId;
  List<DepartmentSecretariesModel> _officerCache = const [];

  bool get isCm => widget.role == ActiveUserDesgRole.cm;

  bool get isSecretary => widget.role == ActiveUserDesgRole.secretary;

  @override
  void initState() {
    super.initState();
    _remarksPanelCtrl.addListener(_onPanelChanged);
    if (!widget.skipInitialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDesk());
    }
  }

  void _onPanelChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadDesk() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final details = await ref
        .read(summariesController.notifier)
        .getSummariesDesk();
    if (!mounted) return;
    setState(() {
      _localDetails = details;
      _initialized = true;
      _isLoading = false;
    });
  }

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

  void _scrollToRemarksSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _remarksPanelCtrl.remarksPadKey?.currentContext;
      if (ctx == null) return;
      final renderObj = ctx.findRenderObject();
      if (renderObj == null || !renderObj.attached) return;
      Scrollable.maybeOf(ctx)?.position.ensureVisible(
        renderObj,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );
    });
  }

  void _scrollToSignatureSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _remarksPanelCtrl.signPadKey?.currentContext;
      if (ctx == null) return;
      final renderObj = ctx.findRenderObject();
      if (renderObj == null || !renderObj.attached) return;
      Scrollable.maybeOf(ctx)?.position.ensureVisible(
        renderObj,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );
    });
  }

  void _scrollPanelToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sc = _remarksPanelCtrl.isLocked
          ? _stickyPanelScrollController
          : _currentPageScrollController;
      if (sc == null || !sc.hasClients) return;
      sc.animateTo(
        sc.position.maxScrollExtent,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
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
        _scrollToRemarksSection();
        return;
      }
    } else {
      typedRemarks = '';
      if (_remarksPanelCtrl.isWrittenEmpty) {
        Toast.error(message: 'Please write your remarks before approving');
        _scrollToRemarksSection();
        return;
      }
    }

    // 2 – Validate signature
    final signatureBytes = await _remarksPanelCtrl.getSignatureBytes();
    if (!mounted) return;
    if (signatureBytes == null || signatureBytes.isEmpty) {
      Toast.error(message: 'Please sign before approving');
      _scrollToSignatureSection();
      return;
    }

    final summaryId = _localDetails[_currentPage].summary?.id;
    final notifier = ref.read(summariesController.notifier);

    if (isSecretary) {
      // 3 – Validate forwarding destination
      final deptId = _selectedDestDept?.id;
      if (deptId == null) {
        Toast.error(message: 'Please select a destination department');
        _scrollPanelToBottom();
        return;
      }
      final hasOfficers =
          _officerCacheDeptId == deptId && _officerCache.isNotEmpty;
      if (hasOfficers && _selectedDestOfficer?.userDesgId == null) {
        Toast.error(message: 'Please select a destination officer');
        _scrollPanelToBottom();
        return;
      }

      bool success;
      if (_remarksPanelCtrl.mode == RemarksPanelMode.write) {
        final strokesJson = _remarksPanelCtrl.getStrokesJson();
        final handwrittenPng = await _remarksPanelCtrl.getWrittenPngBytes();
        if (!mounted) return;
        final handwrittenBase64 = handwrittenPng != null
            ? 'data:image/png;base64,${base64Encode(handwrittenPng)}'
            : '';
        success = await notifier.signAndForward(
          summaryId: summaryId,
          signatureBytes: signatureBytes,
          targetDepartmentId: deptId,
          targetUserDesgId: _selectedDestOfficer?.userDesgId,
          handwrittenStrokesJson: strokesJson,
          handwrittenPngBase64: handwrittenBase64,
          handwrittenWidth: _remarksPanelCtrl.canvasWidth.toInt(),
          handwrittenHeight: _remarksPanelCtrl.canvasHeight.toInt(),
          handwrittenPenColor: _remarksPanelCtrl.penColorHex,
        );
      } else {
        success = await notifier.signAndForward(
          summaryId: summaryId,
          signatureBytes: signatureBytes,
          targetDepartmentId: deptId,
          targetUserDesgId: _selectedDestOfficer?.userDesgId,
          remarks: typedRemarks,
        );
      }

      if (!mounted) return;
      if (!success) return;
    } else {
      // CM path
      List<SummaryDetailsModel>? freshDesk;
      if (_remarksPanelCtrl.mode == RemarksPanelMode.write) {
        final strokesJson = _remarksPanelCtrl.getStrokesJson();
        final handwrittenPng = await _remarksPanelCtrl.getWrittenPngBytes();
        if (!mounted) return;
        final handwrittenBase64 = handwrittenPng != null
            ? 'data:image/png;base64,${base64Encode(handwrittenPng)}'
            : '';
        freshDesk = await notifier.signAndReturnCMDesk(
          summaryId: summaryId,
          signatureBytes: signatureBytes,
          handwrittenStrokesJson: strokesJson,
          handwrittenPngBase64: handwrittenBase64,
          handwrittenWidth: _remarksPanelCtrl.canvasWidth.toInt(),
          handwrittenHeight: _remarksPanelCtrl.canvasHeight.toInt(),
          handwrittenPenColor: _remarksPanelCtrl.penColorHex,
        );
      } else {
        freshDesk = await notifier.signAndReturnCMDesk(
          summaryId: summaryId,
          signatureBytes: signatureBytes,
          body: typedRemarks,
        );
      }

      if (!mounted) return;
      if (freshDesk == null) return;

      Toast.success(message: 'Summary signed and returned successfully');

      if (freshDesk.isEmpty) {
        setState(() {
          _localDetails = freshDesk!;
          _allCaughtUp = true;
        });
        return;
      }

      // Animate away from the current page before applying the fresh list
      final removedIdx = _currentPage;
      final animateToIdx = removedIdx < freshDesk.length
          ? removedIdx
          : freshDesk.length - 1;

      await _pageController.animateToPage(
        animateToIdx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );

      if (!mounted) return;

      _remarksPanelCtrl.reset();
      _destDeptController.clear();
      _destOfficerController.clear();
      setState(() {
        _localDetails = freshDesk!;
        _currentPage = animateToIdx;
        _pageController.jumpToPage(_currentPage);
        _selectedDestDept = null;
        _selectedDestOfficer = null;
      });
      return;
    }

    final removedIdx = _currentPage;
    final totalAfter = _localDetails.length - 1;

    if (totalAfter == 0) {
      setState(() {
        _localDetails.removeAt(removedIdx);
        _allCaughtUp = true;
      });
      return;
    }

    // Animate to the next summary before removing the completed one
    final animateToIdx = removedIdx < _localDetails.length - 1
        ? removedIdx + 1
        : removedIdx - 1;

    await _pageController.animateToPage(
      animateToIdx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;

    _remarksPanelCtrl.reset();
    _destDeptController.clear();
    _destOfficerController.clear();
    setState(() {
      _localDetails.removeAt(removedIdx);
      // After removing removedIdx, animateToIdx shifts left by 1 if it was ahead
      _currentPage = animateToIdx > removedIdx
          ? animateToIdx - 1
          : animateToIdx;
      _pageController.jumpToPage(_currentPage);
      _selectedDestDept = null;
      _selectedDestOfficer = null;
      _officerCacheDeptId = null;
      _officerCache = const [];
    });
  }

  void _goNext() {
    final total = _localDetails.length;
    if (total == 1) {
      Toast.show(message: "You only have one summary pending approval");
      return;
    }
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
    _remarksPanelCtrl.removeListener(_onPanelChanged);
    _pageController.dispose();
    _remarksPanelCtrl.dispose();
    _destDeptController.dispose();
    _destOfficerController.dispose();
    _stickyPanelScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skipInitialLoad) {
      ref.listen(cmApprovalDeskRefreshProvider, (_, __) => _loadDesk());
    }

    final bool canBack = _currentPage > 0;
    const bool canNext = true;

    Widget body;
    if (_isLoading && !_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_allCaughtUp || _localDetails.isEmpty) {
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
                if (isCm) {
                  ref.read(cmNavController.notifier).select(CMNavTab.dashboard);
                } else {
                  RouteHelper.pop();
                }
              },
              text: "Open Dashboard",
            ),
          ],
        ),
      );
    } else if (!_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final isLocked = _remarksPanelCtrl.isLocked;
      body = Padding(
        padding: const EdgeInsets.only(bottom: 52.0),
        child: Column(
          children: [
            _buildPager(
              canBack: canBack,
              canNext: canNext,
              total: _localDetails.length,
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SummaryDeskPager(
                      summaries: _localDetails,
                      pageController: _pageController,
                      onPageChanged: (i) => setState(() {
                        _currentPage = i;
                        _remarksPanelKey = GlobalKey();
                      }),
                      remarksPanelController: _remarksPanelCtrl,
                      bottomContent: _forwardingFields(),
                      isCm: isCm,
                      initialRemarksMode: RemarksPanelMode.write,
                      initialPenColor: isCm
                          ? SignatureColor.darkGreen
                          : SignatureColor.darkBlue,
                      isRemarksLocked: isLocked,
                      onLockToggle: _remarksPanelCtrl.toggleLock,
                      remarksPanelKey: _remarksPanelKey,
                      onScrollControllerChanged: (sc) {
                        _currentPageScrollController = sc;
                      },
                    ),
                  ),
                  if (isLocked)
                    Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.secondaryLight.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryDark.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: RemarksSignPanel(
                            key: _remarksPanelKey,
                            controller: _remarksPanelCtrl,
                            scrollController: _stickyPanelScrollController,
                            bottomContent: _forwardingFields(),
                            initiallyExpanded: true,
                            showHeading: false,
                            initialMode: RemarksPanelMode.write,
                            initialPenColor: isCm
                                ? SignatureColor.darkGreen
                                : SignatureColor.darkBlue,
                            onLockToggle: _remarksPanelCtrl.toggleLock,
                          ),
                        )
                        .animate()
                        .slideY(
                          begin: 1.0,
                          end: 0.0,
                          duration: 320.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 220.ms, curve: Curves.easeOut),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: AppColors.secondaryLight.withValues(alpha: 0.35),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryDark.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _submitButton(),
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
          canBack
              ? AppOutlineButton(
                  onPressed: canBack ? _goBack : null,
                  text: 'Back',
                  icon: Icons.arrow_back_rounded,
                  color: canBack
                      ? AppColors.secondaryDark
                      : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                )
              : const SizedBox.shrink(),
          Card(
            elevation: 6,

            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: AppText.labelLarge(
                '${_currentPage + 1} / $total',
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
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

  /// Dropdowns for secretary forwarding — rendered inside the panel body.
  Widget _forwardingFields() {
    if (!isSecretary) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _forwardingLabel('FORWARD DEPARTMENT'),
        const SizedBox(height: 6),
        _departmentDropdown(),
        const SizedBox(height: 12),
        _forwardingLabel('DEPUTY / OFFICER'),
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
      ],
    );
  }

  /// Just the submit button — rendered in the sticky bottom bar.
  Widget _submitButton() {
    return AppSolidButton(
      onPressed: _submitFromRemarksPanel,
      text: isSecretary ? 'Sign and Forward' : 'Sign and Return',
      icon: Icons.check_rounded,
      width: double.infinity,
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
}
