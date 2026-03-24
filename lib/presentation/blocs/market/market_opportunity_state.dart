part of 'market_opportunity_cubit.dart';

@freezed
sealed class MarketOpportunityState with _$MarketOpportunityState {
  const factory MarketOpportunityState.initial() = _Initial;
  const factory MarketOpportunityState.loading() = _Loading;
  const factory MarketOpportunityState.loaded({
    required List<MarketQuoteEntity> quotes,
    required double cdiRate,
    required DateTime fetchedAt,
  }) = _Loaded;
  const factory MarketOpportunityState.error(String message) = _Error;
}
