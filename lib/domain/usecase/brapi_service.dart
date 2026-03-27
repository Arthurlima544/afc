import 'dart:convert';

import 'package:http/http.dart' as http;

import '../entity/market_quote_entity.dart';

/// Thin HTTP client for the Brapi public API (https://brapi.dev).
///
/// Free-tier limits: ~15 requests / minute, no API key required.
/// Callers should batch tickers and cache results to stay within limits.
class BrapiService {
  BrapiService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const String _base = 'https://brapi.dev/api';

  // ─── Curated ticker lists ──────────────────────────────────────────────────

  /// Top dividend-paying Brazilian equities (Ações) on B3.
  static const List<String> acoesTickers = <String>[
    'PETR4',
    'VALE3',
    'BBAS3',
    'ITUB4',
    'BBDC4',
    'TAEE11',
    'EGIE3',
    'CPLE6',
    'KLBN11',
    'SUZB3',
    'TRPL4',
    'ENGIE3',
    'SAPR11',
    'WEGE3',
    'TOTS3',
  ];

  /// Top dividend-paying FIIs (Fundos de Investimento Imobiliário).
  static const List<String> fiiTickers = <String>[
    'HGLG11',
    'MXRF11',
    'KNRI11',
    'XPML11',
    'VISC11',
    'BCFF11',
    'HGBS11',
    'BTLG11',
    'HSML11',
    'PVBI11',
    'RBVA11',
    'VGHF11',
  ];

  // ─── API calls ─────────────────────────────────────────────────────────────

  /// Fetches fundamental quotes for [tickers] in a single batch request.
  ///
  /// Returns an empty list if Brapi returns a non-200 status.
  Future<List<MarketQuoteEntity>> fetchQuotes(
    List<String> tickers,
  ) async {
    if (tickers.isEmpty) {
      return <MarketQuoteEntity>[];
    }
    final String joined = tickers.join(',');
    final Uri uri = Uri.parse('$_base/quote/$joined?fundamental=true');
    final http.Response response = await _client.get(uri);
    if (response.statusCode != 200) {
      return <MarketQuoteEntity>[];
    }
    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> results =
        body['results'] as List<dynamic>? ?? <dynamic>[];
    return results
        .map(
          (dynamic r) =>
              MarketQuoteEntity.fromJson(r as Map<String, dynamic>),
        )
        .toList();
  }

  /// Fetches 5-day daily close prices for [ticker] (for sparklines).
  ///
  /// Returns an empty list on any network or parse error — callers should
  /// treat an empty list as "sparkline unavailable" and hide the chart.
  Future<List<double>> fetchHistory(String ticker) async {
    try {
      final Uri uri =
          Uri.parse('$_base/quote/$ticker?range=5d&interval=1d');
      final http.Response response = await _client.get(uri);
      if (response.statusCode != 200) {
        return <double>[];
      }
      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> results =
          body['results'] as List<dynamic>? ?? <dynamic>[];
      if (results.isEmpty) {
        return <double>[];
      }
      final Map<String, dynamic> first =
          results.first as Map<String, dynamic>;
      final List<dynamic> history =
          first['historicalDataPrice'] as List<dynamic>? ?? <dynamic>[];
      return history
          .map(
            (dynamic h) =>
                ((h as Map<String, dynamic>)['close'] as num?)?.toDouble() ??
                0.0,
          )
          .where((double v) => v > 0)
          .toList();
    } on Exception {
      return <double>[];
    }
  }

  /// Returns the current Brazilian CDI annual rate as a percentage
  /// (e.g. 13.65 for 13.65 % p.a.).
  ///
  /// Falls back to 13.65 % on any network or parse error — a reasonable
  /// approximation of the Selic when real data is unavailable.
  Future<double> fetchCdiRate() async {
    try {
      final Uri uri = Uri.parse(
        '$_base/v2/prime-rate?country=brazil&historical=false',
      );
      final http.Response response = await _client.get(uri);
      if (response.statusCode != 200) {
        return 13.65;
      }
      final Map<String, dynamic> body =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> rates =
          body['prime-rate'] as List<dynamic>? ?? <dynamic>[];
      if (rates.isEmpty) {
        return 13.65;
      }
      return ((rates.first as Map<String, dynamic>)['value'] as num)
          .toDouble();
    } on Exception {
      return 13.65;
    }
  }
}
