import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  const CustomSwitchTile(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: AppText.titleLarge(title),
      contentPadding: const EdgeInsets.all(0),
    );
  }
}
