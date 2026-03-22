import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_entity.freezed.dart';
part 'template_entity.g.dart';

@freezed
sealed class TemplateEntity with _$TemplateEntity {
  const factory TemplateEntity({
    required String uuid,
    required String userId,
    required String title,
    required double amount,
    required String categoryUUid,
    required String typeUuid,
  }) = _TemplateEntity;

  factory TemplateEntity.fromJson(Map<String, Object?> json) =>
      _$TemplateEntityFromJson(json);
}
