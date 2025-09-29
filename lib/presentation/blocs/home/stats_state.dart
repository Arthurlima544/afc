import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/stats_entity.dart';

part 'stats_state.freezed.dart';

@freezed
class StatsState with _$StatsState {
  const factory StatsState.initial() = _StatsInitial;
  const factory StatsState.loading() = _StatsLoading;
  const factory StatsState.success(List<StatsEntity> stats) = _StatsSuccess;
  const factory StatsState.error(String message) = _StatsError;
}
