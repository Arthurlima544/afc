part of 'fi_score_cubit.dart';

@freezed
sealed class FiScoreState with _$FiScoreState {
  const factory FiScoreState.initial() = _Initial;
  const factory FiScoreState.loading() = _Loading;
  const factory FiScoreState.success(FiScoreData data) = _Success;
  const factory FiScoreState.error(String message) = _Error;
}
