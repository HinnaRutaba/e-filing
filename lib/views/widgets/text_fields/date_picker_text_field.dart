import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';

class DatePickerTextField extends StatelessWidget {
  final TextFieldConfig config;
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  const DatePickerTextField({
    super.key,
    required this.config,
    required this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialDate != null) {
        config.controller.text = DateTimeHelper.datFormatSlash(initialDate!);
      }
    });
    return AppTextField(
      controller: config.controller,
      readOnly: true,
      enabled: !config.disabled,
      hintText: config.hintText,
      labelText: config.labelText,
      showLabel: config.showLabel,
      isMandatory: config.isMandatory,
      suffixIcon: const Icon(Icons.calendar_month_sharp),
      validator: config.isMandatory ? Validators.dateValidator : null,
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        ).then((value) {
          if (value != null) {
            config.controller.text = DateTimeHelper.datFormatSlash(value);
            onDateSelected(value);
          }
        });
      },
    );
  }
}
