import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/market_quote_entity.dart';
import '../../domain/entity/watchlist_entity.dart';
import '../../utils/connectivity_service.dart';
import '../blocs/watchlist/watchlist_cubit.dart';
import '../blocs/watchlist/watchlist_item.dart';
import '../widgets/design_system.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';

class ListaWatchlist extends StatelessWidget {
  const ListaWatchlist({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    if (!ConnectivityService.isOnlineSafe) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: const Text('Watchlist'),
          centerTitle: false,
        ),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: OfflineUnavailableCard(
            message: 'Watchlist indisponível sem conexão à internet',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Watchlist'),
        centerTitle: false,
        actions: <Widget>[
          AppIconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar ativo',
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (BuildContext context, WatchlistState state) => state.when(
          initial: () => const SizedBox(),
          loading: () => const SkeletonList(),
          error: (String msg) => ErrorState(
            message: msg,
            onRetry: () =>
                context.read<WatchlistCubit>().loadWatchlist(userId),
          ),
          loaded: (List<WatchlistItem> items, DateTime lastUpdated) =>
              items.isEmpty
                  ? const EmptyState(
                      message:
                          'Nenhum ativo na watchlist.\nToque em + para adicionar.',
                    )
                  : _WatchlistBody(
                      items: items,
                      lastUpdated: lastUpdated,
                      userId: userId,
                    ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final String? ticker = await showInputDialog(
      context: context,
      title: 'Adicionar ativo',
      hintText: 'Ex: PETR4, HGLG11',
    );
    if (ticker == null || ticker.trim().isEmpty || !context.mounted) {
      return;
    }
    unawaited(
      context.read<WatchlistCubit>().addTicker(ticker.trim()),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _WatchlistBody extends StatelessWidget {
  const _WatchlistBody({
    required this.items,
    required this.lastUpdated,
    required this.userId,
  });

  final List<WatchlistItem> items;
  final DateTime lastUpdated;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final Duration diff = DateTime.now().difference(lastUpdated);
    final String timeLabel = diff.inSeconds < 60
        ? 'agora'
        : diff.inMinutes < 60
            ? 'há ${diff.inMinutes} min'
            : 'há ${diff.inHours} h';

    return RefreshIndicator(
      onRefresh: () => context.read<WatchlistCubit>().refresh(),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Atualizado $timeLabel  ·  ${items.length} ativo${items.length == 1 ? '' : 's'}',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Gap(10),
              itemBuilder: (BuildContext ctx, int i) =>
                  _WatchlistCard(item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({required this.item});

  final WatchlistItem item;

  @override
  Widget build(BuildContext context) {
    final WatchlistEntity entity = item.entity;
    final MarketQuoteEntity? quote = item.quote;

    return Dismissible(
      key: Key(entity.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      onDismissed: (_) {
        context.read<WatchlistCubit>().removeTicker(entity.uuid);
      },
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Ticker + type badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(entity.ticker, style: AppTextStyles.bodyBold),
                        if (item.alertTriggered) ...<Widget>[
                          const Gap(6),
                          const Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                    const Gap(2),
                    if (quote != null)
                      _TypeBadge(isFii: quote.isFii)
                    else
                      _TypeBadge(
                        isFii: entity.ticker.endsWith('11'),
                      ),
                  ],
                ),
                const Spacer(),
                // Price column
                if (quote != null) _PriceColumn(quote: quote),
              ],
            ),
            // ── Name ────────────────────────────────────────────────────────
            if (quote != null && quote.name != entity.ticker) ...<Widget>[
              const Gap(6),
              Text(
                quote.name,
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // ── Sparkline ───────────────────────────────────────────────────
            if (item.sparkline.length >= 2) ...<Widget>[
              const Gap(10),
              SizedBox(
                height: 36,
                child: _Sparkline(closes: item.sparkline),
              ),
            ],
            // ── Metrics row ─────────────────────────────────────────────────
            if (quote != null) ...<Widget>[
              const Gap(10),
              _MetricsRow(quote: quote, entity: entity),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isFii});

  final bool isFii;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: isFii
          ? AppColors.primaryLight.withValues(alpha: 0.15)
          : AppColors.income.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      isFii ? 'FII' : 'Ação',
      style: AppTextStyles.caption.copyWith(
        color: isFii ? AppColors.primaryLight : AppColors.income,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({required this.quote});

  final MarketQuoteEntity quote;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final bool isUp = quote.changePercent >= 0;
    final Color changeColor = isUp ? AppColors.income : AppColors.expense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(brl.format(quote.price), style: AppTextStyles.bodyBold),
        const Gap(2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
              color: changeColor,
            ),
            Text(
              '${quote.changePercent.abs().toStringAsFixed(2)}%',
              style: AppTextStyles.caption.copyWith(color: changeColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.closes});

  final List<double> closes;

  @override
  Widget build(BuildContext context) {
    final double minY =
        closes.reduce((double a, double b) => a < b ? a : b) * 0.999;
    final double maxY =
        closes.reduce((double a, double b) => a > b ? a : b) * 1.001;
    final bool positive = closes.last >= closes.first;
    final Color lineColor = positive ? AppColors.income : AppColors.expense;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: closes
                .asMap()
                .entries
                .map(
                  (MapEntry<int, double> e) =>
                      FlSpot(e.key.toDouble(), e.value),
                )
                .toList(),
            isCurved: true,
            color: lineColor,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.quote, required this.entity});

  final MarketQuoteEntity quote;
  final WatchlistEntity entity;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      if (quote.dividendYield > 0)
        _Metric(label: 'DY 12m', value: '${quote.dividendYield.toStringAsFixed(1)}%'),
      if (quote.priceEarnings != null) ...<Widget>[
        const Gap(16),
        _Metric(label: 'P/L', value: quote.priceEarnings!.toStringAsFixed(1)),
      ],
      const Spacer(),
      if (entity.alertThreshold != null)
        _AlertChip(threshold: entity.alertThreshold!),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
      const Gap(1),
      Text(value, style: AppTextStyles.labelBold),
    ],
  );
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({required this.threshold});

  final double threshold;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.notifications_outlined, size: 12, color: AppColors.warningText),
          const Gap(4),
          Text(
            'Alerta ${brl.format(threshold)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.warningText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
