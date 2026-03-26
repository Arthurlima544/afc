import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/investment_entity.dart';
import '../../domain/usecase/portfolio_calculator.dart';
import '../../utils/share_card_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/investment/investment_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/error_state.dart';
import '../widgets/share_cards/portfolio_share_card.dart';
import '../widgets/skeleton_list.dart';

// ─── Asset type helpers ───────────────────────────────────────────────────────

const Map<String, String> _typeLabels = <String, String>{
  'stock': 'Ações',
  'fixed': 'Renda Fixa',
  'crypto': 'Cripto',
  'other': 'Outros',
};

const Map<String, Color> _typeColors = <String, Color>{
  'stock': Color(0xFF42A5F5),  // blue
  'fixed': Color(0xFF66BB6A),  // green
  'crypto': Color(0xFFFFB74D), // orange
  'other': Color(0xFFAB47BC),  // purple
};

Color _colorFor(String type) => _typeColors[type] ?? const Color(0xFF78909C);
String _labelFor(String type) => _typeLabels[type] ?? 'Outro';

// ─── Screen ────────────────────────────────────────────────────────────────────

class PortfolioDashboardScreen extends StatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  State<PortfolioDashboardScreen> createState() =>
      _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState extends State<PortfolioDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final InvestmentCubit cubit = context.read<InvestmentCubit>();
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';
    Future<void>.microtask(() => cubit.loadInvestments(userId));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Portfólio'),
      centerTitle: false,
    ),
    body: BlocBuilder<InvestmentCubit, InvestmentState>(
      builder: (BuildContext context, InvestmentState state) => state.when(
        initial: () => const SizedBox(),
        loading: () => const SkeletonList(),
        error: (String msg) => ErrorState(
          message: msg,
          onRetry: () {
            final String userId =
                context.read<AuthBloc>().state.whenOrNull(
                      signedIn: (ClerkAuthState s) => s.user?.id,
                    ) ??
                '';
            context.read<InvestmentCubit>().loadInvestments(userId);
          },
        ),
        listed: (List<InvestmentEntity> investments) {
          if (investments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum investimento cadastrado.\nAdicione pelo menu Portfólio.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),
            );
          }
          final PortfolioSummary summary =
              PortfolioCalculator.calculate(investments);
          return _PortfolioBody(summary: summary);
        },
        success: (_) => const SizedBox(),
      ),
    ),
  );
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _PortfolioBody extends StatefulWidget {
  const _PortfolioBody({required this.summary});

  final PortfolioSummary summary;

  @override
  State<_PortfolioBody> createState() => _PortfolioBodyState();
}

class _PortfolioBodyState extends State<_PortfolioBody> {
  final GlobalKey _shareKey = GlobalKey();

