import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/controllers/daak_controller.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_detals_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaakApprovalDesk extends ConsumerStatefulWidget {
  const DaakApprovalDesk({super.key});

  @override
  ConsumerState<DaakApprovalDesk> createState() => _DaakApprovalDeskState();
}

class _DaakApprovalDeskState extends ConsumerState<DaakApprovalDesk> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<DaakModel> _localDaaks = [];
  bool _initialized = false;
  bool _isLoading = false;
  bool _allCaughtUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDesk());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDesk() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await ref.read(daakController.notifier).setViewFilter(DaakViewFilter.inbox);
    if (!mounted) return;
    final daaks = List<DaakModel>.from(
      ref.read(daakController.select((s) => s.filteredDaak)),
    );
    setState(() {
      _localDaaks = daaks;
      _initialized = true;
      _isLoading = false;
      _allCaughtUp = daaks.isEmpty;
    });
  }

  Future<void> _handleActionDone() async {
    final removedIdx = _currentPage;
    final totalAfter = _localDaaks.length - 1;

    if (totalAfter == 0) {
      setState(() {
        _localDaaks.removeAt(removedIdx);
        _allCaughtUp = true;
      });
      return;
    }

    final animateToIdx = removedIdx < _localDaaks.length - 1
        ? removedIdx + 1
        : removedIdx - 1;

    await _pageController.animateToPage(
      animateToIdx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;
    setState(() {
      _localDaaks.removeAt(removedIdx);
      _currentPage = animateToIdx > removedIdx
          ? animateToIdx - 1
          : animateToIdx;
      _pageController.jumpToPage(_currentPage);
    });
  }

  void _goNext() {
    final total = _localDaaks.length;
    if (total == 1) {
      Toast.show(message: 'You only have one daak pending');
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
  Widget build(BuildContext context) {
    Widget body;

    if (_isLoading && !_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_allCaughtUp || (_initialized && _localDaaks.isEmpty)) {
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
              'No daak is pending your action.',
              color: AppColors.secondaryDark,
            ),
            const SizedBox(height: 16),
            AppOutlineButton(
              onPressed: () => RouteHelper.pop(),
              text: 'Go Back',
            ),
          ],
        ),
      );
    } else if (!_initialized) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Column(
        children: [
          _buildPager(total: _localDaaks.length),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _localDaaks.length,
              itemBuilder: (context, index) {
                final daak = _localDaaks[index];
                return DaakDetailsScreen(
                  key: ValueKey(daak.id ?? index),
                  daakId: daak.id,
                  daakDetailsInfo: DaakDetailsInfo(
                    daak: daak,
                    status: daak.status ?? DaakStatus.inProgress1,
                  ),
                  showAppBar: false,
                  onSuccess: _handleActionDone,
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daak Desk'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: body,
    );
  }

  Widget _buildPager({required int total}) {
    final canBack = _currentPage > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: canBack ? 1.0 : 0.35,
            child: AppOutlineButton(
              onPressed: canBack ? _goBack : null,
              text: 'Back',
              icon: Icons.arrow_back_rounded,
              color: AppColors.secondaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          Card(
            elevation: 6,
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppText.labelLarge(
                '${_currentPage + 1} / $total',
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSolidButton(
            onPressed: _goNext,
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
}
