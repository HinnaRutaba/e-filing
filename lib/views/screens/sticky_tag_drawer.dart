import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_detection/keyboard_detection.dart';

class StickyTag {
  final String text;
  final Widget panelContent;
  final Color backgroundColor;
  final Color textColor;

  const StickyTag({
    required this.text,
    required this.panelContent,
    this.backgroundColor = AppColors.secondaryDark,
    this.textColor = Colors.white,
  });
}

class StickyTagDrawer extends StatefulWidget {
  final Widget mainContent;
  final List<StickyTag> tags;
  final double panelWidth;
  final Alignment tagsAlignment;

  const StickyTagDrawer({
    super.key,
    required this.mainContent,
    required this.tags,
    this.panelWidth = 250,
    this.tagsAlignment = Alignment.centerRight,
  });

  @override
  State<StickyTagDrawer> createState() => _StickyTagDrawerState();
}

class _StickyTagDrawerState extends State<StickyTagDrawer>
    with SingleTickerProviderStateMixin {
  int? _openIndex;
  bool _isKeyboardVisible = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late KeyboardDetectionController _keyboardDetectionController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(
      begin: 0,
      end: widget.panelWidth,
    ).animate(_controller);
    _keyboardDetectionController = KeyboardDetectionController(
      onChanged: (value) {
        setState(() {
          _isKeyboardVisible = value == KeyboardState.visible;
        });
      },
    );
  }

  void _openTag(int index) {
    setState(() {
      if (_openIndex == index) {
        _openIndex = null;
        _controller.reverse();
      } else {
        final wasClosed = _openIndex == null;
        _openIndex = index;
        if (wasClosed) _controller.forward();
      }
    });
  }

  void _close() {
    setState(() {
      _openIndex = null;
      _controller.reverse();
    });
  }

  @override
  void didUpdateWidget(covariant StickyTagDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.panelWidth != widget.panelWidth) {
      _widthAnimation = Tween<double>(
        begin: 0,
        end: widget.panelWidth,
      ).animate(_controller);
    }
    if (_openIndex != null && _openIndex! >= widget.tags.length) {
      _openIndex = null;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = _openIndex != null;
    final StickyTag? activeTag = isOpen ? widget.tags[_openIndex!] : null;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Each tag has a minHeight of 80 plus an 8px gap between tags.
    final double totalTagsHeight = widget.tags.isEmpty
        ? 0
        : (widget.tags.length * 80) + ((widget.tags.length - 1) * 8);
    // Map alignment.y (-1..1) to a top offset inside the available track
    // (screenHeight - totalTagsHeight). -1 pins top, 0 centers, 1 pins bottom.
    final double track = (screenHeight - totalTagsHeight).clamp(
      0,
      screenHeight,
    );
    final double baseTop = _isKeyboardVisible
        ? 100
        : ((widget.tagsAlignment.y + 1) / 2) * track;

    return KeyboardDetection(
      controller: _keyboardDetectionController,
      child: Stack(
        children: [
          widget.mainContent,
          AnimatedBuilder(
            animation: _widthAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: _widthAnimation.value,
                child: Material(
                  elevation: 8,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: AppTextLinkButton(
                            onPressed: _close,
                            text: "Close",
                            icon: Icons.close,
                          ),
                        ),
                      ),
                      if (activeTag != null)
                        Expanded(child: activeTag.panelContent),
                    ],
                  ),
                ),
              );
            },
          ),
          if (!isOpen)
            Positioned(
              right: 0,
              top: baseTop,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.tags.length; i++) ...[
                    _buildTag(widget.tags[i], i),
                    if (i != widget.tags.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(StickyTag tag, int index) {
    return GestureDetector(
      onTap: () => _openTag(index),
      child: Container(
        width: 32,
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: tag.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: RotatedBox(
          quarterTurns: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: Text(
              tag.text,
              style: TextStyle(
                color: tag.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
