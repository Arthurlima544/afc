import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Requests an in-app store review after a user's first financial win.
///
/// Rate-limited to at most once every 90 days to avoid annoying users.
/// Caller is responsible for checking the win condition before calling
/// [maybeRequest].
abstract final class ReviewService {
  static const String _lastPromptKey = 'last_review_prompt_ms';
  static const int _cooldownDays = 90;

  /// Shows the native review dialog if the cooldown period has elapsed.
  ///
  /// Safe to call without a prior availability check — handles errors quietly.
  static Future<void> maybeRequest() async {
    try {
      final InAppReview review = InAppReview.instance;
      if (!await review.isAvailable()) {
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int lastMs = prefs.getInt(_lastPromptKey) ?? 0;
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      const int cooldownMs = _cooldownDays * 24 * 60 * 60 * 1000;

      if (nowMs - lastMs < cooldownMs) {
        return;
      }

      await prefs.setInt(_lastPromptKey, nowMs);
      await review.requestReview();
    } on Exception catch (_) {
      // Review API is best-effort — swallow all errors silently.
    }
  }
}
