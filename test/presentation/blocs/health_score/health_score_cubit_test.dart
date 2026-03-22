import 'package:afc/domain/usecase/health_score.dart';
import 'package:afc/presentation/blocs/health_score/health_score_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

const String _userId = 'user-123';

void main() {
  // -------------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------------
  test('initial state is HealthScoreState.initial', () {
    final HealthScoreCubit cubit = HealthScoreCubit(
      firestore: FakeFirebaseFirestore(),
    );
    expect(cubit.state, const HealthScoreState.initial());
    cubit.close();
  });

  // -------------------------------------------------------------------------
  // loadScore — empty userId does nothing
  // -------------------------------------------------------------------------
  blocTest<HealthScoreCubit, HealthScoreState>(
    'loadScore with empty userId emits nothing',
    build: () => HealthScoreCubit(firestore: FakeFirebaseFirestore()),
    act: (HealthScoreCubit cubit) => cubit.loadScore(''),
    expect: () => <HealthScoreState>[],
  );

  // -------------------------------------------------------------------------
  // loadScore — no data (neutral scores only)
  // -------------------------------------------------------------------------
  blocTest<HealthScoreCubit, HealthScoreState>(
    'loadScore with no transactions/limits/goals emits [loading, success] '
    'with neutral score of 36',
    build: () => HealthScoreCubit(firestore: FakeFirebaseFirestore()),
    act: (HealthScoreCubit cubit) => cubit.loadScore(_userId),
    expect: () => <TypeMatcher<HealthScoreState>>[
      isA<HealthScoreState>().having(
        (HealthScoreState s) => s,
        'is loading',
        const HealthScoreState.loading(),
      ),
      isA<HealthScoreState>().having(
        (HealthScoreState s) => s.whenOrNull(
          success: (HealthScoreData d) => d.score,
        ),
        'score',
        // income=0→0pts, limits neutral=12, goals neutral=12, prev=0→12 = 36
        36,
      ),
    ],
  );

  // -------------------------------------------------------------------------
  // loadScore — computes correct score with seeded data
  // -------------------------------------------------------------------------
  group('loadScore with seeded transactions', () {
    late FakeFirebaseFirestore db;

    setUp(() async {
      db = FakeFirebaseFirestore();
      final DateTime now = DateTime.now();
      final DateTime prevMonth = DateTime(now.year, now.month - 1, 15);
      final DateTime thisMonth = DateTime(now.year, now.month, 10);

      // income 2000, expenses 1600 this month → savings 20% → 25 pts
      // prev expenses 1700 → variance (1700-1600)/1700 ≈ 5.9% (stable) → 18 pts
      // no limits → 12 pts neutral
      // no goals → 12 pts neutral
      // total = 25 + 12 + 12 + 18 = 67
      await db.collection('transaction').add(<String, dynamic>{
        'userId': _userId,
        'typeUuid': 'income',
        'amount': 2000.0,
        'categoryUUid': 'cat-1',
        'data': Timestamp.fromDate(thisMonth),
        'uuid': 'tx-1',
        'title': 'Salary',
      });
      await db.collection('transaction').add(<String, dynamic>{
        'userId': _userId,
        'typeUuid': 'expense',
        'amount': 1600.0,
        'categoryUUid': 'cat-2',
        'data': Timestamp.fromDate(thisMonth),
        'uuid': 'tx-2',
        'title': 'Rent',
      });
      await db.collection('transaction').add(<String, dynamic>{
        'userId': _userId,
        'typeUuid': 'expense',
        'amount': 1700.0,
        'categoryUUid': 'cat-2',
        'data': Timestamp.fromDate(prevMonth),
        'uuid': 'tx-3',
        'title': 'Rent prev',
      });
    });

    blocTest<HealthScoreCubit, HealthScoreState>(
      'emits score 67',
      build: () => HealthScoreCubit(firestore: db),
      act: (HealthScoreCubit cubit) => cubit.loadScore(_userId),
      expect: () => <TypeMatcher<HealthScoreState>>[
        isA<HealthScoreState>().having(
          (HealthScoreState s) => s,
          'is loading',
          const HealthScoreState.loading(),
        ),
        isA<HealthScoreState>().having(
          (HealthScoreState s) => s.whenOrNull(
            success: (HealthScoreData d) => d.score,
          ),
          'score',
          67,
        ),
      ],
    );
  });

  // -------------------------------------------------------------------------
  // loadScore — sub-score breakdown is correct
  // -------------------------------------------------------------------------
  group('loadScore sub-score breakdown', () {
    late FakeFirebaseFirestore db;

    setUp(() async {
      db = FakeFirebaseFirestore();
      final DateTime now = DateTime.now();
      final DateTime thisMonth = DateTime(now.year, now.month, 10);

      // savings rate 25% → 25 pts; no prev data → 12 pts; no limits/goals → 12 each
      // total = 25 + 12 + 12 + 12 = 61
      await db.collection('transaction').add(<String, dynamic>{
        'userId': _userId,
        'typeUuid': 'income',
        'amount': 1000.0,
        'categoryUUid': 'cat-1',
        'data': Timestamp.fromDate(thisMonth),
        'uuid': 'tx-a',
        'title': 'Income',
      });
      await db.collection('transaction').add(<String, dynamic>{
        'userId': _userId,
        'typeUuid': 'expense',
        'amount': 750.0,
        'categoryUUid': 'cat-2',
        'data': Timestamp.fromDate(thisMonth),
        'uuid': 'tx-b',
        'title': 'Expense',
      });
    });

    blocTest<HealthScoreCubit, HealthScoreState>(
      'emits correct individual sub-scores',
      build: () => HealthScoreCubit(firestore: db),
      act: (HealthScoreCubit cubit) => cubit.loadScore(_userId),
      verify: (HealthScoreCubit cubit) {
        cubit.state.whenOrNull(
          success: (HealthScoreData d) {
            expect(d.savingsPoints, 25); // 25% savings
            expect(d.limitPoints, 12);   // neutral
            expect(d.goalPoints, 12);    // neutral
            expect(d.variancePoints, 12); // no prev data
            expect(d.score, 61);
          },
        );
      },
    );
  });

  // -------------------------------------------------------------------------
  // loadScore — last6MonthScores always has length 6 and valid range
  // -------------------------------------------------------------------------
  blocTest<HealthScoreCubit, HealthScoreState>(
    'loadScore always emits 6 monthly scores in sparkline within 0-100',
    build: () => HealthScoreCubit(firestore: FakeFirebaseFirestore()),
    act: (HealthScoreCubit cubit) => cubit.loadScore(_userId),
    verify: (HealthScoreCubit cubit) {
      cubit.state.whenOrNull(
        success: (HealthScoreData d) {
          expect(d.last6MonthScores.length, 6);
          for (final int s in d.last6MonthScores) {
            expect(s, inInclusiveRange(0, 100));
          }
        },
      );
    },
  );
}
