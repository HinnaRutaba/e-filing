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
                physics: const NeverScrollableScrollPhysics(),
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
            SvgPicture.asset(
              AssetsConstants.dashboardBG,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
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
                              ref.read(authController.notifier).logout(context);
                            },
                            icon: Icon(
                              Icons.power_settings_new,
                              color: Colors.orange[300],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.summarize,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    ClipRect(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(text: 'You have '),
                                              TextSpan(
                                                text: '3 ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "summaries to review",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate(delay: 300.ms)
                              .scale(
                                alignment: Alignment.centerLeft,
                                begin: const Offset(0, 1),
                                end: const Offset(1, 1),
                                duration: 450.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .fadeIn(duration: 250.ms),
                          ClipPath(
                                clipper: _ConcaveConnectorClipper(),
                                child: Container(
                                  width: 20,
                                  height: 24,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              )
                              .animate(delay: 300.ms)
                              .scale(
                                delay: 450.ms,
                                alignment: Alignment.centerLeft,
                                begin: const Offset(0, 1),
                                end: const Offset(1, 1),
                                duration: 250.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .fadeIn(delay: 450.ms, duration: 150.ms),
                          InkWell(
                                onTap: () {
                                  //RouteHelper.push(Routes.summaries);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: AppText.titleSmall(
                                    "View All >",
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .animate(delay: 300.ms)
                              .scale(
                                delay: 700.ms,
                                alignment: Alignment.centerLeft,
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1),
                                duration: 550.ms,
                                curve: Curves.easeInOutBack,
                              )
                              .fadeIn(delay: 700.ms, duration: 200.ms),
                        ],
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

class _ConcaveConnectorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const double vDip = 0.75; // top/bottom: deep concave
    const double hDip = 0.2; // left/right: very subtle concave
    // Top edge: curves downward toward center (deep concave)
    path.moveTo(0, 0);
    path.quadraticBezierTo(w / 2, h * vDip, w, 0);
    // Right edge: curves leftward very slightly (subtle concave)
    path.quadraticBezierTo(w - w * hDip, h / 2, w, h);
    // Bottom edge: curves upward toward center (deep concave)
    path.quadraticBezierTo(w / 2, h - h * vDip, 0, h);
    // Left edge: curves rightward very slightly (subtle concave)
    path.quadraticBezierTo(w * hDip, h / 2, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
