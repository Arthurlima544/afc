import 'package:freezed_annotation/freezed_annotation.dart';

import 'calendar_entity.dart';
import 'type_entity.dart';

part 'stats_entity.freezed.dart';
part 'stats_entity.g.dart';

@freezed
sealed class StatsEntity with _$StatsEntity {
  const factory StatsEntity({
    required TypeEntity type,
    required double total,
    required CalendarEntity date,
  }) = _StatsEntity;

  factory StatsEntity.fromJson(Map<String, Object?> json) =>
      _$StatsEntityFromJson(json);
}
