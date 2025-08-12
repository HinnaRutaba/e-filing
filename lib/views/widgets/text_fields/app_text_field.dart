import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final int? maxLines;
  final bool autoFocus;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  final bool showLabel;
  final TextStyle? style;
  final Widget? prefix;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool isMandatory;
  final Color? filledColor;
  final String? suffixText;
  final TextInputType? inputType;
  final EdgeInsets? padding;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.border,
    this.maxLines,
    this.autoFocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.showLabel = true,
    this.style,
    this.prefix,
    this.onTap,
    this.inputFormatters,
    this.isMandatory = false,
    this.filledColor,
    this.suffixText,
    this.inputType,
    this.padding,
    this.maxLength,
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
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          autofocus: autoFocus,
          readOnly: readOnly,
          enabled: enabled,
          showCursor: true,
          onTap: onTap,
          style: style ??
              const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: inputType,
          maxLength: maxLength,
          decoration: InputDecoration(
            contentPadding: padding,
            hintText: hintText,
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            border: border,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            prefixIcon: prefix,
            hintStyle: TextStyle(
              color: enabled
                  ? AppColors.secondaryDark.withOpacity(0.8)
                  : AppColors.secondaryLight.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            fillColor: filledColor,
          ),
          obscureText: obscureText,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}

class TextFieldConfig {
  final bool disabled;
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool showLabel;
  final bool isMandatory;

  const TextFieldConfig({
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.disabled = false,
    this.showLabel = true,
    this.isMandatory = false,
  });
}
