import '../../../domain/entity/market_quote_entity.dart';
import '../../../domain/entity/watchlist_entity.dart';

/// Combines a persisted [WatchlistEntity] with its live [MarketQuoteEntity].
///
/// [quote] is null between the initial Firestore load and the first
/// Brapi response. The UI should handle this gracefully (e.g. skeleton).
class WatchlistItem {
  const WatchlistItem({
    required this.entity,
    this.quote,
    this.sparkline = const <double>[],
  });

  final WatchlistEntity entity;
  final MarketQuoteEntity? quote;

  /// 5-day daily close prices fetched lazily; empty list = not yet loaded.
  final List<double> sparkline;

  String get ticker => entity.ticker;

  /// True when the current price has reached or exceeded the alert threshold.
  bool get alertTriggered =>
      entity.alertThreshold != null &&
      quote != null &&
      quote!.price >= entity.alertThreshold!;

  WatchlistItem copyWith({
    MarketQuoteEntity? quote,
    List<double>? sparkline,
  }) =>
      WatchlistItem(
        entity: entity,
        quote: quote ?? this.quote,
        sparkline: sparkline ?? this.sparkline,
      );
}
