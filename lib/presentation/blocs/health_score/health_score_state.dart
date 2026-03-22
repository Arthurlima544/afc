part of 'health_score_cubit.dart';

@freezed
sealed class HealthScoreState with _$HealthScoreState {
  const factory HealthScoreState.initial() = _Initial;
  const factory HealthScoreState.loading() = _Loading;
  const factory HealthScoreState.success(HealthScoreData data) = _Success;
  const factory HealthScoreState.error(String message) = _Error;
}
