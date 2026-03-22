import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Builds Shadcn ThemeData instances for AFC's light and dark themes.
///
/// Shadcn components are styled via LegacyColorSchemes; our own widgets
/// use AppColors tokens directly, making both styling layers independent.
abstract final class AppTheme {
  /// Light theme — zinc-based neutral surfaces.
  static ThemeData light() => ThemeData(
    colorScheme: LegacyColorSchemes.lightZinc(),
  );

  /// Dark theme — violet-based dark surfaces (preserves the existing brand).
  static ThemeData dark() => ThemeData(
    colorScheme: LegacyColorSchemes.darkViolet(),
  );
}
