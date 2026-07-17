import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SearchDropDownField<T> extends StatefulWidget {
  final T? value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final SuggestionsCallback<T> suggestionsCallback;
  final void Function(T suggestion) onSelected;
  final Widget Function(BuildContext context, T value) itemBuilder;
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
  final LayoutArchitecture? layoutArchitecture;

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
    this.focusNode,
    this.enforceTypeLimit = false,
    this.layoutArchitecture,
  });

  @override
  State<SearchDropDownField<T>> createState() => _SearchDropDownFieldState<T>();
}

class _SearchDropDownFieldState<T> extends State<SearchDropDownField<T>> {
  FocusNode? _internalFocusNode;
  ScrollPosition? _scrollPosition;

  // Callers don't always supply a focus node, but this widget needs one it can
  // unfocus to dismiss the suggestions box.
  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onParentScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onParentScroll);
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onParentScroll);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  // The suggestions box is placed where the field was when it opened and only
  // catches up with it every 500ms, so let a scroll of the page dismiss it
  // rather than leave a stale box behind.
  //
  // userScrollDirection stays idle for programmatic scrolls, which keeps this
  // from fighting the scroll-into-view that runs when the field gains focus.
  void _onParentScroll() {
    if (_scrollPosition?.userScrollDirection == ScrollDirection.idle) return;
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText.labelLarge(
                widget.labelText,
                color: widget.enabled
                    ? appColors.textPrimary
                    : appColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              if (widget.isMandatory)
                AppText.headlineSmall(' *', color: theme.colorScheme.error),
            ],
          ),
          const SizedBox(height: 4),
        ],
        // Shares the group of every text field and of the suggestions box
        // itself, so this only fires for taps that land on neither.
        TextFieldTapRegion(
          onTapOutside: (_) {
            if (_focusNode.hasFocus) _focusNode.unfocus();
          },
          child: DropDownSearchFormField<T>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: false,
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(fontSize: 16, color: appColors.textPrimary),
              decoration: InputDecoration(
                enabled: widget.enabled,
                hintText: widget.hintText,
                suffixIcon:
                    widget.suffixIcon ??
                    Icon(Icons.arrow_drop_down, color: appColors.textSecondary),
                border: widget.border,
                fillColor: widget.fillColor,
                filled: true,
                focusedBorder: widget.border,
                enabledBorder: widget.border,
                disabledBorder: widget.border,
                prefixIcon: widget.prefix,
                hintStyle: TextStyle(
                  color: widget.enabled
                      ? appColors.textSecondary
                      : appColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            validator: widget.validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            displayAllSuggestionWhenTap: true,
            // Package defaults to always opening downward; without this the
            // suggestions list stays below the field even when the keyboard
            // covers that space, instead of flipping to open upward.
            autoFlipDirection: true,
            suggestionsCallback: widget.suggestionsCallback,
            itemBuilder: widget.itemBuilder,
            onSuggestionSelected: widget.onSelected,
            layoutArchitecture: widget.layoutArchitecture,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.cardColor,
              // The package's own tap-outside handling is a full-screen opaque
              // barrier, which would also swallow drags and freeze the page
              // while the box is open. The TapRegion above closes it instead.
              closeSuggestionBoxWhenTapOutside: false,
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
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
