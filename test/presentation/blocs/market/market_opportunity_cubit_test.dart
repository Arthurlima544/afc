import 'package:afc/domain/entity/market_quote_entity.dart';
import 'package:afc/domain/usecase/brapi_service.dart';
import 'package:afc/presentation/blocs/market/market_opportunity_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBrapiService extends Mock implements BrapiService {}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

MarketQuoteEntity _quote({
  required String ticker,
  required double dividendYield,
  bool isFii = false,
  double? priceEarnings,
}) =>
    MarketQuoteEntity(
      ticker: ticker,
      name: ticker,
      price: 10,
      changePercent: 0,
      dividendYield: dividendYield,
      isFii: isFii,
      priceEarnings: priceEarnings,
    );

void main() {
  late _MockBrapiService service;

  setUp(() {
    service = _MockBrapiService();
  });

  // ─── fromJson ──────────────────────────────────────────────────────────────

  group('MarketQuoteEntity.fromJson', () {
    test('parses Brapi quote JSON correctly', () {
      final MarketQuoteEntity q = MarketQuoteEntity.fromJson(<String, dynamic>{
        'symbol': 'PETR4',
        'longName': 'Petrobras',
        'regularMarketPrice': 35.5,
        'regularMarketChangePercent': 1.2,
        'dividendYield': 12.5,
        'priceEarnings': 4.0,
        'sector': 'Energy',
        'quoteType': 'EQUITY',
      });
      expect(q.ticker, 'PETR4');
      expect(q.name, 'Petrobras');
      expect(q.price, 35.5);
      expect(q.changePercent, 1.2);
      expect(q.dividendYield, 12.5);
      expect(q.priceEarnings, 4.0);
      expect(q.sector, 'Energy');
      expect(q.isFii, isFalse);
    });

    test('identifies FIIs via quoteType MUTUALFUND', () {
      final MarketQuoteEntity q = MarketQuoteEntity.fromJson(<String, dynamic>{
        'symbol': 'HGLG11',
        'regularMarketPrice': 150.0,
        'regularMarketChangePercent': -0.5,
        'dividendYield': 9.0,
        'quoteType': 'MUTUALFUND',
      });
      expect(q.isFii, isTrue);
    });

    test('falls back to shortName when longName absent', () {
      final MarketQuoteEntity q = MarketQuoteEntity.fromJson(<String, dynamic>{
        'symbol': 'VALE3',
        'shortName': 'Vale',
        'regularMarketPrice': 60.0,
        'regularMarketChangePercent': 0.0,
        'dividendYield': 8.0,
        'quoteType': 'EQUITY',
      });
      expect(q.name, 'Vale');
    });

    test('falls back to ticker when both names absent', () {
      final MarketQuoteEntity q = MarketQuoteEntity.fromJson(<String, dynamic>{
        'symbol': 'XYZ',
        'regularMarketPrice': 10.0,
        'regularMarketChangePercent': 0.0,
        'dividendYield': 0.0,
        'quoteType': 'EQUITY',
      });
      expect(q.name, 'XYZ');
    });
  });

  // ─── dyVsCdi ───────────────────────────────────────────────────────────────

  group('MarketQuoteEntity.dyVsCdi', () {
    test('returns DY / CDI ratio', () {
      final MarketQuoteEntity q =
          _quote(ticker: 'A', dividendYield: 13.0);
      expect(q.dyVsCdi(10.0), closeTo(1.3, 0.001));
    });

    test('returns 0 when CDI is zero', () {
      final MarketQuoteEntity q = _quote(ticker: 'A', dividendYield: 12.0);
      expect(q.dyVsCdi(0), 0);
    });
  });

  // ─── MarketOpportunityCubit ────────────────────────────────────────────────

  group('MarketOpportunityCubit', () {
    final List<MarketQuoteEntity> acoes = <MarketQuoteEntity>[
      _quote(ticker: 'PETR4', dividendYield: 12.0),
      _quote(ticker: 'VALE3', dividendYield: 8.0),
    ];
    final List<MarketQuoteEntity> fiis = <MarketQuoteEntity>[
      _quote(ticker: 'HGLG11', dividendYield: 9.5, isFii: true),
    ];

    blocTest<MarketOpportunityCubit, MarketOpportunityState>(
      'emits loading then loaded with quotes sorted by DY descending',
      setUp: () {
        when(() => service.fetchQuotes(BrapiService.acoesTickers))
            .thenAnswer((_) async => acoes);
        when(() => service.fetchQuotes(BrapiService.fiiTickers))
            .thenAnswer((_) async => fiis);
        when(() => service.fetchCdiRate()).thenAnswer((_) async => 13.65);
      },
      build: () => MarketOpportunityCubit(service: service),
      act: (MarketOpportunityCubit c) => c.load(),
      expect: () => <Matcher>[
        equals(const MarketOpportunityState.loading()),
        isA<MarketOpportunityState>().having(
          (MarketOpportunityState s) => s.whenOrNull(
            loaded: (List<MarketQuoteEntity> q, double cdi, DateTime at) =>
                q.map((MarketQuoteEntity e) => e.ticker).toList(),
          ),
          'tickers in DY order',
          <String>['PETR4', 'HGLG11', 'VALE3'],
        ),
      ],
    );

    blocTest<MarketOpportunityCubit, MarketOpportunityState>(
      'does not re-fetch within cache TTL',
      setUp: () {
        when(() => service.fetchQuotes(any())).thenAnswer((_) async => acoes);
        when(() => service.fetchCdiRate()).thenAnswer((_) async => 13.65);
      },
      build: () => MarketOpportunityCubit(service: service),
      act: (MarketOpportunityCubit c) async {
        await c.load();
        await c.load(); // second call should be a no-op
      },
      verify: (_) {
        // fetchQuotes should only have been called twice (acoes + fiis) in
        // the first load, not four times.
        verify(() => service.fetchQuotes(BrapiService.acoesTickers)).called(1);
        verify(() => service.fetchQuotes(BrapiService.fiiTickers)).called(1);
      },
    );

    blocTest<MarketOpportunityCubit, MarketOpportunityState>(
      'forceRefresh bypasses cache and re-fetches',
      setUp: () {
        when(() => service.fetchQuotes(any())).thenAnswer((_) async => acoes);
        when(() => service.fetchCdiRate()).thenAnswer((_) async => 13.65);
      },
      build: () => MarketOpportunityCubit(service: service),
      act: (MarketOpportunityCubit c) async {
        await c.load();
        await c.load(forceRefresh: true);
      },
      verify: (_) {
        verify(() => service.fetchQuotes(BrapiService.acoesTickers)).called(2);
      },
    );

    blocTest<MarketOpportunityCubit, MarketOpportunityState>(
      'emits error when fetchQuotes throws',
      setUp: () {
        when(() => service.fetchQuotes(any()))
            .thenThrow(Exception('Network error'));
        when(() => service.fetchCdiRate()).thenAnswer((_) async => 13.65);
      },
      build: () => MarketOpportunityCubit(service: service),
      act: (MarketOpportunityCubit c) => c.load(),
      expect: () => <Matcher>[
        equals(const MarketOpportunityState.loading()),
        isA<MarketOpportunityState>().having(
          (MarketOpportunityState s) =>
              s.whenOrNull(error: (String _) => true) ?? false,
          'is error state',
          isTrue,
        ),
      ],
    );
  });
}

