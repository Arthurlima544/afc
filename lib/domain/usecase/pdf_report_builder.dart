import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entity/goal_entity.dart';
import '../entity/investment_entity.dart';
import '../entity/report_data.dart';
import '../entity/transaction_entity.dart';

const List<String> _kMonthNames = <String>[
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// Builds a multi-section A4 PDF from [ReportData].
///
/// Sections:
///   0 — Cover (period, user, summary table)
///   1 — Top expenses ranked list
///   2 — Full transaction list grouped by category
///   3 — Goals snapshot
///   4 — Month-over-month comparison (last 3 months)
///   5 — Investment summary
class PdfReportBuilder {
  static Future<Uint8List> build(ReportData data) async {
    final NumberFormat moneyFmt =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final DateFormat dateFmt = DateFormat('dd/MM/yyyy');
    final DateTime generatedAt = DateTime.now();
    final String periodLabel =
        '${_kMonthNames[data.month - 1]} ${data.year}';

    final pw.Document doc = pw.Document()
      ..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (pw.Context ctx) => _header(periodLabel, ctx),
          footer: (pw.Context ctx) => _footer(generatedAt, ctx),
          build: (pw.Context ctx) => <pw.Widget>[
            // ── Section 0: Cover ────────────────────────────────────────
            _coverSection(data, periodLabel, generatedAt, moneyFmt),
            pw.NewPage(),

            // ── Section 1: Top expenses ──────────────────────────────────
            _topExpensesSection(data, moneyFmt),
            pw.NewPage(),

            // ── Section 2: Transaction list ──────────────────────────────
            _transactionListSection(data, moneyFmt, dateFmt),
            pw.NewPage(),

            // ── Section 3: Goals snapshot ────────────────────────────────
            _goalsSection(data, moneyFmt, dateFmt),
            pw.NewPage(),

            // ── Section 4: Month-over-month ──────────────────────────────
            _monthHistorySection(data, moneyFmt),
            pw.NewPage(),

            // ── Section 5: Investment summary ────────────────────────────
            _investmentsSection(data, moneyFmt),
          ],
        ),
      );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // Header / Footer
  // ---------------------------------------------------------------------------

  static pw.Widget _header(String period, pw.Context ctx) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          'AFC — Relatório Financeiro',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          period,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  static pw.Widget _footer(DateTime generatedAt, pw.Context ctx) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              'Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(generatedAt)}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey500,
              ),
            ),
            pw.Text(
              'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey500,
              ),
            ),
          ],
        ),
      );

  // ---------------------------------------------------------------------------
  // Section 0 — Cover
  // ---------------------------------------------------------------------------

  static pw.Widget _coverSection(
    ReportData data,
    String period,
    DateTime generatedAt,
    NumberFormat fmt,
  ) {
    final double balance = data.totalIncome - data.totalExpenses;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.SizedBox(height: 24),
        pw.Text(
          'AFC',
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo700,
          ),
        ),
        pw.Text(
          'Relatório Financeiro',
          style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          period,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (data.userName.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 4),
          pw.Text(
            'Usuário: ${data.userName}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey600,
            ),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado em ${DateFormat('dd/MM/yyyy').format(generatedAt)}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
        pw.SizedBox(height: 24),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Text(
          'Resumo do Período',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: <pw.TableRow>[
            _tableHeaderRow(
              <String>['Receita', 'Despesas', 'Taxa de Poupança', 'Saldo'],
            ),
            pw.TableRow(
              children: <pw.Widget>[
                _tableCell(fmt.format(data.totalIncome), color: PdfColors.green700),
                _tableCell(fmt.format(data.totalExpenses), color: PdfColors.red700),
                _tableCell(
                  '${data.savingsRate.toStringAsFixed(1)}%',
                  color: data.savingsRate >= 0
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
                _tableCell(
                  fmt.format(balance),
                  color: balance >= 0 ? PdfColors.green700 : PdfColors.red700,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 1 — Top expenses
  // ---------------------------------------------------------------------------

  static pw.Widget _topExpensesSection(ReportData data, NumberFormat fmt) {
    final List<MapEntry<String, double>> sorted = data.expensesByCategory.entries
        .toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('1. Principais Despesas'),
        pw.SizedBox(height: 12),
        if (sorted.isEmpty)
          _emptyNote('Nenhuma despesa neste período.')
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const <int, pw.TableColumnWidth>{
              0: pw.FixedColumnWidth(28),
              1: pw.FlexColumnWidth(),
              2: pw.FixedColumnWidth(90),
              3: pw.FixedColumnWidth(52),
            },
            children: <pw.TableRow>[
              _tableHeaderRow(<String>['#', 'Categoria', 'Valor', '% Total']),
              for (int i = 0; i < sorted.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.grey50 : PdfColors.white,
                  ),
                  children: <pw.Widget>[
                    _tableCell('${i + 1}'),
                    _tableCell(
                      data.categoryNames[sorted[i].key] ?? sorted[i].key,
                      align: pw.Alignment.centerLeft,
                    ),
                    _tableCell(fmt.format(sorted[i].value)),
                    _tableCell(
                      data.totalExpenses > 0
                          ? '${(sorted[i].value / data.totalExpenses * 100).toStringAsFixed(1)}%'
                          : '0%',
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2 — Transaction list
  // ---------------------------------------------------------------------------

  static pw.Widget _transactionListSection(
    ReportData data,
    NumberFormat fmt,
    DateFormat dateFmt,
  ) {
    // Group by category
    final Map<String, List<TransactionEntity>> grouped =
        <String, List<TransactionEntity>>{};
    for (final TransactionEntity tx in data.transactions) {
      grouped.putIfAbsent(tx.categoryUUid, () => <TransactionEntity>[]).add(tx);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('2. Transações do Mês'),
        pw.SizedBox(height: 12),
        if (grouped.isEmpty)
          _emptyNote('Nenhuma transação neste período.')
        else
          for (final MapEntry<String, List<TransactionEntity>> entry
              in grouped.entries) ...<pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              color: PdfColors.grey200,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    data.categoryNames[entry.key] ?? entry.key,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    fmt.format(
                      entry.value.fold(
                        0.0,
                        (double sum, TransactionEntity tx) =>
                            sum + (tx.typeUuid == 'expense' ? tx.amount : -tx.amount),
                      ),
                    ),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Table(
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey200,
                  width: 0.5,
                ),
                left: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                right: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              columnWidths: const <int, pw.TableColumnWidth>{
                0: pw.FixedColumnWidth(64),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(84),
              },
              children: <pw.TableRow>[
                for (final TransactionEntity tx in entry.value)
                  pw.TableRow(
                    children: <pw.Widget>[
                      _tableCell(dateFmt.format(tx.data)),
                      _tableCell(
                        tx.title,
                        align: pw.Alignment.centerLeft,
                      ),
                      _tableCell(
                        fmt.format(tx.amount),
                        color: tx.typeUuid == 'income'
                            ? PdfColors.green700
                            : PdfColors.red700,
                      ),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 3 — Goals
  // ---------------------------------------------------------------------------

  static pw.Widget _goalsSection(
    ReportData data,
    NumberFormat fmt,
    DateFormat dateFmt,
  ) {
    final DateTime today = DateTime.now();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('3. Metas de Poupança'),
        pw.SizedBox(height: 12),
        if (data.goals.isEmpty)
          _emptyNote('Nenhuma meta cadastrada.')
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const <int, pw.TableColumnWidth>{
              0: pw.FlexColumnWidth(2),
              1: pw.FixedColumnWidth(80),
              2: pw.FixedColumnWidth(80),
              3: pw.FixedColumnWidth(56),
              4: pw.FixedColumnWidth(64),
            },
            children: <pw.TableRow>[
              _tableHeaderRow(<String>[
                'Meta', 'Alvo', 'Atual', 'Progresso', 'Dias',
              ]),
              for (int i = 0; i < data.goals.length; i++)
                _goalRow(data.goals[i], fmt, dateFmt, today, i),
            ],
          ),
      ],
    );
  }

  static pw.TableRow _goalRow(
    GoalEntity goal,
    NumberFormat fmt,
    DateFormat dateFmt,
    DateTime today,
    int index,
  ) {
    final double pct = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount * 100).clamp(0.0, 100.0)
        : 0.0;
    final DateTime deadline = DateTime(
      goal.deadline.year,
      goal.deadline.month,
      goal.deadline.day,
    );
    final DateTime todayNormalized =
        DateTime(today.year, today.month, today.day);
    final int days = deadline.difference(todayNormalized).inDays;
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: index.isEven ? PdfColors.grey50 : PdfColors.white,
      ),
      children: <pw.Widget>[
        _tableCell(goal.name, align: pw.Alignment.centerLeft),
        _tableCell(fmt.format(goal.targetAmount)),
        _tableCell(fmt.format(goal.currentAmount)),
        _tableCell('${pct.toStringAsFixed(0)}%'),
        _tableCell(
          days >= 0 ? '$days dias' : '${-days}d atrás',
          color: days < 0 ? PdfColors.red700 : null,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 4 — Month-over-month
  // ---------------------------------------------------------------------------

  static pw.Widget _monthHistorySection(ReportData data, NumberFormat fmt) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _sectionTitle('4. Comparativo dos Últimos 3 Meses'),
          pw.SizedBox(height: 12),
          if (data.monthHistory.isEmpty)
            _emptyNote('Histórico não disponível.')
          else
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              children: <pw.TableRow>[
                _tableHeaderRow(
                  <String>['Mês', 'Receita', 'Despesas', 'Taxa de Poupança'],
                ),
                for (int i = 0; i < data.monthHistory.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven ? PdfColors.grey50 : PdfColors.white,
                    ),
                    children: <pw.Widget>[
                      _tableCell(
                        '${_kMonthNames[data.monthHistory[i].month - 1]} ${data.monthHistory[i].year}',
                        align: pw.Alignment.centerLeft,
                      ),
                      _tableCell(
                        fmt.format(data.monthHistory[i].income),
                        color: PdfColors.green700,
                      ),
                      _tableCell(
                        fmt.format(data.monthHistory[i].expenses),
                        color: PdfColors.red700,
                      ),
                      _tableCell(
                        '${data.monthHistory[i].savingsRate.toStringAsFixed(1)}%',
                        color: data.monthHistory[i].savingsRate >= 0
                            ? PdfColors.green700
                            : PdfColors.red700,
                      ),
                    ],
                  ),
              ],
            ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Section 5 — Investments
  // ---------------------------------------------------------------------------

  static pw.Widget _investmentsSection(ReportData data, NumberFormat fmt) {
    double totalCost = 0;
    double totalValue = 0;

    for (final InvestmentEntity inv in data.investments) {
      totalCost += inv.avgCost * inv.quantity;
      totalValue += inv.currentPrice * inv.quantity;
    }

    final double totalGain = totalValue - totalCost;
    final double totalGainPct =
        totalCost > 0 ? totalGain / totalCost * 100 : 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('5. Resumo de Investimentos'),
        pw.SizedBox(height: 12),
        if (data.investments.isEmpty)
          _emptyNote('Nenhum investimento cadastrado.')
        else ...<pw.Widget>[
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const <int, pw.TableColumnWidth>{
              0: pw.FlexColumnWidth(2),
              1: pw.FixedColumnWidth(60),
              2: pw.FixedColumnWidth(80),
              3: pw.FixedColumnWidth(80),
              4: pw.FixedColumnWidth(80),
              5: pw.FixedColumnWidth(50),
            },
            children: <pw.TableRow>[
              _tableHeaderRow(<String>[
                'Nome', 'Tipo', 'Custo Total', 'Valor Atual',
                'Ganho/Perda', '%',
              ]),
              for (int i = 0; i < data.investments.length; i++)
                _investmentRow(data.investments[i], fmt, i),
              // Totals row
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                children: <pw.Widget>[
                  _tableCell(
                    'Total',
                    align: pw.Alignment.centerLeft,
                    bold: true,
                  ),
                  _tableCell(''),
                  _tableCell(fmt.format(totalCost), bold: true),
                  _tableCell(fmt.format(totalValue), bold: true),
                  _tableCell(
                    fmt.format(totalGain),
                    color: totalGain >= 0 ? PdfColors.green700 : PdfColors.red700,
                    bold: true,
                  ),
                  _tableCell(
                    '${totalGainPct.toStringAsFixed(1)}%',
                    color: totalGainPct >= 0
                        ? PdfColors.green700
                        : PdfColors.red700,
                    bold: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  static pw.TableRow _investmentRow(
    InvestmentEntity inv,
    NumberFormat fmt,
    int index,
  ) {
    final double cost = inv.avgCost * inv.quantity;
    final double value = inv.currentPrice * inv.quantity;
    final double gain = value - cost;
    final double gainPct = cost > 0 ? gain / cost * 100 : 0;

    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: index.isEven ? PdfColors.grey50 : PdfColors.white,
      ),
      children: <pw.Widget>[
        _tableCell(inv.name, align: pw.Alignment.centerLeft),
        _tableCell(inv.type),
        _tableCell(fmt.format(cost)),
        _tableCell(fmt.format(value)),
        _tableCell(
          fmt.format(gain),
          color: gain >= 0 ? PdfColors.green700 : PdfColors.red700,
        ),
        _tableCell(
          '${gainPct.toStringAsFixed(1)}%',
          color: gainPct >= 0 ? PdfColors.green700 : PdfColors.red700,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  static pw.Widget _sectionTitle(String title) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 4),
      pw.Divider(color: PdfColors.indigo200, thickness: 1.5),
    ],
  );

  static pw.Widget _emptyNote(String msg) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 12),
    child: pw.Text(
      msg,
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
    ),
  );

  static pw.TableRow _tableHeaderRow(List<String> labels) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
    children: <pw.Widget>[
      for (final String label in labels)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo900,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
    ],
  );

  static pw.Widget _tableCell(
    String text, {
    pw.Alignment align = pw.Alignment.center,
    PdfColor? color,
    double fontSize = 9,
    bool bold = false,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Align(
          alignment: align,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: bold ? pw.FontWeight.bold : null,
            ),
          ),
        ),
      );
}
