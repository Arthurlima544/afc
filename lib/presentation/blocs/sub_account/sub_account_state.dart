part of 'sub_account_cubit.dart';

/// Per-account income / expense aggregation.
class SubAccountTotals {
  const SubAccountTotals({required this.income, required this.expenses});

  final double income;
  final double expenses;

  double get balance => income - expenses;
}

@freezed
sealed class SubAccountState with _$SubAccountState {
  const factory SubAccountState.initial() = _Initial;
  const factory SubAccountState.loading() = _Loading;
  const factory SubAccountState.listed(
    List<SubAccountEntity> accounts,
    Map<String, SubAccountTotals> totals,
  ) = _Listed;
  const factory SubAccountState.success(SubAccountEntity account) = _Success;
  const factory SubAccountState.error(String message) = _Error;
}
