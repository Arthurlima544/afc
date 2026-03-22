part of 'recurring_cubit.dart';

@freezed
sealed class RecurringState with _$RecurringState {
  const factory RecurringState.initial() = _Initial;
  const factory RecurringState.loading() = _Loading;
  const factory RecurringState.listed(List<RecurringEntity> rules) = _Listed;
  const factory RecurringState.success(RecurringEntity rule) = _Success;
  const factory RecurringState.error(String message) = _Error;
}
