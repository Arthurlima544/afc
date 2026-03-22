import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_entity.freezed.dart';
part 'investment_entity.g.dart';

@freezed
sealed class InvestmentEntity with _$InvestmentEntity {
  const factory InvestmentEntity({
    required String uuid,
    required String userId,
    required String name,
    required String type,
    required double quantity,
    required double avgCost,
    required double currentPrice,
    String? ticker,
  }) = _InvestmentEntity;

  factory InvestmentEntity.fromJson(Map<String, Object?> json) =>
      _$InvestmentEntityFromJson(json);
}
