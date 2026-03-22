import 'package:afc/domain/entity/import_candidate_entity.dart';
import 'package:afc/domain/entity/type_entity.dart';
import 'package:afc/domain/usecase/statement_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // OFX parser
  // -------------------------------------------------------------------------

  group('parseOfx', () {
    const String sgml = '''
OFXHEADER:100
DATA:OFXSGML

<OFX>
<BANKMSGSRSV1>
<STMTTRNRS>
<STMTRS>
<BANKTRANLIST>
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20250315120000
<TRNAMT>-150.00
<NAME>SUPERMERCADO EXTRA
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20250320
<TRNAMT>3000.00
<NAME>SALARIO
</STMTTRN>
</BANKTRANLIST>
</STMTRS>
</STMTTRNRS>
</BANKMSGSRSV1>
</OFX>
''';

    test('parses two transactions', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result, hasLength(2));
    });

    test('debit maps to expense type', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[0].typeUuid, TypeEntity.expense.name);
    });

    test('credit maps to income type', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[1].typeUuid, TypeEntity.income.name);
    });

    test('amount is always positive', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[0].amount, 150.00);
      expect(result[1].amount, 3000.00);
    });

    test('date parsed correctly from YYYYMMDDHHMMSS', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[0].date, DateTime(2025, 3, 15));
    });

    test('date parsed correctly from YYYYMMDD (no time)', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[1].date, DateTime(2025, 3, 20));
    });

    test('title is title-cased from NAME', () {
      final List<ImportCandidateEntity> result = parseOfx(sgml);
      expect(result[0].title, 'Supermercado Extra');
    });

    test('returns empty list when no STMTTRN blocks found', () {
      expect(parseOfx('<OFX></OFX>'), isEmpty);
    });

    test('falls back to MEMO when NAME is absent', () {
      const String withMemo = '''
<OFX>
<STMTTRN>
<DTPOSTED>20250101
<TRNAMT>-20.00
<MEMO>CAFE DA MANHA
</STMTTRN>
</OFX>''';
      final List<ImportCandidateEntity> result = parseOfx(withMemo);
      expect(result.first.title, 'Cafe Da Manha');
    });

    test('skips blocks with missing date or amount', () {
      const String incomplete = '''
<OFX>
<STMTTRN>
<NAME>NO DATE
<TRNAMT>-10.00
</STMTTRN>
<STMTTRN>
<DTPOSTED>20250101
<NAME>NO AMOUNT
</STMTTRN>
</OFX>''';
      expect(parseOfx(incomplete), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // CSV parser
  // -------------------------------------------------------------------------

  group('parseCsv', () {
    const String csvComma = 'data,descricao,valor\n'
        '15/03/2025,Netflix,-49.90\n'
        '20/03/2025,Salario,3000.00\n';

    const String csvSemicolon = 'data;descricao;valor\n'
        '15/03/2025;Aluguel;-1200,00\n'
        '01/03/2025;Freelance;800,50\n';

    const String csvIso = 'date,description,amount\n'
        '2025-03-10,Spotify,-19.90\n';

    test('parses comma-separated CSV', () {
      expect(parseCsv(csvComma), hasLength(2));
    });

    test('parses semicolon-separated CSV', () {
      expect(parseCsv(csvSemicolon), hasLength(2));
    });

    test('negative amount maps to expense', () {
      final List<ImportCandidateEntity> result = parseCsv(csvComma);
      expect(result[0].typeUuid, TypeEntity.expense.name);
      expect(result[0].amount, 49.90);
    });

    test('positive amount maps to income', () {
      final List<ImportCandidateEntity> result = parseCsv(csvComma);
      expect(result[1].typeUuid, TypeEntity.income.name);
      expect(result[1].amount, 3000.00);
    });

    test('parses DD/MM/YYYY date', () {
      final List<ImportCandidateEntity> result = parseCsv(csvComma);
      expect(result[0].date, DateTime(2025, 3, 15));
    });

    test('parses YYYY-MM-DD date', () {
      final List<ImportCandidateEntity> result = parseCsv(csvIso);
      expect(result[0].date, DateTime(2025, 3, 10));
    });

    test('handles Brazilian amount format with comma decimal', () {
      final List<ImportCandidateEntity> result = parseCsv(csvSemicolon);
      expect(result[0].amount, closeTo(1200.00, 0.001));
      expect(result[1].amount, closeTo(800.50, 0.001));
    });

    test('handles parentheses as negative', () {
      const String csvParen = 'data,descricao,valor\n'
          '15/03/2025,Conta,(250.00)\n';
      final List<ImportCandidateEntity> result = parseCsv(csvParen);
      expect(result[0].typeUuid, TypeEntity.expense.name);
      expect(result[0].amount, 250.00);
    });

    test('strips currency prefix', () {
      // ignore: prefer_interpolation_to_compose_strings
      final String csvCurrency = 'data,descricao,valor\n'
          '15/03/2025,Gas,' + r'R$ -80.00' + '\n';
      final List<ImportCandidateEntity> result = parseCsv(csvCurrency);
      expect(result[0].amount, closeTo(80.00, 0.001));
    });

    test('returns empty list when file has fewer than 2 lines', () {
      expect(parseCsv('data,descricao,valor'), isEmpty);
    });

    test('returns empty list when required columns are missing', () {
      expect(parseCsv('foo,bar,baz\n1,2,3'), isEmpty);
    });

    test('skips rows with unparseable date or amount', () {
      const String bad = 'data,descricao,valor\n'
          'not-a-date,Test,50.00\n'
          '15/03/2025,Test,not-an-amount\n';
      expect(parseCsv(bad), isEmpty);
    });
  });
}
