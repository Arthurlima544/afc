import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/usecase/investment_goal_calculator.dart';
import '../widgets/design_system.dart';

// ─── Screen ────────────────────────────────────────────────────────────────────

class InvestmentGoalScreen extends StatefulWidget {
  const InvestmentGoalScreen({super.key});

  @override
  State<InvestmentGoalScreen> createState() => _InvestmentGoalScreenState();
}

class _InvestmentGoalScreenState extends State<InvestmentGoalScreen> {
  final TextEditingController _targetCtrl =
      TextEditingController(text: '1000000');
  final TextEditingController _currentCtrl =
      TextEditingController(text: '50000');
  final TextEditingController _yearsCtrl = TextEditingController(text: '20');
  final TextEditingController _returnCtrl = TextEditingController(text: '10');

  InvestmentGoalResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _yearsCtrl.dispose();
    _returnCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final double target =
        double.tryParse(_targetCtrl.text.replaceAll(',', '.')) ?? 0;
    final double current =
        double.tryParse(_currentCtrl.text.replaceAll(',', '.')) ?? 0;
    final int years = int.tryParse(_yearsCtrl.text) ?? 0;
    final double returnPct =
        double.tryParse(_returnCtrl.text.replaceAll(',', '.')) ?? 0;

    if (target <= 0 || years <= 0) {
      return;
    }

    setState(() {
      _result = InvestmentGoalCalculator.calculate(
        targetAmount: target,
        currentAmount: current,
        months: years * 12,
        annualReturnPercent: returnPct,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Planejador de Meta'),
      centerTitle: false,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InputCard(
            targetCtrl: _targetCtrl,
            currentCtrl: _currentCtrl,
            yearsCtrl: _yearsCtrl,
            returnCtrl: _returnCtrl,
            onChanged: _calculate,
          ),
          const Gap(16),
          if (_result != null) ...<Widget>[
            _ResultCard(result: _result!),
            const Gap(16),
            _CompositionCard(result: _result!),
            const Gap(16),
            _GrowthChart(result: _result!),
          ],
        ],
      ),
    ),
  );
}

// ─── Input card ───────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.targetCtrl,
    required this.currentCtrl,
    required this.yearsCtrl,
    required this.returnCtrl,
    required this.onChanged,
  });

  final TextEditingController targetCtrl;
  final TextEditingController currentCtrl;
  final TextEditingController yearsCtrl;
  final TextEditingController returnCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Parâmetros', style: AppTextStyles.sectionTitle),
        const Gap(12),
        AppTextField(
          controller: targetCtrl,
          hintText: 'Meta (R\$)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
        ),
        const Gap(8),
        AppTextField(
          controller: currentCtrl,
          hintText: 'Patrimônio atual (R\$)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
        ),
        const Gap(8),
        AppTextField(
          controller: yearsCtrl,
          hintText: 'Prazo (anos)',
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
        ),
        const Gap(8),
        AppTextField(
          controller: returnCtrl,
          hintText: 'Retorno anual esperado (%)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
        ),
      ],
    ),
  );
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final InvestmentGoalResult result;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          const Icon(Icons.savings_outlined, color: AppColors.income, size: 28),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Aporte mensal necessário',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted),
                    ),
                    const Gap(4),
                    const AppTooltipIcon(
                      'Quanto você precisa investir por mês para atingir '
                      'sua meta, dado o prazo e retorno informados.',
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  brl.format(result.requiredMonthlyContribution),
                  style:
                      AppTextStyles.title.copyWith(color: AppColors.income),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Composition card ─────────────────────────────────────────────────────────

class _CompositionCard extends StatelessWidget {
  const _CompositionCard({required this.result});

  final InvestmentGoalResult result;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    final double total =
        result.totalContributed + result.totalInterestEarned;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Composição ao final', style: AppTextStyles.sectionTitle),
          const Gap(12),
          _BreakdownRow(
            label: 'Total aportado',
            value: brl.format(result.totalContributed),
            color: AppColors.primary,
            fraction: total > 0 ? result.totalContributed / total : 0,
          ),
          const Gap(8),
          _BreakdownRow(
            label: 'Juros / crescimento',
            value: brl.format(result.totalInterestEarned),
            color: AppColors.income,
            fraction: total > 0 ? result.totalInterestEarned / total : 0,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
    required this.fraction,
  });

  final String label;
  final String value;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: AppTextStyles.caption),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const Gap(4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: fraction.clamp(0.0, 1.0),
          minHeight: 6,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
        ),
      ),
    ],
  );
}

// ─── Growth chart ─────────────────────────────────────────────────────────────

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.result});

  final InvestmentGoalResult result;

  @override
  Widget build(BuildContext context) {
    final List<double> timeline = result.yearlyTimeline;
    if (timeline.isEmpty) {
      return const SizedBox();
    }
    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < timeline.length; i++)
        FlSpot((i + 1).toDouble(), timeline[i]),
    ];
    final double maxY = timeline.last * 1.1;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Evolução do patrimônio', style: AppTextStyles.sectionTitle),
          const Gap(12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (timeline.length / 4).ceilToDouble(),
                      getTitlesWidget: (double value, TitleMeta meta) =>
                          Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'A${value.toInt()}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.income,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
