import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_state.freezed.dart';

@freezed
class LastTransactionState with _$LastTransactionState {
  const factory LastTransactionState.initial() = _TransactionInitial;
  const factory LastTransactionState.loading() = _TransactionLoading;
  const factory LastTransactionState.success(List<String> transactions) =
      _TransactionSuccess;
  const factory LastTransactionState.error(String message) = _TransactionError;
}
