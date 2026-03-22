import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// AFC branded icon button.
///
/// Replaces shadcn's `IconButton(variance: ButtonStyle.outline(), ...)` and
/// `IconButton(variance: ButtonStyle.primary(), shape: ButtonShape.circle, ...)`.
///
/// Usage:
/// ```dart
/// // outline variant (default) — matches former ButtonStyle.outline()
/// AppIconButton(icon: Icon(Icons.edit), onPressed: () { ... })
///
/// // filled circle — matches former ButtonStyle.primary() + ButtonShape.circle
/// AppIconButton.circle(icon: Icon(Icons.add), onPressed: () { ... })
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    super.key,
  }) : _filled = false,
       _circle = false;

  const AppIconButton.filled({
    required this.icon,
    this.onPressed,
    this.tooltip,
    super.key,
  }) : _filled = true,
       _circle = false;

  const AppIconButton.circle({
    required this.icon,
    this.onPressed,
    this.tooltip,
    super.key,
  }) : _filled = true,
       _circle = true;

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool _filled;
  final bool _circle;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final OutlinedBorder shape = _circle
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    if (_filled) {
      return IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: icon,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: shape,
          minimumSize: const Size(40, 40),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      style: IconButton.styleFrom(
        foregroundColor: isDark ? AppColors.onPrimary : AppColors.primary,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        shape: shape,
        minimumSize: const Size(40, 40),
      ),
    );
  }
}
