import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/usecase/compound_interest_calculator.dart';
import '../../domain/usecase/inflation_calculator.dart';
import '../widgets/design_system.dart';

// ─── Comparison rates ─────────────────────────────────────────────────────────

// Three fixed "what-if" rates shown as alternative series on the chart.
const List<double> _compareRates = <double>[0.06, 0.10, 0.14];
const List<String> _compareLabels = <String>['6%', '10%', '14%'];
const List<Color> _compareColors = <Color>[
  Color(0xFF64B5F6), // blue-300
  Color(0xFF81C784), // green-300
  Color(0xFFFFB74D), // orange-300
];

// ─── Screen ────────────────────────────────────────────────────────────────────

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final TextEditingController _initialCtrl =
      TextEditingController(text: '10000');
  final TextEditingController _monthlyCtrl =
      TextEditingController(text: '1000');
  final TextEditingController _rateCtrl = TextEditingController(text: '12');
  final TextEditingController _yearsCtrl = TextEditingController(text: '20');
  final TextEditingController _inflationCtrl =
      TextEditingController(text: '4.5');

  bool _showComparison = false;
  bool _inflationAdjusted = false;
  CompoundResult? _result;
  List<CompoundResult> _comparisons = <CompoundResult>[];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _initialCtrl.dispose();
    _monthlyCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    _inflationCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final double initial =
        double.tryParse(_initialCtrl.text.replaceAll(',', '.')) ?? 0;
    final double monthly =
        double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0;
    final double rate =
        (double.tryParse(_rateCtrl.text.replaceAll(',', '.')) ?? 0) / 100;
    final int years = int.tryParse(_yearsCtrl.text) ?? 1;
    final int safeYears = years.clamp(1, 50);

    setState(() {
      _result = CompoundInterestCalculator.calculate(
        initialAmount: initial,
        monthlyContribution: monthly,
        annualRate: rate,
        years: safeYears,
      );
      _comparisons = CompoundInterestCalculator.compare(
        initialAmount: initial,
        monthlyContribution: monthly,
        rates: _compareRates,
        years: safeYears,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double inflation = _inflationAdjusted
        ? (double.tryParse(_inflationCtrl.text.replaceAll(',', '.')) ?? 4.5)
        : 0;
    final List<double>? realTimeline =
        (_inflationAdjusted && _result != null)
            ? InflationCalculator.adjustTimeline(
                nominalTimeline: _result!.yearlyTimeline,
                inflationPercent: inflation,
              )
            : null;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Juros Compostos'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionLabel('Parâmetros'),
            const Gap(8),
            _InputCard(
              initialCtrl: _initialCtrl,
              monthlyCtrl: _monthlyCtrl,
              rateCtrl: _rateCtrl,
              yearsCtrl: _yearsCtrl,
              onChanged: _calculate,
            ),
            const Gap(12),
            _InflationCard(
              adjusted: _inflationAdjusted,
              controller: _inflationCtrl,
              onToggle: (bool v) => setState(() => _inflationAdjusted = v),
              onChanged: _calculate,
            ),
            const Gap(16),
            if (_result != null) ...<Widget>[
              const _SectionLabel('Resultado'),
              const Gap(8),
              _ResultCard(
                result: _result!,
                inflationAdjusted: _inflationAdjusted,
                realFinalAmount: realTimeline?.lastOrNull,
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const _SectionLabel('Evolução do Patrimônio'),
                  _ComparisonToggle(
                    value: _showComparison,
                    onChanged: (bool v) =>
                        setState(() => _showComparison = v),
                  ),
                ],
              ),
              const Gap(8),
              _GrowthChart(
                result: _result!,
                comparisons:
                    _showComparison ? _comparisons : <CompoundResult>[],
                realTimeline: realTimeline,
              ),
              if (_showComparison) ...<Widget>[
                const Gap(8),
                _ComparisonLegend(
                  result: _result!,
                  comparisons: _comparisons,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Input card ───────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.initialCtrl,
    required this.monthlyCtrl,
    required this.rateCtrl,
    required this.yearsCtrl,
    required this.onChanged,
  });

  final TextEditingController initialCtrl;
  final TextEditingController monthlyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController yearsCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: <Widget>[
        _NumField(
          controller: initialCtrl,
          label: 'Aporte inicial (R\$)',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: monthlyCtrl,
          label: 'Aporte mensal (R\$)',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: rateCtrl,
          label: 'Taxa anual esperada (%)',
          hint: 'Ex: 12 %',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: yearsCtrl,
          label: 'Período (anos)',
          hint: 'Ex: 20',
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
      ),
      const Gap(4),
      AppTextField(
        controller: controller,
        hintText: hint ?? 'Ex: 1000',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => onChanged(),
      ),
    ],
  );
}

// ─── Inflation card ────────────────────────────────────────────────────────────

class _InflationCard extends StatelessWidget {
  const _InflationCard({
    required this.adjusted,
    required this.controller,
    required this.onToggle,
    required this.onChanged,
  });

  final bool adjusted;
  final TextEditingController controller;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Ajuste de Inflação',
                    style: AppTextStyles.label,
                  ),
                  const Gap(2),
                  Text(
                    'Valores em poder de compra de hoje',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: adjusted,
              onChanged: onToggle,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        if (adjusted) ...<Widget>[
          const Gap(8),
          _NumField(
            controller: controller,
            label: 'Taxa de inflação anual (%)',
            hint: 'Ex: 4.5 %',
            onChanged: onChanged,
          ),
        ],
      ],
    ),
  );
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    this.inflationAdjusted = false,
    this.realFinalAmount,
  });

  final CompoundResult result;
  final bool inflationAdjusted;
  final double? realFinalAmount;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          _ResultRow(
            label: 'Montante final',
            value: brl.format(result.finalAmount),
            highlight: true,
            tooltip:
                'Valor total acumulado ao fim do período, '
                'incluindo todos os aportes e rendimentos compostos.',
          ),
          const Gap(10),
          _ResultRow(
            label: 'Total investido',
            value: brl.format(result.totalInvested),
          ),
          const Gap(10),
          _ResultRow(
            label: 'Juros ganhos',
            value: brl.format(result.totalInterest),
            tooltip:
                'Diferença entre o montante final e o total investido. '
                'Representa o poder dos juros compostos ao longo do tempo.',
          ),
          if (inflationAdjusted && realFinalAmount != null) ...<Widget>[
            const Gap(10),
            const Divider(height: 1),
            const Gap(10),
            _ResultRow(
              label: 'Poder de compra hoje',
              value: brl.format(realFinalAmount),
              tooltip:
                  'O montante final ajustado pela inflação estimada '
                  '— o que esse valor representaria em poder de compra hoje.',
            ),
          ],
          const Gap(12),
          // Visual split: invested vs interest bar
          _CompositionBar(
            invested: result.totalInvested,
            interest: result.totalInterest,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.tooltip,
  });

  final String label;
  final String value;
  final bool highlight;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
          if (tooltip != null) ...<Widget>[
            const Gap(4),
            AppTooltipIcon(tooltip!),
          ],
        ],
      ),
      Text(
        value,
        style: AppTextStyles.bodyBold.copyWith(
          color: highlight ? AppColors.income : null,
        ),
      ),
    ],
  );
}

