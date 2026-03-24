part of 'passive_income_cubit.dart';

@freezed
sealed class PassiveIncomeState with _$PassiveIncomeState {
  const factory PassiveIncomeState.initial() = _Initial;
  const factory PassiveIncomeState.loading() = _Loading;
  const factory PassiveIncomeState.listed(
    List<PassiveIncomeEntity> streams,
  ) = _Listed;
  const factory PassiveIncomeState.error(String message) = _Error;
}
