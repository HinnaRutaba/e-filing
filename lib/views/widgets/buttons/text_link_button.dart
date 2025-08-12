import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AppTextLinkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final IconData? icon;
  const AppTextLinkButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? TextButton(
            onPressed: onPressed,
            child: AppText(text, color: color),
          )
        : TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            label: AppText(text, color: color),
          );
  }
}
