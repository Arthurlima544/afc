part of 'feedback_cubit.dart';

@freezed
sealed class FeedbackState with _$FeedbackState {
  const factory FeedbackState.initial() = _Initial;
  const factory FeedbackState.loading() = _Loading;
  const factory FeedbackState.success() = _Success;
  const factory FeedbackState.error(String message) = _Error;
}
