import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../entity/transaction_entity.dart';

/// Converts a list of [TransactionEntity] to RFC-4180 CSV bytes (UTF-8).
///
/// Columns: Data, Título, Categoria, Tipo, Valor
class CsvExporter {
  static Uint8List export(
    List<TransactionEntity> transactions,
    Map<String, String> categoryNames,
  ) {
    final DateFormat dateFmt = DateFormat('dd/MM/yyyy');
    final NumberFormat moneyFmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final StringBuffer buf = StringBuffer()
      ..writeln('Data,Título,Categoria,Tipo,Valor');

    for (final TransactionEntity tx in transactions) {
      final String date = dateFmt.format(tx.data);
      final String title = _escape(tx.title);
      final String category =
          _escape(categoryNames[tx.categoryUUid] ?? tx.categoryUUid);
      final String type = tx.typeUuid == 'income' ? 'Receita' : 'Despesa';
      final String amount = _escape(moneyFmt.format(tx.amount));
      buf.writeln('$date,$title,$category,$type,$amount');
    }

    return Uint8List.fromList(buf.toString().codeUnits);
  }

  /// Wraps [value] in double quotes and escapes internal double quotes
  /// per RFC-4180 (double-quote → two double-quotes).
  static String _escape(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
