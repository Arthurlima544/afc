// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionEntity _$TransactionEntityFromJson(Map<String, dynamic> json) =>
    _TransactionEntity(
      uuid: json['uuid'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryUUid: json['categoryUUid'] as String,
      typeUuid: json['typeUuid'] as String,
      data: DateTime.parse(json['data'] as String),
      title: json['title'] as String,
    );

Map<String, dynamic> _$TransactionEntityToJson(_TransactionEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'amount': instance.amount,
      'categoryUUid': instance.categoryUUid,
      'typeUuid': instance.typeUuid,
      'data': instance.data.toIso8601String(),
      'title': instance.title,
    };
