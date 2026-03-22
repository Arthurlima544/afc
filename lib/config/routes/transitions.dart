import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Slide-up transition — used for modal / form screens.
///
/// The new screen slides up from the bottom of the viewport.
/// Back navigation reverses the motion.
Page<T> slideUpTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (
        BuildContext ctx,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget c,
      ) {
        final Animation<Offset> position = animation.drive(
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeInOutCubic),
          ),
        );
        return SlideTransition(position: position, child: c);
      },
    );

/// Fade + scale transition — used for top-level / dashboard screens.
///
/// The new screen fades in and scales from 92 % → 100 %.
Page<T> fadeScaleTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (
        BuildContext ctx,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget c,
      ) {
        final Animation<double> fade = animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeIn),
          ),
        );
        final Animation<double> scale = animation.drive(
          Tween<double>(begin: 0.92, end: 1.0).chain(
            CurveTween(curve: Curves.easeOutCubic),
          ),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: c),
        );
      },
    );
