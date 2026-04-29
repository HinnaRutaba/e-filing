import 'dart:ui';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/services/version_sync_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// When true the login panel is visible immediately (no animation).
  /// When false the panel animates in — used from SplashScreen after the
  /// auth check has already determined the user is not logged in.
  final bool static;

  const LoginScreen({super.key, this.static = true});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _panelController;

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  static const _darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A5C), Color(0xFF102040)],
  );

  static const _panelRadius = BorderRadius.only(
    topRight: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (!widget.static) {
      // Slight delay so the user sees the background before the panel comes in
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _panelController.forward();
      });
    } else {
      _panelController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _panelController.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Background ──────────────────────────────────────────────────────────────

  Widget _background() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(gradient: _darkGradient),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 140),
            child: Lottie.asset(
              AssetsConstants.loginBgAnimated,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Branding column ─────────────────────────────────────────────────────────

  Widget _branding() {
    return Column(
      children: [
        const Spacer(),
        Hero(
          tag: HeroTags.logo,
          child: Image.asset(AssetsConstants.logo, width: 140, height: 80),
        ),
        const SizedBox(height: 12),
        AppText.headlineMedium("CMDU E-Filing System", color: Colors.white),
        const Spacer(flex: 3),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppText.titleSmall("Powered By", color: Colors.white70),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(AssetsConstants.cmduLogo, height: 48),
                  ),
                  const SizedBox(width: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: Image.asset(AssetsConstants.govtLogo, height: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: VersionSyncService().getAppVersionString(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppText.bodySmall(
                "Version: ${snapshot.data}",
                textAlign: TextAlign.center,
                color: Colors.white54,
              ),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────

  Widget _loginForm({bool isWide = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isWide) ...[
            AppText.headlineMedium("Sign In", color: AppColors.secondary),
            const SizedBox(height: 8),
            AppText.titleSmall(
              "Sign in to your Dashboard",
              textAlign: TextAlign.center,
            ),
          ] else ...[
            AppText.headlineMedium("Sign In", color: Colors.white),
            const SizedBox(height: 4),
            AppText.titleSmall(
              "Sign in to your Dashboard",
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          AppTextField(
            controller: _usernameCtrl,
            labelText: 'Username',
            hintText: 'Username',
            showLabel: false,
            prefix: const Icon(Icons.person),
            validator: Validators.notEmptyValidator,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _passwordCtrl,
            labelText: 'Password',
            hintText: 'Password',
            obscureText: _obscurePassword,
            showLabel: false,
            prefix: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: Validators.passwordValidator,
          ),
          const SizedBox(height: 24),
          AppSolidButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (_formKey.currentState?.validate() != true) return;
              ref
                  .read(authController.notifier)
                  .login(
                    username: _usernameCtrl.text,
                    password: _passwordCtrl.text,
                  );
            },
            width: double.infinity,
            text: "Sign In",
          ),
          if (!isWide) ...[
            const SizedBox(height: 24),
            FutureBuilder(
              future: VersionSyncService().getAppVersionString(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppText.bodySmall(
                    "Version: ${snapshot.data}",
                    textAlign: TextAlign.center,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── Wide panel ──────────────────────────────────────────────────────────────

  Widget _widePanel(double screenWidth) {
    final curved = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final panelWidth = screenWidth * 0.52 * curved.value;

        return Row(
          children: [
            SizedBox(
              width: panelWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Shadow — outside ClipRect so it casts onto the Lottie BG
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: _panelRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 48,
                            spreadRadius: 4,
                            offset: const Offset(8, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Panel content revealed as width grows
                  Positioned.fill(
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        maxWidth: screenWidth * 0.52,
                        child: SizedBox(
                          width: screenWidth * 0.52,
                          height: double.infinity,
                          child: ClipRRect(
                            borderRadius: _panelRadius,
                            child: Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.96),
                              child: SafeArea(
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 32,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 420,
                                      ),
                                      child: _loginForm(isWide: true),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _branding()),
          ],
        );
      },
    );
  }

  // ── Mobile header (always visible above the panel) ──────────────────────────

  Widget _mobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //const Spacer(),
        const SizedBox(height: 116),
        Hero(
          tag: HeroTags.logo,
          child: Image.asset(AssetsConstants.logo, width: 140, height: 80),
        ),
        const SizedBox(height: 8),
        AppText.headlineMedium("CMDU E-Filing System", color: Colors.white),
        const SizedBox(height: 16),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText.titleSmall("Powered By", color: Colors.white),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white38,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(AssetsConstants.cmduLogo, height: 40),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: Image.asset(AssetsConstants.govtLogo, height: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  // ── Mobile panel ─────────────────────────────────────────────────────────────

  Widget _mobilePanel() {
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic),
        );

    return SlideTransition(
      position: slide,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.50),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(child: _loginForm()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: isMobile,
      body: Stack(
        children: [
          Positioned.fill(child: _background()),
          Positioned.fill(
            child: isMobile
                ? Stack(children: [_mobileHeader(), _mobilePanel()])
                : _widePanel(width),
          ),
        ],
      ),
    );
  }
}
