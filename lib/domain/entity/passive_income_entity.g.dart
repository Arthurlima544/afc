// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passive_income_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PassiveIncomeEntity _$PassiveIncomeEntityFromJson(Map<String, dynamic> json) =>
    _PassiveIncomeEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      source: json['source'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'] as String,
      assetUuid: json['assetUuid'] as String?,
    );

Map<String, dynamic> _$PassiveIncomeEntityToJson(
  _PassiveIncomeEntity instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'userId': instance.userId,
  'name': instance.name,
  'source': instance.source,
  'amount': instance.amount,
  'frequency': instance.frequency,
  'assetUuid': instance.assetUuid,
};
