import 'dart:io';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/usecase/csv_exporter.dart';
import '../../domain/usecase/pdf_report_builder.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/report/report_cubit.dart';
import '../widgets/design_system.dart';

const List<Color> _kPieColors = <Color>[
  Color(0xFF6366F1),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF3B82F6),
  Color(0xFFF97316),
  Color(0xFF14B8A6),
];

const List<String> _kMonthNames = <String>[
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

class Relatorio extends StatefulWidget {
  const Relatorio({required this.userId, super.key});

  final String userId;

  @override
  State<Relatorio> createState() => _RelatorioState();
}

class _RelatorioState extends State<Relatorio> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _load();
  }

  void _load() {
    final String userName = context
            .read<AuthBloc>()
            .state
            .whenOrNull(signedIn: (ClerkAuthState s) => s.user?.firstName) ??
        '';
    context
        .read<ReportCubit>()
        .loadReport(widget.userId, _year, _month, userName: userName);
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
    _load();
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
    _load();
  }

  Future<void> _exportPdf(ReportData data) async {
    await Printing.layoutPdf(
      onLayout: (_) => PdfReportBuilder.build(data),
    );
  }

  Future<void> _exportCsv(ReportData data) async {
    final List<int> bytes = CsvExporter.export(
      data.transactions,
      data.categoryNames,
    );
    final Directory dir = await getTemporaryDirectory();
    final String fileName =
        'afc_${data.year}_${data.month.toString().padLeft(2, '0')}.csv';
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      <XFile>[XFile(file.path, mimeType: 'text/csv')],
      subject: 'Transações AFC — ${_kMonthNames[data.month - 1]} ${data.year}',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                AppIconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Gap(8),
                const Expanded(
                  child: Text('Relatório', style: AppTextStyles.heading),
                ),
              BlocBuilder<ReportCubit, ReportState>(
                builder: (BuildContext context, ReportState state) {
                  final ReportData? data = state.whenOrNull(
                    success: (ReportData d) => d,
                  );
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppIconButton(
                        onPressed: data != null
                            ? () => _exportCsv(data)
                            : null,
                        icon: const Icon(Icons.table_chart_outlined),
                        tooltip: 'Exportar CSV',
                      ),
                      const Gap(4),
                      AppIconButton(
                        onPressed:
                            data != null ? () => _exportPdf(data) : null,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        tooltip: 'Exportar PDF',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const Gap(20),

          // Month picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              const Gap(8),
              Text(
                '${_kMonthNames[_month - 1]} $_year',
                style: AppTextStyles.sectionTitle,
              ),
              const Gap(8),
              AppIconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const Gap(20),

          BlocBuilder<ReportCubit, ReportState>(
            builder: (BuildContext context, ReportState state) => state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (String msg) => Center(child: Text(msg)),
              success: (ReportData data) => _ReportContent(data: data),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Summary cards
        Row(
          children: <Widget>[
            Expanded(
              child: _SummaryCard(
                label: 'Receita',
                value: fmt.format(data.totalIncome),
                color: AppColors.income,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _SummaryCard(
                label: 'Despesa',
                value: fmt.format(data.totalExpenses),
                color: AppColors.expense,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _SummaryCard(
                label: 'Poupança',
                value: '${data.savingsRate.toStringAsFixed(1)}%',
                color: data.savingsRate >= 0
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),
          ],
        ),
        const Gap(24),

        // Pie chart — expenses by category
        if (data.expensesByCategory.isNotEmpty) ...<Widget>[
          const Text('Despesas por categoria', style: AppTextStyles.labelBold),
          const Gap(12),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(data, fmt),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const Gap(12),
          _PieLegend(data: data),
          const Gap(24),
        ],

        // Bar chart — month-over-month comparison
        if (data.expensesByCategory.isNotEmpty ||
            data.prevExpensesByCategory.isNotEmpty) ...<Widget>[
          const Text(
            'Comparativo com mês anterior',
            style: AppTextStyles.labelBold,
          ),
          const Gap(12),
          _ComparisonChart(data: data, fmt: fmt),
          const Gap(8),
          const Row(
            children: <Widget>[
              _LegendDot(color: AppColors.expense),
              Gap(4),
              Text('Mês atual', style: AppTextStyles.caption),
              Gap(16),
              _LegendDot(color: Color(0xFF94A3B8)),
              Gap(4),
              Text('Mês anterior', style: AppTextStyles.caption),
            ],
          ),
          const Gap(24),
        ],

        // Empty state
        if (data.totalIncome == 0 && data.totalExpenses == 0)
          const Center(
            child: Text(
              'Nenhuma transação neste mês.',
              style: AppTextStyles.body,
            ),
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
    ReportData data,
    NumberFormat fmt,
  ) {
    final List<MapEntry<String, double>> entries = data
        .expensesByCategory
        .entries
        .toList();
    return List<PieChartSectionData>.generate(entries.length, (int i) {
      final MapEntry<String, double> entry = entries[i];
      final double pct = data.totalExpenses > 0
          ? entry.value / data.totalExpenses * 100
          : 0;
      return PieChartSectionData(
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        color: _kPieColors[i % _kPieColors.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
      );
    });
  }
}

class _ComparisonChart extends StatelessWidget {
  const _ComparisonChart({required this.data, required this.fmt});

  final ReportData data;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    // Merge keys from both months
    final Set<String> allKeys = <String>{
      ...data.expensesByCategory.keys,
      ...data.prevExpensesByCategory.keys,
    };
    final List<String> categories = allKeys.toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: List<BarChartGroupData>.generate(categories.length, (
            int i,
          ) {
            final String key = categories[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: data.expensesByCategory[key] ?? 0,
                  color: AppColors.expense,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: data.prevExpensesByCategory[key] ?? 0,
                  color: const Color(0xFF94A3B8),
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int idx = value.toInt();
                  if (idx < 0 || idx >= categories.length) {
                    return const SizedBox.shrink();
                  }
                  final String name = data.categoryNames[categories[idx]] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      name.length > 6 ? '${name.substring(0, 6)}…' : name,
                      style: AppTextStyles.chartLabel,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.caption),
        const Gap(4),
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final List<MapEntry<String, double>> entries = data
        .expensesByCategory
        .entries
        .toList();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: <Widget>[
        for (int i = 0; i < entries.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LegendDot(color: _kPieColors[i % _kPieColors.length]),
              const Gap(4),
              Text(
                '${data.categoryNames[entries[i].key] ?? entries[i].key} (${fmt.format(entries[i].value)})',
                style: AppTextStyles.caption,
              ),
            ],
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
