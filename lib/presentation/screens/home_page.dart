import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/bill_entity.dart';
import '../../domain/entity/investment_entity.dart';
import '../../domain/entity/market_quote_entity.dart';
import '../../domain/entity/stats_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../domain/usecase/health_score.dart';
import '../../utils/connectivity_service.dart';
import '../../utils/flavors.dart';
import '../../utils/sync_queue.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/fi_score/fi_score_cubit.dart';
import '../blocs/health_score/health_score_cubit.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/stats_state.dart';
import '../blocs/home/transaction_state.dart';
import '../blocs/limit/limit_cubit.dart';
import '../blocs/market/market_opportunity_cubit.dart';
import '../blocs/privacy/privacy_cubit.dart';
import '../widgets/design_system.dart';
import '../widgets/privacy_text.dart';
import '../widgets/skeleton_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const SafeArea(child: SingleChildScrollView(child: _HomeContent()));
}

// ---------------------------------------------------------------------------
// Settings badge
// ---------------------------------------------------------------------------

class _SettingsBadge extends StatelessWidget {
  const _SettingsBadge({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: SyncQueue.instance.countStream,
    initialData: SyncQueue.instance.count,
    builder: (BuildContext context, AsyncSnapshot<int> snap) {
      final int count = snap.data ?? 0;
      return Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: AppIconButton(
          onPressed: onPressed,
          icon: const Icon(AppIcons.settings, size: 20),
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: <Widget>[
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (Flavor.isDevelopment())
              AppIconButton(
                onPressed: () => context.push('/seed'),
                icon: const Icon(Icons.data_object, size: 20),
              ),
            BlocBuilder<PrivacyCubit, bool>(
              builder: (BuildContext context, bool isHidden) => Semantics(
                label: isHidden ? 'Mostrar valores' : 'Ocultar valores',
                child: AppIconButton(
                  onPressed: () => context.read<PrivacyCubit>().toggle(),
                  icon: Icon(
                    isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'Configurações',
              child: _SettingsBadge(onPressed: () => context.push('/settings')),
            ),
          ],
        ),
        const SyncStatusWidget(),
        const SummaryWidget(),
        const Gap(12),
        const _NetWorthCard(),
        const Gap(12),
        const _BillsCard(),
        const Gap(12),
        const _HealthScoreCard(),
        const Gap(12),
        const _FiScoreCard(),
        const Gap(20),
        const LastTransactionsWidget(),
        const MonthLimitWidget(),
        const Gap(20),
        const StatsWidget(),
        const Gap(12),
        const _MarketOpportunitiesCard(),
        const Gap(12),
        const _FireCard(),
        const Gap(8),
        const _CompoundInterestCard(),
        const Gap(8),
        const _PortfolioCard(),
        const Gap(8),
        const _PassiveIncomeCard(),
        const Gap(8),
        const _PatrimonioCard(),
        const Gap(8),
        const _InvestmentGoalCard(),
        const Gap(20),
      ],
    ),
  );
}

class _NetWorthCard extends StatefulWidget {
  const _NetWorthCard();

  @override
  State<_NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends State<_NetWorthCard> {
  double _portfolioValue = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadPortfolio);
  }

  Future<void> _loadPortfolio() async {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';
    if (userId.isEmpty) {
      return;
    }
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('investment')
          .where('userId', isEqualTo: userId)
          .get();

      final List<InvestmentEntity> investments = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                InvestmentEntity.fromJson(doc.data()),
          )
          .toList();

      final double total = investments.fold(
        0.0,
        (double sum, InvestmentEntity inv) =>
            sum + inv.quantity * inv.currentPrice,
      );

      if (mounted) {
        setState(() {
          _portfolioValue = total;
          _loaded = true;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _loaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _portfolioValue == 0) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () => context.push('/lista-investimentos'),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.trending_up, size: 28),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Carteira de investimentos',
                    style: AppTextStyles.label,
                  ),
                  PrivacyText(
                    convertToCurrencyFormated(_portfolioValue),
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (BuildContext context, HomeState state) {
      double totalIncome = 0;
      double totalExpenses = 0;

      state.statsState.whenOrNull(
        success: (List<StatsEntity> stats) {
          totalIncome = stats
              .where((StatsEntity s) => s.type == TypeEntity.income)
              .fold(0.0, (double sum, StatsEntity s) => sum + s.total);
          totalExpenses = stats
              .where((StatsEntity s) => s.type == TypeEntity.expense)
              .fold(0.0, (double sum, StatsEntity s) => sum + s.total);
        },
      );

      final double savingsRate = totalIncome > 0
          ? ((totalIncome - totalExpenses) / totalIncome * 100).clamp(0, 100)
          : 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Resumo do mês', style: AppTextStyles.sectionTitle),
              TextButton(
                onPressed: () => context.push('/relatorio'),
                child: const Text(
                  'Ver relatório',
                  style: TextStyle(
                    fontSize: AppTextStyle.sizeMd,
                    color: AppColors.link,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatCell(
                    label: 'Taxa de poupança',
                    value: '${savingsRate.toStringAsFixed(0)}%',
                    valueColor: savingsRate >= 20
                        ? AppColors.income
                        : savingsRate >= 10
                        ? AppColors.warning
                        : AppColors.expense,
                  ),
                ),
                _divider(),
                Expanded(
                  child: _StatCell(
                    label: 'Receita do mês',
                    value: convertToCurrencyFormated(totalIncome),
                    valueColor: AppColors.income,
                    private: true,
                  ),
                ),
                _divider(),
                Expanded(
                  child: _StatCell(
                    label: 'Gastos do mês',
                    value: convertToCurrencyFormated(totalExpenses),
                    valueColor: AppColors.expense,
                    private: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: const Color(0xFF3A3A3A),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.private = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool private;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      if (private)
        PrivacyText(
          value,
          style: TextStyle(
            fontSize: AppTextStyle.sizeMd,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        )
      else
        Text(
          value,
          style: TextStyle(
            fontSize: AppTextStyle.sizeMd,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      const Gap(4),
      Text(
        label,
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class MonthLimitWidget extends StatefulWidget {
  const MonthLimitWidget({super.key});

  @override
  State<MonthLimitWidget> createState() => _MonthLimitWidgetState();
}

class _MonthLimitWidgetState extends State<MonthLimitWidget> {
  bool _overspendAlerted = false;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Limites do mês', style: AppTextStyles.sectionTitle),
          TextButton(
            onPressed: () => context.go('/lista-limites'),
            child: const Text(
              'Ver Todas',
              style: TextStyle(
                fontSize: AppTextStyle.sizeMd,
                color: AppColors.link,
              ),
            ),
          ),
        ],
      ),
      const Gap(10),
      BlocConsumer<LimitCubit, LimitState>(
        listenWhen: (LimitState _, LimitState next) =>
            next.whenOrNull(loaded: (_) => true) == true,
        listener: (BuildContext context, LimitState state) {
          state.whenOrNull(
            loaded: (List<LimitProgressItem> items) {
              final bool hasOverspend = items.any(
                (LimitProgressItem i) => i.spent > i.limitAmount,
              );
              if (hasOverspend && !_overspendAlerted) {
                _overspendAlerted = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Limite excedido! Você ultrapassou o limite em uma ou mais categorias.',
                    ),
                  ),
                );
              }
            },
          );
        },
        builder: (BuildContext context, LimitState state) => state.when(
          initial: (_) => const SizedBox(),
          loading: () => const SkeletonList(itemCount: 2),
          error: Text.new,
          success: (_) => const SizedBox(),
          listed: (_) => const SizedBox(),
          loaded: (List<LimitProgressItem> items) => items.isEmpty
              ? const SizedBox()
              : Column(
                  children: <Widget>[
                    for (final LimitProgressItem item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MonthLimit(
                          category: item.categoryName,
                          amount: item.spent,
                          icon: _iconFromType(item.iconType),
                          totalLimit: item.limitAmount,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    ],
  );
}

class MonthLimit extends StatelessWidget {
  const MonthLimit({
    required this.category,
    required this.amount,
    required this.icon,
    required this.totalLimit,
    super.key,
  });

  final String category;
  final double amount;
  final double totalLimit;
  final IconData icon;

  bool get isExceeded => amount > totalLimit;
  double get percent => (amount / totalLimit).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isExceeded ? AppColors.expense : AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          isExceeded ? Icons.warning_amber_rounded : icon,
          size: 24,
          color: AppColors.onPrimary,
        ),
      ),
      const Gap(15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(category, style: AppTextStyles.sectionTitle),
          const Gap(5),
          PrivacyText(
            '${convertToCurrencyFormated(amount)} de ${convertToCurrencyFormated(totalLimit)}',
            style: AppTextStyles.body.copyWith(
              color: isExceeded ? AppColors.expense : null,
            ),
          ),
          const Gap(5),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: isExceeded
                  ? AppColors.expense
                  : percent > 0.5
                  ? AppColors.warning
                  : AppColors.income,
              value: percent,
              minHeight: 3,
            ),
          ),
          if (isExceeded) ...<Widget>[
            const Gap(4),
            const Text(
              'Limite excedido!',
              style: TextStyle(
                fontSize: AppTextStyle.sizeXs,
                color: AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      const Gap(5),
    ],
  );
}

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (BuildContext context, HomeState state) {
      double totalIncome = 0;
      double totalExpenses = 0;

      state.statsState.whenOrNull(
        success: (List<StatsEntity> stats) {
          totalIncome = stats
              .where((StatsEntity s) => s.type == TypeEntity.income)
              .fold(0.0, (double sum, StatsEntity s) => sum + s.total);
          totalExpenses = stats
              .where((StatsEntity s) => s.type == TypeEntity.expense)
              .fold(0.0, (double sum, StatsEntity s) => sum + s.total);
        },
      );

      final double balance = totalIncome - totalExpenses;

      return Column(
        children: <Widget>[
          HomeCard(
            title: 'Saldo',
            totalAmount: balance,
            icon: Icons.savings_outlined,
            backgroundColor: const Color(0xFFDCE1FF),
            iconColor: Colors.black,
          ),
          const Gap(20),
          Row(
            children: <Widget>[
              Expanded(
                child: HomeCard(
                  title: 'Entradas',
                  totalAmount: totalIncome,
                  icon: Icons.attach_money,
                  backgroundColor: const Color(0xFFBDECB5),
                  iconColor: Colors.black,
                ),
              ),
              const Gap(5),
              Expanded(
                child: HomeCard(
                  title: 'Despesas',
                  totalAmount: totalExpenses,
                  icon: Icons.currency_exchange,
                  backgroundColor: const Color(0xFFFFDAD6),
                  iconColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class LastTransactionsWidget extends StatelessWidget {
  const LastTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Transações Recentes', style: AppTextStyles.sectionTitle),
          TextButton(
            onPressed: () => context.go('/lista-transacoes'),
            child: const Text(
              'Ver Todas',
              style: TextStyle(
                fontSize: AppTextStyle.sizeMd,
                color: AppColors.link,
              ),
            ),
          ),
        ],
      ),
      const Gap(10),
      BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) =>
            state.transactionState.when(
              initial: () => const SizedBox(),
              loading: () => const SkeletonList(itemCount: 3),
              error: Text.new,
              success: (List<TransactionEntity> transactions) => Column(
                children: <Widget>[
                  for (final TransactionEntity tx in transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LastTransactions(
                        category: tx.title,
                        amount: tx.typeUuid == TypeEntity.income.name
                            ? tx.amount
                            : -tx.amount,
                      ),
                    ),
                ],
              ),
            ),
      ),
    ],
  );
}

class LastTransactions extends StatelessWidget {
  const LastTransactions({
    required this.category,
    required this.amount,
    super.key,
  });

  final String category;
  final double amount;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: amount >= 0
                ? AppColors.income.withValues(alpha: 0.15)
                : AppColors.expense.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
            size: 18,
            color: amount >= 0 ? AppColors.income : AppColors.expense,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            category,
            style: AppTextStyles.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PrivacyText(
          convertToCurrencyFormated(amount),
          style: TextStyle(
            fontSize: AppTextStyle.sizeMd,
            fontWeight: FontWeight.w600,
            color: amount >= 0 ? AppColors.income : AppColors.expense,
          ),
        ),
      ],
    ),
  );
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.title,
    required this.totalAmount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    super.key,
  });

  final String title;
  final double totalAmount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth;

        const double baseCardWidth = 180.0;

        final double scaleFactor = (cardWidth / baseCardWidth).clamp(0.75, 1.2);

        final double iconSize = 24.0 * scaleFactor;
        final double gapSize = 15.0 * scaleFactor;
        final double largeFontSize = 18.0 * scaleFactor;
        final double smallFontSize = 14.0 * scaleFactor;

        return Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
            Gap(gapSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PrivacyText(
                    convertToCurrencyFormated(totalAmount),
                    style: TextStyle(
                      fontSize: largeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      // user icon
      const Icon(Icons.person, size: 40),
      const Gap(10),
      const Text('Welcome, User!', style: TextStyle(fontSize: 20)),
      const Gap(10),
      const Icon(Icons.notifications, size: 30),
      const Gap(10),
      const Icon(Icons.settings, size: 30),
      const Gap(10),
      if (Flavor.isDevelopment()) ...<Widget>[
        const Gap(10),
        AppIconButton(
          onPressed: () => context.push('/seed'),
          icon: const Icon(Icons.data_object, size: 20),
        ),
      ],
    ],
  );
}

final List<IconData> _categoryIcons = <IconData>[
  Icons.share_outlined,
  Icons.play_arrow_rounded,
  Icons.local_taxi,
  Icons.star_border,
  Icons.camera_alt_outlined,
  Icons.calendar_month,
  Icons.file_upload_outlined,
  Icons.coffee,
  Icons.savings,
  Icons.access_time_rounded,
  Icons.heart_broken,
  Icons.compare_arrows_rounded,
];

IconData _iconFromType(int iconType) =>
    (iconType >= 0 && iconType < _categoryIcons.length)
    ? _categoryIcons[iconType]
    : Icons.category;

String convertToCurrencyFormated(double amount) {
  final NumberFormat format = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  return format.format(amount);
}

// ---------------------------------------------------------------------------
// Health Score Card (US-27)
// ---------------------------------------------------------------------------

Color _scoreColor(int score) {
  if (score >= 70) {
    return AppColors.income;
  }
  if (score >= 40) {
    return AppColors.warning;
  }
  return AppColors.expense;
}

String _scoreLabel(int score) {
  if (score >= 70) {
    return 'Excelente';
  }
  if (score >= 40) {
    return 'Regular';
  }
  return 'Atenção';
}

class _HealthScoreCard extends StatefulWidget {
  const _HealthScoreCard();

  @override
  State<_HealthScoreCard> createState() => _HealthScoreCardState();
}

class _HealthScoreCardState extends State<_HealthScoreCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HealthScoreCubit, HealthScoreState>(
        builder: (BuildContext context, HealthScoreState state) => state.when(
          initial: () => const SizedBox(),
          loading: () => const AppCard(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (String msg) => AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erro ao carregar score: $msg',
              style: const TextStyle(
                fontSize: AppTextStyle.sizeSm,
                color: AppColors.expense,
              ),
            ),
          ),
          success: (HealthScoreData data) => AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Saúde Financeira',
                            style: AppTextStyles.sectionTitle,
                          ),
                          const Gap(2),
                          Text(
                            _scoreLabel(data.score),
                            style: TextStyle(
                              fontSize: AppTextStyle.sizeSm,
                              color: _scoreColor(data.score),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${data.score}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor(data.score),
                      ),
                    ),
                    const Gap(4),
                    const Text(
                      '/100',
                      style: TextStyle(
                        fontSize: AppTextStyle.sizeSm,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // Sparkline — last 6 months
                _HealthSparkline(scores: data.last6MonthScores),

                const Gap(12),

                // Expand/collapse toggle
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: <Widget>[
                      const Text(
                        'Detalhes',
                        style: TextStyle(
                          fontSize: AppTextStyle.sizeSm,
                          color: AppColors.link,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.link,
                      ),
                    ],
                  ),
                ),

                if (_expanded) ...<Widget>[
                  const Gap(10),
                  _ScoreRow(
                    label: 'Poupança',
                    points: data.savingsPoints,
                    tooltip: 'Taxa de poupança (renda − despesas) / renda',
                  ),
                  const Gap(6),
                  _ScoreRow(
                    label: 'Limites',
                    points: data.limitPoints,
                    tooltip: 'Média de gasto/limite por categoria',
                  ),
                  const Gap(6),
                  _ScoreRow(
                    label: 'Metas',
                    points: data.goalPoints,
                    tooltip: 'Progresso médio das metas ativas',
                  ),
                  const Gap(6),
                  _ScoreRow(
                    label: 'Variação',
                    points: data.variancePoints,
                    tooltip: 'Variação de gastos em relação ao mês anterior',
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.points,
    required this.tooltip,
  });

  final String label;
  final int points;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Text(label, style: AppTextStyles.bodyBold),
      const Gap(4),
      AppTooltipIcon(tooltip),
      const Spacer(),
      Text(
        '$points / 25',
        style: TextStyle(
          fontSize: AppTextStyle.sizeSm,
          fontWeight: FontWeight.w600,
          color: _scoreColor(points * 4),
        ),
      ),
    ],
  );
}

class _HealthSparkline extends StatelessWidget {
  const _HealthSparkline({required this.scores});

  final List<int> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const SizedBox();
    }

    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < scores.length; i++)
        FlSpot(i.toDouble(), scores[i].toDouble()),
    ];

    return SizedBox(
      height: 48,
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(),
            leftTitles: AxisTitles(),
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
          ),
          minY: 0,
          maxY: 100,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.income,
              dotData: FlDotData(
                getDotPainter:
                    (
                      FlSpot spot,
                      double xPercentage,
                      LineChartBarData bar,
                      int index,
                    ) => FlDotCirclePainter(
                      radius: 3,
                      color: _scoreColor(spot.y.toInt()),
                      strokeColor: _scoreColor(spot.y.toInt()),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FI Score card
// ---------------------------------------------------------------------------

class _FiScoreCard extends StatelessWidget {
  const _FiScoreCard();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FiScoreCubit, FiScoreState>(
        builder: (BuildContext context, FiScoreState state) => state.when(
          initial: () => const SizedBox(),
          loading: () => const AppCard(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (String msg) => AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erro ao carregar score IF: $msg',
              style: const TextStyle(
                fontSize: AppTextStyle.sizeSm,
                color: AppColors.expense,
              ),
            ),
          ),
          success: (FiScoreData data) => AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Row(
                            children: <Widget>[
                              Text(
                                'Independência Financeira',
                                style: AppTextStyles.sectionTitle,
                              ),
                              Gap(6),
                              AppTooltipIcon(
                                'Renda passiva ÷ despesas mensais × 100. '
                                '100% significa que sua renda passiva cobre todas as despesas.',
                              ),
                            ],
                          ),
                          const Gap(2),
                          Text(
                            _fiLabel(data.fiScore),
                            style: TextStyle(
                              fontSize: AppTextStyle.sizeSm,
                              color: _fiColor(data.fiScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${data.fiScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _fiColor(data.fiScore),
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // Sparkline
                _FiSparkline(scores: data.last6Scores),

                const Gap(12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (data.fiScore / 100).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        AppColors.muted.withValues(alpha: 0.2),
                    color: _fiColor(data.fiScore),
                  ),
                ),

                const Gap(8),

                // Income vs expenses caption
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PrivacyText(
                      'Renda passiva: ${NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0).format(data.passiveIncomeMonthly)}/mês',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted),
                    ),
                    PrivacyText(
                      'Despesas: ${NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0).format(data.monthlyExpenses)}/mês',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted),
                    ),
                  ],
                ),

                const Gap(12),

                // Milestone badges
                Row(
                  children: <int>[10, 25, 50, 75, 100]
                      .map<Widget>(
                        (int m) => _MilestoneBadge(
                          value: m,
                          achieved: data.fiScore >= m,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
}

Color _fiColor(double score) {
  if (score >= 75) {
    return AppColors.income;
  }
  if (score >= 25) {
    return AppColors.warning;
  }
  return AppColors.expense;
}

String _fiLabel(double score) {
  if (score >= 100) {
    return 'FIRE Atingido';
  }
  if (score >= 75) {
    return 'Próximo do FIRE';
  }
  if (score >= 50) {
    return 'Metade do caminho';
  }
  if (score >= 25) {
    return 'Em progresso';
  }
  return 'Início da jornada';
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.value, required this.achieved});

  final int value;
  final bool achieved;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: achieved
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: achieved
            ? AppColors.primary
            : AppColors.muted.withValues(alpha: 0.3),
        width: achieved ? 1.5 : 1,
      ),
    ),
    child: Text(
      '$value%',
      style: AppTextStyles.caption.copyWith(
        color: achieved ? AppColors.primary : AppColors.muted,
        fontWeight: achieved ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}

class _FiSparkline extends StatelessWidget {
  const _FiSparkline({required this.scores});

  final List<double> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const SizedBox();
    }
    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < scores.length; i++)
        FlSpot(i.toDouble(), scores[i]),
    ];
    return SizedBox(
      height: 40,
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(),
            leftTitles: AxisTitles(),
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
          ),
          minY: 0,
          maxY: 100,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              dotData: FlDotData(
                getDotPainter:
                    (
                      FlSpot spot,
                      double xPercentage,
                      LineChartBarData bar,
                      int index,
                    ) => FlDotCirclePainter(
                      radius: 3,
                      color: _fiColor(spot.y),
                      strokeColor: _fiColor(spot.y),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BillsCard extends StatefulWidget {
  const _BillsCard();

  @override
  State<_BillsCard> createState() => _BillsCardState();
}

class _BillsCardState extends State<_BillsCard> {
  int _dueThisMonth = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadBills);
  }

  Future<void> _loadBills() async {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';
    if (userId.isEmpty) {
      return;
    }
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection('bill')
          .where('userId', isEqualTo: userId)
          .get();

      final DateTime now = DateTime.now();
      final int today = now.day;

      final List<BillEntity> bills = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                BillEntity.fromJson(doc.data()),
          )
          .toList();

      final int dueThisMonth = bills
          .where((BillEntity b) => b.dueDay >= today)
          .length;

      if (mounted) {
        setState(() {
          _dueThisMonth = dueThisMonth;
          _loaded = true;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _loaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () => context.push('/lista-contas'),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.receipt_long_outlined, size: 28),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Contas a pagar', style: AppTextStyles.label),
                  Text(
                    _dueThisMonth == 0
                        ? 'Nenhuma conta pendente'
                        : '$_dueThisMonth conta(s) este mês',
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  String _formatSyncTime(DateTime? lastSynced) {
    if (lastSynced == null) {
      return 'Nunca sincronizado';
    }
    final Duration diff = DateTime.now().difference(lastSynced);
    if (diff.inMinutes < 1) {
      return 'agora';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min atrás';
    }
    return '${diff.inHours}h atrás';
  }

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.watch<AuthBloc>().state.whenOrNull(
          signedIn: (ClerkAuthState s) => s.user?.id,
        ) ??
        '';

    if (userId.isEmpty) {
      return const SizedBox();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('connected_account')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.account_balance_outlined, size: 18),
                      const Gap(8),
                      const Expanded(
                        child: Text(
                          'Nenhum banco conectado',
                          style: AppTextStyles.label,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/contas-conectadas'),
                        child: const Text(
                          'Conectar banco',
                          style: TextStyle(
                            fontSize: AppTextStyle.sizeSm,
                            color: AppColors.link,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;

            DateTime? mostRecent;
            bool hasExpired = false;

            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in docs) {
              final dynamic rawSynced = doc.data()['lastSyncedAt'];
              if (rawSynced is Timestamp) {
                final DateTime dt = rawSynced.toDate();
                if (mostRecent == null || dt.isAfter(mostRecent)) {
                  mostRecent = dt;
                }
              }
              final dynamic status = doc.data()['status'];
              if (status == 'consent_expired') {
                hasExpired = true;
              }
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('raw_transaction')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    pendingSnap,
                  ) {
                    final int pendingCount = pendingSnap.hasData
                        ? pendingSnap.data!.docs.length
                        : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(Icons.sync, size: 18),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    'Última sincronização: ${_formatSyncTime(mostRecent)}',
                                    style: AppTextStyles.label,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/contas-conectadas'),
                                  child: const Text(
                                    'Open Finance',
                                    style: TextStyle(
                                      fontSize: AppTextStyle.sizeSm,
                                      color: AppColors.link,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hasExpired) ...<Widget>[
                              const Gap(6),
                              GestureDetector(
                                onTap: () => context.push('/contas-conectadas'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.warning_amber,
                                        size: 14,
                                        color: AppColors.warning,
                                      ),
                                      Gap(4),
                                      Text(
                                        'Consentimento expirado — reconecte',
                                        style: TextStyle(
                                          fontSize: AppTextStyle.sizeXs,
                                          color: AppColors.warningText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (pendingCount > 0) ...<Widget>[
                              const Gap(6),
                              TextButton(
                                onPressed: () =>
                                    context.push('/revisar-transacoes'),
                                child: Text(
                                  'Revisar $pendingCount importação(ões) pendente(s)',
                                  style: const TextStyle(
                                    fontSize: AppTextStyle.sizeSm,
                                    color: AppColors.link,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
            );
          },
    );
  }
}

// ─── Market Opportunities Card ─────────────────────────────────────────────────

/// Shows the top 3 dividend-paying stocks from Brapi with a link to
/// the full opportunities screen.
class _MarketOpportunitiesCard extends StatelessWidget {
  const _MarketOpportunitiesCard();

  @override
  Widget build(BuildContext context) {
    if (!ConnectivityService.instance.isOnline) {
      return const OfflineUnavailableCard(
        message: 'Oportunidades de mercado indisponíveis sem conexão',
      );
    }
    return BlocProvider<MarketOpportunityCubit>(
      create: (_) => MarketOpportunityCubit()..load(),
      child: BlocBuilder<MarketOpportunityCubit, MarketOpportunityState>(
        builder: (BuildContext ctx, MarketOpportunityState state) => state.when(
          initial: () => const SizedBox(),
          loading: () => const AppCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Oportunidades do Mercado',
                style: AppTextStyles.title,
              ),
              Gap(12),
              Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
        error: (_) => const SizedBox(),
        loaded: (
          List<MarketQuoteEntity> quotes,
          double cdiRate,
          DateTime _,
        ) {
          final List<MarketQuoteEntity> top = quotes.take(3).toList();
          return AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'Oportunidades do Mercado',
                      style: AppTextStyles.title,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/oportunidades'),
                      child: Text(
                        'Ver todas',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'CDI: ${cdiRate.toStringAsFixed(2)}% a.a.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const Gap(12),
                for (final MarketQuoteEntity q in top) ...<Widget>[
                  _MiniQuoteRow(quote: q, cdiRate: cdiRate),
                  const Gap(8),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
  }
}

// ─── FIRE card ────────────────────────────────────────────────────────────────

class _FireCard extends StatelessWidget {
  const _FireCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.income.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.savings_outlined,
            color: AppColors.income,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Calculadora FIRE', style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'Descubra seu número para aposentadoria antecipada',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/fire-calculadora'),
        ),
      ],
    ),
  );
}

// ─── Compound Interest card ───────────────────────────────────────────────────

class _CompoundInterestCard extends StatelessWidget {
  const _CompoundInterestCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.trending_up,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Simulador de Juros Compostos',
                  style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'Veja o poder dos aportes mensais ao longo do tempo',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/juros-compostos'),
        ),
      ],
    ),
  );
}

// ─── Portfolio performance card ───────────────────────────────────────────────

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.pie_chart_outline,
            color: Color(0xFF42A5F5),
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Performance do Portfólio',
                  style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'ROI, alocação e destaques de rentabilidade',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/portfolio-dashboard'),
        ),
      ],
    ),
  );
}

// ─── Passive income card ──────────────────────────────────────────────────────

class _PassiveIncomeCard extends StatelessWidget {
  const _PassiveIncomeCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.income.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.income,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Renda Passiva', style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'Dividendos, juros e outras fontes mensais',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/renda-passiva'),
        ),
      ],
    ),
  );
}

class _PatrimonioCard extends StatelessWidget {
  const _PatrimonioCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.show_chart,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Patrimônio Líquido', style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'Evolução mensal de ativos e passivos',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/patrimonio'),
        ),
      ],
    ),
  );
}

