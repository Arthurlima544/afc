import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// AFC branded card.
///
/// Flat, no elevation. Uses a 1 dp border and 16 dp border radius to match
/// the visual identity established in the splash and onboarding screens.
/// In dark mode the surface is [AppColors.surfaceDark]; in light mode it is
/// [AppColors.surfaceLight].
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding, super.key});

  final Widget child;

  /// Defaults to [EdgeInsets.all(0)] — let each call site decide its padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }
}
