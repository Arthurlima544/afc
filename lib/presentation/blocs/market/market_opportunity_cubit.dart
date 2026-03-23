import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/market_quote_entity.dart';
import '../../../domain/usecase/brapi_service.dart';
import '../../../utils/logger.dart';

part 'market_opportunity_state.dart';
part 'market_opportunity_cubit.freezed.dart';

/// Fetches and caches top dividend-paying B3 stocks and FIIs from Brapi.
///
/// Results are sorted by trailing 12-month dividend yield (descending).
/// A 30-minute in-memory cache prevents hammering the free-tier API.
class MarketOpportunityCubit extends Cubit<MarketOpportunityState> {
  MarketOpportunityCubit({BrapiService? service})
      : _service = service ?? BrapiService(),
        super(const MarketOpportunityState.initial());

  final BrapiService _service;
  DateTime? _lastFetch;

  static const Duration _cacheTtl = Duration(minutes: 30);

  /// Loads market opportunities unless the cache is still fresh.
  ///
  /// Pass [forceRefresh] = true to bypass the TTL (e.g. pull-to-refresh).
  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheTtl) {
      return;
    }

    emit(const MarketOpportunityState.loading());
    try {
      // Two sequential requests — keeps us within Brapi free-tier rate limits.
      final List<MarketQuoteEntity> acoes =
          await _service.fetchQuotes(BrapiService.acoesTickers);
      final List<MarketQuoteEntity> fiis =
          await _service.fetchQuotes(BrapiService.fiiTickers);
      final double cdi = await _service.fetchCdiRate();

      final List<MarketQuoteEntity> all = <MarketQuoteEntity>[
        ...acoes,
        ...fiis,
      ]..sort(
          (MarketQuoteEntity a, MarketQuoteEntity b) =>
              b.dividendYield.compareTo(a.dividendYield),
        );

      _lastFetch = DateTime.now();
      emit(
        MarketOpportunityState.loaded(
          quotes: all,
          cdiRate: cdi,
          fetchedAt: _lastFetch!,
        ),
      );
    } on Exception catch (e) {
      logger.e('MarketOpportunityCubit.load failed', error: e);
      emit(MarketOpportunityState.error(e.toString()));
    }
  }
}
