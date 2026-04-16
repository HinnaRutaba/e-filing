import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/screens/summaries/components/summary_brief.dart';
import 'package:efiling_balochistan/views/screens/summaries/summary_document_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CMDashboardScreen extends ConsumerStatefulWidget {
  const CMDashboardScreen({super.key});

  @override
  ConsumerState<CMDashboardScreen> createState() => _CMDashboardScreenState();
}

class _CMDashboardScreenState extends ConsumerState<CMDashboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _summaries = [
    {
      'barcode': 'SUM-001',
      'summaryNumber': 'No. 01/CM/2026',
      'department': 'Home Department',
      'subject': 'Sample Summary Subject One',
      'htmlContent':
          '<p>This is a placeholder summary document content for item one.</p>',
    },
    {
      'barcode': 'SUM-002',
      'summaryNumber': 'No. 02/CM/2026',
      'department': 'Finance Department',
      'subject': 'Sample Summary Subject Two',
      'htmlContent':
          '<p>This is a placeholder summary document content for item two.</p>',
    },
    {
      'barcode': 'SUM-003',
      'summaryNumber': 'No. 03/CM/2026',
      'department': 'Education Department',
      'subject': 'Sample Summary Subject Three',
      'htmlContent':
          '<p>This is a placeholder summary document content for item three.</p>',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _summaries.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
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
    const headerHeight = 148.0;
    final dashboardState = ref.watch(dashboardController);
    final bool canBack = _currentPage > 0;
    final bool canNext = _currentPage < _summaries.length - 1;

    return GradientScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(context, dashboardState, headerHeight),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _summaries.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) {
                  final s = _summaries[i];
                  return StickyTagDrawer(
                    panelWidth: MediaQuery.sizeOf(context).width * 0.8,
                    tagsAlignment: const Alignment(0.0, -0.5),
                    mainContent: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SummaryDocumentCard(
                        barcode: s['barcode'] as String,
                        summaryNumber: s['summaryNumber'] as String,
                        summaryDate: DateTime.now(),
                        department: s['department'] as String,
                        subject: s['subject'] as String,
                        htmlContent: s['htmlContent'] as String,
                        recipientTitle: 'Mr. Chief Minister',
                        recipientDesignation: 'Chief Minister',
                        recipientDepartment: 'Chief Minister Secretariat',
                        recipientTimestamp: DateTime.now(),
                        destination: 'Quetta',
                      ),
                    ),
                    tags: [
                      StickyTag(
                        text: "Attachment",
                        backgroundColor: AppColors.primary,
                        panelContent: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Center(
                              child: AppText.bodyMedium(
                                "No attachments available",
                              ),
                            ),
                          ),
                        ),
                      ),
                      StickyTag(
                        text: "Brief",
                        backgroundColor: Colors.orange,
                        panelContent: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          child: SummaryBrief(
                            note:
                                'Will not appear on the printed summary as it will be meant for internal departments.',
                            paragraphs: const [
                              '03. Furthermore, it is submitted that the initial presentation, all suggested changes have been incorporated, and the system is now ready for deployment. As an initial step, it is proposed to deploy the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project. Upon successful implementation and evaluation, the system can be expanded to the entire Chief Minister Secretariat and eventually deployed across other government departments.',
                              '04. In this regard, it is kindly requested to approve the deployment of the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project and provide directions for its phased expansion.',
                            ],
                            authorName: 'Mumtaz Haider Khan',
                            authorDesignation: 'Deputy Coordinator (CM)',
                            timestamp: DateTime(2025, 4, 14, 16, 27),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildPager(canBack: canBack, canNext: canNext),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic dashboardState,
    double headerHeight,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: headerHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (dashboardState.animated)
              SvgPicture.asset(
                AssetsConstants.dashboardBG,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              )
            else
              SvgPicture.asset(
                    AssetsConstants.dashboardBG,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  )
                  .animate(
                    delay: 800.ms,
                    onComplete: (_) {
                      ref
                          .read(dashboardController.notifier)
                          .markBackdropAnimated();
                    },
                  )
                  .scale(
                    alignment: Alignment.bottomRight,
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 400.ms),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryDark.withValues(alpha: 0.8),
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryDark,
                    AppColors.secondaryLight.withValues(alpha: 0.7),
                    AppColors.accent.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Welcome, ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'CM'),
                                ],
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              ref.read(authController.notifier).logout();
                            },
                            icon: Icon(
                              Icons.power_settings_new,
                              color: Colors.orange[300],
                            ),
                          ),
                        ],
                      ),
                      //const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.summarize,
                              color: Colors.white,
                              size: 22,
                            ),
                            ClipRect(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(text: 'You have '),
                                      TextSpan(
                                        text: '3 ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      TextSpan(text: "summaries to review"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPager({required bool canBack, required bool canNext}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            color: AppColors.secondaryDark,
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
        ? AppColors.secondaryDark
        : AppColors.secondaryDark.withValues(alpha: 0.35);
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
}