class _InvestmentGoalCard extends StatelessWidget {
  const _InvestmentGoalCard();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.income.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flag_outlined,
            color: AppColors.income,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Planejador de Meta',
                style: AppTextStyles.labelBold,
              ),
              const Gap(2),
              Text(
                'Calcule o aporte mensal para atingir sua meta',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Gap(8),
        AppIconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          onPressed: () => context.push('/meta-investimento'),
        ),
      ],
    ),
  );
}

class _MiniQuoteRow extends StatelessWidget {
  const _MiniQuoteRow({required this.quote, required this.cdiRate});

  final MarketQuoteEntity quote;
  final double cdiRate;

  @override
  Widget build(BuildContext context) {
    final double ratio = quote.dyVsCdi(cdiRate);
    final bool isUp = quote.changePercent >= 0;
    return Row(
      children: <Widget>[
        Text(quote.ticker, style: AppTextStyles.labelBold),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: quote.isFii
                ? AppColors.primaryLight.withValues(alpha: 0.15)
                : AppColors.income.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            quote.isFii ? 'FII' : 'Ação',
            style: AppTextStyles.caption.copyWith(
              color: quote.isFii ? AppColors.primaryLight : AppColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'DY ${quote.dividendYield.toStringAsFixed(1)}%',
          style: AppTextStyles.labelBold.copyWith(
            color: quote.dividendYield > cdiRate
                ? AppColors.income
                : AppColors.muted,
          ),
        ),
        const Gap(8),
        Text(
          '${ratio.toStringAsFixed(1)}× CDI',
          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
        ),
        const Gap(8),
        Icon(
          isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 16,
          color: isUp ? AppColors.income : AppColors.expense,
        ),
      ],
    );
  }
}
