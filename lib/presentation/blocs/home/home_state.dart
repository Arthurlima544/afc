part of 'home_bloc.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    required LastTransactionState transactionState,
    required StatsState statsState,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState(
    transactionState: LastTransactionState.initial(),
    statsState: StatsState.initial(),
  );
}
