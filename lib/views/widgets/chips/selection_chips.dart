import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/chips/custom_app_chip.dart';
import 'package:flutter/material.dart';

class SelectionChipMenuItem<T> {
  final String label;
  final IconData? icon;
  final T value;
  final GlobalKey? key;

  const SelectionChipMenuItem({
    // Made const
    required this.label,
    required this.value,
    this.icon,
    this.key,
  });
}

class SelectionChips<T> extends StatefulWidget {
  final List<SelectionChipMenuItem> menu;
  final int initialSelected;
  final void Function(int, T) onSelected;
  final void Function(List<int>, List<T>)? onMultiSelect;
  final String? label;
  final bool isMandatory;
  final bool enableMultiSelect;
  final double minMenuItemWidth;
  final bool singleLineScroll;
  final Color? chipColor;

  const SelectionChips({
    // Made const
    super.key,
    required this.menu,
    this.initialSelected = 0,
    required this.onSelected,
    this.onMultiSelect,
    this.label,
    this.isMandatory = false,
    this.enableMultiSelect = false,
    this.minMenuItemWidth = 80,
    this.singleLineScroll = false,
    this.chipColor,
  });

  @override
  State<SelectionChips<T>> createState() => _SelectionChipsState<T>();
}

class _SelectionChipsState<T> extends State<SelectionChips<T>> {
  late int selectedIndex;
  late List<int> selectedIndexes;
  final ScrollController scrollController = ScrollController();
  bool _isProcessing = false; // Debounce flag

  @override
  void initState() {
    super.initState();
    _initializeSelection();
    _scrollToInitial();
  }

  void _initializeSelection() {
    selectedIndex = widget.initialSelected;
    selectedIndexes = widget.enableMultiSelect
        ? [widget.initialSelected]
        : [widget.initialSelected];

    // Call callbacks after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enableMultiSelect) {
        widget.onMultiSelect?.call(
          selectedIndexes,
          selectedIndexes.map<T>((e) => widget.menu[e].value).toList(),
        );
      } else {
        widget.onSelected(selectedIndex, widget.menu[selectedIndex].value);
      }
    });
  }

  void _scrollToInitial() {
    if (widget.singleLineScroll && widget.menu[selectedIndex].key != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = widget.menu[selectedIndex].key;
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _handleTap(int index) {
    if (_isProcessing) return; // Debounce
    _isProcessing = true;

    setState(() {
      if (widget.enableMultiSelect) {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          selectedIndexes.add(index);
        }
      } else {
        selectedIndex = index;
      }
    });

    // Call callbacks
    if (widget.enableMultiSelect) {
      widget.onMultiSelect?.call(
        selectedIndexes,
        selectedIndexes.map<T>((e) => widget.menu[e].value).toList(),
      );
    } else {
      widget.onSelected(index, widget.menu[index].value);
    }

    // Scroll to selected item
    if (widget.singleLineScroll && widget.menu[index].key != null) {
      Scrollable.ensureVisible(
        widget.menu[index].key!.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }

    // Reset debounce after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _isProcessing = false;
    });
  }

  bool isSelected(int index) {
    return widget.enableMultiSelect
        ? selectedIndexes.contains(index)
        : selectedIndex == index;
  }

  @override
  void didUpdateWidget(covariant SelectionChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if initialSelected changed
    if (oldWidget.initialSelected != widget.initialSelected) {
      setState(() {
        selectedIndex = widget.initialSelected;
        if (!widget.enableMultiSelect) {
          selectedIndexes = [widget.initialSelected];
        }
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.label != null) _buildLabel(),
          if (widget.singleLineScroll)
            _buildHorizontalScroll()
          else
            _buildWrap(),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: AppText.labelLarge(
              widget.label!,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (widget.isMandatory)
            AppText.headlineSmall(" *", color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildHorizontalScroll() {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(widget.menu.length, (index) {
          return Container(
            key: widget.menu[index].key,
            margin: const EdgeInsets.only(right: 8),
            child: _buildChip(index),
          );
        }),
      ),
    );
  }

  Widget _buildWrap() {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      alignment: WrapAlignment.start,
      children: List.generate(widget.menu.length, (index) {
        return Container(
          key: widget.menu[index].key,
          child: _buildChip(index),
        );
      }),
    );
  }

  Widget _buildChip(int index) {
    final isSelected = this.isSelected(index);
    final theme = Theme.of(context);

    return CustomAppChip(
      minWidth: widget.minMenuItemWidth,
      label: widget.menu[index].label,
      leadingIcon: widget.menu[index].icon != null
          ? Icon(widget.menu[index].icon, size: 16)
          : null,
      chipColor:
          isSelected ? widget.chipColor ?? theme.primaryColor : AppColors.white,
      borderColor: isSelected
          ? AppColors.white
          : widget.chipColor ?? theme.primaryColorDark,
      padding: EdgeInsets.zero,
      onTap: () => _handleTap(index),
    );
  }
}
