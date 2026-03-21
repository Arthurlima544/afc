import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;

import '../../domain/entity/stats_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../domain/entity/type_entity.dart';
import '../../utils/flavors.dart';
import '../../utils/logger.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/stats_state.dart';
import '../blocs/home/transaction_state.dart';
import '../blocs/limit/limit_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
    child: SingleChildScrollView(
      child: _HomeContent(),
    ),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      const Gap(20),
      if (Flavor.isDevelopment())
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            variance: const ButtonStyle.outline(),
            onPressed: () => context.push('/seed'),
            icon: const Icon(Icons.data_object, size: 20),
          ),
        ),
      const SyncStatusWidget(),
      const SummaryWidget(),
      const Gap(20),
      const LastTransactionsWidget(),
      const MonthLimitWidget(),
      const Gap(20),
      const StatsWidget(),
    ],
  ).withPadding(all: 20);
}

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          List<FlSpot> expenseSpots = <FlSpot>[const FlSpot(0, 0)];
          List<FlSpot> incomeSpots = <FlSpot>[const FlSpot(0, 0)];

          state.statsState.whenOrNull(
            success: (List<StatsEntity> stats) {
              final List<FlSpot> expenses = stats
                  .where((StatsEntity s) => s.type == TypeEntity.expense)
                  .map(
                    (StatsEntity s) =>
                        FlSpot(s.date.index.toDouble(), s.total),
                  )
                  .toList()
                ..sort((FlSpot a, FlSpot b) => a.x.compareTo(b.x));

              final List<FlSpot> income = stats
                  .where((StatsEntity s) => s.type == TypeEntity.income)
                  .map(
                    (StatsEntity s) =>
                        FlSpot(s.date.index.toDouble(), s.total),
                  )
                  .toList()
                ..sort((FlSpot a, FlSpot b) => a.x.compareTo(b.x));

              if (expenses.isNotEmpty) {
                expenseSpots = expenses;
              }
              if (income.isNotEmpty) {
                incomeSpots = income;
              }
            },
          );

          final double maxY = <FlSpot>[...expenseSpots, ...incomeSpots]
              .map((FlSpot s) => s.y)
              .fold(0.0, (double max, double y) => y > max ? y : max);
          final double yInterval =
              maxY > 0 ? (maxY / 5).ceilToDouble() : 500;

          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Estatísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/lista-transacoes'),
                    child: const Text(
                      'Ver Todas',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              LineChartSample7(
                line1Color: Colors.red,
                line2Color: Colors.green,
                expenseSpots: expenseSpots,
                incomeSpots: incomeSpots,
                yInterval: yInterval,
              ),
            ],
          );
        },
      );
}

class LineChartSample7 extends StatelessWidget {
  const LineChartSample7({
    required this.line1Color,
    required this.line2Color,
    required this.expenseSpots,
    required this.incomeSpots,
    required this.yInterval,
    super.key,
  });

  final Color line1Color;
  final Color line2Color;
  final List<FlSpot> expenseSpots;
  final List<FlSpot> incomeSpots;
  final double yInterval;

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Fev';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Abr';
        break;
      case 4:
        text = 'Mai';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Ago';
        break;
      case 8:
        text = 'Set';
        break;
      case 9:
        text = 'Out';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dez';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(fontSize: 10);

    String text;
    if (value >= 1000) {
      // format like 1k, 1.5k etc
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2,
    child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 18, top: 10, bottom: 4),
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: expenseSpots,
              color: line1Color,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: incomeSpots,
              color: line2Color,
              dotData: const FlDotData(show: false),
            ),
          ],
          betweenBarsData: <BetweenBarsData>[
            // BetweenBarsData(fromIndex: 0, toIndex: 1, color: betweenColor),
          ],
          minY: 0,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: leftTitleWidgets,
                interval: yInterval,
                reservedSize: 36,
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 1,
            checkToShowHorizontalLine: (double value) =>
                value == 1 || value == 6 || value == 4 || value == 5,
          ),
        ),
      ),
    ),
  );
}

class MonthLimitWidget extends StatelessWidget {
  const MonthLimitWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Limites do mês',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () => context.push('/lista-limites'),
            child: const Text(
              'Ver Todas',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
      const Gap(10),
      BlocBuilder<LimitCubit, LimitState>(
        builder: (BuildContext context, LimitState state) =>
            state.when(
              initial: (_) => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
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

  double get percent => amount / totalLimit;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      IconButton(
        variance: const ButtonStyle.primary(),
        onPressed: () => logger.d('percent: $percent'),
        enabled: true,
        shape: ButtonShape.circle,
        icon: Icon(icon, size: 24, color: Colors.white),
      ),
      const Gap(15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(category, style: const TextStyle(fontSize: 18)),
          const Gap(5),
          Text(
            '${convertToCurrencyFormated(amount)} de ${convertToCurrencyFormated(totalLimit)}',
            style: const TextStyle(fontSize: 14),
          ),
          const Gap(5),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: percent > 0.5 ? Colors.red : Colors.green,
              value: percent,
              minHeight: 3,
            ),
          ),
        ],
      ),
      const Gap(5),
    ],
  );
}

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeBloc, HomeState>(
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
          const Text(
            'Transações Recentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () => context.push('/lista-transacoes'),
            child: const Text(
              'Ver Todas',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
      const Gap(10),
      BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) =>
            state.transactionState.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: Text.new,
              success: (List<TransactionEntity> transactions) => Column(
                children: <Widget>[
                  for (final TransactionEntity tx in transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LastTransactions(
                        category: tx.title,
                        amount: tx.typeUuid == TypeEntity.income.name
                            ? tx.amount
                            : -tx.amount,
                        icon: Icons.attach_money,
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
    required this.icon,
    super.key,
  });

  final String category;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      IconButton(
        variance: const ButtonStyle.primary(),
        enabled: true,
        shape: ButtonShape.circle,
        icon: Icon(icon, size: 24, color: Colors.white),
      ),
      const Gap(15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(category, style: const TextStyle(fontSize: 18)),
            Text(
              convertToCurrencyFormated(amount),
              style: TextStyle(
                fontSize: 14,
                color: amount < 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    ],
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
  Widget build(BuildContext context) => Card(
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
            IconButton(
              variance: const ButtonStyle.primary().withBackgroundColor(
                color: backgroundColor,
              ),
              enabled: true,
              shape: ButtonShape.circle,
              icon: Icon(icon, size: iconSize, color: iconColor),
            ),
            Gap(gapSize),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
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
                      color: Colors.gray,
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
        IconButton(
          variance: const ButtonStyle.outline(),
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
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data!.docs;

        DateTime? mostRecent;
        bool hasExpired = false;

        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
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
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> pendingSnap,
          ) {
            final int pendingCount =
                pendingSnap.hasData ? pendingSnap.data!.docs.length : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
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
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/contas-conectadas'),
                            child: const Text(
                              'Open Finance',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
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
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.warning_amber,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                Gap(4),
                                Text(
                                  'Consentimento expirado — reconecte',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF92400E),
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
                              fontSize: 13,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
