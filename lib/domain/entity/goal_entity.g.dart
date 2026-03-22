// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalEntity _$GoalEntityFromJson(Map<String, dynamic> json) => _GoalEntity(
  uuid: json['uuid'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
  deadline: DateTime.parse(json['deadline'] as String),
  icon: (json['icon'] as num).toInt(),
);

Map<String, dynamic> _$GoalEntityToJson(_GoalEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'deadline': instance.deadline.toIso8601String(),
      'icon': instance.icon,
    };
