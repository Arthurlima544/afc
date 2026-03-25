import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_entity.freezed.dart';
part 'benefit_entity.g.dart';

enum BenefitType { va, vt, vr, other }

@freezed
sealed class BenefitEntity with _$BenefitEntity {
  const factory BenefitEntity({
    required String uuid,
    required String userId,
    required String name,
    required BenefitType type,
    required double monthlyCredit,
    required int color,
    @Default(0.0) double balance,
    @Default('') String resetMonth,
  }) = _BenefitEntity;

  factory BenefitEntity.fromJson(Map<String, Object?> json) =>
      _$BenefitEntityFromJson(json);
}
