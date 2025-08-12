import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ScrollWrapper extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;
  const ScrollWrapper(
      {super.key,
      this.controller, //Add controller if scroll bar need to be shown
      required this.child});

  @override
  Widget build(BuildContext context) {
    return controller != null
        ? Scrollbar(
            controller: controller,
            interactive: true,
            trackVisibility: true,
            child: pointerWidget(context),
          )
        : pointerWidget(context);
  }

  Widget pointerWidget(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: child,
    );
  }
}