class _CompositionBar extends StatelessWidget {
  const _CompositionBar({required this.invested, required this.interest});

  final double invested;
  final double interest;

  @override
  Widget build(BuildContext context) {
    final double total = invested + interest;
    if (total <= 0) {
      return const SizedBox.shrink();
    }
    final double investedFraction = invested / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: (investedFraction * 100).round(),
                child: Container(
                  height: 8,
                  color: AppColors.muted.withValues(alpha: 0.5),
                ),
              ),
              Expanded(
                flex: ((1 - investedFraction) * 100).round().clamp(1, 99),
                child: Container(height: 8, color: AppColors.income),
              ),
            ],
          ),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(4),
                Text(
                  'Capital investido',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.income,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(4),
                Text(
                  'Rendimentos',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Comparison toggle ────────────────────────────────────────────────────────

class _ComparisonToggle extends StatelessWidget {
  const _ComparisonToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Text(
        'Comparar taxas',
        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
      ),
      const Gap(6),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    ],
  );
}

// ─── Growth chart ─────────────────────────────────────────────────────────────

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({
    required this.result,
    required this.comparisons,
    this.realTimeline,
  });

  final CompoundResult result;
  final List<CompoundResult> comparisons;
  final List<double>? realTimeline;

  @override
  Widget build(BuildContext context) {
    final double maxY = comparisons.isEmpty
        ? result.finalAmount * 1.05
        : comparisons
              .map((CompoundResult r) => r.finalAmount)
              .reduce((double a, double b) => a > b ? a : b) *
          1.05;

    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    List<LineChartBarData> bars = <LineChartBarData>[
      LineChartBarData(
        spots: result.yearlyTimeline
            .asMap()
            .entries
            .map(
              (MapEntry<int, double> e) =>
                  FlSpot(e.key.toDouble(), e.value),
            )
            .toList(),
        isCurved: true,
        color: AppColors.primary,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: comparisons.isEmpty,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
    ];

    for (int i = 0; i < comparisons.length; i++) {
      bars = <LineChartBarData>[
        ...bars,
        LineChartBarData(
          spots: comparisons[i]
              .yearlyTimeline
              .asMap()
              .entries
              .map(
                (MapEntry<int, double> e) =>
                    FlSpot(e.key.toDouble(), e.value),
              )
              .toList(),
          isCurved: true,
          color: _compareColors[i].withValues(alpha: 0.8),
          barWidth: 1.5,
          dashArray: <int>[5, 3],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(),
        ),
      ];
    }

    if (realTimeline != null) {
      bars = <LineChartBarData>[
        ...bars,
        LineChartBarData(
          spots: realTimeline!
              .asMap()
              .entries
              .map(
                (MapEntry<int, double> e) =>
                    FlSpot(e.key.toDouble(), e.value),
              )
              .toList(),
          isCurved: true,
          color: AppColors.warning.withValues(alpha: 0.9),
          barWidth: 1.5,
          dashArray: <int>[4, 4],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(),
        ),
      ];
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (result.yearlyTimeline.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.muted.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: maxY / 4,
                  getTitlesWidget: (double v, TitleMeta m) => Text(
                    compact.format(v),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted, fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (result.yearlyTimeline.length / 5).ceilToDouble(),
                  getTitlesWidget: (double v, TitleMeta m) => Text(
                    'Ano ${v.toInt()}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted, fontSize: 9),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: bars,
          ),
        ),
      ),
    );
  }
}

// ─── Comparison legend ────────────────────────────────────────────────────────

class _ComparisonLegend extends StatelessWidget {
  const _ComparisonLegend({
    required this.result,
    required this.comparisons,
  });

  final CompoundResult result;
  final List<CompoundResult> comparisons;

  @override
  Widget build(BuildContext context) {
    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 12, height: 3, color: AppColors.primary),
              const Gap(8),
              const Text('Taxa atual', style: AppTextStyles.caption),
              const Spacer(),
              Text(
                compact.format(result.finalAmount),
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          for (int i = 0; i < comparisons.length; i++) ...<Widget>[
            const Gap(6),
            Row(
              children: <Widget>[
                Container(width: 12, height: 2, color: _compareColors[i]),
                const Gap(8),
                Text(_compareLabels[i], style: AppTextStyles.caption),
                const Spacer(),
                Text(
                  compact.format(comparisons[i].finalAmount),
                  style: AppTextStyles.labelBold.copyWith(
                    color: _compareColors[i],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.labelBold.copyWith(color: AppColors.muted),
  );
}
