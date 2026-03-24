/// Sprint 13 regression tests — verifies the specific bugs fixed in this sprint:
///
/// US-71: Goal list is visible again after contribute/edit/delete.
/// US-74: Bill list refreshes after create and update.
/// US-73: RecurringCubit.create emits success so the BlocListener can pop.
/// US-70: Error states are emitted so listeners can show snackbars.
library;

import 'package:afc/domain/entity/bill_entity.dart';
import 'package:afc/domain/entity/goal_entity.dart';
import 'package:afc/domain/entity/recurring_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/presentation/blocs/bill/bill_cubit.dart';
import 'package:afc/presentation/blocs/goal/goal_cubit.dart';
import 'package:afc/presentation/blocs/recurring/recurring_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  final DateTime tDeadline = DateTime(2028, 12, 31);

  final GoalEntity tGoal = GoalEntity(
    uuid: 'goal-1',
    userId: 'user-1',
    name: 'Viagem',
    targetAmount: 5000.0,
    deadline: tDeadline,
    icon: 0,
  );

  const BillEntity tBill = BillEntity(
    uuid: 'bill-1',
    userId: 'user-1',
    name: 'Aluguel',
    amount: 1200.0,
    dueDay: 10,
    categoryUuid: 'cat-1',
  );

  final TransactionEntity tTemplate = TransactionEntity(
    uuid: 'tx-1',
    amount: 50.0,
    categoryUUid: 'cat-1',
    typeUuid: 'expense',
    data: DateTime(2025),
    title: 'Netflix',
    userId: 'user-1',
  );

  final RecurringEntity tRule = RecurringEntity(
    uuid: 'rule-1',
    userId: 'user-1',
    templateTransaction: tTemplate,
    frequency: 'monthly',
    nextDue: DateTime(2025, 2),
    active: true,
  );

  // ── US-71: Goal list stays visible after mutations ─────────────────────────

  group('US-71 — GoalCubit list stays visible after mutations', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<GoalCubit, GoalState>(
      'contribute emits success — screen can then call loadGoals for refresh',
      setUp: () async {
        await fakeFirestore.collection('goal').add(tGoal.toJson());
      },
      build: () => GoalCubit(firestore: fakeFirestore),
      act: (GoalCubit cubit) async {
        // Screen loads list first, then user contributes
        await cubit.loadGoals('user-1');
        await cubit.contribute('goal-1', 300.0);
        // Screen reloads after contribute
        await cubit.loadGoals('user-1');
      },
      expect: () => <GoalState>[
        const GoalState.loading(),
        GoalState.listed(<GoalEntity>[tGoal]),
        const GoalState.loading(),
        GoalState.success(tGoal.copyWith(currentAmount: 300.0)),
        const GoalState.loading(),
        GoalState.listed(<GoalEntity>[tGoal.copyWith(currentAmount: 300.0)]),
      ],
    );

    blocTest<GoalCubit, GoalState>(
      'create emits success — screen can then call loadGoals for refresh',
      build: () => GoalCubit(firestore: fakeFirestore),
      act: (GoalCubit cubit) async {
        await cubit.loadGoals('user-1');
        await cubit.create(tGoal);
        await cubit.loadGoals('user-1');
      },
      expect: () => <GoalState>[
        const GoalState.loading(),
        const GoalState.listed(<GoalEntity>[]),
        const GoalState.loading(),
        GoalState.success(tGoal),
        const GoalState.loading(),
        GoalState.listed(<GoalEntity>[tGoal]),
      ],
    );

    blocTest<GoalCubit, GoalState>(
      'delete followed by loadGoals shows empty list',
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
    );
  });

  // ── US-74: Bill list refreshes after create / update ──────────────────────

  group('US-74 — BillCubit list refreshes after create and update', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<BillCubit, BillState>(
      'create followed by loadBills shows the new bill',
      build: () => BillCubit(firestore: fakeFirestore),
      act: (BillCubit cubit) async {
        await cubit.loadBills('user-1');
        await cubit.create(tBill);
        await cubit.loadBills('user-1');
      },
      expect: () => <BillState>[
        const BillState.loading(),
        const BillState.listed(<BillEntity>[]),
        const BillState.loading(),
        const BillState.success(tBill),
        const BillState.loading(),
        const BillState.listed(<BillEntity>[tBill]),
      ],
    );

    blocTest<BillCubit, BillState>(
      'update followed by loadBills shows the updated bill',
      setUp: () async {
        await fakeFirestore.collection('bill').add(tBill.toJson());
      },
      build: () => BillCubit(firestore: fakeFirestore),
      act: (BillCubit cubit) async {
        final BillEntity updated = tBill.copyWith(amount: 1500.0);
        await cubit.update(updated);
        await cubit.loadBills('user-1');
      },
      expect: () => <BillState>[
        const BillState.loading(),
        BillState.success(tBill.copyWith(amount: 1500.0)),
        const BillState.loading(),
        BillState.listed(<BillEntity>[tBill.copyWith(amount: 1500.0)]),
      ],
    );
  });

  // ── US-73: RecurringCubit.create emits success (enables sheet pop) ─────────

  group('US-73 — RecurringCubit.create emits success', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<RecurringCubit, RecurringState>(
      'create emits [loading, success] so BlocListener can pop the sheet',
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.create(tRule),
      expect: () => <RecurringState>[
        const RecurringState.loading(),
        RecurringState.success(tRule),
      ],
    );
  });

  // ── US-70: Error states are emitted for snackbar display ──────────────────

  group('US-70 — cubits emit error states for snackbar feedback', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<GoalCubit, GoalState>(
      'contribute emits error when goal uuid is not found',
      build: () => GoalCubit(firestore: fakeFirestore),
      act: (GoalCubit cubit) async => cubit.contribute('non-existent', 100.0),
      expect: () => <GoalState>[
        const GoalState.loading(),
        const GoalState.error('Meta não encontrada.'),
      ],
    );
  });
}
