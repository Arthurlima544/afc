import 'package:afc/domain/entity/category_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
import 'package:afc/presentation/blocs/transaction/transaction_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const String userId = 'user-1';

    final TransactionEntity tTransaction = TransactionEntity(
      uuid: 'tx-1',
      amount: 99.90,
      categoryUUid: 'cat-1',
      typeUuid: TypeEntity.expense.name,
      data: DateTime(2024, 3, 10),
      title: 'Groceries',
      userId: userId,
    );

    const CategoryEntity tCategory = CategoryEntity(
      uuid: 'user-1',
      name: 'Food',
      iconType: 1,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is TransactionState.initial with empty list', () async {
      // Arrange & Act
      final TransactionCubit cubit =
          TransactionCubit(firestore: fakeFirestore);

      // Assert
      expect(
        cubit.state,
        const TransactionState.initial(<CategoryEntity>[]),
      );
      await cubit.close();
    });

    group('getCategories', () {
      blocTest<TransactionCubit, TransactionState>(
        'emits initial([]) when Firestore has no categories',
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async => cubit.getCategories(),
        expect: () => <TransactionState>[
          const TransactionState.initial(<CategoryEntity>[]),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'emits initial with loaded categories when Firestore has data',
        setUp: () async {
          await fakeFirestore
              .collection('category')
              .add(tCategory.toJson());
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async => cubit.getCategories(),
        expect: () => <TransactionState>[
          const TransactionState.initial(<CategoryEntity>[tCategory]),
        ],
      );
    });

    group('saveTransaction', () {
      blocTest<TransactionCubit, TransactionState>(
        'emits [loading, success] when transaction is saved successfully',
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.saveTransaction(tTransaction),
        expect: () => <TransactionState>[
          const TransactionState.loading(),
          TransactionState.success(tTransaction),
        ],
      );

      test('persists transaction to Firestore collection', () async {
        // Arrange
        final TransactionCubit cubit =
            TransactionCubit(firestore: fakeFirestore);

        // Act
        await cubit.saveTransaction(tTransaction);

        // Assert
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('transaction').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['title'], 'Groceries');
        expect(snapshot.docs.first.data()['amount'], 99.90);
        await cubit.close();
      });

      blocTest<TransactionCubit, TransactionState>(
        'retains categories in state before and after save',
        setUp: () async {
          await fakeFirestore
              .collection('category')
              .add(tCategory.toJson());
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async {
          await cubit.getCategories();
          await cubit.saveTransaction(tTransaction);
        },
        expect: () => <TransactionState>[
          const TransactionState.initial(<CategoryEntity>[tCategory]),
          const TransactionState.loading(),
          TransactionState.success(tTransaction),
        ],
      );
    });

    group('loadTransactions', () {
      blocTest<TransactionCubit, TransactionState>(
        'emits [loading, listed([])] when no transactions exist for user',
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.loadTransactions(userId),
        expect: () => <TransactionState>[
          const TransactionState.loading(),
          const TransactionState.listed(<TransactionEntity>[]),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'emits listed with transactions belonging to userId',
        setUp: () async {
          await fakeFirestore.collection('transaction').add(<String, dynamic>{
            'uuid': 'tx-1',
            'amount': 99.90,
            'categoryUUid': 'cat-1',
            'typeUuid': TypeEntity.expense.name,
            'data': DateTime(2024, 3, 10).toIso8601String(),
            'title': 'Groceries',
            'userId': userId,
          });
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.loadTransactions(userId),
        expect: () => <TransactionState>[
          const TransactionState.loading(),
          TransactionState.listed(<TransactionEntity>[tTransaction]),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'does not include transactions for other users',
        setUp: () async {
          await fakeFirestore.collection('transaction').add(<String, dynamic>{
            'uuid': 'tx-other',
            'amount': 500.0,
            'categoryUUid': 'cat-1',
            'typeUuid': TypeEntity.income.name,
            'data': DateTime(2024, 3, 5).toIso8601String(),
            'title': 'Salário',
            'userId': 'other-user',
          });
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.loadTransactions(userId),
        expect: () => <TransactionState>[
          const TransactionState.loading(),
          const TransactionState.listed(<TransactionEntity>[]),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'returns transactions sorted newest-first',
        setUp: () async {
          await fakeFirestore.collection('transaction').add(<String, dynamic>{
            'uuid': 'tx-old',
            'amount': 100.0,
            'categoryUUid': 'cat-1',
            'typeUuid': TypeEntity.expense.name,
            'data': DateTime(2024, 1, 5).toIso8601String(),
            'title': 'Antigo',
            'userId': userId,
          });
          await fakeFirestore.collection('transaction').add(<String, dynamic>{
            'uuid': 'tx-new',
            'amount': 200.0,
            'categoryUUid': 'cat-1',
            'typeUuid': TypeEntity.income.name,
            'data': DateTime(2024, 3, 10).toIso8601String(),
            'title': 'Recente',
            'userId': userId,
          });
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.loadTransactions(userId),
        verify: (TransactionCubit cubit) {
          cubit.state.whenOrNull(
            listed: (List<TransactionEntity> txs) {
              expect(txs.first.title, 'Recente');
              expect(txs.last.title, 'Antigo');
            },
          );
        },
      );
    });

    group('deleteTransaction', () {
      blocTest<TransactionCubit, TransactionState>(
        'removes transaction and reloads listed state',
        setUp: () async {
          await fakeFirestore
              .collection('transaction')
              .add(tTransaction.toJson());
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async {
          await cubit.loadTransactions(userId);
          await cubit.deleteTransaction('tx-1');
        },
        verify: (TransactionCubit cubit) {
          cubit.state.whenOrNull(
            listed: (List<TransactionEntity> txs) {
              expect(txs.isEmpty, isTrue);
            },
          );
        },
      );
    });

    group('updateTransaction', () {
      blocTest<TransactionCubit, TransactionState>(
        'emits [loading, success] after update',
        setUp: () async {
          await fakeFirestore
              .collection('transaction')
              .add(tTransaction.toJson());
        },
        build: () => TransactionCubit(firestore: fakeFirestore),
        act: (TransactionCubit cubit) async =>
            cubit.updateTransaction(tTransaction.copyWith(title: 'Updated')),
        expect: () => <TransactionState>[
          const TransactionState.loading(),
          TransactionState.success(tTransaction.copyWith(title: 'Updated')),
        ],
      );

      test('persists updated title to Firestore', () async {
        await fakeFirestore
            .collection('transaction')
            .add(tTransaction.toJson());

        final TransactionCubit cubit =
            TransactionCubit(firestore: fakeFirestore);
        await cubit.updateTransaction(
          tTransaction.copyWith(title: 'Updated'),
        );

        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('transaction')
            .where('uuid', isEqualTo: 'tx-1')
            .get();
        expect(snap.docs.first.data()['title'], 'Updated');
        await cubit.close();
      });
    });
  });
}
