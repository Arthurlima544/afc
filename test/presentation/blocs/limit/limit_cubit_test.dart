import 'package:afc/domain/entity/calendar_entity.dart';
import 'package:afc/domain/entity/category_entity.dart';
import 'package:afc/domain/entity/limit_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
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

  group('LimitCubit loadLimitsWithProgress', () {
    late FakeFirebaseFirestore fakeFirestore;

    final String currentMonth =
        CalendarEntity.values[DateTime.now().month - 1].name;

    const String userId = 'user-42';
    const String catId = 'cat-transport';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<LimitCubit, LimitState>(
      'emits loading then loaded([]) when no limits exist for user',
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[]),
      ],
    );

    blocTest<LimitCubit, LimitState>(
      'emits loading then loaded([]) when limits exist but not in current month',
      setUp: () async {
        // Use a month that is definitely not the current one
        final String safeMonth = currentMonth == 'january' ? 'february' : 'january';
        await fakeFirestore.collection('limit').add(<String, dynamic>{
          'uuid': 'limit-old',
          'categoryUUid': catId,
          'month': safeMonth,
          'limitAmount': 500.0,
          'userId': userId,
        });
      },
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[]),
      ],
    );

    blocTest<LimitCubit, LimitState>(
      'emits loaded with correct spent amount for current month expense transactions',
      setUp: () async {
        // Seed limit
        await fakeFirestore.collection('limit').add(<String, dynamic>{
          'uuid': 'limit-1',
          'categoryUUid': catId,
          'month': currentMonth,
          'limitAmount': 1000.0,
          'userId': userId,
        });
        // Seed category
        await fakeFirestore.collection('category').add(<String, dynamic>{
          'uuid': catId,
          'name': 'Transport',
          'iconType': 2,
        });
        // Seed expense transaction in current month/year
        final DateTime now = DateTime.now();
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'uuid': 'tx-1',
          'amount': 200.0,
          'categoryUUid': catId,
          'typeUuid': TypeEntity.expense.name,
          'data': DateTime(now.year, now.month, 5).toIso8601String(),
          'title': 'Bus',
          'userId': userId,
        });
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'uuid': 'tx-2',
          'amount': 150.0,
          'categoryUUid': catId,
          'typeUuid': TypeEntity.expense.name,
          'data': DateTime(now.year, now.month, 10).toIso8601String(),
          'title': 'Taxi',
          'userId': userId,
        });
      },
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[
          LimitProgressItem(
            categoryName: 'Transport',
            iconType: 2,
            spent: 350.0,
            limitAmount: 1000.0,
          ),
        ]),
      ],
    );

    blocTest<LimitCubit, LimitState>(
      'ignores income transactions when computing spent',
      setUp: () async {
        await fakeFirestore.collection('limit').add(<String, dynamic>{
          'uuid': 'limit-2',
          'categoryUUid': catId,
          'month': currentMonth,
          'limitAmount': 500.0,
          'userId': userId,
        });
        await fakeFirestore.collection('category').add(<String, dynamic>{
          'uuid': catId,
          'name': 'Transport',
          'iconType': 2,
        });
        final DateTime now = DateTime.now();
        // Income transaction — should be ignored
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'uuid': 'tx-income',
          'amount': 300.0,
          'categoryUUid': catId,
          'typeUuid': TypeEntity.income.name,
          'data': DateTime(now.year, now.month, 3).toIso8601String(),
          'title': 'Salary',
          'userId': userId,
        });
      },
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[
          LimitProgressItem(
            categoryName: 'Transport',
            iconType: 2,
            spent: 0.0,
            limitAmount: 500.0,
          ),
        ]),
      ],
    );

    blocTest<LimitCubit, LimitState>(
      'ignores transactions from other months',
      setUp: () async {
        await fakeFirestore.collection('limit').add(<String, dynamic>{
          'uuid': 'limit-3',
          'categoryUUid': catId,
          'month': currentMonth,
          'limitAmount': 600.0,
          'userId': userId,
        });
        await fakeFirestore.collection('category').add(<String, dynamic>{
          'uuid': catId,
          'name': 'Transport',
          'iconType': 2,
        });
        final DateTime now = DateTime.now();
        // Expense in a different month
        final DateTime otherMonth = DateTime(now.year, now.month == 1 ? 2 : now.month - 1, 5);
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'uuid': 'tx-old',
          'amount': 400.0,
          'categoryUUid': catId,
          'typeUuid': TypeEntity.expense.name,
          'data': otherMonth.toIso8601String(),
          'title': 'Old bus',
          'userId': userId,
        });
      },
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[
          LimitProgressItem(
            categoryName: 'Transport',
            iconType: 2,
            spent: 0.0,
            limitAmount: 600.0,
          ),
        ]),
      ],
    );

    blocTest<LimitCubit, LimitState>(
      'uses category name and iconType from category collection',
      setUp: () async {
        await fakeFirestore.collection('limit').add(<String, dynamic>{
          'uuid': 'limit-4',
          'categoryUUid': catId,
          'month': currentMonth,
          'limitAmount': 800.0,
          'userId': userId,
        });
        await fakeFirestore.collection('category').add(<String, dynamic>{
          'uuid': catId,
          'name': 'Alimentação',
          'iconType': 7,
        });
      },
      build: () => LimitCubit(firestore: fakeFirestore),
      act: (LimitCubit cubit) async =>
          cubit.loadLimitsWithProgress(userId),
      expect: () => <LimitState>[
        const LimitState.loading(),
        const LimitState.loaded(<LimitProgressItem>[
          LimitProgressItem(
            categoryName: 'Alimentação',
            iconType: 7,
            spent: 0.0,
            limitAmount: 800.0,
          ),
        ]),
      ],
    );
  });
}
