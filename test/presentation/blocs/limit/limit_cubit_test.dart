import 'package:afc/domain/entity/category_entity.dart';
import 'package:afc/domain/entity/limit_entity.dart';
import 'package:afc/presentation/blocs/limit/limit_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LimitCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const LimitEntity tLimit = LimitEntity(
      uuid: 'limit-1',
      categoryUUid: 'cat-1',
      month: 'march',
      limitAmount: 400.0,
      userId: 'user-1',
    );

    const CategoryEntity tCategory = CategoryEntity(
      uuid: 'user-1',
      name: 'Transport',
      iconType: 3,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is LimitState.initial with empty list', () {
      // Arrange & Act
      final LimitCubit cubit = LimitCubit(firestore: fakeFirestore);

      // Assert
      expect(cubit.state, const LimitState.initial(<CategoryEntity>[]));
      cubit.close();
    });

    group('getCategories', () {
      blocTest<LimitCubit, LimitState>(
        'emits initial([]) when Firestore has no categories',
        build: () => LimitCubit(firestore: fakeFirestore),
        act: (LimitCubit cubit) async => cubit.getCategories(),
        expect: () => <LimitState>[
          const LimitState.initial(<CategoryEntity>[]),
        ],
      );

      blocTest<LimitCubit, LimitState>(
        'emits initial with loaded categories when Firestore has data',
        setUp: () async {
          await fakeFirestore
              .collection('category')
              .add(tCategory.toJson());
        },
        build: () => LimitCubit(firestore: fakeFirestore),
        act: (LimitCubit cubit) async => cubit.getCategories(),
        expect: () => <LimitState>[
          const LimitState.initial(<CategoryEntity>[tCategory]),
        ],
      );
    });

    group('saveLimit', () {
      blocTest<LimitCubit, LimitState>(
        'emits [loading, success] when limit is saved successfully',
        build: () => LimitCubit(firestore: fakeFirestore),
        act: (LimitCubit cubit) async => cubit.saveLimit(tLimit),
        expect: () => <LimitState>[
          const LimitState.loading(),
          const LimitState.success(tLimit),
        ],
      );

      test('persists limit to Firestore collection', () async {
        // Arrange
        final LimitCubit cubit = LimitCubit(firestore: fakeFirestore);

        // Act
        await cubit.saveLimit(tLimit);

        // Assert
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('limit').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['month'], 'march');
        expect(snapshot.docs.first.data()['limitAmount'], 400.0);
        await cubit.close();
      });

      blocTest<LimitCubit, LimitState>(
        'retains categories in state before and after save',
        setUp: () async {
          await fakeFirestore
              .collection('category')
              .add(tCategory.toJson());
        },
        build: () => LimitCubit(firestore: fakeFirestore),
        act: (LimitCubit cubit) async {
          await cubit.getCategories();
          await cubit.saveLimit(tLimit);
        },
        expect: () => <LimitState>[
          const LimitState.initial(<CategoryEntity>[tCategory]),
          const LimitState.loading(),
          const LimitState.success(tLimit),
        ],
      );
    });
  });
}
