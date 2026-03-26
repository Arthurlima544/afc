import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/type_entity.dart';
import '../../domain/usecase/fire_calculator.dart';
import '../../domain/usecase/inflation_calculator.dart';
import '../blocs/auth/auth_bloc.dart';
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

// ─── Real data snapshot ───────────────────────────────────────────────────────

class _RealSnapshot {
  const _RealSnapshot({
    required this.avgMonthlyIncome,
    required this.avgMonthlyExpenses,
    required this.portfolioValue,
    required this.netWorthPoints,
  });

  final double avgMonthlyIncome;
  final double avgMonthlyExpenses;
  final double portfolioValue;

  /// Monthly net-worth snapshots (totalAmount) sorted oldest-first.
  final List<double> netWorthPoints;

  double get avgMonthlySavings => avgMonthlyIncome - avgMonthlyExpenses;
  double get savingsRatePct =>
      avgMonthlyIncome > 0
          ? (avgMonthlySavings / avgMonthlyIncome * 100).clamp(0, 100)
          : 0;
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
  final TextEditingController _inflationCtrl =
      TextEditingController(text: '4.5');

  _FirePreset _preset = _FirePreset.standard;
  bool _inflationAdjusted = false;
  FireResult? _result;

  _RealSnapshot? _real;
  bool _realDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _calculate();
    final AuthBloc auth = context.read<AuthBloc>();
    final String userId =
        auth.state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';
    if (userId.isNotEmpty) {
      unawaited(_loadRealData(userId));
    }
  }

  @override
  void dispose() {
    _expensesCtrl.dispose();
    _portfolioCtrl.dispose();
    _savingsCtrl.dispose();
    _returnCtrl.dispose();
    _inflationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRealData(String userId) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime threeMonthsAgo = DateTime(now.year, now.month - 3);

      // Fetch all three in parallel.
      final List<QuerySnapshot<Map<String, dynamic>>> snaps =
          await Future.wait(<Future<QuerySnapshot<Map<String, dynamic>>>>[
        FirebaseFirestore.instance
            .collection('transaction')
            .where('userId', isEqualTo: userId)
            .get(),
        FirebaseFirestore.instance
            .collection('investment')
            .where('userId', isEqualTo: userId)
            .get(),
        FirebaseFirestore.instance
            .collection('net_worth_snapshot')
            .where('userId', isEqualTo: userId)
            .get(),
      ]);

      // ── Avg income / expenses (last 3 months) ────────────────────────────
      final Map<String, double> incomeByMonth = <String, double>{};
      final Map<String, double> expenseByMonth = <String, double>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snaps[0].docs) {
        final Map<String, dynamic> data = doc.data();
        final dynamic rawDate = data['data'];
        final DateTime date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is String) {
          date = DateTime.parse(rawDate);
        } else if (rawDate is DateTime) {
          date = rawDate;
        } else {
          continue;
        }
        if (date.isBefore(threeMonthsAgo)) {
          continue;
        }
        final String monthKey = '${date.year}-${date.month}';
        final double amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final String typeUuid = data['typeUuid'] as String? ?? '';
        if (typeUuid == TypeEntity.income.name) {
          incomeByMonth[monthKey] = (incomeByMonth[monthKey] ?? 0) + amount;
        } else if (typeUuid == TypeEntity.expense.name) {
          expenseByMonth[monthKey] =
              (expenseByMonth[monthKey] ?? 0) + amount;
        }
      }

      final Set<String> months = <String>{
        ...incomeByMonth.keys,
        ...expenseByMonth.keys,
      };
      double totalIncome = 0;
      double totalExpenses = 0;
      for (final String m in months) {
        totalIncome += incomeByMonth[m] ?? 0;
        totalExpenses += expenseByMonth[m] ?? 0;
      }
      final int monthCount = months.isEmpty ? 1 : months.length;
      final double avgIncome = totalIncome / monthCount;
      final double avgExpenses = totalExpenses / monthCount;

      // ── Portfolio value ────────────────────────────────────────────────────
      double portfolioValue = 0;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snaps[1].docs) {
        final Map<String, dynamic> data = doc.data();
        final double qty = (data['quantity'] as num?)?.toDouble() ?? 0;
        final double price = (data['currentPrice'] as num?)?.toDouble() ?? 0;
        portfolioValue += qty * price;
      }

      // ── Net worth snapshots (sorted oldest-first) ─────────────────────────
      final List<Map<String, dynamic>> snapDocs = snaps[2].docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
          .toList()
        ..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final dynamic da = a['date'];
        final dynamic db = b['date'];
        final DateTime ta = da is Timestamp
            ? da.toDate()
            : (da is String ? DateTime.parse(da) : DateTime(2000));
        final DateTime tb = db is Timestamp
            ? db.toDate()
            : (db is String ? DateTime.parse(db) : DateTime(2000));
        return ta.compareTo(tb);
        });
      final List<double> netWorthPoints = snapDocs
          .map(
            (Map<String, dynamic> d) =>
                (d['totalAmount'] as num?)?.toDouble() ?? 0,
          )
          .toList();

      final _RealSnapshot real = _RealSnapshot(
        avgMonthlyIncome: avgIncome,
        avgMonthlyExpenses: avgExpenses,
        portfolioValue: portfolioValue,
        netWorthPoints: netWorthPoints,
      );

      if (mounted) {
        setState(() {
          _real = real;
          _realDataLoaded = true;
          // Pre-fill controllers with real data if user hasn't touched them.
          if (avgExpenses > 0) {
            _expensesCtrl.text = avgExpenses.toStringAsFixed(0);
          }
          if (portfolioValue > 0) {
            _portfolioCtrl.text = portfolioValue.toStringAsFixed(0);
          }
          if (real.avgMonthlySavings > 0) {
            _savingsCtrl.text = real.avgMonthlySavings.toStringAsFixed(0);
          }
          _calculate();
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _realDataLoaded = true);
      }
    }
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
        title: const Text('Calculadora FIRE'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Real data section (only shown after load)
            if (_realDataLoaded && _real != null) ...<Widget>[
              const _SectionLabel('Sua posição atual'),
              const Gap(8),
              _RealDataCard(real: _real!),
              const Gap(16),
            ],
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
                inflationPercent: inflation,
              ),
              const Gap(16),
              const _SectionLabel('Trajetória do Portfólio'),
              const Gap(8),
              _GrowthChart(
                result: _result!,
                realTimeline: realTimeline,
                netWorthPoints:
                    (_real?.netWorthPoints.length ?? 0) >= 2
                        ? _real!.netWorthPoints
                        : null,
              ),
              if ((_real?.netWorthPoints.length ?? 0) >= 2) ...<Widget>[
                const Gap(8),
                const _ChartLegend(),
              ] else if (_realDataLoaded) ...<Widget>[
                const Gap(8),
                Text(
                  'Adicione transações e investimentos para ver sua trajetória real',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
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
}

// ─── Real data card ───────────────────────────────────────────────────────────

class _RealDataCard extends StatelessWidget {
  const _RealDataCard({required this.real});

  final _RealSnapshot real;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          _RealRow(
            label: 'Renda média mensal',
            value: brl.format(real.avgMonthlyIncome),
            icon: Icons.trending_up,
            iconColor: AppColors.income,
          ),
          const Gap(8),
          const Divider(height: 1),
          const Gap(8),
          _RealRow(
            label: 'Gastos médios mensais',
            value: brl.format(real.avgMonthlyExpenses),
            icon: Icons.trending_down,
            iconColor: AppColors.expense,
          ),
          const Gap(8),
          const Divider(height: 1),
          const Gap(8),
          _RealRow(
            label: 'Taxa de poupança',
            value: '${real.savingsRatePct.toStringAsFixed(1)}%',
            icon: Icons.savings_outlined,
            iconColor: AppColors.primary,
          ),
          const Gap(8),
          const Divider(height: 1),
          const Gap(8),
          _RealRow(
            label: 'Portfólio atual',
            value: brl.format(real.portfolioValue),
            icon: Icons.account_balance_outlined,
            iconColor: AppColors.primary,
          ),
          const Gap(4),
          Text(
            'Baseado nos últimos 3 meses · valores editáveis abaixo',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _RealRow extends StatelessWidget {
  const _RealRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(icon, size: 16, color: iconColor),
      const Gap(8),
      Expanded(
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
      ),
      Text(value, style: AppTextStyles.labelBold),
    ],
  );
}

// ─── Chart legend ─────────────────────────────────────────────────────────────

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      SizedBox(
        width: 16,
        height: 3,
        child: ColoredBox(color: AppColors.income),
      ),
      Gap(6),
      Text('Projeção', style: AppTextStyles.caption),
      Gap(16),
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        child: SizedBox(width: 16, height: 3),
      ),
      Gap(6),
      Text('Trajetória real', style: AppTextStyles.caption),
    ],
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
                  const Text('Ajuste de Inflação', style: AppTextStyles.label),
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
            suffix: '%',
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
    this.inflationPercent = 0,
  });

  final FireResult result;
  final bool inflationAdjusted;
  final double inflationPercent;

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
            tooltip:
                'Portfólio total necessário para se aposentar. '
                'Calculado como gastos anuais ÷ taxa de retirada segura.',
          ),
          const Gap(12),
          _ResultRow(label: 'Tempo até FIRE', value: timeLabel),
          const Gap(12),
          _ResultRow(label: 'Data estimada', value: dateLabel),
          if (inflationAdjusted &&
              !result.fireNumber.isInfinite &&
              result.yearsToFire != null) ...<Widget>[
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            _ResultRow(
              label: 'Valor real hoje',
              value: brl.format(
                InflationCalculator.realValue(
                  nominalValue: result.fireNumber,
                  inflationPercent: inflationPercent,
                  years: result.yearsToFire!.toDouble(),
                ),
              ),
              tooltip:
                  'O seu Número FIRE ajustado pela inflação estimada '
                  '— o que esse valor representaria em poder de compra hoje.',
            ),
          ],
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
          color: highlight ? AppColors.primary : null,
        ),
      ),
    ],
  );
}

