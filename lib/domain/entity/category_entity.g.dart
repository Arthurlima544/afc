// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryEntity _$CategoryEntityFromJson(Map<String, dynamic> json) =>
    _CategoryEntity(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      iconType: (json['iconType'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryEntityToJson(_CategoryEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'iconType': instance.iconType,
    };
