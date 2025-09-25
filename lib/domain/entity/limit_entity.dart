import 'package:freezed_annotation/freezed_annotation.dart';

part 'limit_entity.freezed.dart';
part 'limit_entity.g.dart';

@freezed
sealed class LimitEntity with _$LimitEntity {
  const factory LimitEntity({
    required String uuid,
    required String categoryUUid,
    required String month,
    required double limitAmount,
    required String userId,
  }) = _LimitEntity;

  factory LimitEntity.fromJson(Map<String, Object?> json) =>
      _$LimitEntityFromJson(json);
}
