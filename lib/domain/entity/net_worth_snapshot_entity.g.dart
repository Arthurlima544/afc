// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_snapshot_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NetWorthSnapshotEntity _$NetWorthSnapshotEntityFromJson(
  Map<String, dynamic> json,
) => _NetWorthSnapshotEntity(
  uuid: json['uuid'] as String,
  userId: json['userId'] as String,
  date: json['date'] as String,
  assets: (json['assets'] as num).toDouble(),
  liabilities: (json['liabilities'] as num).toDouble(),
  netWorth: (json['netWorth'] as num).toDouble(),
);

Map<String, dynamic> _$NetWorthSnapshotEntityToJson(
  _NetWorthSnapshotEntity instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'userId': instance.userId,
  'date': instance.date,
  'assets': instance.assets,
  'liabilities': instance.liabilities,
  'netWorth': instance.netWorth,
};
