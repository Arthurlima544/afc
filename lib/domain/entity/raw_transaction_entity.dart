import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_transaction_entity.freezed.dart';
part 'raw_transaction_entity.g.dart';

@freezed
sealed class RawTransactionEntity with _$RawTransactionEntity {
  const factory RawTransactionEntity({
    required String uuid,
    required String userId,
    required String pluggyTransactionId,
    required String accountId,
    required double amount,
    required String description,
    required DateTime date,
    required String type,
    required String status,
    String? suggestedCategoryUuid,
  }) = _RawTransactionEntity;

  factory RawTransactionEntity.fromJson(Map<String, Object?> json) =>
      _$RawTransactionEntityFromJson(json);
}
