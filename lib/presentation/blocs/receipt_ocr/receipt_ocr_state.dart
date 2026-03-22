part of 'receipt_ocr_cubit.dart';

@freezed
sealed class ReceiptOcrState with _$ReceiptOcrState {
  const factory ReceiptOcrState.idle() = _Idle;
  const factory ReceiptOcrState.loading() = _Loading;
  const factory ReceiptOcrState.success({
    required double? amount,
    required String? merchant,
  }) = _Success;
  const factory ReceiptOcrState.error(String message) = _Error;
}
