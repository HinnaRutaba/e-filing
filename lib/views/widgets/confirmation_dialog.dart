import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  const ConfirmationDialog(
      {super.key, required this.title, required this.onConfirm, this.onCancel});

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppText.headlineSmall(
                widget.title,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AppSolidButton(
                    text: 'Yes',
                    onPressed: () {
                      widget.onConfirm();
                    },
                    width: 100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  const SizedBox(width: 16),
                  AppOutlineButton(
                    text: 'No',
                    onPressed: () {
                      if (widget.onCancel == null) {
                        RouteHelper.pop();
                        return;
                      }
                      widget.onCancel?.call();
                    },
                    width: 100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
