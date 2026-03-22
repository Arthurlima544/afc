import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_entity.freezed.dart';
part 'bill_entity.g.dart';

@freezed
sealed class BillEntity with _$BillEntity {
  const factory BillEntity({
    required String uuid,
    required String userId,
    required String name,
    required double amount,
    required int dueDay,
    required String categoryUuid,
  }) = _BillEntity;

  factory BillEntity.fromJson(Map<String, Object?> json) =>
      _$BillEntityFromJson(json);
}
