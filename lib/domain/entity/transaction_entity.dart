import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';
part 'transaction_entity.g.dart';

@freezed
sealed class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String uuid,
    required double amount,
    required String categoryUUid,
    required String typeUuid,
    required DateTime data,
    required String title,
    required String userId,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, Object?> json) =>
      _$TransactionEntityFromJson(json);
}
