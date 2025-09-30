import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/chips/custom_app_chip.dart';
import 'package:flutter/material.dart';

class SelectionChipMenuItem<T> {
  final String label;
  final IconData? icon;
  final T value;
  final GlobalKey? key;

  SelectionChipMenuItem({
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
  int selectedIndex = 0;
  List<int> selectedIndexes = [0];
  final ScrollController scrollController = ScrollController();

  scrollToItem(GlobalKey? key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.singleLineScroll &&
          key != null &&
          key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          alignment: 0.5,
        );
      }
    });
  }

  handleTap(int index) {
    if (widget.enableMultiSelect) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          selectedIndexes.add(index);
        }
      });
      widget.onMultiSelect?.call(
        selectedIndexes,
        selectedIndexes.map<T>((e) => widget.menu[e].value).toList(),
      );
    } else {
      setState(() {
        selectedIndex = index;
      });
      widget.onSelected(index, widget.menu[index].value);
    }
  }

  bool isSelected(int index) {
    return widget.enableMultiSelect
        ? selectedIndexes.contains(index)
        : selectedIndex == index;
  }

  @override
  void initState() {
    setState(() {
      selectedIndex = widget.initialSelected;

      //widget.onSelected(selectedIndex, widget.menu[selectedIndex].value);

      widget.onMultiSelect?.call(
        selectedIndexes,
        selectedIndexes.map<T>((e) => widget.menu[e].value).toList(),
      );
    });
    scrollToItem(widget.menu[selectedIndex].key);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SelectionChips<T> oldWidget) {
    setState(() {
      selectedIndex = widget.initialSelected;

      // widget.onSelected(selectedIndex, widget.menu[selectedIndex].value);

      widget.onMultiSelect?.call(
        selectedIndexes,
        selectedIndexes.map<T>((e) => widget.menu[e].value).toList(),
      );
    });
    scrollToItem(widget.menu[selectedIndex].key);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Row(
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
          ],
          widget.singleLineScroll
              ? Center(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: chips(
                        margin: const EdgeInsets.only(right: 8),
                      ),
                    ),
                  ),
                )
              : Wrap(
                  runSpacing: 0,
                  spacing: 8,
                  alignment: WrapAlignment.start,
                  children: chips(),
                ),
        ],
      ),
    );
  }

  List<Widget> chips({EdgeInsets margin = const EdgeInsets.all(0)}) {
    final ThemeData theme = Theme.of(context);
    return List.generate(
      widget.menu.length,
      (index) {
        return Container(
          key: widget.menu[index].key,
          margin: margin,
          child: CustomAppChip(
            minWidth: widget.minMenuItemWidth,
            label: widget.menu[index].label,
            leadingIcon: widget.menu[index].icon != null
                ? Icon(widget.menu[index].icon)
                : null,
            chipColor: isSelected(index)
                ? widget.chipColor ?? theme.primaryColor
                : AppColors.white,
            borderColor: isSelected(index)
                ? AppColors.white
                : widget.chipColor ?? theme.primaryColorDark,
            padding: const EdgeInsets.all(0),
            onTap: () {
              scrollToItem(widget.menu[index].key);
              handleTap(index);
            },
          ),
        );
      },
    );
  }
}
