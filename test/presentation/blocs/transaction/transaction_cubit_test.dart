import 'package:afc/domain/entity/category_entity.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/presentation/blocs/transaction/transaction_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    final TransactionEntity tTransaction = TransactionEntity(
      uuid: 'tx-1',
      amount: 99.90,
      categoryUUid: 'cat-1',
      typeUuid: 'expense',
      data: DateTime(2024, 3, 10),
      title: 'Groceries',
      userId: 'user-1',
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
  });
}
