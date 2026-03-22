part of 'goal_cubit.dart';

@freezed
sealed class GoalState with _$GoalState {
  const factory GoalState.initial() = _Initial;
  const factory GoalState.loading() = _Loading;
  const factory GoalState.listed(List<GoalEntity> goals) = _Listed;
  const factory GoalState.success(GoalEntity goal) = _Success;
  const factory GoalState.error(String message) = _Error;
}
