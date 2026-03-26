// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillEntity _$BillEntityFromJson(Map<String, dynamic> json) => _BillEntity(
  uuid: json['uuid'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  dueDay: (json['dueDay'] as num).toInt(),
  categoryUuid: json['categoryUuid'] as String,
  isPaid: json['isPaid'] as bool? ?? false,
);

Map<String, dynamic> _$BillEntityToJson(_BillEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'name': instance.name,
      'amount': instance.amount,
      'dueDay': instance.dueDay,
      'categoryUuid': instance.categoryUuid,
      'isPaid': instance.isPaid,
    };
