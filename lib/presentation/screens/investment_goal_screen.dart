import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/usecase/investment_goal_calculator.dart';
import '../blocs/auth/auth_bloc.dart';
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
  List<double> _netWorthPoints = <double>[];

  @override
  void initState() {
    super.initState();
    _calculate();
    final AuthBloc authBloc = context.read<AuthBloc>();
    unawaited(_loadRealData(authBloc));
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _yearsCtrl.dispose();
    _returnCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRealData(AuthBloc authBloc) async {
    final String? userId = authBloc.state.whenOrNull(
      signedIn: (ClerkAuthState authState) => authState.user?.id,
    );
    if (userId == null) {
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<QuerySnapshot<Map<String, dynamic>>> results =
        await Future.wait(<Future<QuerySnapshot<Map<String, dynamic>>>>[
      firestore
          .collection('net_worth_snapshot')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .get(),
      firestore
          .collection('investment')
          .where('userId', isEqualTo: userId)
          .get(),
    ]);

    final QuerySnapshot<Map<String, dynamic>> snapDocs = results[0];
    final QuerySnapshot<Map<String, dynamic>> investDocs = results[1];

    // Compute total portfolio value from investments.
    double portfolioValue = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in investDocs.docs) {
      final Map<String, dynamic> data = doc.data();
      final double qty = (data['quantity'] as num?)?.toDouble() ?? 0;
      final double price = (data['currentPrice'] as num?)?.toDouble() ?? 0;
      portfolioValue += qty * price;
    }

    // Extract net worth history (oldest-first).
    final List<double> netWorthPoints = snapDocs.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              (d.data()['netWorth'] as num?)?.toDouble() ?? 0,
        )
        .toList();

    if (!mounted) {
      return;
    }
    setState(() {
      _netWorthPoints = netWorthPoints;
      if (portfolioValue > 0) {
        _currentCtrl.text = portfolioValue.toStringAsFixed(0);
      }
      _calculate();
    });
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
            _GrowthChart(
              result: _result!,
              currentAmount:
                  double.tryParse(_currentCtrl.text.replaceAll(',', '.')) ?? 0,
              netWorthPoints:
                  _netWorthPoints.isNotEmpty ? _netWorthPoints : null,
            ),
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
  const _GrowthChart({
    required this.result,
    required this.currentAmount,
    this.netWorthPoints,
  });

  final InvestmentGoalResult result;
  final double currentAmount;
  final List<double>? netWorthPoints;

  @override
  Widget build(BuildContext context) {
    final List<double> timeline = result.yearlyTimeline;
    if (timeline.isEmpty) {
      return const SizedBox();
    }

    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    // Projection spots: x=0 (today/current) → x=1..N (yearly milestones).
    final List<FlSpot> projSpots = <FlSpot>[
      FlSpot(0, currentAmount),
      for (int i = 0; i < timeline.length; i++)
        FlSpot((i + 1).toDouble(), timeline[i]),
    ];

    // Historical net worth spots mapped to negative x (months before today).
    final List<FlSpot> histSpots = <FlSpot>[];
    final List<double>? pts = netWorthPoints;
    if (pts != null && pts.isNotEmpty) {
      final int n = pts.length;
      for (int i = 0; i < n; i++) {
        final double x = (i - (n - 1)) / 12.0;
        histSpots.add(FlSpot(x, pts[i]));
      }
    }

    final double maxY = timeline.last * 1.1;
    final double minX = histSpots.isNotEmpty ? histSpots.first.x : 0;

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
                minX: minX,
                maxX: timeline.length.toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  verticalLines: <VerticalLine>[
                    VerticalLine(
                      x: 0,
                      color: AppColors.muted.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: <int>[4, 4],
                      label: VerticalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                        labelResolver: (_) => 'Hoje',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (double value, TitleMeta meta) =>
                          Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          compact.format(value),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (timeline.length / 4).ceilToDouble(),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value <= 0) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'A${value.toInt()}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  // Projection line (dashed, income colour).
                  LineChartBarData(
                    spots: projSpots,
                    isCurved: true,
                    color: AppColors.income,
                    dashArray: <int>[6, 4],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withValues(alpha: 0.08),
                    ),
                  ),
                  // Real trajectory (solid, primary colour) — only when data exists.
                  if (histSpots.isNotEmpty)
                    LineChartBarData(
                      spots: histSpots,
                      isCurved: true,
                      color: AppColors.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (histSpots.isNotEmpty) ...<Widget>[
            const Gap(8),
            const _ChartLegend(),
          ] else ...<Widget>[
            const Gap(8),
            Text(
              'Adicione transações e investimentos para ver sua trajetória real',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ],
          const Gap(4),
        ],
      ),
    );
  }
}

// ─── Chart legend ─────────────────────────────────────────────────────────────

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      _LegendItem(color: AppColors.income, label: 'Projeção', dashed: true),
      Gap(16),
      _LegendItem(color: AppColors.primary, label: 'Patrimônio real'),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      CustomPaint(
        size: const Size(20, 2),
        painter: _LinePainter(color: color, dashed: dashed),
      ),
      const Gap(6),
      Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
    ],
  );
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
      return;
    }
    double x = 0;
    const double dashLen = 5;
    const double gapLen = 3;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dashLen).clamp(0, size.width), 0),
        paint,
      );
      x += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || old.dashed != dashed;
}
