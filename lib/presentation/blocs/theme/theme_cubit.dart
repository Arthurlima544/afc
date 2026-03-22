import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's preferred theme mode.
enum ThemePreference {
  /// Follow the OS setting (default).
  system,

  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,
}

/// Manages the app's theme preference.
///
/// State is persisted across restarts via [SharedPreferences] under the
/// key [_kKey]. Default value is [ThemePreference.dark] so the first
/// launch retains the existing dark-violet look until the user changes it.
class ThemeCubit extends Cubit<ThemePreference> {
  ThemeCubit() : super(ThemePreference.dark);

  static const String _kKey = 'theme_preference';

  /// Load the stored preference from SharedPreferences and emit it.
  /// Call once at startup inside the root widget's initState.
  Future<void> loadSavedTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_kKey);
    final ThemePreference preference = ThemePreference.values.firstWhere(
      (ThemePreference t) => t.name == raw,
      orElse: () => ThemePreference.dark,
    );
    emit(preference);
  }

  /// Switch to [preference] and persist the choice.
  Future<void> setTheme(ThemePreference preference) async {
    emit(preference);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, preference.name);
  }
}
