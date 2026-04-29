import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/services/version_sync_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool navigate;
  const SplashScreen({super.key, this.navigate = true});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A5C), Color(0xFF102040)],
  );

  @override
  void initState() {
    super.initState();
    if (widget.navigate) fetchData();
  }

  Future<void> fetchData() async {
    bool laterPressed = await VersionSyncService().showUpdateDialog();
    if (!laterPressed) return;

    final ctrl = ref.read(authController.notifier);
    final loggedIn = await ctrl.isLoggedIn();

    if (!loggedIn) {
      RouteHelper.navigateTo(Routes.login, extra: false);
      return;
    }

    await ctrl.fetchLoggedInUser();
    ctrl.getOpenAIToken();
    DesignationModel? designation = await ctrl.fetchDesignation();
    if (designation == null) {
      RouteHelper.navigateTo(Routes.login, extra: false);
      return;
    }
    ref.read(summariesController.notifier).fetchSummariesMeta();
    ref.read(daakController.notifier).fetchDaakMeta();
    RouteHelper.navigateTo(Routes.dashboard);
  }

  Widget _poweredBySection(bool isMobile) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.titleSmall(
          "Powered By",
          color: isMobile ? Colors.black54 : Colors.white70,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(AssetsConstants.cmduLogo, height: 72),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: Image.asset(AssetsConstants.govtLogo, height: 64),
            ),
          ],
        ),
      ],
    );

    if (!isMobile) {
      return Padding(padding: const EdgeInsets.all(16), child: content);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: _darkGradient),
            ),
          ),

          // Lottie animation
          Positioned.fill(
            child: Lottie.asset(
              AssetsConstants.loginBgAnimated,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Branding
          Positioned.fill(
            child: Column(
              children: [
                Spacer(flex: isMobile ? 2 : 3),
                Hero(
                  tag: HeroTags.logo,
                  child: Image.asset(AssetsConstants.logo, height: 200),
                ).animate().fade(duration: const Duration(milliseconds: 400)),
                Spacer(flex: isMobile ? 1 : 2),
                _poweredBySection(isMobile),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
