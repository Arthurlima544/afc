import 'package:flutter/widgets.dart';

/// Complete brand color palette for AFC.
///
/// All tokens are `const Color` values — no runtime allocations.
/// Use semantic names (e.g. [income], [expense]) over raw hex throughout the app.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────

  /// Primary brand color — deep teal. Used for FAB, active tabs, CTAs.
  static const Color primary = Color(0xFF0D9488);

  /// Lighter teal — hover / pressed states on the primary color.
  static const Color primaryLight = Color(0xFF14B8A6);

  /// Text / icon color when placed on [primary] backgrounds.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Semantic ────────────────────────────────────────────────────────────────

  /// Green — income amounts, positive balance, success states.
  static const Color income = Color(0xFF22C55E);

  /// Red — expense amounts, errors, exceeded limits.
  static const Color expense = Color(0xFFEF4444);

  /// Amber — warnings, approaching limit, upcoming bills.
  static const Color warning = Color(0xFFF59E0B);

  /// Warm brown — text on amber [warningBackground].
  static const Color warningText = Color(0xFF92400E);

  /// Light amber — background for warning chips and badges.
  static const Color warningBackground = Color(0xFFFEF3C7);

  /// Blue — hyperlinks, tertiary navigation text buttons.
  static const Color link = Color(0xFF60A5FA);

  // ── Neutral ────────────────────────────────────────────────────────────────

  /// Muted gray — empty state icons and labels, secondary text.
  static const Color muted = Color(0xFF888888);

  /// Light muted — dividers, placeholder backgrounds.
  static const Color mutedLight = Color(0xFFE5E7EB);

  // ── Surface — Light theme ──────────────────────────────────────────────────

  /// Page background in light mode.
  static const Color backgroundLight = Color(0xFFF9FAFB);

  /// Card / sheet surface in light mode.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Primary text in light mode.
  static const Color textPrimaryLight = Color(0xFF111827);

  /// Secondary text in light mode.
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // ── Surface — Dark theme ───────────────────────────────────────────────────

  /// Page background in dark mode.
  static const Color backgroundDark = Color(0xFF0F0F0F);

  /// Card / sheet surface in dark mode.
  static const Color surfaceDark = Color(0xFF1C1C1E);

  /// Primary text in dark mode.
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// Secondary text in dark mode.
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
}
