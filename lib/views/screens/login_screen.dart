import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/constants/hero_tags.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.10,
              ),
              Hero(
                tag: HeroTags.logo,
                child: Image.asset(
                  AssetsConstants.logo,
                  width: 140,
                  height: 80,
                ),
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
              const SizedBox(height: 24),
              AppTextField(
                controller: usernameController,
                labelText: 'Username',
                //labelColor: AppColors.white,
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
                // labelColor: AppColors.white,
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
                  ref.read(authController.notifier).login(
                        username: usernameController.text,
                        password: passwordController.text,
                      );
                },
                width: double.infinity,
                text: "Sign In",
              ),
              const SizedBox(height: 24),
              // AppText.bodyMedium(
              //   "Or use fingerprint to sign in ",
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 8),
              // Image.asset(
              //   AssetsConstants.fingerprint,
              //   width: 48,
              //   height: 48,
              // ),
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
                        )
                      ],
                    ),
                  ],
                ),
              )
            ]
                .animate(
                  interval: const Duration(milliseconds: 20),
                )
                .slideY(
                  begin: 3.8,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutQuad,
                )
                .fade(
                  duration: const Duration(milliseconds: 600),
                ),
          ),
        ),
      ),
    );
  }
}
