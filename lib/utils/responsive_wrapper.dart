import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints({
    this.tablet = 600,
    this.desktop = 1024,
  });

  final double tablet;
  final double desktop;
}

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.breakpoints = const ResponsiveBreakpoints(),
  });

  final Widget child;
  final ResponsiveBreakpoints breakpoints;

  DeviceType _resolve(double width) {
    if (width >= breakpoints.desktop) return DeviceType.desktop;
    if (width >= breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = _resolve(constraints.maxWidth);
        return _ResponsiveScope(
          deviceType: deviceType,
          screenWidth: constraints.maxWidth,
          screenHeight: constraints.maxHeight,
          child: child,
        );
      },
    );
  }
}

class _ResponsiveScope extends InheritedWidget {
  const _ResponsiveScope({
    required this.deviceType,
    required this.screenWidth,
    required this.screenHeight,
    required super.child,
  });

  final DeviceType deviceType;
  final double screenWidth;
  final double screenHeight;

  @override
  bool updateShouldNotify(_ResponsiveScope oldWidget) {
    return deviceType != oldWidget.deviceType ||
        screenWidth != oldWidget.screenWidth ||
        screenHeight != oldWidget.screenHeight;
  }
}

extension ResponsiveContext on BuildContext {
  DeviceType get deviceType {
    final scope = dependOnInheritedWidgetOfExactType<_ResponsiveScope>();
    assert(scope != null, 'ResponsiveWrapper is missing above this widget.');
    return scope!.deviceType;
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  double get screenWidth =>
      dependOnInheritedWidgetOfExactType<_ResponsiveScope>()!.screenWidth;
  double get screenHeight =>
      dependOnInheritedWidgetOfExactType<_ResponsiveScope>()!.screenHeight;

  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}
