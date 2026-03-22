part of 'investment_cubit.dart';

@freezed
sealed class InvestmentState with _$InvestmentState {
  const factory InvestmentState.initial() = _Initial;
  const factory InvestmentState.loading() = _Loading;
  const factory InvestmentState.listed(
    List<InvestmentEntity> investments,
  ) = _Listed;
  const factory InvestmentState.success(InvestmentEntity investment) = _Success;
  const factory InvestmentState.error(String message) = _Error;
}
