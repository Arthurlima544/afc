import 'package:afc/domain/entity/sub_account_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/presentation/blocs/sub_account/sub_account_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubAccountCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const SubAccountEntity tPersonal = SubAccountEntity(
      uuid: 'acc-1',
      userId: 'user-1',
      name: 'Pessoal',
      type: SubAccountType.personal,
    );

    const SubAccountEntity tCompany = SubAccountEntity(
      uuid: 'acc-2',
      userId: 'user-1',
      name: 'Empresa',
      type: SubAccountType.company,
      color: 0xFF4CAF50,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is SubAccountState.initial', () {
      final SubAccountCubit cubit = SubAccountCubit(firestore: fakeFirestore);
      expect(cubit.state, const SubAccountState.initial());
      cubit.close();
    });

    group('loadAccounts', () {
      blocTest<SubAccountCubit, SubAccountState>(
        'emits [loading, listed([], {})] when no accounts exist',
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async => cubit.loadAccounts('user-1'),
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.listed(
            <SubAccountEntity>[],
            <String, SubAccountTotals>{},
          ),
        ],
      );

      blocTest<SubAccountCubit, SubAccountState>(
        'emits listed with seeded accounts',
        setUp: () async {
          await fakeFirestore.collection('sub_account').add(tPersonal.toJson());
        },
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async => cubit.loadAccounts('user-1'),
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.listed(<SubAccountEntity>[
            tPersonal,
          ], <String, SubAccountTotals>{}),
        ],
      );

      blocTest<SubAccountCubit, SubAccountState>(
        'does not include accounts for other users',
        setUp: () async {
          await fakeFirestore
              .collection('sub_account')
              .add(tPersonal.copyWith(userId: 'other-user').toJson());
        },
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async => cubit.loadAccounts('user-1'),
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.listed(
            <SubAccountEntity>[],
            <String, SubAccountTotals>{},
          ),
        ],
      );
    });

    group('create', () {
      blocTest<SubAccountCubit, SubAccountState>(
        'emits [loading, success] when account is created',
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async => cubit.create(tPersonal),
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.success(tPersonal),
        ],
      );

      test('persists account to Firestore', () async {
        final SubAccountCubit cubit = SubAccountCubit(firestore: fakeFirestore);
        await cubit.create(tPersonal);

        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('sub_account')
            .get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['name'], 'Pessoal');
        await cubit.close();
      });
    });

    group('update', () {
      blocTest<SubAccountCubit, SubAccountState>(
        'emits [loading, success] after updating account',
        setUp: () async {
          await fakeFirestore.collection('sub_account').add(tPersonal.toJson());
        },
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async =>
            cubit.update(tPersonal.copyWith(name: 'Pessoal 2')),
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.success(
            SubAccountEntity(
              uuid: 'acc-1',
              userId: 'user-1',
              name: 'Pessoal 2',
              type: SubAccountType.personal,
            ),
          ),
        ],
      );
    });

    group('delete', () {
      blocTest<SubAccountCubit, SubAccountState>(
        'delete removes account from Firestore',
        setUp: () async {
          await fakeFirestore.collection('sub_account').add(tPersonal.toJson());
        },
        build: () => SubAccountCubit(firestore: fakeFirestore),
        act: (SubAccountCubit cubit) async {
          await cubit.loadAccounts('user-1');
          await cubit.delete('acc-1', 'user-1');
          await cubit.loadAccounts('user-1');
        },
        expect: () => <SubAccountState>[
          const SubAccountState.loading(),
          const SubAccountState.listed(<SubAccountEntity>[
            tPersonal,
          ], <String, SubAccountTotals>{}),
          const SubAccountState.loading(),
          const SubAccountState.listed(
            <SubAccountEntity>[],
            <String, SubAccountTotals>{},
          ),
        ],
      );
    });

    group('loadWithTotals — per-account aggregation', () {
      test(
        'income and expenses aggregated correctly per sub-account',
        () async {
          await fakeFirestore.collection('sub_account').add(tPersonal.toJson());
          await fakeFirestore.collection('sub_account').add(tCompany.toJson());

          // Personal: 1000 income, 300 expense → balance 700
          await fakeFirestore
              .collection('transaction')
              .add(
                TransactionEntity(
                  uuid: 'tx-1',
                  amount: 1000.0,
                  categoryUUid: 'cat-1',
                  typeUuid: 'income',
                  data: DateTime(2026),
                  title: 'Salário',
                  userId: 'user-1',
                  subAccountUuid: 'acc-1',
                ).toJson(),
              );
          await fakeFirestore
              .collection('transaction')
              .add(
                TransactionEntity(
                  uuid: 'tx-2',
                  amount: 300.0,
                  categoryUUid: 'cat-2',
                  typeUuid: 'expense',
                  data: DateTime(2026, 1, 5),
                  title: 'Mercado',
                  userId: 'user-1',
                  subAccountUuid: 'acc-1',
                ).toJson(),
              );

          // Company: 2000 income → balance 2000
          await fakeFirestore
              .collection('transaction')
              .add(
                TransactionEntity(
                  uuid: 'tx-3',
                  amount: 2000.0,
                  categoryUUid: 'cat-3',
                  typeUuid: 'income',
                  data: DateTime(2026, 1, 10),
                  title: 'Contrato PJ',
                  userId: 'user-1',
                  subAccountUuid: 'acc-2',
                ).toJson(),
              );

          // Untagged transaction — should not affect any sub-account totals
          await fakeFirestore
              .collection('transaction')
              .add(
                TransactionEntity(
                  uuid: 'tx-4',
                  amount: 500.0,
                  categoryUUid: 'cat-1',
                  typeUuid: 'expense',
                  data: DateTime(2026, 1, 12),
                  title: 'Sem sub-conta',
                  userId: 'user-1',
                ).toJson(),
              );

          final SubAccountCubit cubit = SubAccountCubit(
            firestore: fakeFirestore,
          );
          await cubit.loadWithTotals('user-1');

          final SubAccountState state = cubit.state;
          final Map<String, SubAccountTotals> totals =
              state.whenOrNull(
                listed: (_, Map<String, SubAccountTotals> t) => t,
              ) ??
              <String, SubAccountTotals>{};

          expect(totals['acc-1']?.income, 1000.0);
          expect(totals['acc-1']?.expenses, 300.0);
          expect(totals['acc-1']?.balance, 700.0);

          expect(totals['acc-2']?.income, 2000.0);
          expect(totals['acc-2']?.expenses, 0.0);
          expect(totals['acc-2']?.balance, 2000.0);

          await cubit.close();
        },
      );

      test('transactions for other users are excluded', () async {
        await fakeFirestore.collection('sub_account').add(tPersonal.toJson());

        await fakeFirestore
            .collection('transaction')
            .add(
              TransactionEntity(
                uuid: 'tx-other',
                amount: 999.0,
                categoryUUid: 'cat-1',
                typeUuid: 'income',
                data: DateTime(2026),
                title: 'Other user income',
                userId: 'other-user',
                subAccountUuid: 'acc-1',
              ).toJson(),
            );

        final SubAccountCubit cubit = SubAccountCubit(firestore: fakeFirestore);
        await cubit.loadWithTotals('user-1');

        final SubAccountState state = cubit.state;
        final Map<String, SubAccountTotals> totals =
            state.whenOrNull(
              listed: (_, Map<String, SubAccountTotals> t) => t,
            ) ??
            <String, SubAccountTotals>{};

        // acc-1 belongs to user-1 but the income tx belongs to other-user
        // user-1 query returns no transactions → totals = 0
        expect(totals['acc-1']?.income, 0.0);
        expect(totals['acc-1']?.balance, 0.0);

        await cubit.close();
      });

      test('zero totals when sub-account has no linked transactions', () async {
        await fakeFirestore.collection('sub_account').add(tPersonal.toJson());

        final SubAccountCubit cubit = SubAccountCubit(firestore: fakeFirestore);
        await cubit.loadWithTotals('user-1');

        final SubAccountState state = cubit.state;
        final Map<String, SubAccountTotals> totals =
            state.whenOrNull(
              listed: (_, Map<String, SubAccountTotals> t) => t,
            ) ??
            <String, SubAccountTotals>{};

        expect(totals['acc-1']?.income, 0.0);
        expect(totals['acc-1']?.expenses, 0.0);
        expect(totals['acc-1']?.balance, 0.0);

        await cubit.close();
      });
    });
  });
}
