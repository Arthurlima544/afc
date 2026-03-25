part of 'benefit_cubit.dart';

@freezed
sealed class BenefitState with _$BenefitState {
  const factory BenefitState.initial() = _Initial;
  const factory BenefitState.loading() = _Loading;
  const factory BenefitState.listed(List<BenefitEntity> benefits) = _Listed;
  const factory BenefitState.success(BenefitEntity benefit) = _Success;
  const factory BenefitState.error(String message) = _Error;
}
