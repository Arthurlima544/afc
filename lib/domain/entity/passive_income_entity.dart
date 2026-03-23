import 'package:freezed_annotation/freezed_annotation.dart';

part 'passive_income_entity.freezed.dart';
part 'passive_income_entity.g.dart';

/// Represents a recurring passive income stream (dividends, interest, rent…).
@freezed
sealed class PassiveIncomeEntity with _$PassiveIncomeEntity {
  const factory PassiveIncomeEntity({
    required String uuid,
    required String userId,

    /// Human-readable label (e.g. "Dividendos PETR4", "Aluguel Sala Comercial").
    required String name,

    /// Category: 'dividend', 'interest', 'rent', 'other'.
    required String source,

    /// Amount received per [frequency] cycle.
    required double amount,

    /// 'monthly', 'quarterly', 'annual'.
    required String frequency,

    /// Optional link to an investment UUID.
    String? assetUuid,
  }) = _PassiveIncomeEntity;

  factory PassiveIncomeEntity.fromJson(Map<String, Object?> json) =>
      _$PassiveIncomeEntityFromJson(json);
}

/// Returns the monthly equivalent of [amount] given [frequency].
double monthlyEquivalent(double amount, String frequency) {
  switch (frequency) {
    case 'quarterly':
      return amount / 3;
    case 'annual':
      return amount / 12;
    default: // 'monthly'
      return amount;
  }
}
