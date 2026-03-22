import 'dart:math';

import '../entity/import_candidate_entity.dart';
import '../entity/type_entity.dart';

// ---------------------------------------------------------------------------
// OFX / SGML parser
// ---------------------------------------------------------------------------

/// Parses OFX SGML or OFX 2.x XML content into import candidates.
///
/// Handles the classic headerless SGML format (no closing tags) as well as
/// OFX 2.x XML where every element is properly closed.
List<ImportCandidateEntity> parseOfx(String content) {
  final List<ImportCandidateEntity> results = <ImportCandidateEntity>[];

  final String upper = content.toUpperCase();
  final List<String> parts = upper.split('<STMTTRN>');

  for (int i = 1; i < parts.length; i++) {
    final String block = parts[i];

    String field(String name) {
      final RegExp re = RegExp('<$name>([^<\\n\\r]+)', caseSensitive: false);
      return re.firstMatch(block)?.group(1)?.trim() ?? '';
    }

    final String rawDate = field('DTPOSTED');
    final String rawAmount = field('TRNAMT');
    final String name =
        field('NAME').isEmpty ? field('MEMO') : field('NAME');

    if (rawDate.isEmpty || rawAmount.isEmpty) {
      continue;
    }

    final DateTime? date = _parseOfxDate(rawDate);
    final double? amount = double.tryParse(rawAmount.replaceAll(',', '.'));

    if (date == null || amount == null) {
      continue;
    }

    results.add(
      ImportCandidateEntity(
        title: name.isEmpty ? 'Importado' : _titleCase(name),
        amount: amount.abs(),
        date: date,
        typeUuid: amount < 0
            ? TypeEntity.expense.name
            : TypeEntity.income.name,
      ),
    );
  }

  return results;
}

DateTime? _parseOfxDate(String raw) {
  // Formats: YYYYMMDDHHMMSS, YYYYMMDD, YYYYMMDD[offset:TZ]
  final String digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 8) {
    return null;
  }
  try {
    return DateTime(
      int.parse(digits.substring(0, 4)),
      int.parse(digits.substring(4, 6)),
      int.parse(digits.substring(6, 8)),
    );
  } on Exception catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// CSV parser
// ---------------------------------------------------------------------------

/// Parses CSV (or semicolon-separated) bank statement content.
///
/// Expects a header row. Recognised column names (case-insensitive):
/// - Date: `data`, `date`, `dt`, `datapagamento`, `data_lancamento`
/// - Amount: `valor`, `amount`, `value`, `montante`
/// - Description: `descricao`, `description`, `historico`, `memo`, `nome`, `name`
List<ImportCandidateEntity> parseCsv(String content) {
  final List<String> lines = content
      .split('\n')
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

  if (lines.length < 2) {
    return <ImportCandidateEntity>[];
  }

  final String sep = lines[0].contains(';') ? ';' : ',';

  final List<String> headers = lines[0]
      .split(sep)
      .map((String s) => s.trim().toLowerCase().replaceAll('"', ''))
      .toList();

  final int dateIdx = _findCol(headers, <String>[
    'data',
    'date',
    'dt',
    'datapagamento',
    'data_lancamento',
  ]);
  final int amountIdx = _findCol(headers, <String>[
    'valor',
    'amount',
    'value',
    'montante',
  ]);
  final int descIdx = _findCol(headers, <String>[
    'descricao',
    'description',
    'historico',
    'memo',
    'nome',
    'name',
  ]);

  if (dateIdx < 0 || amountIdx < 0) {
    return <ImportCandidateEntity>[];
  }

  final List<ImportCandidateEntity> results = <ImportCandidateEntity>[];

  for (int i = 1; i < lines.length; i++) {
    final List<String> cols = _splitRow(lines[i], sep);
    final int needed = max(dateIdx, amountIdx);
    if (cols.length <= needed) {
      continue;
    }

    final String rawDate = cols[dateIdx].trim().replaceAll('"', '');
    final String rawAmount = cols[amountIdx].trim().replaceAll('"', '');
    final String title = descIdx >= 0 && cols.length > descIdx
        ? cols[descIdx].trim().replaceAll('"', '')
        : '';

    final DateTime? date = _parseCsvDate(rawDate);
    final double? amount = _parseCsvAmount(rawAmount);

    if (date == null || amount == null) {
      continue;
    }

    results.add(
      ImportCandidateEntity(
        title: title.isEmpty ? 'Importado' : title,
        amount: amount.abs(),
        date: date,
        typeUuid: amount < 0
            ? TypeEntity.expense.name
            : TypeEntity.income.name,
      ),
    );
  }

  return results;
}

