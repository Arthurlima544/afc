import 'package:afc/domain/entity/passive_income_entity.dart';
import 'package:afc/presentation/blocs/passive_income/passive_income_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── monthlyEquivalent helper ───────────────────────────────────────────────

  group('monthlyEquivalent', () {
    test('returns amount unchanged for monthly frequency', () {
      expect(monthlyEquivalent(120.0, 'monthly'), 120.0);
    });

    test('returns amount / 3 for quarterly frequency', () {
      expect(monthlyEquivalent(300.0, 'quarterly'), 100.0);
    });

    test('returns amount / 12 for annual frequency', () {
      expect(monthlyEquivalent(1200.0, 'annual'), 100.0);
    });

    test('defaults to monthly for unknown frequency', () {
      expect(monthlyEquivalent(50.0, 'unknown'), 50.0);
    });
  });

  // ── PassiveIncomeCubit ─────────────────────────────────────────────────────

  group('PassiveIncomeCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const PassiveIncomeEntity tStream = PassiveIncomeEntity(
      uuid: 'pi-1',
      userId: 'user-1',
      name: 'Dividendos PETR4',
      source: 'dividend',
      amount: 500.0,
      frequency: 'monthly',
    );

    PassiveIncomeEntity entity({
      String uuid = 'pi-1',
      String userId = 'user-1',
      String name = 'Dividendos PETR4',
      String source = 'dividend',
      double amount = 500.0,
      String frequency = 'monthly',
      String? assetUuid,
    }) =>
        PassiveIncomeEntity(
          uuid: uuid,
          userId: userId,
          name: name,
          source: source,
          amount: amount,
          frequency: frequency,
          assetUuid: assetUuid,
        );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is PassiveIncomeState.initial', () {
      final PassiveIncomeCubit cubit =
          PassiveIncomeCubit(firestore: fakeFirestore);
      expect(cubit.state, const PassiveIncomeState.initial());
      cubit.close();
    });

    // ── loadStreams ────────────────────────────────────────────────────────

    group('loadStreams', () {
      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'emits [loading, listed([])] when no streams exist',
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) => cubit.loadStreams('user-1'),
        expect: () => <PassiveIncomeState>[
          const PassiveIncomeState.loading(),
          const PassiveIncomeState.listed(<PassiveIncomeEntity>[]),
        ],
      );

      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'emits listed with seeded streams',
        setUp: () async {
          await fakeFirestore
              .collection('passive_income')
              .add(tStream.toJson());
        },
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) => cubit.loadStreams('user-1'),
        expect: () => <PassiveIncomeState>[
          const PassiveIncomeState.loading(),
          const PassiveIncomeState.listed(<PassiveIncomeEntity>[tStream]),
        ],
      );

      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'does not include streams for other users',
        setUp: () async {
          await fakeFirestore.collection('passive_income').add(
            entity(userId: 'other-user').toJson(),
          );
        },
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) => cubit.loadStreams('user-1'),
        expect: () => <PassiveIncomeState>[
          const PassiveIncomeState.loading(),
          const PassiveIncomeState.listed(<PassiveIncomeEntity>[]),
        ],
      );

      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'sorts streams by amount descending',
        setUp: () async {
          await fakeFirestore.collection('passive_income').add(
            entity(uuid: 'pi-low', name: 'Low', amount: 100.0).toJson(),
          );
          await fakeFirestore.collection('passive_income').add(
            entity(uuid: 'pi-high', name: 'High', amount: 900.0).toJson(),
          );
        },
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) => cubit.loadStreams('user-1'),
        verify: (PassiveIncomeCubit cubit) {
          final PassiveIncomeState state = cubit.state;
          final List<PassiveIncomeEntity> streams = state.whenOrNull(
                listed: (List<PassiveIncomeEntity> s) => s,
              ) ??
              <PassiveIncomeEntity>[];
          expect(streams.first.uuid, 'pi-high');
          expect(streams.last.uuid, 'pi-low');
        },
      );
    });

    // ── add ───────────────────────────────────────────────────────────────

    group('add', () {
      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'persists stream and reloads list',
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) async {
          await cubit.loadStreams('user-1');
          await cubit.add(
            name: 'Aluguel Sala',
            source: 'rent',
            amount: 1500.0,
            frequency: 'monthly',
          );
        },
        verify: (PassiveIncomeCubit cubit) {
          final PassiveIncomeState state = cubit.state;
          final List<PassiveIncomeEntity> streams = state.whenOrNull(
                listed: (List<PassiveIncomeEntity> s) => s,
              ) ??
              <PassiveIncomeEntity>[];
          expect(streams.length, 1);
          expect(streams.first.name, 'Aluguel Sala');
          expect(streams.first.source, 'rent');
          expect(streams.first.amount, 1500.0);
        },
      );

      test('persists stream to Firestore collection', () async {
        final PassiveIncomeCubit cubit =
            PassiveIncomeCubit(firestore: fakeFirestore);
        await cubit.loadStreams('user-1');
        await cubit.add(
          name: 'Juros CDB',
          source: 'interest',
          amount: 200.0,
          frequency: 'monthly',
        );

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('passive_income').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['name'], 'Juros CDB');
        expect(snap.docs.first.data()['source'], 'interest');
        await cubit.close();
      });
    });

    // ── delete ────────────────────────────────────────────────────────────

    group('delete', () {
      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'removes stream and reloads empty list',
        setUp: () async {
          await fakeFirestore
              .collection('passive_income')
              .add(tStream.toJson());
        },
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) async {
          await cubit.loadStreams('user-1');
          await cubit.delete('pi-1');
        },
        verify: (PassiveIncomeCubit cubit) {
          final PassiveIncomeState state = cubit.state;
          final List<PassiveIncomeEntity> streams = state.whenOrNull(
                listed: (List<PassiveIncomeEntity> s) => s,
              ) ??
              <PassiveIncomeEntity>[tStream];
          expect(streams, isEmpty);
        },
      );
    });

    // ── update ────────────────────────────────────────────────────────────

    group('update', () {
      blocTest<PassiveIncomeCubit, PassiveIncomeState>(
        'updates stream amount and reloads list',
        setUp: () async {
          await fakeFirestore
              .collection('passive_income')
              .add(tStream.toJson());
        },
        build: () => PassiveIncomeCubit(firestore: fakeFirestore),
        act: (PassiveIncomeCubit cubit) async {
          await cubit.loadStreams('user-1');
          await cubit.update(tStream.copyWith(amount: 750.0));
        },
        verify: (PassiveIncomeCubit cubit) {
          final PassiveIncomeState state = cubit.state;
          final List<PassiveIncomeEntity> streams = state.whenOrNull(
                listed: (List<PassiveIncomeEntity> s) => s,
              ) ??
              <PassiveIncomeEntity>[];
          expect(streams.first.amount, 750.0);
        },
      );
    });
  });
}
