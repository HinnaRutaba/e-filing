import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoutesTransitions {
  static CustomTransitionPage slidePageTransition(
      GoRouterState state, Widget child,
      {Offset offset = const Offset(10, 0),
      Duration duration = const Duration(milliseconds: 450)}) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween).drive(
                Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ),
              ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static CustomTransitionPage expandPageTransition(
      GoRouterState state, Widget child,
      {Alignment align = Alignment.bottomCenter,
      Duration duration = const Duration(milliseconds: 450)}) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          alignment: align,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  static CustomTransitionPage fadePageTransition(
      GoRouterState state, Widget child,
      {Duration duration = const Duration(milliseconds: 450),
      Curve curve = Curves.easeInOut}) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}