int _findCol(List<String> headers, List<String> candidates) {
  for (final String candidate in candidates) {
    final int idx = headers.indexOf(candidate);
    if (idx >= 0) {
      return idx;
    }
  }
  return -1;
}

/// Splits a CSV row respecting double-quoted fields.
List<String> _splitRow(String row, String sep) {
  final List<String> result = <String>[];
  final StringBuffer current = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < row.length; i++) {
    final String ch = row[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
    } else if (ch == sep && !inQuotes) {
      result.add(current.toString());
      current.clear();
    } else {
      current.write(ch);
    }
  }
  result.add(current.toString());
  return result;
}

/// Parses date strings in DD/MM/YYYY, YYYY-MM-DD, or DD-MM-YYYY format.
DateTime? _parseCsvDate(String raw) {
  // DD/MM/YYYY
  final RegExp dmySlash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
  final Match? m1 = dmySlash.firstMatch(raw);
  if (m1 != null) {
    return DateTime(
      int.parse(m1.group(3)!),
      int.parse(m1.group(2)!),
      int.parse(m1.group(1)!),
    );
  }

  // YYYY-MM-DD
  final RegExp isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  final Match? m2 = isoDate.firstMatch(raw);
  if (m2 != null) {
    return DateTime(
      int.parse(m2.group(1)!),
      int.parse(m2.group(2)!),
      int.parse(m2.group(3)!),
    );
  }

  // DD-MM-YYYY
  final RegExp dmyDash = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$');
  final Match? m3 = dmyDash.firstMatch(raw);
  if (m3 != null) {
    return DateTime(
      int.parse(m3.group(3)!),
      int.parse(m3.group(2)!),
      int.parse(m3.group(1)!),
    );
  }

  return null;
}

/// Parses amount strings, handling:
/// - Brazilian format: `1.234,56` → 1234.56
/// - Standard format: `1,234.56` → 1234.56
/// - Negative: `-50.00` or `(50.00)`
/// - Currency prefix: `R$`, `$`
double? _parseCsvAmount(String raw) {
  String cleaned = raw
      .replaceAll('R\$', '')
      .replaceAll('\$', '')
      .replaceAll(' ', '');

  // Parentheses mean negative: (50,00)
  final bool negative = cleaned.startsWith('(') && cleaned.endsWith(')');
  cleaned = cleaned.replaceAll('(', '').replaceAll(')', '');

  // Detect Brazilian format: has comma as decimal separator
  // e.g. "1.234,56" — last separator is comma
  final int lastComma = cleaned.lastIndexOf(',');
  final int lastDot = cleaned.lastIndexOf('.');

  if (lastComma > lastDot) {
    // Comma is decimal separator
    cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
  } else {
    // Dot is decimal separator (or no decimal at all)
    cleaned = cleaned.replaceAll(',', '');
  }

  final double? value = double.tryParse(cleaned);
  if (value == null) {
    return null;
  }
  return negative ? -value.abs() : value;
}

String _titleCase(String s) {
  if (s.isEmpty) {
    return s;
  }
  return s
      .toLowerCase()
      .split(' ')
      .map(
        (String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
      )
      .join(' ');
}
