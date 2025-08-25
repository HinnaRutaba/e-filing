import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AppDropDownField<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final Widget Function(T?) itemBuilder;
  final String? Function(T?)? validator;
  final String labelText;
  final String hintText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final bool enabled;
  final bool showLabel;
  final Widget? prefix;
  final Color? fillColor;
  final bool isMandatory;
  final EdgeInsets? padding;

  const AppDropDownField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    required this.itemBuilder,
    this.validator,
    this.suffixIcon,
    this.border,
    this.enabled = true,
    this.showLabel = true,
    this.prefix,
    this.fillColor,
    this.isMandatory = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText.labelLarge(
                labelText,
                color: enabled == false ? Colors.grey : null,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              if (isMandatory) AppText.headlineSmall(' *', color: Colors.red),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          padding: padding,
          hint: Text(
            hintText,
            style: TextStyle(
              color: enabled
                  ? AppColors.secondaryDark.withOpacity(0.8)
                  : AppColors.secondaryLight.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            border: border,
            fillColor: fillColor,
            filled: true,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            prefix: prefix,
            hintStyle: TextStyle(
              color: enabled
                  ? AppColors.primaryDark.withOpacity(0.6)
                  : AppColors.primaryDark.withOpacity(0.3),
              fontWeight: FontWeight.w400,
            ),
          ),
          validator: validator,
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Container(
                child: itemBuilder(value),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
