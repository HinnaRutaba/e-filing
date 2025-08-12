import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Change Password",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              AppTextField(
                controller: currentPasswordController,
                labelText: 'Current Password',
                hintText: "Current Password",
                obscureText: obscureCurrentPassword,
                showLabel: false,
                // labelColor: AppColors.white,
                prefix: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureCurrentPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureCurrentPassword = !obscureCurrentPassword;
                    });
                  },
                ),
                validator: Validators.passwordValidator,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: newPasswordController,
                labelText: 'New Password',
                hintText: "New Password",
                obscureText: obscureNewPassword,
                showLabel: false,
                // labelColor: AppColors.white,
                prefix: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureNewPassword = !obscureNewPassword;
                    });
                  },
                ),
                validator: Validators.passwordValidator,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: "Confirm Password",
                obscureText: obscureConfirmPassword,
                showLabel: false,
                // labelColor: AppColors.white,
                prefix: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
                validator: (text) {
                  if (text != newPasswordController.text) {
                    return "Passwords don't match";
                  }
                  return Validators.passwordValidator(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
