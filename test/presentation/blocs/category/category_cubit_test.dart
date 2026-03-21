import 'package:afc/domain/entity/category_entity.dart';
import 'package:afc/presentation/blocs/category/category_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const CategoryEntity tCategory = CategoryEntity(
      uuid: 'user-1',
      name: 'Food',
      iconType: 1,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is CategoryState.initial(-1)', () {
      // Arrange & Act
      final CategoryCubit cubit = CategoryCubit(firestore: fakeFirestore);

      // Assert
      expect(cubit.state, const CategoryState.initial(-1));
      cubit.close();
    });

    group('changeSelectedCategory', () {
      blocTest<CategoryCubit, CategoryState>(
        'emits initial(index) when a new index is selected',
        build: () => CategoryCubit(firestore: fakeFirestore),
        act: (CategoryCubit cubit) => cubit.changeSelectedCategory(2),
        expect: () => <CategoryState>[const CategoryState.initial(2)],
      );

      blocTest<CategoryCubit, CategoryState>(
        'emits initial(-1) when same index is selected again (deselect)',
        build: () => CategoryCubit(firestore: fakeFirestore),
        seed: () => const CategoryState.initial(2),
        act: (CategoryCubit cubit) => cubit.changeSelectedCategory(2),
        expect: () => <CategoryState>[const CategoryState.initial(-1)],
      );

      blocTest<CategoryCubit, CategoryState>(
        'replaces selection when a different index is chosen',
        build: () => CategoryCubit(firestore: fakeFirestore),
        seed: () => const CategoryState.initial(1),
        act: (CategoryCubit cubit) => cubit.changeSelectedCategory(3),
        expect: () => <CategoryState>[const CategoryState.initial(3)],
      );
    });

    group('saveCategory', () {
      blocTest<CategoryCubit, CategoryState>(
        'emits [loading, success] when category is saved successfully',
        build: () => CategoryCubit(firestore: fakeFirestore),
        act: (CategoryCubit cubit) => cubit.saveCategory(tCategory),
        expect: () => <CategoryState>[
          const CategoryState.loading(),
          const CategoryState.success(tCategory),
        ],
      );

      test('persists category to Firestore collection', () async {
        // Arrange
        final CategoryCubit cubit = CategoryCubit(firestore: fakeFirestore);

        // Act
        await cubit.saveCategory(tCategory);

        // Assert
        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('category').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Food');
        await cubit.close();
      });
    });
  });
}