// ─── Growth chart ─────────────────────────────────────────────────────────────

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({
    required this.result,
    this.realTimeline,
    this.netWorthPoints,
  });

  final FireResult result;
  final List<double>? realTimeline;

  /// Historical net-worth snapshots (oldest-first). Null = hide series.
  final List<double>? netWorthPoints;

  @override
  Widget build(BuildContext context) {
    final List<double> timeline = result.yearlyTimeline;
    final double fireNumber = result.fireNumber;

    // Projection spots: x = years from today (0 = today).
    final List<FlSpot> projectionSpots = timeline
        .asMap()
        .entries
        .map(
          (MapEntry<int, double> e) =>
              FlSpot(e.key.toDouble(), e.value),
        )
        .toList();

    // Historical spots: x = negative fractional years from today.
    // Each net_worth_snapshot = 1 month = -1/12 year per step back from today.
    final List<FlSpot> histSpots = <FlSpot>[];
    if (netWorthPoints != null && netWorthPoints!.isNotEmpty) {
      final int n = netWorthPoints!.length;
      for (int i = 0; i < n; i++) {
        // i=0 is oldest; i=n-1 is most recent (= today's approximate position)
        final double x = (i - (n - 1)) / 12.0;
        histSpots.add(FlSpot(x, netWorthPoints![i]));
      }
      // Connect to today (x=0) using the first projection point.
      if (projectionSpots.isNotEmpty) {
        histSpots.add(FlSpot(0, projectionSpots.first.y));
      }
    }

    final double minX = histSpots.isNotEmpty
        ? histSpots.first.x
        : 0;
    final double maxX = (timeline.length - 1).toDouble();

    final double maxY = fireNumber.isInfinite
        ? (timeline.last * 1.1)
        : (fireNumber * 1.15).clamp(timeline.last * 1.05, double.infinity);

    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    final List<LineChartBarData> bars = <LineChartBarData>[
      // Projection line (dashed, income colour)
      LineChartBarData(
        spots: projectionSpots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: AppColors.income,
        dashArray: <int>[6, 4],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: histSpots.isEmpty,
          color: AppColors.income.withValues(alpha: 0.08),
        ),
      ),
      // Inflation-adjusted overlay
      if (realTimeline != null)
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
          curveSmoothness: 0.3,
          color: AppColors.warning.withValues(alpha: 0.8),
          barWidth: 1.5,
          dashArray: <int>[5, 3],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(),
        ),
      // Real trajectory (solid primary colour)
      if (histSpots.isNotEmpty)
        LineChartBarData(
          spots: histSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.primary,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.10),
          ),
        ),
    ];

    // "Hoje" vertical line at x=0, and FIRE horizontal line.
    final ExtraLinesData extraLines = ExtraLinesData(
      verticalLines: <VerticalLine>[
        VerticalLine(
          x: 0,
          color: AppColors.muted.withValues(alpha: 0.4),
          strokeWidth: 1.5,
          dashArray: <int>[4, 4],
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.muted,
              fontSize: 9,
            ),
            labelResolver: (_) => 'Hoje',
          ),
        ),
      ],
      horizontalLines: fireNumber.isInfinite
          ? <HorizontalLine>[]
          : <HorizontalLine>[
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
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: 0,
            maxY: maxY,
            extraLinesData: extraLines,
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
                  getTitlesWidget: (double v, TitleMeta m) {
                    final int year = v.toInt();
                    return Text(
                      year == 0 ? 'Hoje' : 'A$year',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted, fontSize: 9),
                    );
                  },
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
