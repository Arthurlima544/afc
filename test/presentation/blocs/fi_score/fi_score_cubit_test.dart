import 'package:afc/presentation/blocs/fi_score/fi_score_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FiScoreData', () {
    test('achievedMilestones is empty when score is below 10', () {
      const FiScoreData data = FiScoreData(
        fiScore: 5,
        passiveIncomeMonthly: 50,
        monthlyExpenses: 1000,
        last6Scores: <double>[],
      );
      expect(data.achievedMilestones, isEmpty);
    });

    test('achievedMilestones includes 10 and 25 when score is 30', () {
      const FiScoreData data = FiScoreData(
        fiScore: 30,
        passiveIncomeMonthly: 300,
        monthlyExpenses: 1000,
        last6Scores: <double>[],
      );
      expect(data.achievedMilestones, containsAll(<int>[10, 25]));
      expect(data.achievedMilestones, isNot(contains(50)));
    });

    test('achievedMilestones includes all thresholds at score 100', () {
      const FiScoreData data = FiScoreData(
        fiScore: 100,
        passiveIncomeMonthly: 2000,
        monthlyExpenses: 1000,
        last6Scores: <double>[],
      );
      expect(
        data.achievedMilestones,
        containsAll(<int>[10, 25, 50, 75, 100]),
      );
    });
  });

  group('FiScoreCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<FiScoreCubit, FiScoreState>(
      'emits initial state',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      expect: () => <FiScoreState>[],
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'emits loading then success with zero score when no data',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      act: (FiScoreCubit c) => c.load('user-1'),
      expect: () => <dynamic>[
        const FiScoreState.loading(),
        isA<FiScoreState>().having(
          (FiScoreState s) => s,
          'success',
          isA<_Success>(),
        ),
      ],
      verify: (FiScoreCubit c) {
        final FiScoreState state = c.state;
        state.whenOrNull(
          success: (FiScoreData data) {
            expect(data.fiScore, equals(0.0));
            expect(data.passiveIncomeMonthly, equals(0.0));
            expect(data.last6Scores.length, equals(6));
          },
        );
      },
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'computes score correctly from passive income and expenses',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      setUp: () async {
        // Add passive income stream: R$500/month
        await fakeFirestore.collection('passive_income').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'pi-1',
          'name': 'Dividendos',
          'source': 'dividend',
          'amount': 500.0,
          'frequency': 'monthly',
        });

        // Add an expense for the current month
        final DateTime now = DateTime.now();
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'tx-1',
          'amount': 1000.0,
          'typeUuid': 'expense',
          'categoryUUid': 'cat-1',
          'title': 'Aluguel',
          'data': now.toIso8601String(),
        });
      },
      act: (FiScoreCubit c) => c.load('user-1'),
      verify: (FiScoreCubit c) {
        c.state.whenOrNull(
          success: (FiScoreData data) {
            // FI score = (500 / 1000) * 100 = 50
            expect(data.fiScore, closeTo(50.0, 0.01));
            expect(data.passiveIncomeMonthly, closeTo(500.0, 0.01));
            expect(data.monthlyExpenses, closeTo(1000.0, 0.01));
          },
        );
      },
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'caps score at 100 when passive income exceeds expenses',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      setUp: () async {
        await fakeFirestore.collection('passive_income').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'pi-2',
          'name': 'Aluguel',
          'source': 'rent',
          'amount': 5000.0,
          'frequency': 'monthly',
        });
        final DateTime now = DateTime.now();
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'tx-2',
          'amount': 1000.0,
          'typeUuid': 'expense',
          'categoryUUid': 'cat-1',
          'title': 'Gasto',
          'data': now.toIso8601String(),
        });
      },
      act: (FiScoreCubit c) => c.load('user-1'),
      verify: (FiScoreCubit c) {
        c.state.whenOrNull(
          success: (FiScoreData data) {
            expect(data.fiScore, equals(100.0));
          },
        );
      },
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'ignores income transactions (only counts expenses)',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      setUp: () async {
        await fakeFirestore.collection('passive_income').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'pi-3',
          'name': 'CDB',
          'source': 'interest',
          'amount': 200.0,
          'frequency': 'monthly',
        });
        final DateTime now = DateTime.now();
        // Income transaction (should NOT count as expenses)
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'tx-income',
          'amount': 3000.0,
          'typeUuid': 'income',
          'categoryUUid': 'cat-1',
          'title': 'Salário',
          'data': now.toIso8601String(),
        });
        // Expense transaction
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'userId': 'user-1',
          'uuid': 'tx-expense',
          'amount': 400.0,
          'typeUuid': 'expense',
          'categoryUUid': 'cat-1',
          'title': 'Mercado',
          'data': now.toIso8601String(),
        });
      },
      act: (FiScoreCubit c) => c.load('user-1'),
      verify: (FiScoreCubit c) {
        c.state.whenOrNull(
          success: (FiScoreData data) {
            // 200 / 400 * 100 = 50
            expect(data.fiScore, closeTo(50.0, 0.01));
            expect(data.monthlyExpenses, closeTo(400.0, 0.01));
          },
        );
      },
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'filters transactions by userId',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      setUp: () async {
        final DateTime now = DateTime.now();
        // Another user's transaction (should be ignored)
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'userId': 'other-user',
          'uuid': 'tx-other',
          'amount': 9999.0,
          'typeUuid': 'expense',
          'categoryUUid': 'cat-1',
          'title': 'Other',
          'data': now.toIso8601String(),
        });
      },
      act: (FiScoreCubit c) => c.load('user-1'),
      verify: (FiScoreCubit c) {
        c.state.whenOrNull(
          success: (FiScoreData data) {
            expect(data.monthlyExpenses, equals(0.0));
          },
        );
      },
    );

    blocTest<FiScoreCubit, FiScoreState>(
      'does nothing when userId is empty',
      build: () => FiScoreCubit(firestore: fakeFirestore),
      act: (FiScoreCubit c) => c.load(''),
      expect: () => <FiScoreState>[],
    );
  });
}

// Type alias to make the isA check work for the sealed Freezed class
typedef _Success = FiScoreState;
