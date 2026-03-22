import 'package:afc/domain/entity/bank_profile_entity.dart';
import 'package:afc/domain/entity/import_candidate_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
import 'package:afc/domain/usecase/statement_parser.dart';
import 'package:flutter_test/flutter_test.dart';

// Matches the actual format of extrato_exemplo_nubank.csv
const String _extrato = '''Data,Valor,Identificador,Descrição
01/02/2026,-81.69,697f772d-7471-47cd-bac2-f5bf4a7d0ac5,Pagamento de fatura
06/02/2026,4023.27,69856822-6d8e-4516-a211-66db0f94199d,Transferência recebida pelo Pix - PLACE TECNOLOGIA
27/02/2026,-72.00,69a22aa6-6e8e-4d3d-be54-3083ce282d08,Compra no débito - OFICINA BAR NORTE
''';

// Matches the actual format of fatura_exemplo_nubank.csv
const String _fatura = '''date,title,amount
2026-02-14,Google Play Pass,9.90
2026-02-13,Lanches da Ro,9.00
2026-02-01,Pagamento recebido,-81.69
2026-01-28,"IOF de ""Overleaf Sharelatex""",0.90
''';

void main() {
  // -------------------------------------------------------------------------
  // Nubank Extrato
  // -------------------------------------------------------------------------

  group('parseNubankExtrato', () {
    test('parses all three rows', () {
      expect(parseNubankExtrato(_extrato), hasLength(3));
    });

    test('negative Valor maps to expense', () {
      final List<ImportCandidateEntity> r = parseNubankExtrato(_extrato);
      expect(r[0].typeUuid, TypeEntity.expense.name);
    });

    test('positive Valor maps to income', () {
      final List<ImportCandidateEntity> r = parseNubankExtrato(_extrato);
      expect(r[1].typeUuid, TypeEntity.income.name);
    });

    test('amount is always positive', () {
      final List<ImportCandidateEntity> r = parseNubankExtrato(_extrato);
      expect(r[0].amount, closeTo(81.69, 0.001));
      expect(r[1].amount, closeTo(4023.27, 0.001));
      expect(r[2].amount, closeTo(72.00, 0.001));
    });

    test('parses DD/MM/YYYY date', () {
      final List<ImportCandidateEntity> r = parseNubankExtrato(_extrato);
      expect(r[0].date, DateTime(2026, 2));
    });

    test('uses Descrição as title', () {
      final List<ImportCandidateEntity> r = parseNubankExtrato(_extrato);
      expect(r[0].title, 'Pagamento de fatura');
    });

    test('returns empty for missing required columns', () {
      expect(parseNubankExtrato('foo,bar\n1,2'), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Nubank Fatura
  // -------------------------------------------------------------------------

  group('parseNubankFatura', () {
    test('parses all four rows', () {
      expect(parseNubankFatura(_fatura), hasLength(4));
    });

    test('positive amount maps to expense (inverted polarity)', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      expect(r[0].typeUuid, TypeEntity.expense.name); // 9.90
    });

    test('negative amount maps to income (payment received)', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      expect(r[2].typeUuid, TypeEntity.income.name); // -81.69
    });

    test('amount is always positive', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      expect(r[0].amount, closeTo(9.90, 0.001));
      expect(r[2].amount, closeTo(81.69, 0.001));
    });

    test('parses YYYY-MM-DD date', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      expect(r[0].date, DateTime(2026, 2, 14));
    });

    test('uses title column as title', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      expect(r[0].title, 'Google Play Pass');
    });

    test('handles quoted fields with escaped double quotes', () {
      final List<ImportCandidateEntity> r = parseNubankFatura(_fatura);
      // Row 4: "IOF de ""Overleaf Sharelatex"""
      expect(r[3].title, contains('IOF'));
      expect(r[3].amount, closeTo(0.90, 0.001));
    });

    test('returns empty for missing required columns', () {
      expect(parseNubankFatura('foo,bar\n1,2'), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // parseBankStatement routing
  // -------------------------------------------------------------------------

  group('parseBankStatement', () {
    test('routes Nubank extrato correctly', () {
      final List<ImportCandidateEntity> r = parseBankStatement(
        _extrato,
        BankProfile.nubank,
        StatementType.extrato,
      );
      expect(r, hasLength(3));
      // First row is a negative value → expense
      expect(r[0].typeUuid, TypeEntity.expense.name);
    });

    test('routes Nubank fatura correctly', () {
      final List<ImportCandidateEntity> r = parseBankStatement(
        _fatura,
        BankProfile.nubank,
        StatementType.fatura,
      );
      expect(r, hasLength(4));
      // First row is positive → expense (inverted polarity)
      expect(r[0].typeUuid, TypeEntity.expense.name);
    });
  });
}
