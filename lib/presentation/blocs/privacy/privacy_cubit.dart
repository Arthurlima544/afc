import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kPrivacyKey = 'privacy_mode';

/// Controls whether sensitive monetary values are visible or masked.
///
/// State is `true` when values are hidden (privacy mode on).
/// Persists across app restarts via SharedPreferences.
class PrivacyCubit extends Cubit<bool> {
  PrivacyCubit() : super(false);

  bool get isHidden => state;

  /// Load the stored preference. Call once at startup.
  Future<void> loadSavedPrivacy() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool saved = prefs.getBool(_kPrivacyKey) ?? false;
    emit(saved);
  }

  Future<void> toggle() async {
    final bool next = !state;
    emit(next);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyKey, next);
  }
}
