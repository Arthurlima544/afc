import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';
part 'category_entity.g.dart';

@freezed
sealed class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String uuid,
    required String name,
    required int iconType,
  }) = _CategoryEntity;

  factory CategoryEntity.fromJson(Map<String, Object?> json) =>
      _$CategoryEntityFromJson(json);
}
