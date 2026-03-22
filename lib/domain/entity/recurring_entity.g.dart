// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringEntity _$RecurringEntityFromJson(Map<String, dynamic> json) =>
    _RecurringEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      templateTransaction: TransactionEntity.fromJson(
        json['templateTransaction'] as Map<String, dynamic>,
      ),
      frequency: json['frequency'] as String,
      nextDue: DateTime.parse(json['nextDue'] as String),
      active: json['active'] as bool,
    );

Map<String, dynamic> _$RecurringEntityToJson(_RecurringEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'templateTransaction': instance.templateTransaction.toJson(),
      'frequency': instance.frequency,
      'nextDue': instance.nextDue.toIso8601String(),
      'active': instance.active,
    };
