import 'package:flutter/material.dart';

class AppIconTrigger extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;
  final Color? iconColor;
  final double? size;
  const AppIconTrigger(
      {super.key,
      required this.onPressed,
      this.icon,
      this.child,
      this.iconColor,
      this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      icon: icon != null
          ? Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: size,
            )
          : child ?? Container(),
    );
  }
}
