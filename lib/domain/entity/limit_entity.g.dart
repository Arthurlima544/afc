// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limit_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LimitEntity _$LimitEntityFromJson(Map<String, dynamic> json) => _LimitEntity(
  uuid: json['uuid'] as String,
  categoryUUid: json['categoryUUid'] as String,
  month: json['month'] as String,
  limitAmount: (json['limitAmount'] as num).toDouble(),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$LimitEntityToJson(_LimitEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'categoryUUid': instance.categoryUUid,
      'month': instance.month,
      'limitAmount': instance.limitAmount,
      'userId': instance.userId,
    };
