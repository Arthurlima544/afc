import 'package:afc/domain/entity/calendar_entity.dart';
import 'package:afc/domain/entity/stats_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
import 'package:afc/presentation/blocs/home/home_bloc.dart';
import 'package:afc/presentation/blocs/home/stats_state.dart';
import 'package:afc/presentation/blocs/home/transaction_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeBloc', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    // -------------------------------------------------------------------------
    // Initial state
    // -------------------------------------------------------------------------

    test('initial state has both sub-states as initial', () async {
      // Arrange & Act
      final HomeBloc bloc = HomeBloc(firestore: fakeFirestore);

      // Assert
      expect(
        bloc.state,
        const HomeState(
          transactionState: LastTransactionState.initial(),
          statsState: StatsState.initial(),
        ),
      );
      await bloc.close();
    });

    // -------------------------------------------------------------------------
    // loadHome — empty Firestore
    // -------------------------------------------------------------------------

    group('HomeEvent.loadHome — no data', () {
      blocTest<HomeBloc, HomeState>(
        'emits loading then empty-success for both sub-states',
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-no-data')),
        expect: () => <HomeState>[
          // _loadStats: loading
          const HomeState(
            transactionState: LastTransactionState.initial(),
            statsState: StatsState.loading(),
          ),
          // _loadStats: success([])
          const HomeState(
            transactionState: LastTransactionState.initial(),
            statsState: StatsState.success(<StatsEntity>[]),
          ),
          // _loadLastTransactions: loading
          const HomeState(
            transactionState: LastTransactionState.loading(),
            statsState: StatsState.success(<StatsEntity>[]),
          ),
          // _loadLastTransactions: success([])
          const HomeState(
            transactionState:
                LastTransactionState.success(<TransactionEntity>[]),
            statsState: StatsState.success(<StatsEntity>[]),
          ),
        ],
      );
    });

    // -------------------------------------------------------------------------
    // loadHome — with transaction data
    // -------------------------------------------------------------------------

    group('HomeEvent.loadHome — with data', () {
      final DateTime janDate = DateTime(2025, 1, 15);
      final DateTime febDate = DateTime(2025, 2, 10);

      setUp(() async {
        // Arrange — seed Firestore with transactions for 'user-1'
        await fakeFirestore.collection('transaction').add(<String, Object>{
          'uuid': 'tx-1',
          'amount': 1000.0,
          'categoryUUid': 'cat-1',
          'typeUuid': 'income',
          'data': janDate.toIso8601String(),
          'title': 'Salário',
          'userId': 'user-1',
        });
        await fakeFirestore.collection('transaction').add(<String, Object>{
          'uuid': 'tx-2',
          'amount': 300.0,
          'categoryUUid': 'cat-2',
          'typeUuid': 'expense',
          'data': janDate.toIso8601String(),
          'title': 'Aluguel',
          'userId': 'user-1',
        });
        await fakeFirestore.collection('transaction').add(<String, Object>{
          'uuid': 'tx-3',
          'amount': 500.0,
          'categoryUUid': 'cat-1',
          'typeUuid': 'income',
          'data': febDate.toIso8601String(),
          'title': 'Freela',
          'userId': 'user-1',
        });
      });

      blocTest<HomeBloc, HomeState>(
        'emits StatsState.success with correct stats grouped by type and month',
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-1')),
        verify: (HomeBloc bloc) {
          // Assert — check final state stats
          final HomeState finalState = bloc.state;
          finalState.statsState.whenOrNull(
            success: (List<StatsEntity> stats) {
              // January income: 1000
              expect(
                stats.firstWhere(
                  (StatsEntity s) =>
                      s.type == TypeEntity.income &&
                      s.date == CalendarEntity.january,
                ).total,
                1000.0,
              );
              // January expense: 300
              expect(
                stats.firstWhere(
                  (StatsEntity s) =>
                      s.type == TypeEntity.expense &&
                      s.date == CalendarEntity.january,
                ).total,
                300.0,
              );
              // February income: 500
              expect(
                stats.firstWhere(
                  (StatsEntity s) =>
                      s.type == TypeEntity.income &&
                      s.date == CalendarEntity.february,
                ).total,
                500.0,
              );
            },
          );
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits LastTransactionState.success with transactions sorted newest first',
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-1')),
        verify: (HomeBloc bloc) {
          final HomeState finalState = bloc.state;
          finalState.transactionState.whenOrNull(
            success: (List<TransactionEntity> transactions) {
              // Arrange — febDate > janDate, so freela should be first
              expect(transactions.length, 3);
              expect(transactions.first.title, 'Freela');
            },
          );
        },
      );

      blocTest<HomeBloc, HomeState>(
        'does not include transactions from other users',
        setUp: () async {
          await fakeFirestore.collection('transaction').add(<String, Object>{
            'uuid': 'tx-other',
            'amount': 9999.0,
            'categoryUUid': 'cat-x',
            'typeUuid': 'income',
            'data': janDate.toIso8601String(),
            'title': 'Other user tx',
            'userId': 'other-user',
          });
        },
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-1')),
        verify: (HomeBloc bloc) {
          bloc.state.transactionState.whenOrNull(
            success: (List<TransactionEntity> transactions) {
              expect(
                transactions.any(
                  (TransactionEntity t) => t.userId == 'other-user',
                ),
                isFalse,
              );
            },
          );
        },
      );

      blocTest<HomeBloc, HomeState>(
        'limits last transactions to 5 most recent',
        setUp: () async {
          // Add 4 more transactions (total 7 for user-1)
          for (int i = 4; i <= 7; i++) {
            await fakeFirestore.collection('transaction').add(<String, Object>{
              'uuid': 'tx-$i',
              'amount': 100.0 * i,
              'categoryUUid': 'cat-1',
              'typeUuid': 'income',
              'data': DateTime(2025, i).toIso8601String(),
              'title': 'Transaction $i',
              'userId': 'user-1',
            });
          }
        },
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-1')),
        verify: (HomeBloc bloc) {
          bloc.state.transactionState.whenOrNull(
            success: (List<TransactionEntity> transactions) {
              expect(transactions.length, 5);
            },
          );
        },
      );
    });
  });
}
