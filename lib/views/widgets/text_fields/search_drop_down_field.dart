import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SearchDropDownField<T> extends StatelessWidget {
  final T? value;
  final TextEditingController? controller;
  final SuggestionsCallback<T> suggestionsCallback;
  final void Function(T suggestion) onSelected;
  final Widget Function(
    BuildContext context,
    T value,
  ) itemBuilder;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final bool enabled;
  final bool showLabel;
  final Widget? prefix;
  final Color? fillColor;
  final bool isMandatory;
  final bool enforceTypeLimit;

  const SearchDropDownField({
    super.key,
    required this.suggestionsCallback,
    required this.onSelected,
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
    this.value,
    this.controller,
    this.enforceTypeLimit = false,
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
              AppText.bodySmall(
                labelText,
                color: enabled == false ? Colors.grey : Colors.black,
              ),
              if (isMandatory) AppText.headlineSmall(' *', color: Colors.red),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropDownSearchField<T>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            autofocus: false,
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
            decoration: InputDecoration(
              enabled: enabled,
              hintText: hintText,
              suffixIcon: suffixIcon ??
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.secondaryDark,
                  ),
              border: border,
              fillColor: fillColor,
              filled: true,
              focusedBorder: border,
              enabledBorder: border,
              disabledBorder: border,
              prefixIcon: prefix,
              hintStyle: TextStyle(
                color: enabled
                    ? AppColors.textSecondary
                    : AppColors.primaryDark.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          displayAllSuggestionWhenTap: true,
          //isMultiSelectDropdown: false,
          suggestionsCallback: suggestionsCallback,
          itemBuilder: itemBuilder,
          onSuggestionSelected: onSelected,
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          noItemsFoundBuilder: (context) {
            return Container(
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: AppText.bodyLarge(
                  "No Items Found!",
                  color: AppColors.error,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
