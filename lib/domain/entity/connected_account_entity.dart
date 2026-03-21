import 'package:freezed_annotation/freezed_annotation.dart';

part 'connected_account_entity.freezed.dart';
part 'connected_account_entity.g.dart';

@freezed
sealed class ConnectedAccountEntity with _$ConnectedAccountEntity {
  const factory ConnectedAccountEntity({
    required String uuid,
    required String userId,
    required String pluggyItemId,
    required String institutionName,
    required String status,
    String? institutionLogo,
    DateTime? lastSyncedAt,
  }) = _ConnectedAccountEntity;

  factory ConnectedAccountEntity.fromJson(Map<String, Object?> json) =>
      _$ConnectedAccountEntityFromJson(json);
}
