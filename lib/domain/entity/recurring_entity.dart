import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_entity.dart';

part 'recurring_entity.freezed.dart';
part 'recurring_entity.g.dart';

@freezed
sealed class RecurringEntity with _$RecurringEntity {
  @JsonSerializable(explicitToJson: true)
  const factory RecurringEntity({
    required String uuid,
    required String userId,
    required TransactionEntity templateTransaction,
    required String frequency,
    required DateTime nextDue,
    required bool active,
  }) = _RecurringEntity;

  factory RecurringEntity.fromJson(Map<String, Object?> json) =>
      _$RecurringEntityFromJson(json);
}
