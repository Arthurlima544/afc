part of 'bill_cubit.dart';

@freezed
sealed class BillState with _$BillState {
  const factory BillState.initial() = _Initial;
  const factory BillState.loading() = _Loading;
  const factory BillState.listed(List<BillEntity> bills) = _Listed;
  const factory BillState.success(BillEntity bill) = _Success;
  const factory BillState.error(String message) = _Error;
}
