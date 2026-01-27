import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectDesignationScreen extends ConsumerStatefulWidget {
  final List<DesignationModel> designations;
  const SelectDesignationScreen({super.key, required this.designations});

  @override
  ConsumerState<SelectDesignationScreen> createState() =>
      _SelectDesignationScreenState();
}

class _SelectDesignationScreenState
    extends ConsumerState<SelectDesignationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Designation"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              ...widget.designations
                  .map((designation) =>
                      DesignationCard(designation: designation))
                  .toList(),
              const SizedBox(height: 24),
              AppSolidButton(
                  onPressed: () {
                    ref.read(authController.notifier).logout();
                  },
                  text: "Go back to Login"),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignationCard extends ConsumerWidget {
  final DesignationModel designation;
  const DesignationCard({super.key, required this.designation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await ref.read(authController.notifier).setDesignation(designation);
          RouteHelper.navigateTo(Routes.dashboard);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleLarge(designation.designation ?? "---"),
                  const SizedBox(height: 4),
                  AppText.bodyMedium(designation.department ?? "----"),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
