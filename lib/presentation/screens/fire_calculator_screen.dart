import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/usecase/fire_calculator.dart';
import '../widgets/design_system.dart';

// ─── Preset SWR rates ──────────────────────────────────────────────────────────

enum _FirePreset {
  lean('Lean FIRE', 0.03),
  standard('Padrão (4%)', 0.04),
  fat('Fat FIRE', 0.05);

  const _FirePreset(this.label, this.swr);

  final String label;
  final double swr;
}

// ─── Screen ────────────────────────────────────────────────────────────────────

class FireCalculatorScreen extends StatefulWidget {
  const FireCalculatorScreen({super.key});

  @override
  State<FireCalculatorScreen> createState() => _FireCalculatorScreenState();
}

class _FireCalculatorScreenState extends State<FireCalculatorScreen> {
  final TextEditingController _expensesCtrl =
      TextEditingController(text: '5000');
  final TextEditingController _portfolioCtrl =
      TextEditingController(text: '50000');
  final TextEditingController _savingsCtrl =
      TextEditingController(text: '2000');
  final TextEditingController _returnCtrl =
      TextEditingController(text: '10');

  _FirePreset _preset = _FirePreset.standard;
  FireResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _expensesCtrl.dispose();
    _portfolioCtrl.dispose();
    _savingsCtrl.dispose();
    _returnCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final double expenses =
        double.tryParse(_expensesCtrl.text.replaceAll(',', '.')) ?? 0;
    final double portfolio =
        double.tryParse(_portfolioCtrl.text.replaceAll(',', '.')) ?? 0;
    final double savings =
        double.tryParse(_savingsCtrl.text.replaceAll(',', '.')) ?? 0;
    final double annualReturn =
        (double.tryParse(_returnCtrl.text.replaceAll(',', '.')) ?? 0) / 100;

    setState(() {
      _result = FireCalculator.calculate(
        monthlyExpenses: expenses,
        annualReturnRate: annualReturn,
        safeWithdrawalRate: _preset.swr,
        currentPortfolio: portfolio,
        monthlySavings: savings,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Calculadora FIRE'),
      centerTitle: false,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionLabel('Estratégia'),
          const Gap(8),
          _PresetBar(
            selected: _preset,
            onChanged: (_FirePreset p) {
              setState(() => _preset = p);
              _calculate();
            },
          ),
          const Gap(16),
          const _SectionLabel('Entradas'),
          const Gap(8),
          _InputCard(
            expensesCtrl: _expensesCtrl,
            portfolioCtrl: _portfolioCtrl,
            savingsCtrl: _savingsCtrl,
            returnCtrl: _returnCtrl,
            onChanged: _calculate,
          ),
          const Gap(16),
          if (_result != null) ...<Widget>[
            const _SectionLabel('Resultado'),
            const Gap(8),
            _ResultCard(result: _result!),
            const Gap(16),
            const _SectionLabel('Trajetória do Portfólio'),
            const Gap(8),
            _GrowthChart(result: _result!),
            const Gap(8),
            Text(
              'Taxa de retirada segura: ${(_preset.swr * 100).toStringAsFixed(0)}% a.a.  ·  '
              'Projeção até ${DateTime.now().year + 50}',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── Preset bar ───────────────────────────────────────────────────────────────

class _PresetBar extends StatelessWidget {
  const _PresetBar({required this.selected, required this.onChanged});

  final _FirePreset selected;
  final ValueChanged<_FirePreset> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: _FirePreset.values
        .map(
          (_FirePreset p) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PresetChip(
              label: p.label,
              active: selected == p,
              onTap: () => onChanged(p),
            ),
          ),
        )
        .toList(),
  );
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: active ? AppColors.onPrimary : null,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}

// ─── Input card ───────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.expensesCtrl,
    required this.portfolioCtrl,
    required this.savingsCtrl,
    required this.returnCtrl,
    required this.onChanged,
  });

  final TextEditingController expensesCtrl;
  final TextEditingController portfolioCtrl;
  final TextEditingController savingsCtrl;
  final TextEditingController returnCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: <Widget>[
        _NumField(
          controller: expensesCtrl,
          label: 'Gastos mensais (R\$)',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: portfolioCtrl,
          label: 'Portfólio atual (R\$)',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: savingsCtrl,
          label: 'Investimento mensal (R\$)',
          onChanged: onChanged,
        ),
        const Gap(12),
        _NumField(
          controller: returnCtrl,
          label: 'Retorno anual esperado (%)',
          suffix: '%',
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
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final String hint = suffix != null ? 'Ex: 5000 $suffix' : 'Ex: 5000';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const Gap(4),
        AppTextField(
          controller: controller,
          hintText: hint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final FireResult result;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    final String fireLabel = result.fireNumber.isInfinite
        ? '—'
        : brl.format(result.fireNumber);

    final String timeLabel;
    if (result.monthsToFire == null) {
      timeLabel = 'Não atingido em 50 anos';
    } else if (result.yearsToFire! < 1) {
      timeLabel = '${result.monthsToFire} meses';
    } else {
      timeLabel =
          '${result.yearsToFire} anos e ${result.monthsToFire! % 12} meses';
    }

    final String dateLabel = result.retirementDate == null
        ? '—'
        : DateFormat('MM/yyyy', 'pt_BR').format(result.retirementDate!);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          _ResultRow(
            label: 'Número FIRE',
            value: fireLabel,
            highlight: true,
          ),
          const Gap(12),
          _ResultRow(label: 'Tempo até FIRE', value: timeLabel),
          const Gap(12),
          _ResultRow(label: 'Data estimada', value: dateLabel),
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
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(label, style: AppTextStyles.body.copyWith(color: AppColors.muted)),
      Text(
        value,
        style: AppTextStyles.bodyBold.copyWith(
          color: highlight ? AppColors.primary : null,
        ),
      ),
    ],
  );
}

// ─── Growth chart ─────────────────────────────────────────────────────────────

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.result});

  final FireResult result;

  @override
  Widget build(BuildContext context) {
    final List<double> timeline = result.yearlyTimeline;
    final double fireNumber = result.fireNumber;

    final List<FlSpot> spots = timeline
        .asMap()
        .entries
        .map(
          (MapEntry<int, double> e) =>
              FlSpot(e.key.toDouble(), e.value),
        )
        .toList();

    final double maxY = fireNumber.isInfinite
        ? (timeline.last * 1.1)
        : (fireNumber * 1.15).clamp(timeline.last * 1.05, double.infinity);

    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (timeline.length - 1).toDouble(),
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
                  reservedSize: 56,
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
                  interval: 10,
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
            extraLinesData: fireNumber.isInfinite
                ? const ExtraLinesData()
                : ExtraLinesData(
                    horizontalLines: <HorizontalLine>[
                      HorizontalLine(
                        y: fireNumber,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        strokeWidth: 1.5,
                        dashArray: <int>[6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 4, bottom: 2),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 9,
                          ),
                          labelResolver: (_) => 'FIRE',
                        ),
                      ),
                    ],
                  ),
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.income,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.income.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),
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
