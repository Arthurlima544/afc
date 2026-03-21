// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connected_account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectedAccountEntity _$ConnectedAccountEntityFromJson(
  Map<String, dynamic> json,
) => _ConnectedAccountEntity(
  uuid: json['uuid'] as String,
  userId: json['userId'] as String,
  pluggyItemId: json['pluggyItemId'] as String,
  institutionName: json['institutionName'] as String,
  status: json['status'] as String,
  institutionLogo: json['institutionLogo'] as String?,
  lastSyncedAt: json['lastSyncedAt'] == null
      ? null
      : DateTime.parse(json['lastSyncedAt'] as String),
);

Map<String, dynamic> _$ConnectedAccountEntityToJson(
  _ConnectedAccountEntity instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'userId': instance.userId,
  'pluggyItemId': instance.pluggyItemId,
  'institutionName': instance.institutionName,
  'status': instance.status,
  'institutionLogo': instance.institutionLogo,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
