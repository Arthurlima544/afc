// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubAccountEntity _$SubAccountEntityFromJson(Map<String, dynamic> json) =>
    _SubAccountEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$SubAccountTypeEnumMap, json['type']),
      color: (json['color'] as num?)?.toInt() ?? 0xFF2196F3,
      icon: (json['icon'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubAccountEntityToJson(_SubAccountEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'name': instance.name,
      'type': _$SubAccountTypeEnumMap[instance.type]!,
      'color': instance.color,
      'icon': instance.icon,
    };

const _$SubAccountTypeEnumMap = {
  SubAccountType.personal: 'personal',
  SubAccountType.company: 'company',
  SubAccountType.benefit: 'benefit',
};
