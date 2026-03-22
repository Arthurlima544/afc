import 'package:afc/domain/entity/bill_entity.dart';
import 'package:afc/presentation/blocs/bill/bill_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const BillEntity tBill = BillEntity(
      uuid: 'bill-1',
      userId: 'user-1',
      name: 'Aluguel',
      amount: 1500.0,
      dueDay: 10,
      categoryUuid: 'cat-1',
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is BillState.initial', () {
      final BillCubit cubit = BillCubit(firestore: fakeFirestore);
      expect(cubit.state, const BillState.initial());
      cubit.close();
    });

    group('loadBills', () {
      blocTest<BillCubit, BillState>(
        'emits [loading, listed([])] when no bills exist',
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async => cubit.loadBills('user-1'),
        expect: () => <BillState>[
          const BillState.loading(),
          const BillState.listed(<BillEntity>[]),
        ],
      );

      blocTest<BillCubit, BillState>(
        'emits listed with seeded bills',
        setUp: () async {
          await fakeFirestore.collection('bill').add(tBill.toJson());
        },
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async => cubit.loadBills('user-1'),
        expect: () => <BillState>[
          const BillState.loading(),
          const BillState.listed(<BillEntity>[tBill]),
        ],
      );

      blocTest<BillCubit, BillState>(
        'does not include bills for other users',
        setUp: () async {
          await fakeFirestore.collection('bill').add(
            tBill.copyWith(userId: 'other-user').toJson(),
          );
        },
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async => cubit.loadBills('user-1'),
        expect: () => <BillState>[
          const BillState.loading(),
          const BillState.listed(<BillEntity>[]),
        ],
      );
    });

    group('create', () {
      blocTest<BillCubit, BillState>(
        'emits [loading, success] when bill is created',
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async => cubit.create(tBill),
        expect: () => <BillState>[
          const BillState.loading(),
          const BillState.success(tBill),
        ],
      );

      test('persists bill to Firestore collection', () async {
        final BillCubit cubit = BillCubit(firestore: fakeFirestore);

        await cubit.create(tBill);

        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('bill').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Aluguel');
        expect(snapshot.docs.first.data()['amount'], 1500.0);
        await cubit.close();
      });
    });

    group('delete', () {
      blocTest<BillCubit, BillState>(
        'delete removes bill from Firestore and reloads',
        setUp: () async {
          await fakeFirestore.collection('bill').add(tBill.toJson());
        },
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async {
          await cubit.loadBills('user-1');
          await cubit.delete('bill-1', 'user-1');
        },
        expect: () => <BillState>[
          const BillState.loading(),
          const BillState.listed(<BillEntity>[tBill]),
          const BillState.loading(),
          const BillState.listed(<BillEntity>[]),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('bill').get();
          expect(snap.docs.isEmpty, isTrue);
        },
      );
    });

    group('update', () {
      blocTest<BillCubit, BillState>(
        'emits [loading, success] after updating bill',
        setUp: () async {
          await fakeFirestore.collection('bill').add(tBill.toJson());
        },
        build: () => BillCubit(firestore: fakeFirestore),
        act: (BillCubit cubit) async =>
            cubit.update(tBill.copyWith(name: 'Financiamento')),
        expect: () => <BillState>[
          const BillState.loading(),
          BillState.success(tBill.copyWith(name: 'Financiamento')),
        ],
      );

      test('changes bill name in Firestore', () async {
        await fakeFirestore.collection('bill').add(tBill.toJson());
        final BillCubit cubit = BillCubit(firestore: fakeFirestore);

        await cubit.update(tBill.copyWith(name: 'Financiamento'));

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('bill').get();
        expect(snap.docs.first.data()['name'], 'Financiamento');
        await cubit.close();
      });
    });

    group('upcoming bill logic', () {
      test('bill is upcoming when dueDay is within next 7 days', () {
        final DateTime now = DateTime.now();
        final int today = now.day;
        final BillEntity upcomingBill = tBill.copyWith(dueDay: today + 3);

        final bool isUpcoming =
            upcomingBill.dueDay >= today && upcomingBill.dueDay <= today + 7;
        expect(isUpcoming, isTrue);
      });

      test('bill is overdue when dueDay is before today', () {
        final DateTime now = DateTime.now();
        final int today = now.day;
        if (today <= 1) {
          // Skip test when we can't go before day 1
          return;
        }
        final BillEntity overdueBill = tBill.copyWith(dueDay: today - 1);

        final bool isOverdue = overdueBill.dueDay < today;
        expect(isOverdue, isTrue);
      });

      test('bill is not upcoming when dueDay is more than 7 days away', () {
        final DateTime now = DateTime.now();
        final int today = now.day;
        // Only run if dueDay + 10 <= 31
        if (today + 10 > 31) {
          return;
        }
        final BillEntity farBill = tBill.copyWith(dueDay: today + 10);

        final bool isUpcoming =
            farBill.dueDay >= today && farBill.dueDay <= today + 7;
        expect(isUpcoming, isFalse);
      });

      test('multiple bills can be filtered for upcoming', () {
        final DateTime now = DateTime.now();
        final int today = now.day;

        final List<BillEntity> bills = <BillEntity>[
          tBill.copyWith(uuid: 'b1', dueDay: today + 2),
          tBill.copyWith(uuid: 'b2', dueDay: today + 10),
          tBill.copyWith(uuid: 'b3', dueDay: today + 5),
        ];

        final List<BillEntity> upcoming = bills
            .where(
              (BillEntity b) =>
                  b.dueDay >= today && b.dueDay <= today + 7,
            )
            .toList();

        expect(upcoming.length, 2);
        expect(
          upcoming.map((BillEntity b) => b.uuid).toList(),
          containsAll(<String>['b1', 'b3']),
        );
      });
    });
  });
}
