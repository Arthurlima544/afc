import 'package:afc/domain/entity/market_quote_entity.dart';
import 'package:afc/domain/entity/watchlist_entity.dart';
import 'package:afc/domain/usecase/brapi_service.dart';
import 'package:afc/presentation/blocs/watchlist/watchlist_cubit.dart';
import 'package:afc/presentation/blocs/watchlist/watchlist_item.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBrapiService extends Mock implements BrapiService {}

// ─── Helpers ──────────────────────────────────────────────────────────────────

WatchlistEntity _entity({
  String uuid = 'uuid-1',
  String ticker = 'PETR4',
  double? alertThreshold,
}) =>
    WatchlistEntity(
      uuid: uuid,
      userId: 'user-1',
      ticker: ticker,
      addedAt: DateTime(2025),
      alertThreshold: alertThreshold,
    );

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late _MockBrapiService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = _MockBrapiService();
    // Default stubs — individual tests can override.
    when(() => service.fetchQuotes(any()))
        .thenAnswer((_) async => <MarketQuoteEntity>[]);
    when(() => service.fetchHistory(any()))
        .thenAnswer((_) async => <double>[]);
  });

  // ─── WatchlistItem ─────────────────────────────────────────────────────────

  group('WatchlistItem', () {
    test('ticker delegates to entity.ticker', () {
      final WatchlistItem item = WatchlistItem(entity: _entity());
      expect(item.ticker, 'PETR4');
    });

    test('alertTriggered is false when no threshold set', () {
      final WatchlistItem item = WatchlistItem(entity: _entity());
      expect(item.alertTriggered, isFalse);
    });

    test('alertTriggered is false when quote is null', () {
      final WatchlistItem item = WatchlistItem(
        entity: _entity(alertThreshold: 30.0),
      );
      expect(item.alertTriggered, isFalse);
    });

    test('copyWith replaces sparkline only', () {
      final WatchlistItem item = WatchlistItem(entity: _entity());
      final WatchlistItem updated =
          item.copyWith(sparkline: <double>[1.0, 2.0]);
      expect(updated.sparkline, <double>[1.0, 2.0]);
      expect(updated.entity, item.entity);
    });
  });

  // ─── WatchlistCubit ────────────────────────────────────────────────────────

  group('WatchlistCubit', () {
    test('initial state is WatchlistState.initial', () {
      final WatchlistCubit cubit = WatchlistCubit(
        firestore: fakeFirestore,
        service: service,
      );
      expect(cubit.state, const WatchlistState.initial());
      cubit.close();
    });

    // ── loadWatchlist ──────────────────────────────────────────────────────

    blocTest<WatchlistCubit, WatchlistState>(
      'emits loading then loaded([]) when watchlist is empty',
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) => c.loadWatchlist('user-1'),
      expect: () => <Matcher>[
        equals(const WatchlistState.loading()),
        isA<WatchlistState>().having(
          (WatchlistState s) =>
              s.whenOrNull(
                loaded: (List<WatchlistItem> items, DateTime _) =>
                    items.isEmpty,
              ) ??
              false,
          'items is empty',
          isTrue,
        ),
      ],
    );

    blocTest<WatchlistCubit, WatchlistState>(
      'emits loaded with items for the correct userId',
      setUp: () async {
        await fakeFirestore
            .collection('watchlist')
            .add(_entity().toJson());
        // Different user — should not appear.
        await fakeFirestore
            .collection('watchlist')
            .add(_entity(uuid: 'uuid-other').copyWith(userId: 'other').toJson());
      },
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) => c.loadWatchlist('user-1'),
      verify: (WatchlistCubit c) {
        final int? count = c.state.whenOrNull(
          loaded: (List<WatchlistItem> items, DateTime _) => items.length,
        );
        expect(count, 1);
      },
    );

    // ── addTicker ──────────────────────────────────────────────────────────

    blocTest<WatchlistCubit, WatchlistState>(
      'addTicker persists to Firestore and reloads',
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) async {
        await c.loadWatchlist('user-1');
        await c.addTicker('VALE3');
      },
      verify: (_) async {
        final docs = await fakeFirestore
            .collection('watchlist')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(docs.docs.length, 1);
        expect(docs.docs.first.data()['ticker'], 'VALE3');
      },
    );

    blocTest<WatchlistCubit, WatchlistState>(
      'addTicker uppercases and trims the ticker',
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) async {
        await c.loadWatchlist('user-1');
        await c.addTicker('  vale3  ');
      },
      verify: (_) async {
        final docs = await fakeFirestore.collection('watchlist').get();
        expect(docs.docs.first.data()['ticker'], 'VALE3');
      },
    );

    // ── removeTicker ──────────────────────────────────────────────────────

    blocTest<WatchlistCubit, WatchlistState>(
      'removeTicker deletes the correct document',
      setUp: () async {
        await fakeFirestore
            .collection('watchlist')
            .add(_entity(uuid: 'uuid-1', ticker: 'PETR4').toJson());
        await fakeFirestore
            .collection('watchlist')
            .add(_entity(uuid: 'uuid-2', ticker: 'VALE3').toJson());
      },
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) async {
        await c.loadWatchlist('user-1');
        await c.removeTicker('uuid-1');
      },
      verify: (_) async {
        final docs = await fakeFirestore
            .collection('watchlist')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(docs.docs.length, 1);
        expect(docs.docs.first.data()['ticker'], 'VALE3');
      },
    );

    // ── setAlert ──────────────────────────────────────────────────────────

    blocTest<WatchlistCubit, WatchlistState>(
      'setAlert updates alertThreshold in Firestore',
      setUp: () async {
        await fakeFirestore
            .collection('watchlist')
            .add(_entity(uuid: 'uuid-1').toJson());
      },
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) async {
        await c.loadWatchlist('user-1');
        await c.setAlert('uuid-1', 45.0);
      },
      verify: (_) async {
        final docs = await fakeFirestore
            .collection('watchlist')
            .where('uuid', isEqualTo: 'uuid-1')
            .get();
        expect(docs.docs.first.data()['alertThreshold'], 45.0);
      },
    );

    blocTest<WatchlistCubit, WatchlistState>(
      'setAlert is a no-op when uuid is not found',
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) async {
        await c.loadWatchlist('user-1');
        await c.setAlert('non-existent', 50.0); // should not throw
      },
      errors: () => <Matcher>[],
    );

    // ── refresh ───────────────────────────────────────────────────────────

    blocTest<WatchlistCubit, WatchlistState>(
      'refresh is a no-op when state is not loaded',
      build: () =>
          WatchlistCubit(firestore: fakeFirestore, service: service),
      act: (WatchlistCubit c) => c.refresh(),
      expect: () => <Matcher>[],
      // fetchQuotes should never be called if there are no items.
      verify: (_) {
        verifyNever(() => service.fetchQuotes(any()));
      },
    );
  });
}
