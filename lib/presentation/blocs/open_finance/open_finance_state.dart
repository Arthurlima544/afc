part of 'open_finance_cubit.dart';

@freezed
sealed class OpenFinanceState with _$OpenFinanceState {
  const factory OpenFinanceState.initial() = _Initial;
  const factory OpenFinanceState.loading() = _Loading;
  const factory OpenFinanceState.listed(List<ConnectedAccountEntity> accounts) =
      _Listed;
  const factory OpenFinanceState.tokenReady(String connectToken) = _TokenReady;
  const factory OpenFinanceState.error(String message) = _Error;
}
