import 'package:afc/presentation/blocs/report/report_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Helpers to seed Firestore with test data
Future<void> _seedTransaction(
  FakeFirebaseFirestore fs, {
  required String userId,
  required double amount,
  required String typeUuid,
  required DateTime date,
  required String categoryUuid,
}) async {
  await fs.collection('transaction').add(<String, dynamic>{
    'uuid': 'tx-${date.millisecondsSinceEpoch}',
    'userId': userId,
    'amount': amount,
    'typeUuid': typeUuid,
    'categoryUUid': categoryUuid,
    'data': date.toIso8601String(),
    'title': 'Test',
  });
}

Future<void> _seedCategory(
  FakeFirebaseFirestore fs, {
  required String uuid,
  required String name,
}) async {
  await fs.collection('category').add(<String, dynamic>{
    'uuid': uuid,
    'name': name,
    'iconType': 0,
  });
}

void main() {
  group('ReportCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is ReportState.initial()', () {
      final ReportCubit cubit = ReportCubit(firestore: fakeFirestore);
      expect(cubit.state, const ReportState.initial());
      cubit.close();
    });

    blocTest<ReportCubit, ReportState>(
      'loadReport emits [loading, success] with correct income and expense totals',
      setUp: () async {
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 500,
          typeUuid: 'income',
          date: DateTime(2025, 3, 10),
          categoryUuid: 'cat-1',
        );
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 200,
          typeUuid: 'expense',
          date: DateTime(2025, 3, 15),
          categoryUuid: 'cat-1',
        );
        await _seedCategory(fakeFirestore, uuid: 'cat-1', name: 'Alimentação');
      },
      build: () => ReportCubit(firestore: fakeFirestore),
      act: (ReportCubit cubit) => cubit.loadReport('user-1', 2025, 3),
      expect: () => <dynamic>[
        const ReportState.loading(),
        isA<ReportState>().having(
          (ReportState s) => s.whenOrNull(success: (ReportData d) => d.totalIncome),
          'totalIncome',
          500.0,
        ),
      ],
      verify: (ReportCubit cubit) {
        final ReportData? data =
            cubit.state.whenOrNull(success: (ReportData d) => d);
        expect(data, isNotNull);
        expect(data!.totalIncome, 500.0);
        expect(data.totalExpenses, 200.0);
        expect(data.savingsRate, closeTo(60.0, 0.001));
      },
    );

    blocTest<ReportCubit, ReportState>(
      'loadReport groups expenses by category',
      setUp: () async {
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 100,
          typeUuid: 'expense',
          date: DateTime(2025, 3, 5),
          categoryUuid: 'cat-1',
        );
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 50,
          typeUuid: 'expense',
          date: DateTime(2025, 3, 10),
          categoryUuid: 'cat-2',
        );
        await _seedCategory(fakeFirestore, uuid: 'cat-1', name: 'Alimentação');
        await _seedCategory(fakeFirestore, uuid: 'cat-2', name: 'Transporte');
      },
      build: () => ReportCubit(firestore: fakeFirestore),
      act: (ReportCubit cubit) => cubit.loadReport('user-1', 2025, 3),
      verify: (ReportCubit cubit) {
        final ReportData? data =
            cubit.state.whenOrNull(success: (ReportData d) => d);
        expect(data, isNotNull);
        expect(data!.expensesByCategory['cat-1'], 100.0);
        expect(data.expensesByCategory['cat-2'], 50.0);
        expect(data.categoryNames['cat-1'], 'Alimentação');
      },
    );

    blocTest<ReportCubit, ReportState>(
      'loadReport computes previous month totals',
      setUp: () async {
        // Current month: March 2025
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 300,
          typeUuid: 'expense',
          date: DateTime(2025, 3),
          categoryUuid: 'cat-1',
        );
        // Previous month: February 2025
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 150,
          typeUuid: 'expense',
          date: DateTime(2025, 2, 28),
          categoryUuid: 'cat-1',
        );
        await _seedCategory(fakeFirestore, uuid: 'cat-1', name: 'Alimentação');
      },
      build: () => ReportCubit(firestore: fakeFirestore),
      act: (ReportCubit cubit) => cubit.loadReport('user-1', 2025, 3),
      verify: (ReportCubit cubit) {
        final ReportData? data =
            cubit.state.whenOrNull(success: (ReportData d) => d);
        expect(data, isNotNull);
        expect(data!.totalExpenses, 300.0);
        expect(data.prevMonthExpenses, 150.0);
      },
    );

    blocTest<ReportCubit, ReportState>(
      'loadReport handles January correctly (prev month = December of prior year)',
      setUp: () async {
        await _seedTransaction(
          fakeFirestore,
          userId: 'user-1',
          amount: 100,
          typeUuid: 'expense',
          date: DateTime(2024, 12, 15),
          categoryUuid: 'cat-1',
        );
        await _seedCategory(fakeFirestore, uuid: 'cat-1', name: 'Alimentação');
      },
      build: () => ReportCubit(firestore: fakeFirestore),
      act: (ReportCubit cubit) => cubit.loadReport('user-1', 2025, 1),
      verify: (ReportCubit cubit) {
        final ReportData? data =
            cubit.state.whenOrNull(success: (ReportData d) => d);
        expect(data, isNotNull);
        expect(data!.prevMonthExpenses, 100.0);
      },
    );

    blocTest<ReportCubit, ReportState>(
      'loadReport emits [loading, success(empty)] when no transactions exist',
      build: () => ReportCubit(firestore: fakeFirestore),
      act: (ReportCubit cubit) => cubit.loadReport('user-1', 2025, 3),
      verify: (ReportCubit cubit) {
        final ReportData? data =
            cubit.state.whenOrNull(success: (ReportData d) => d);
        expect(data, isNotNull);
        expect(data!.totalIncome, 0.0);
        expect(data.totalExpenses, 0.0);
        expect(data.expensesByCategory, isEmpty);
      },
    );
  });
}
