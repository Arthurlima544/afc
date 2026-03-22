// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawTransactionEntity _$RawTransactionEntityFromJson(
  Map<String, dynamic> json,
) => _RawTransactionEntity(
  uuid: json['uuid'] as String,
  userId: json['userId'] as String,
  pluggyTransactionId: json['pluggyTransactionId'] as String,
  accountId: json['accountId'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  date: DateTime.parse(json['date'] as String),
  type: json['type'] as String,
  status: json['status'] as String,
  suggestedCategoryUuid: json['suggestedCategoryUuid'] as String?,
);

Map<String, dynamic> _$RawTransactionEntityToJson(
  _RawTransactionEntity instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'userId': instance.userId,
  'pluggyTransactionId': instance.pluggyTransactionId,
  'accountId': instance.accountId,
  'amount': instance.amount,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'type': instance.type,
  'status': instance.status,
  'suggestedCategoryUuid': instance.suggestedCategoryUuid,
};
