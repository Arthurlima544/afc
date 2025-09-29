// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatsEntity _$StatsEntityFromJson(Map<String, dynamic> json) => _StatsEntity(
  type: $enumDecode(_$TypeEntityEnumMap, json['type']),
  total: (json['total'] as num).toDouble(),
  date: $enumDecode(_$CalendarEntityEnumMap, json['date']),
);

Map<String, dynamic> _$StatsEntityToJson(_StatsEntity instance) =>
    <String, dynamic>{
      'type': _$TypeEntityEnumMap[instance.type]!,
      'total': instance.total,
      'date': _$CalendarEntityEnumMap[instance.date]!,
    };

const _$TypeEntityEnumMap = {
  TypeEntity.income: 'income',
  TypeEntity.expense: 'expense',
};

const _$CalendarEntityEnumMap = {
  CalendarEntity.january: 'january',
  CalendarEntity.february: 'february',
  CalendarEntity.march: 'march',
  CalendarEntity.april: 'april',
  CalendarEntity.may: 'may',
  CalendarEntity.june: 'june',
  CalendarEntity.july: 'july',
  CalendarEntity.august: 'august',
  CalendarEntity.september: 'september',
  CalendarEntity.october: 'october',
  CalendarEntity.november: 'november',
  CalendarEntity.december: 'december',
};
