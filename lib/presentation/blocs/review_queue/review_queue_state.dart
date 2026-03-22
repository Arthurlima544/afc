part of 'review_queue_cubit.dart';

class ReviewItem {
  const ReviewItem({
    required this.rawTransaction,
    this.selectedCategoryUuid,
    this.selectedCategoryName,
  });

  final RawTransactionEntity rawTransaction;
  final String? selectedCategoryUuid;
  final String? selectedCategoryName;

  ReviewItem copyWith({
    String? selectedCategoryUuid,
    String? selectedCategoryName,
  }) =>
      ReviewItem(
        rawTransaction: rawTransaction,
        selectedCategoryUuid:
            selectedCategoryUuid ?? this.selectedCategoryUuid,
        selectedCategoryName:
            selectedCategoryName ?? this.selectedCategoryName,
      );

  @override
  bool operator ==(Object other) =>
      other is ReviewItem &&
      other.rawTransaction.uuid == rawTransaction.uuid;

  @override
  int get hashCode => rawTransaction.uuid.hashCode;
}

@freezed
sealed class ReviewQueueState with _$ReviewQueueState {
  const factory ReviewQueueState.initial() = _Initial;
  const factory ReviewQueueState.loading() = _Loading;
  const factory ReviewQueueState.listed(List<ReviewItem> items) = _Listed;
  const factory ReviewQueueState.error(String message) = _Error;
}
