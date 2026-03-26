import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Pure filter helper — mirrors _ListaTransacoesState._applyFilters logic.
// Kept here so filter logic can be tested without a widget tree.
// ---------------------------------------------------------------------------

List<TransactionEntity> applyFilters(
  List<TransactionEntity> txs, {
  String? subAccountUuid,
  String searchQuery = '',
  DateTime? filterFrom,
  DateTime? filterTo,
  String? filterType,
}) =>
    txs.where((TransactionEntity tx) {
      if (subAccountUuid != null && tx.subAccountUuid != subAccountUuid) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !tx.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      if (filterFrom != null && tx.data.isBefore(filterFrom)) {
        return false;
      }
      if (filterTo != null &&
          tx.data.isAfter(filterTo.add(const Duration(days: 1)))) {
        return false;
      }
      if (filterType != null && tx.typeUuid != filterType) {
        return false;
      }
      return true;
    }).toList();

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

TransactionEntity _tx({
  required String uuid,
  required String title,
  required String type,
  required DateTime date,
  String? subAccountUuid,
}) =>
    TransactionEntity(
      uuid: uuid,
      amount: 100,
      categoryUUid: 'cat-1',
      typeUuid: type,
      data: date,
      title: title,
      userId: 'user-1',
      subAccountUuid: subAccountUuid,
    );

void main() {
  final TransactionEntity txIncome = _tx(
    uuid: 'tx-1',
    title: 'Salário',
    type: 'income',
    date: DateTime(2025, 3, 5),
    subAccountUuid: 'acc-1',
  );
  final TransactionEntity txExpense1 = _tx(
    uuid: 'tx-2',
    title: 'Supermercado',
    type: 'expense',
    date: DateTime(2025, 3, 10),
    subAccountUuid: 'acc-1',
  );
  final TransactionEntity txExpense2 = _tx(
    uuid: 'tx-3',
    title: 'Combustível',
    type: 'expense',
    date: DateTime(2025, 3, 20),
    subAccountUuid: 'acc-2',
  );
  final TransactionEntity txOldIncome = _tx(
    uuid: 'tx-4',
    title: 'Freelance',
    type: 'income',
    date: DateTime(2025, 2),
  );

  final List<TransactionEntity> all = <TransactionEntity>[
    txIncome,
    txExpense1,
    txExpense2,
    txOldIncome,
  ];

  group('applyFilters — no filter', () {
    test('returns all transactions when no filter is set', () {
      expect(applyFilters(all), all);
    });
  });

  group('applyFilters — search', () {
    test('filters by case-insensitive title substring', () {
      final List<TransactionEntity> result =
          applyFilters(all, searchQuery: 'super');
      expect(result, <TransactionEntity>[txExpense1]);
    });

    test('returns empty when no title matches', () {
      final List<TransactionEntity> result =
          applyFilters(all, searchQuery: 'nonexistent');
      expect(result, isEmpty);
    });

    test('is case-insensitive', () {
      final List<TransactionEntity> result =
          applyFilters(all, searchQuery: 'SALÁRIO');
      expect(result, <TransactionEntity>[txIncome]);
    });
  });

  group('applyFilters — type filter', () {
    test('filters income only', () {
      final List<TransactionEntity> result =
          applyFilters(all, filterType: 'income');
      expect(result, <TransactionEntity>[txIncome, txOldIncome]);
    });

    test('filters expense only', () {
      final List<TransactionEntity> result =
          applyFilters(all, filterType: 'expense');
      expect(result, <TransactionEntity>[txExpense1, txExpense2]);
    });
  });

  group('applyFilters — date range', () {
    test('filters from start date (inclusive)', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        filterFrom: DateTime(2025, 3),
      );
      expect(result, <TransactionEntity>[txIncome, txExpense1, txExpense2]);
    });

    test('filters to end date (inclusive)', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        filterTo: DateTime(2025, 3, 10),
      );
      expect(result, <TransactionEntity>[txIncome, txExpense1, txOldIncome]);
    });

    test('filters within a date range', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        filterFrom: DateTime(2025, 3, 6),
        filterTo: DateTime(2025, 3, 15),
      );
      expect(result, <TransactionEntity>[txExpense1]);
    });

    test('returns empty when range excludes all transactions', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        filterFrom: DateTime(2024),
        filterTo: DateTime(2024, 12, 31),
      );
      expect(result, isEmpty);
    });
  });

  group('applyFilters — sub-account filter', () {
    test('filters by sub-account uuid', () {
      final List<TransactionEntity> result =
          applyFilters(all, subAccountUuid: 'acc-2');
      expect(result, <TransactionEntity>[txExpense2]);
    });

    test('returns empty when no transaction belongs to sub-account', () {
      final List<TransactionEntity> result =
          applyFilters(all, subAccountUuid: 'acc-99');
      expect(result, isEmpty);
    });
  });

  group('applyFilters — combined filters', () {
    test('search + type filter compose correctly', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        searchQuery: 'a',
        filterType: 'income',
      );
      // 'Salário' and 'Freelance' match 'a' AND type income
      expect(result, <TransactionEntity>[txIncome, txOldIncome]);
    });

    test('date range + type filter compose correctly', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        filterFrom: DateTime(2025, 3),
        filterType: 'expense',
      );
      expect(result, <TransactionEntity>[txExpense1, txExpense2]);
    });

    test('all filters together narrow to single result', () {
      final List<TransactionEntity> result = applyFilters(
        all,
        searchQuery: 'Supermercado',
        filterType: 'expense',
        filterFrom: DateTime(2025, 3),
        filterTo: DateTime(2025, 3, 15),
        subAccountUuid: 'acc-1',
      );
      expect(result, <TransactionEntity>[txExpense1]);
    });

    test('clear all filters returns all transactions', () {
      final List<TransactionEntity> result = applyFilters(all);
      expect(result, all);
    });
  });
}
