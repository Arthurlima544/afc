/// A stock / FII quote returned by the Brapi API.
///
/// Display-only — not stored in Firestore. Constructed directly from the
/// Brapi `/api/quote/{tickers}?fundamental=true` JSON response.
class MarketQuoteEntity {
  const MarketQuoteEntity({
    required this.ticker,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.dividendYield,
    required this.isFii,
    this.priceEarnings,
    this.sector = '',
  });

  factory MarketQuoteEntity.fromJson(Map<String, dynamic> json) {
    final String ticker = (json['symbol'] as String?) ?? '';
    // Brapi marks FIIs with quoteType == 'MUTUALFUND'.
    final bool isFii = (json['quoteType'] as String?) == 'MUTUALFUND';
    return MarketQuoteEntity(
      ticker: ticker,
      name: (json['longName'] as String?) ??
          (json['shortName'] as String?) ??
          ticker,
      price: ((json['regularMarketPrice'] as num?) ?? 0).toDouble(),
      changePercent:
          ((json['regularMarketChangePercent'] as num?) ?? 0).toDouble(),
      dividendYield: ((json['dividendYield'] as num?) ?? 0).toDouble(),
      priceEarnings: (json['priceEarnings'] as num?)?.toDouble(),
      sector: (json['sector'] as String?) ?? '',
      isFii: isFii,
    );
  }

  final String ticker;
  final String name;

  /// Current market price in BRL.
  final double price;

  /// Today's price change in percent (positive = gain, negative = loss).
  final double changePercent;

  /// Trailing 12-month dividend yield in percent (e.g. 12.5 means 12.5 %).
  final double dividendYield;

  /// True when the asset is a FII (Fundo de Investimento Imobiliário).
  final bool isFii;

  /// Price-to-earnings ratio; null when unavailable (e.g. for most FIIs).
  final double? priceEarnings;

  final String sector;

  /// Returns [dividendYield] expressed as a multiple of [cdiRate].
  /// Example: DY 13 % with CDI 10 % → 1.3× CDI.
  double dyVsCdi(double cdiRate) =>
      cdiRate > 0 ? dividendYield / cdiRate : 0;
}