  Future<void> _shareCard() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) {
      return;
    }
    await ShareCardService.captureAndShare(
      _shareKey,
      'afc_portfolio.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PortfolioPosition> sorted = List<PortfolioPosition>.of(
      widget.summary.positions,
    )..sort(
      (PortfolioPosition a, PortfolioPosition b) =>
          b.currentValue.compareTo(a.currentValue),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AppIconButton(
                onPressed: _shareCard,
                icon: const Icon(Icons.share_outlined, size: 18),
                tooltip: 'Compartilhar portfólio',
              ),
            ],
          ),
          _OverallCard(summary: widget.summary),
          const Gap(16),
          if (widget.summary.allocationByType.length > 1) ...<Widget>[
            const _SectionLabel('Alocação por tipo'),
            const Gap(8),
            _AllocationChart(allocation: widget.summary.allocationByType),
            const Gap(16),
          ],
          if (widget.summary.bestPerformer != null &&
              widget.summary.bestPerformer !=
                  widget.summary.worstPerformer) ...<Widget>[
            const _SectionLabel('Destaques'),
            const Gap(8),
            _HighlightCards(summary: widget.summary),
            const Gap(16),
          ],
          const _SectionLabel('Posições'),
          const Gap(8),
          for (final PortfolioPosition p in sorted) ...<Widget>[
            _PositionCard(position: p),
            const Gap(8),
          ],
          // ── Off-screen portfolio card for share capture ────────────────
          Offstage(
            child: RepaintBoundary(
              key: _shareKey,
              child: PortfolioShareCard(summary: widget.summary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overall summary card ─────────────────────────────────────────────────────

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final bool positive = summary.totalProfit >= 0;
    final Color profitColor = positive ? AppColors.income : AppColors.expense;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Valor total',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const Gap(4),
          Text(brl.format(summary.totalValue), style: AppTextStyles.title),
          const Gap(12),
          Row(
            children: <Widget>[
              _KpiCell(
                label: 'Investido',
                value: brl.format(summary.totalCost),
              ),
              const Gap(24),
              _KpiCell(
                label: positive ? 'Ganho' : 'Perda',
                value: brl.format(summary.totalProfit.abs()),
                color: profitColor,
              ),
              const Gap(24),
              _KpiCell(
                label: 'ROI',
                value:
                    '${positive ? '+' : ''}${summary.overallRoiPercent.toStringAsFixed(2)}%',
                color: profitColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
      ),
      const Gap(2),
      Text(
        value,
        style: AppTextStyles.labelBold.copyWith(color: color),
      ),
    ],
  );
}

// ─── Allocation donut ─────────────────────────────────────────────────────────

class _AllocationChart extends StatelessWidget {
  const _AllocationChart({required this.allocation});

  final Map<String, double> allocation;

  @override
  Widget build(BuildContext context) {
    final double total =
        allocation.values.fold(0, (double s, double v) => s + v);
    final List<MapEntry<String, double>> sorted = allocation.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                sections: sorted
                    .map(
                      (MapEntry<String, double> e) => PieChartSectionData(
                        value: e.value,
                        color: _colorFor(e.key),
                        radius: 28,
                        showTitle: false,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sorted
                  .map(
                    (MapEntry<String, double> e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _LegendRow(
                        label: _labelFor(e.key),
                        color: _colorFor(e.key),
                        percent: total > 0 ? e.value / total * 100 : 0,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.color,
    required this.percent,
  });

  final String label;
  final Color color;
  final double percent;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const Gap(6),
      Expanded(
        child: Text(label, style: AppTextStyles.caption),
      ),
      Text(
        '${percent.toStringAsFixed(1)}%',
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    ],
  );
}

// ─── Highlight cards (best / worst) ──────────────────────────────────────────

class _HighlightCards extends StatelessWidget {
  const _HighlightCards({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      if (summary.bestPerformer != null)
        Expanded(
          child: _HighlightTile(
            label: 'Melhor desempenho',
            position: summary.bestPerformer!,
            isPositive: true,
          ),
        ),
      if (summary.bestPerformer != null && summary.worstPerformer != null)
        const Gap(10),
      if (summary.worstPerformer != null)
        Expanded(
          child: _HighlightTile(
            label: 'Pior desempenho',
            position: summary.worstPerformer!,
            isPositive: false,
          ),
        ),
    ],
  );
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.label,
    required this.position,
    required this.isPositive,
  });

  final String label;
  final PortfolioPosition position;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final Color color = isPositive ? AppColors.income : AppColors.expense;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const Gap(4),
          Text(
            position.entity.name,
            style: AppTextStyles.labelBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          Text(
            '${isPositive && position.roiPercent >= 0 ? '+' : ''}'
            '${position.roiPercent.toStringAsFixed(2)}%',
            style: AppTextStyles.bodyBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Position list card ───────────────────────────────────────────────────────

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position});

  final PortfolioPosition position;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final bool positive = position.profit >= 0;
    final Color profitColor = positive ? AppColors.income : AppColors.expense;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          // Type colour dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _colorFor(position.entity.type),
              shape: BoxShape.circle,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(position.entity.name, style: AppTextStyles.labelBold),
                const Gap(2),
                Text(
                  _labelFor(position.entity.type),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(brl.format(position.currentValue),
                  style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                '${positive ? '+' : ''}${position.roiPercent.toStringAsFixed(2)}%',
                style: AppTextStyles.caption.copyWith(color: profitColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.labelBold.copyWith(color: AppColors.muted),
  );
}

// ─── Firestore loader (used from router) ──────────────────────────────────────

/// Loads portfolio data from Firestore for the given [userId].
/// Used by [PortfolioDashboardScreen] without depending on a global cubit.
Future<List<InvestmentEntity>> loadInvestmentsForUser(
  String userId, {
  FirebaseFirestore? firestore,
}) async {
  final FirebaseFirestore db = firestore ?? FirebaseFirestore.instance;
  final QuerySnapshot<Map<String, dynamic>> snap = await db
      .collection('investment')
      .where('userId', isEqualTo: userId)
      .get();
  return snap.docs
      .map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            InvestmentEntity.fromJson(doc.data()),
      )
      .toList();
}
