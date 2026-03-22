// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateEntity _$TemplateEntityFromJson(Map<String, dynamic> json) =>
    _TemplateEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryUUid: json['categoryUUid'] as String,
      typeUuid: json['typeUuid'] as String,
    );

Map<String, dynamic> _$TemplateEntityToJson(_TemplateEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'title': instance.title,
      'amount': instance.amount,
      'categoryUUid': instance.categoryUUid,
      'typeUuid': instance.typeUuid,
    };
