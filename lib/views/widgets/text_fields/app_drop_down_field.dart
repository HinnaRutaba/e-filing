import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
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
  final T? value;

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
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText.labelLarge(
                labelText,
                color: enabled
                    ? appColors.textPrimary
                    : appColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              if (isMandatory)
                AppText.headlineSmall(' *', color: theme.colorScheme.error),
            ],
          ),
          const SizedBox(height: 4),
        ],
        DropdownButtonFormField2<T>(
          isExpanded: true,
          buttonStyleData: ButtonStyleData(
            height: buttonHeight ?? 24,
            width: buttonWidth,
          ),
          style: TextStyle(fontSize: 14, color: appColors.textPrimary),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: appColors.secondaryLight.withValues(alpha: 0.4),
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: appColors.textSecondary,
            ),
          ),
          hint: Text(
            hintText,
            style: TextStyle(
              color: enabled
                  ? appColors.textSecondary.withValues(alpha: 0.8)
                  : appColors.textSecondary.withValues(alpha: 0.5),
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
            contentPadding: padding ?? const EdgeInsets.fromLTRB(-8, 0, 0, 0),
            hintStyle: TextStyle(
              color: enabled
                  ? appColors.textSecondary.withValues(alpha: 0.8)
                  : appColors.textSecondary.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
          value: value,
          validator: validator,
          selectedItemBuilder: selectedItemBuilder,
          items: items.map((T item) {
            return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
