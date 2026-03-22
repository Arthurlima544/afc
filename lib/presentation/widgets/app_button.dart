import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Shared constants
// ---------------------------------------------------------------------------

const double _kButtonRadius = 10;
const double _kButtonHeight = 48;
final BorderRadius _kBorderRadius = BorderRadius.circular(_kButtonRadius);

// ---------------------------------------------------------------------------
// PrimaryButton
// ---------------------------------------------------------------------------

/// Teal-filled primary action button.
///
/// Use for the main CTA on any screen (Save, Confirm, etc.).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _kButtonHeight,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primary.withAlpha(0x80),
        shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// OutlineButton
// ---------------------------------------------------------------------------

/// Transparent button with a 1 dp teal border.
///
/// Use for secondary / alternative actions alongside a [PrimaryButton].
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _kButtonHeight,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// SecondaryButton
// ---------------------------------------------------------------------------

/// Surface-coloured button with no border — least prominent action.
///
/// Use for Cancel / neutral alternatives in dialogs and forms.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _kButtonHeight,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.muted,
        shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// DestructiveButton
// ---------------------------------------------------------------------------

/// Red-filled button for irreversible / destructive actions.
///
/// Use for Delete, Sign out, and similar high-consequence operations.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _kButtonHeight,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.expense,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.expense.withAlpha(0x80),
        shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: child,
    ),
  );
}
