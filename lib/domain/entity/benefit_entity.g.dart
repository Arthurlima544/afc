// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitEntity _$BenefitEntityFromJson(Map<String, dynamic> json) =>
    _BenefitEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$BenefitTypeEnumMap, json['type']),
      monthlyCredit: (json['monthlyCredit'] as num).toDouble(),
      color: (json['color'] as num).toInt(),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      resetMonth: json['resetMonth'] as String? ?? '',
    );

Map<String, dynamic> _$BenefitEntityToJson(_BenefitEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'name': instance.name,
      'type': _$BenefitTypeEnumMap[instance.type]!,
      'monthlyCredit': instance.monthlyCredit,
      'color': instance.color,
      'balance': instance.balance,
      'resetMonth': instance.resetMonth,
    };

const _$BenefitTypeEnumMap = {
  BenefitType.va: 'va',
  BenefitType.vt: 'vt',
  BenefitType.vr: 'vr',
  BenefitType.other: 'other',
};
