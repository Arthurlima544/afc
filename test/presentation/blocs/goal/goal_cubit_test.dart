import 'package:afc/domain/entity/goal_entity.dart';
import 'package:afc/presentation/blocs/goal/goal_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    final DateTime tDeadline = DateTime(2027, 12, 31);

    final GoalEntity tGoal = GoalEntity(
      uuid: 'goal-1',
      userId: 'user-1',
      name: 'Viagem',
      targetAmount: 5000.0,
      deadline: tDeadline,
      icon: 0,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is GoalState.initial', () {
      final GoalCubit cubit = GoalCubit(firestore: fakeFirestore);
      expect(cubit.state, const GoalState.initial());
      cubit.close();
    });

    group('loadGoals', () {
      blocTest<GoalCubit, GoalState>(
        'emits [loading, listed([])] when no goals exist',
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async => cubit.loadGoals('user-1'),
        expect: () => <GoalState>[
          const GoalState.loading(),
          const GoalState.listed(<GoalEntity>[]),
        ],
      );

      blocTest<GoalCubit, GoalState>(
        'emits listed with seeded goals',
        setUp: () async {
          await fakeFirestore.collection('goal').add(tGoal.toJson());
        },
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async => cubit.loadGoals('user-1'),
        expect: () => <GoalState>[
          const GoalState.loading(),
          GoalState.listed(<GoalEntity>[tGoal]),
        ],
      );

      blocTest<GoalCubit, GoalState>(
        'does not include goals for other users',
        setUp: () async {
          await fakeFirestore.collection('goal').add(
            tGoal.copyWith(userId: 'other-user').toJson(),
          );
        },
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async => cubit.loadGoals('user-1'),
        expect: () => <GoalState>[
          const GoalState.loading(),
          const GoalState.listed(<GoalEntity>[]),
        ],
      );
    });

    group('create', () {
      blocTest<GoalCubit, GoalState>(
        'emits [loading, success] when goal is created',
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async => cubit.create(tGoal),
        expect: () => <GoalState>[
          const GoalState.loading(),
          GoalState.success(tGoal),
        ],
      );

      test('persists goal to Firestore collection', () async {
        final GoalCubit cubit = GoalCubit(firestore: fakeFirestore);

        await cubit.create(tGoal);

        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('goal').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Viagem');
        expect(snapshot.docs.first.data()['targetAmount'], 5000.0);
        await cubit.close();
      });
    });

    group('contribute', () {
      blocTest<GoalCubit, GoalState>(
        'contribute increments currentAmount in Firestore',
        setUp: () async {
          await fakeFirestore.collection('goal').add(tGoal.toJson());
        },
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async =>
            cubit.contribute('goal-1', 200.0),
        expect: () => <GoalState>[
          const GoalState.loading(),
          GoalState.success(tGoal.copyWith(currentAmount: 200.0)),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('goal').get();
          expect(snap.docs.first.data()['currentAmount'], 200.0);
        },
      );

      blocTest<GoalCubit, GoalState>(
        'contribute emits error when uuid not found',
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async =>
            cubit.contribute('non-existent-uuid', 100.0),
        expect: () => <GoalState>[
          const GoalState.loading(),
          const GoalState.error('Meta não encontrada.'),
        ],
      );

      test('contribute accumulates amounts on repeated calls', () async {
        await fakeFirestore.collection('goal').add(tGoal.toJson());
        final GoalCubit cubit = GoalCubit(firestore: fakeFirestore);

        await cubit.contribute('goal-1', 100.0);
        await cubit.contribute('goal-1', 150.0);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('goal').get();
        expect(snap.docs.first.data()['currentAmount'], 250.0);
        await cubit.close();
      });
    });

    group('delete', () {
      blocTest<GoalCubit, GoalState>(
        'delete removes goal from Firestore then reloads',
        setUp: () async {
          await fakeFirestore.collection('goal').add(tGoal.toJson());
        },
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async {
          await cubit.loadGoals('user-1');
          await cubit.delete('goal-1');
          await cubit.loadGoals('user-1');
        },
        expect: () => <GoalState>[
          const GoalState.loading(),
          GoalState.listed(<GoalEntity>[tGoal]),
          const GoalState.loading(),
          const GoalState.listed(<GoalEntity>[]),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('goal').get();
          expect(snap.docs.isEmpty, isTrue);
        },
      );
    });

    group('update', () {
      blocTest<GoalCubit, GoalState>(
        'update emits [loading, success] after updating goal',
        setUp: () async {
          await fakeFirestore.collection('goal').add(tGoal.toJson());
        },
        build: () => GoalCubit(firestore: fakeFirestore),
        act: (GoalCubit cubit) async =>
            cubit.update(tGoal.copyWith(name: 'Novo carro')),
        expect: () => <GoalState>[
          const GoalState.loading(),
          GoalState.success(tGoal.copyWith(name: 'Novo carro')),
        ],
      );
    });

    group('progress calculation', () {
      test('progress ratio is zero when currentAmount is 0', () {
        final GoalEntity goal = tGoal.copyWith(
          currentAmount: 0.0,
          targetAmount: 1000.0,
        );
        final double ratio = goal.currentAmount / goal.targetAmount;
        expect(ratio, 0.0);
      });

      test('progress ratio is 1.0 when currentAmount equals targetAmount', () {
        final GoalEntity goal = tGoal.copyWith(
          currentAmount: 1000.0,
          targetAmount: 1000.0,
        );
        final double ratio = goal.currentAmount / goal.targetAmount;
        expect(ratio, 1.0);
      });

      test('progress ratio is fractional for partial completion', () {
        final GoalEntity goal = tGoal.copyWith(
          currentAmount: 250.0,
          targetAmount: 1000.0,
        );
        final double ratio = goal.currentAmount / goal.targetAmount;
        expect(ratio, 0.25);
      });

      test('days remaining is positive for future deadline', () {
        final DateTime future = DateTime.now().add(const Duration(days: 10));
        final GoalEntity goal = tGoal.copyWith(deadline: future);
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime deadline = DateTime(
          goal.deadline.year,
          goal.deadline.month,
          goal.deadline.day,
        );
        final int days = deadline.difference(today).inDays;
        expect(days, greaterThan(0));
      });

      test('days remaining is negative for past deadline', () {
        final DateTime past = DateTime.now().subtract(const Duration(days: 5));
        final GoalEntity goal = tGoal.copyWith(deadline: past);
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime deadline = DateTime(
          goal.deadline.year,
          goal.deadline.month,
          goal.deadline.day,
        );
        final int days = deadline.difference(today).inDays;
        expect(days, lessThan(0));
      });
    });
  });
}
