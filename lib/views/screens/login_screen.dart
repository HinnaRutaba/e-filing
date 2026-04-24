import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/services/version_sync_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return GradientScaffold(child: isMobile ? _mobileLayout() : _wideLayout());
  }

  // ── Mobile ──────────────────────────────────────────────────────────────────

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _loginForm(),
        ),
      ),
    );
  }

  // ── Tablet / Desktop ────────────────────────────────────────────────────────

  Widget _wideLayout() {
    return Row(
      children: [
        // Left — login form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _loginForm(isWide: true),
              ),
            ),
          ),
        ),
        // Right — animated lottie panel
        Expanded(child: _lottiePannel()),
      ],
    );
  }

  Widget _lottiePannel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A5C), Color(0xFF102040)],
        ),
      ),
      child: Stack(
        children: [
          // Background — Lottie fills the entire panel
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Lottie.asset(
                AssetsConstants.loginBgAnimated,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          // Foreground — branding anchored to top & bottom
          Column(
            children: [
              const Spacer(),
              Hero(
                tag: HeroTags.logo,
                child: Image.asset(
                  AssetsConstants.logo,
                  width: 140,
                  height: 80,
                ),
              ),
              const SizedBox(height: 12),
              AppText.headlineMedium(
                "CMDU E-Filing System",
                color: Colors.white,
              ),
              const Spacer(flex: 3),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AppText.titleSmall("Powered By", color: Colors.white70),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            AssetsConstants.cmduLogo,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1.0),
                          child: Image.asset(
                            AssetsConstants.govtLogo,
                            height: 40,
                          ),
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
                    padding: const EdgeInsets.only(bottom: 16.0),
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
          ),
        ],
      ),
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────

  Widget _loginForm({bool isWide = false}) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isWide) ...[
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
            Hero(
              tag: HeroTags.logo,
              child: Image.asset(AssetsConstants.logo, width: 140, height: 80),
            ),
            const SizedBox(height: 16),
            AppText.headlineMedium(
              "CMDU E-Filing System",
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            AppText.titleSmall(
              "Sign in to Dashboard",
              textAlign: TextAlign.center,
            ),
          ] else ...[
            AppText.headlineMedium("Sign In", color: AppColors.secondary),
            const SizedBox(height: 8),
            AppText.titleSmall(
              "Sign in to your Dashboard",
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          AppTextField(
            controller: usernameController,
            labelText: 'Username',
            hintText: 'Username',
            showLabel: false,
            prefix: const Icon(Icons.person),
            validator: Validators.notEmptyValidator,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: passwordController,
            labelText: 'Password',
            hintText: "Password",
            obscureText: obscurePassword,
            showLabel: false,
            prefix: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
            validator: Validators.passwordValidator,
          ),
          const SizedBox(height: 24),
          AppSolidButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (formKey.currentState?.validate() != true) return;
              ref
                  .read(authController.notifier)
                  .login(
                    username: usernameController.text,
                    password: passwordController.text,
                  );
            },
            width: double.infinity,
            text: "Sign In",
          ),
          if (!isWide) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AppText.titleSmall("Powered By"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          AssetsConstants.cmduLogo,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1.0),
                        child: Image.asset(
                          AssetsConstants.govtLogo,
                          height: 40,
                        ),
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
                  padding: const EdgeInsets.only(top: 48.0),
                  child: AppText.bodySmall(
                    "Version: ${snapshot.data}",
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
