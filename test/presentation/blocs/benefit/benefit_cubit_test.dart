import 'package:afc/domain/entity/benefit_entity.dart';
import 'package:afc/presentation/blocs/benefit/benefit_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BenefitCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    final BenefitEntity tBenefit = BenefitEntity(
      uuid: 'benefit-1',
      userId: 'user-1',
      name: 'VA Sodexo',
      type: BenefitType.va,
      monthlyCredit: 500.0,
      balance: 500.0,
      color: 0xFF4CAF50,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is BenefitState.initial', () {
      final BenefitCubit cubit = BenefitCubit(firestore: fakeFirestore);
      expect(cubit.state, const BenefitState.initial());
      cubit.close();
    });

    group('loadBenefits', () {
      blocTest<BenefitCubit, BenefitState>(
        'emits [loading, listed([])] when no benefits exist',
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.loadBenefits('user-1'),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          const BenefitState.listed(<BenefitEntity>[]),
        ],
      );

      blocTest<BenefitCubit, BenefitState>(
        'emits listed with seeded benefits',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(tBenefit.toJson());
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.loadBenefits('user-1'),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.listed(<BenefitEntity>[tBenefit]),
        ],
      );

      blocTest<BenefitCubit, BenefitState>(
        'does not include benefits for other users',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(
            tBenefit.copyWith(userId: 'other-user').toJson(),
          );
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.loadBenefits('user-1'),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          const BenefitState.listed(<BenefitEntity>[]),
        ],
      );
    });

    group('create', () {
      blocTest<BenefitCubit, BenefitState>(
        'emits [loading, success] when benefit is created',
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.create(tBenefit),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.success(tBenefit),
        ],
      );

      test('persists benefit to Firestore collection', () async {
        final BenefitCubit cubit = BenefitCubit(firestore: fakeFirestore);

        await cubit.create(tBenefit);

        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('benefit').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'VA Sodexo');
        expect(snapshot.docs.first.data()['monthlyCredit'], 500.0);
        await cubit.close();
      });
    });

    group('update', () {
      blocTest<BenefitCubit, BenefitState>(
        'emits [loading, success] after updating benefit',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(tBenefit.toJson());
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async =>
            cubit.update(tBenefit.copyWith(name: 'VR Alelo')),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.success(tBenefit.copyWith(name: 'VR Alelo')),
        ],
      );
    });

    group('delete', () {
      blocTest<BenefitCubit, BenefitState>(
        'delete removes benefit from Firestore',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(tBenefit.toJson());
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async {
          await cubit.loadBenefits('user-1');
          await cubit.delete('benefit-1', 'user-1');
          await cubit.loadBenefits('user-1');
        },
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.listed(<BenefitEntity>[tBenefit]),
          const BenefitState.loading(),
          const BenefitState.listed(<BenefitEntity>[]),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('benefit').get();
          expect(snap.docs.isEmpty, isTrue);
        },
      );
    });

    group('deduct', () {
      blocTest<BenefitCubit, BenefitState>(
        'deduct reduces balance by amount',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(tBenefit.toJson());
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.deduct(tBenefit, 100.0),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.success(tBenefit.copyWith(balance: 400.0)),
        ],
      );

      blocTest<BenefitCubit, BenefitState>(
        'deduct clamps balance to 0.0 when amount exceeds balance',
        setUp: () async {
          await fakeFirestore.collection('benefit').add(tBenefit.toJson());
        },
        build: () => BenefitCubit(firestore: fakeFirestore),
        act: (BenefitCubit cubit) async => cubit.deduct(tBenefit, 9999.0),
        expect: () => <BenefitState>[
          const BenefitState.loading(),
          BenefitState.success(tBenefit.copyWith(balance: 0.0)),
        ],
      );
    });

    group('resetMonthIfNeeded', () {
      test('resets balance to monthlyCredit when month differs', () async {
        final BenefitEntity staleMonthBenefit = tBenefit.copyWith(
          balance: 120.0,
          resetMonth: '2024-01',
        );
        await fakeFirestore
            .collection('benefit')
            .add(staleMonthBenefit.toJson());

        final BenefitCubit cubit = BenefitCubit(firestore: fakeFirestore);
        await cubit.resetMonthIfNeeded(staleMonthBenefit);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('benefit').get();
        expect(snap.docs.first.data()['balance'], 500.0);
        await cubit.close();
      });

      test('skips reset when resetMonth matches current month', () async {
        final String currentMonth =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
        final BenefitEntity currentMonthBenefit = tBenefit.copyWith(
          balance: 200.0,
          resetMonth: currentMonth,
        );
        await fakeFirestore
            .collection('benefit')
            .add(currentMonthBenefit.toJson());

        final BenefitCubit cubit = BenefitCubit(firestore: fakeFirestore);
        await cubit.resetMonthIfNeeded(currentMonthBenefit);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('benefit').get();
        // balance unchanged since no reset needed
        expect(snap.docs.first.data()['balance'], 200.0);
        await cubit.close();
      });
    });
  });
}
