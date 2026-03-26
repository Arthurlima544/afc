import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/usecase/csv_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionEntity _tx({
  required String uuid,
  required String title,
  required String type,
  required DateTime date,
  required double amount,
  String categoryUUid = 'cat-1',
}) =>
    TransactionEntity(
      uuid: uuid,
      amount: amount,
      categoryUUid: categoryUUid,
      typeUuid: type,
      data: date,
      title: title,
      userId: 'user-1',
    );

void main() {
  const Map<String, String> categories = <String, String>{
    'cat-1': 'Alimentação',
    'cat-2': 'Transporte',
  };

  group('CsvExporter', () {
    test('output starts with correct header row', () {
      final String csv = String.fromCharCodes(
        CsvExporter.export(<TransactionEntity>[], categories),
      );
      expect(csv.startsWith('Data,Título,Categoria,Tipo,Valor'), isTrue);
    });

    test('income transaction produces correct row', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-1',
          title: 'Salário',
          type: 'income',
          date: DateTime(2025, 3, 5),
          amount: 5000,
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      final List<String> lines = csv.trim().split('\n');
      expect(lines.length, 2); // header + 1 data row
      expect(lines[1], contains('05/03/2025'));
      expect(lines[1], contains('Salário'));
      expect(lines[1], contains('Alimentação'));
      expect(lines[1], contains('Receita'));
    });

    test('expense transaction is labelled Despesa', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-2',
          title: 'Mercado',
          type: 'expense',
          date: DateTime(2025, 3, 10),
          amount: 300,
          categoryUUid: 'cat-2',
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      expect(csv, contains('Despesa'));
      expect(csv, contains('Transporte'));
    });

    test('unknown category falls back to uuid', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-3',
          title: 'Misc',
          type: 'expense',
          date: DateTime(2025, 3, 15),
          amount: 50,
          categoryUUid: 'cat-unknown',
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      expect(csv, contains('cat-unknown'));
    });

    test('title with comma is quoted', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-4',
          title: 'Salário, bônus',
          type: 'income',
          date: DateTime(2025, 3, 20),
          amount: 1000,
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      expect(csv, contains('"Salário, bônus"'));
    });

    test('title with double quote escapes correctly', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-5',
          title: 'He said "hello"',
          type: 'income',
          date: DateTime(2025, 3, 22),
          amount: 500,
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      expect(csv, contains('"He said ""hello"""'));
    });

    test('multiple transactions produce multiple rows', () {
      final List<TransactionEntity> txs = <TransactionEntity>[
        _tx(
          uuid: 'tx-a',
          title: 'A',
          type: 'income',
          date: DateTime(2025, 3, 5),
          amount: 100,
        ),
        _tx(
          uuid: 'tx-b',
          title: 'B',
          type: 'expense',
          date: DateTime(2025, 3, 6),
          amount: 50,
        ),
        _tx(
          uuid: 'tx-c',
          title: 'C',
          type: 'expense',
          date: DateTime(2025, 3, 7),
          amount: 25,
        ),
      ];
      final String csv = String.fromCharCodes(
        CsvExporter.export(txs, categories),
      );
      final int rowCount = csv.trim().split('\n').length;
      expect(rowCount, 4); // header + 3 rows
    });

    test('empty list produces only header row', () {
      final String csv = String.fromCharCodes(
        CsvExporter.export(<TransactionEntity>[], categories),
      );
      final int rowCount = csv.trim().split('\n').length;
      expect(rowCount, 1); // header only
    });
  });
}
