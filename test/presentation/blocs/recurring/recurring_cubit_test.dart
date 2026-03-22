import 'package:afc/domain/entity/recurring_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/presentation/blocs/recurring/recurring_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TransactionEntity _template({
  String uuid = 'tx-template',
  double amount = 100,
  String typeUuid = 'expense',
}) =>
    TransactionEntity(
      uuid: uuid,
      amount: amount,
      categoryUUid: 'cat-1',
      typeUuid: typeUuid,
      data: DateTime(2025),
      title: 'Netflix',
      userId: 'user-1',
    );

RecurringEntity _rule({
  String uuid = 'rule-1',
  String frequency = 'monthly',
  DateTime? nextDue,
  bool active = true,
}) =>
    RecurringEntity(
      uuid: uuid,
      userId: 'user-1',
      templateTransaction: _template(),
      frequency: frequency,
      nextDue: nextDue ?? DateTime(2025, 2),
      active: active,
    );

// ---------------------------------------------------------------------------
// nextDueAfter unit tests
// ---------------------------------------------------------------------------

void main() {
  group('nextDueAfter', () {
    test('daily advances by 1 day', () {
      final DateTime from = DateTime(2025, 3, 10);
      expect(nextDueAfter('daily', from), DateTime(2025, 3, 11));
    });

    test('weekly advances by 7 days', () {
      final DateTime from = DateTime(2025, 3, 10);
      expect(nextDueAfter('weekly', from), DateTime(2025, 3, 17));
    });

    test('monthly advances to same day next month', () {
      final DateTime from = DateTime(2025, 3, 15);
      expect(nextDueAfter('monthly', from), DateTime(2025, 4, 15));
    });

    test('monthly wraps December to January next year', () {
      final DateTime from = DateTime(2025, 12);
      expect(nextDueAfter('monthly', from), DateTime(2026));
    });

    test('unknown frequency falls back to 30 days', () {
      final DateTime from = DateTime(2025, 3);
      expect(nextDueAfter('unknown', from), DateTime(2025, 3, 31));
    });
  });

  // -------------------------------------------------------------------------
  // RecurringCubit
  // -------------------------------------------------------------------------

  group('RecurringCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is RecurringState.initial()', () {
      final RecurringCubit cubit =
          RecurringCubit(firestore: fakeFirestore);
      expect(cubit.state, const RecurringState.initial());
      cubit.close();
    });

    // -----------------------------------------------------------------------
    // create
    // -----------------------------------------------------------------------

    blocTest<RecurringCubit, RecurringState>(
      'create emits [loading, success] and persists to Firestore',
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.create(_rule()),
      expect: () => <RecurringState>[
        const RecurringState.loading(),
        RecurringState.success(_rule()),
      ],
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('recurring')
            .where('uuid', isEqualTo: 'rule-1')
            .get();
        expect(snap.docs, hasLength(1));
      },
    );

    // -----------------------------------------------------------------------
    // loadRecurring
    // -----------------------------------------------------------------------

    blocTest<RecurringCubit, RecurringState>(
      'loadRecurring emits [loading, listed([])] when no rules exist',
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.loadRecurring('user-1'),
      expect: () => <RecurringState>[
        const RecurringState.loading(),
        const RecurringState.listed(<RecurringEntity>[]),
      ],
    );

    blocTest<RecurringCubit, RecurringState>(
      'loadRecurring emits listed with seeded rules',
      setUp: () async {
        await fakeFirestore.collection('recurring').add(_rule().toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.loadRecurring('user-1'),
      verify: (RecurringCubit cubit) {
        cubit.state.whenOrNull(
          listed: (List<RecurringEntity> rules) {
            expect(rules, hasLength(1));
            expect(rules.first.uuid, 'rule-1');
          },
        );
      },
    );

    // -----------------------------------------------------------------------
    // pause / resume
    // -----------------------------------------------------------------------

    blocTest<RecurringCubit, RecurringState>(
      'pause sets active=false in Firestore',
      setUp: () async {
        await fakeFirestore.collection('recurring').add(_rule().toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.pause('rule-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('recurring')
            .where('uuid', isEqualTo: 'rule-1')
            .get();
        expect(snap.docs.first.data()['active'], isFalse);
      },
    );

    blocTest<RecurringCubit, RecurringState>(
      'resume sets active=true in Firestore',
      setUp: () async {
        await fakeFirestore
            .collection('recurring')
            .add(_rule(active: false).toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.resume('rule-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('recurring')
            .where('uuid', isEqualTo: 'rule-1')
            .get();
        expect(snap.docs.first.data()['active'], isTrue);
      },
    );

    // -----------------------------------------------------------------------
    // delete
    // -----------------------------------------------------------------------

    blocTest<RecurringCubit, RecurringState>(
      'delete removes rule from Firestore',
      setUp: () async {
        await fakeFirestore.collection('recurring').add(_rule().toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) => cubit.delete('rule-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('recurring')
            .where('uuid', isEqualTo: 'rule-1')
            .get();
        expect(snap.docs, isEmpty);
      },
    );

    // -----------------------------------------------------------------------
    // checkAndMaterialise
    // -----------------------------------------------------------------------

    blocTest<RecurringCubit, RecurringState>(
      'checkAndMaterialise creates transaction and advances nextDue '
      'when rule is overdue by one period',
      setUp: () async {
        // nextDue is in the past (one month ago)
        final DateTime pastDue = DateTime.now().subtract(const Duration(days: 35));
        await fakeFirestore
            .collection('recurring')
            .add(_rule(nextDue: pastDue).toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) =>
          cubit.checkAndMaterialise('user-1'),
      verify: (_) async {
        // A transaction should have been created
        final QuerySnapshot<Map<String, dynamic>> txSnap = await fakeFirestore
            .collection('transaction')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(txSnap.docs, isNotEmpty);

        // nextDue should have advanced to a future date
        final QuerySnapshot<Map<String, dynamic>> ruleSnap = await fakeFirestore
            .collection('recurring')
            .where('uuid', isEqualTo: 'rule-1')
            .get();
        final String rawNextDue =
            ruleSnap.docs.first.data()['nextDue'] as String;
        final DateTime newNextDue = DateTime.parse(rawNextDue);
        expect(newNextDue.isAfter(DateTime.now()), isTrue);
      },
    );

    blocTest<RecurringCubit, RecurringState>(
      'checkAndMaterialise skips inactive rules',
      setUp: () async {
        final DateTime pastDue =
            DateTime.now().subtract(const Duration(days: 35));
        await fakeFirestore
            .collection('recurring')
            .add(_rule(nextDue: pastDue, active: false).toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) =>
          cubit.checkAndMaterialise('user-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> txSnap = await fakeFirestore
            .collection('transaction')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(txSnap.docs, isEmpty);
      },
    );

    blocTest<RecurringCubit, RecurringState>(
      'checkAndMaterialise does nothing when nextDue is in the future',
      setUp: () async {
        final DateTime futureDue =
            DateTime.now().add(const Duration(days: 10));
        await fakeFirestore
            .collection('recurring')
            .add(_rule(nextDue: futureDue).toJson());
      },
      build: () => RecurringCubit(firestore: fakeFirestore),
      act: (RecurringCubit cubit) =>
          cubit.checkAndMaterialise('user-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> txSnap = await fakeFirestore
            .collection('transaction')
            .where('userId', isEqualTo: 'user-1')
            .get();
        expect(txSnap.docs, isEmpty);
      },
    );
  });
}
