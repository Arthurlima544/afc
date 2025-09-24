part of 'transaction_cubit.dart';

@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState.initial(List<CategoryEntity> categories) =
      _Initial;
  const factory TransactionState.loading() = _Loading;
  const factory TransactionState.error(String message) = _Error;
  const factory TransactionState.success(TransactionEntity transaction) =
      _Success;
}
