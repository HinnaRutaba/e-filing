import 'package:dropdown_button2/dropdown_button2.dart';
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
  final DropdownButtonBuilder? selectedItemBuilder;
  final double? buttonHeight;
  final double? buttonWidth;

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
    this.selectedItemBuilder,
    this.buttonHeight,
    this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText.labelLarge(
                labelText,
                color: enabled ? null : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              if (isMandatory) AppText.headlineSmall(' *', color: Colors.red),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField2<T>(
          isExpanded: true,
          buttonStyleData: ButtonStyleData(
            height: buttonHeight ?? 24,
            width: buttonWidth,
            //padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          // menuItemStyleData: const MenuItemStyleData(
          //   height: 48,
          // ),
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
            suffixIcon: suffixIcon,
            border: border,
            fillColor: fillColor,
            filled: true,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            prefixIcon: prefix,
            contentPadding: padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            hintStyle: TextStyle(
              color: enabled
                  ? AppColors.primaryDark.withOpacity(0.6)
                  : AppColors.primaryDark.withOpacity(0.3),
              fontWeight: FontWeight.w400,
            ),
          ),
          validator: validator,
          selectedItemBuilder: selectedItemBuilder,
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: itemBuilder(value),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
