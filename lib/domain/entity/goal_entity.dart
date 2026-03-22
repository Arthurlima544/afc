import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_entity.freezed.dart';
part 'goal_entity.g.dart';

@freezed
sealed class GoalEntity with _$GoalEntity {
  const factory GoalEntity({
    required String uuid,
    required String userId,
    required String name,
    required double targetAmount,
    required DateTime deadline,
    required int icon,
    @Default(0.0) double currentAmount,
  }) = _GoalEntity;

  factory GoalEntity.fromJson(Map<String, Object?> json) =>
      _$GoalEntityFromJson(json);
}
