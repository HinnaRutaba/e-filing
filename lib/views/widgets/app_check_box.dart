import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AppCheckBox extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool?>? onChanged;
  const AppCheckBox(
      {super.key, required this.value, this.onChanged, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      horizontalTitleGap: 0,
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: AppText.bodyMedium(title),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
