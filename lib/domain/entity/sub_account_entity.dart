import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_account_entity.freezed.dart';
part 'sub_account_entity.g.dart';

enum SubAccountType { personal, company, benefit }

@freezed
sealed class SubAccountEntity with _$SubAccountEntity {
  const factory SubAccountEntity({
    required String uuid,
    required String userId,
    required String name,
    required SubAccountType type,
    @Default(0xFF2196F3) int color,
    @Default(0) int icon,
  }) = _SubAccountEntity;

  factory SubAccountEntity.fromJson(Map<String, Object?> json) =>
      _$SubAccountEntityFromJson(json);
}
