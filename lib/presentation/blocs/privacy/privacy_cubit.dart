import 'package:bloc/bloc.dart';

/// Controls whether sensitive monetary values are visible or masked.
///
/// State is `true` when values are hidden (privacy mode on).
/// Resets to visible every time the app restarts (no persistence).
class PrivacyCubit extends Cubit<bool> {
  PrivacyCubit() : super(false);

  bool get isHidden => state;

  void toggle() => emit(!state);
}
