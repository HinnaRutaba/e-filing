import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';

class StickyTagDrawer extends StatefulWidget {
  final Widget mainContent; // main page content
  final String flagText; // text on the sticky flag
  final Widget panelContent; // content of the drawer/panel
  final double panelWidth; // optional width

  const StickyTagDrawer({
    Key? key,
    required this.mainContent,
    required this.flagText,
    required this.panelContent,
    this.panelWidth = 250,
  }) : super(key: key);

  @override
  _StickyTagDrawerState createState() => _StickyTagDrawerState();
}

class _StickyTagDrawerState extends State<StickyTagDrawer>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation =
        Tween<double>(begin: 0, end: widget.panelWidth).animate(_controller);
  }

  void _togglePanel() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Main content of the page
        widget.mainContent,

        /// Side panel
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
                          onPressed: _togglePanel,
                          text: "Close",
                          icon: Icons.close,
                        ),
                      ),
                    ),
                    if (_isOpen) Expanded(child: widget.panelContent),
                  ],
                ),
              ),
            );
          },
        ),

        /// Sticky flag
        Positioned(
          right: 0,
          top: MediaQuery.of(context).size.height / 2 - 40,
          child: _isOpen
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    width: 32,
                    constraints: const BoxConstraints(minHeight: 80),
                    //height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      boxShadow: [
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
                      child: Text(
                        widget.flagText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
