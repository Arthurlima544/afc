import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/market_quote_entity.dart';
import '../blocs/market/market_opportunity_cubit.dart';
import '../blocs/watchlist/watchlist_cubit.dart';
import '../blocs/watchlist/watchlist_item.dart';
import '../widgets/design_system.dart';
import '../widgets/error_state.dart';
import '../widgets/skeleton_list.dart';

// ─── Sort options ──────────────────────────────────────────────────────────────

enum _SortMode { highestDy, dyVsCdi, lowestPl }

// ─── Screen ────────────────────────────────────────────────────────────────────

class OportunidadesScreen extends StatefulWidget {
  const OportunidadesScreen({required this.userId, super.key});

  final String userId;

  @override
  State<OportunidadesScreen> createState() => _OportunidadesScreenState();
}

class _OportunidadesScreenState extends State<OportunidadesScreen> {
  // 0 = Todos, 1 = Ações, 2 = FIIs
  int _filterIndex = 0;
  _SortMode _sort = _SortMode.highestDy;

  List<MarketQuoteEntity> _apply(
    List<MarketQuoteEntity> quotes,
    double cdi,
  ) {
    List<MarketQuoteEntity> filtered;
    if (_filterIndex == 1) {
      filtered = quotes.where((MarketQuoteEntity q) => !q.isFii).toList();
    } else if (_filterIndex == 2) {
      filtered = quotes.where((MarketQuoteEntity q) => q.isFii).toList();
    } else {
      filtered = List<MarketQuoteEntity>.of(quotes);
    }

    switch (_sort) {
      case _SortMode.highestDy:
        filtered.sort(
          (MarketQuoteEntity a, MarketQuoteEntity b) =>
              b.dividendYield.compareTo(a.dividendYield),
        );
      case _SortMode.dyVsCdi:
        filtered.sort(
          (MarketQuoteEntity a, MarketQuoteEntity b) =>
              b.dyVsCdi(cdi).compareTo(a.dyVsCdi(cdi)),
        );
      case _SortMode.lowestPl:
        // Stocks without P/L go to the bottom.
        filtered.sort((MarketQuoteEntity a, MarketQuoteEntity b) {
          final double? pa = a.priceEarnings;
          final double? pb = b.priceEarnings;
          if (pa == null && pb == null) {
            return 0;
          }
          if (pa == null) {
            return 1;
          }
          if (pb == null) {
            return -1;
          }
          return pa.compareTo(pb);
        });
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.pop()),
      title: const Text('Oportunidades'),
      centerTitle: false,
      actions: <Widget>[
        AppIconButton(
          icon: const Icon(Icons.bookmark_outline),
          tooltip: 'Minha Watchlist',
          onPressed: () => context.push('/watchlist'),
        ),
      ],
    ),
    body: BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (BuildContext context, WatchlistState watchlistState) {
        final Set<String> watchlistTickers = watchlistState.whenOrNull(
              loaded: (List<WatchlistItem> items, DateTime _) =>
                  items.map((WatchlistItem i) => i.ticker).toSet(),
            ) ??
            <String>{};
        return BlocBuilder<MarketOpportunityCubit, MarketOpportunityState>(
          builder: (BuildContext context, MarketOpportunityState state) =>
              state.when(
                initial: () => const SizedBox(),
                loading: () => const SkeletonList(),
                error: (String msg) => ErrorState(
                  message: msg,
                  onRetry: () => context
                      .read<MarketOpportunityCubit>()
                      .load(forceRefresh: true),
                ),
                loaded: (
                  List<MarketQuoteEntity> quotes,
                  double cdiRate,
                  DateTime fetchedAt,
                ) {
                  final List<MarketQuoteEntity> visible =
                      _apply(quotes, cdiRate);
              return RefreshIndicator(
                onRefresh: () => context
                    .read<MarketOpportunityCubit>()
                    .load(forceRefresh: true),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _BenchmarkBanner(cdiRate: cdiRate),
                            const Gap(12),
                            _FilterBar(
                              selected: _filterIndex,
                              onChanged: (int i) =>
                                  setState(() => _filterIndex = i),
                            ),
                            const Gap(8),
                            _SortBar(
                              selected: _sort,
                              onChanged: (_SortMode m) =>
                                  setState(() => _sort = m),
                            ),
                            const Gap(4),
                            Text(
                              'Atualizado ${_timeAgo(fetchedAt)}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const Gap(12),
                          ],
                        ),
                      ),
                    ),
                    if (visible.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Nenhum ativo encontrado.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const Gap(10),
                          itemBuilder: (BuildContext ctx, int i) =>
                              _QuoteCard(
                                quote: visible[i],
                                cdiRate: cdiRate,
                                inWatchlist: watchlistTickers
                                    .contains(visible[i].ticker),
                              ),
                        ),
                      ),
                  ],
                ),
              );
                },
              ),
        );
      },
    ),
  );

  String _timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return 'agora';
    }
    if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes} min';
    }
    return 'há ${diff.inHours} h';
  }
}

// ─── Benchmark banner ──────────────────────────────────────────────────────────

class _BenchmarkBanner extends StatelessWidget {
  const _BenchmarkBanner({required this.cdiRate});

  final double cdiRate;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        const Icon(Icons.account_balance_outlined, size: 20),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Referência de mercado', style: AppTextStyles.labelBold),
              const Gap(2),
              Text(
                'CDI: ${cdiRate.toStringAsFixed(2)}% a.a.'
                '  ·  Selic ≈ ${(cdiRate + 0.1).toStringAsFixed(2)}% a.a.',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Filter chips ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      _Chip(label: 'Todos', active: selected == 0, onTap: () => onChanged(0)),
      const Gap(8),
      _Chip(label: 'Ações', active: selected == 1, onTap: () => onChanged(1)),
      const Gap(8),
      _Chip(label: 'FIIs', active: selected == 2, onTap: () => onChanged(2)),
    ],
  );
}

// ─── Sort chips ───────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  const _SortBar({required this.selected, required this.onChanged});

  final _SortMode selected;
  final ValueChanged<_SortMode> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: <Widget>[
        _Chip(
          label: 'Maior DY',
          active: selected == _SortMode.highestDy,
          onTap: () => onChanged(_SortMode.highestDy),
        ),
        const Gap(8),
        _Chip(
          label: 'DY vs CDI',
          active: selected == _SortMode.dyVsCdi,
          onTap: () => onChanged(_SortMode.dyVsCdi),
        ),
        const Gap(8),
        _Chip(
          label: 'Menor P/L',
          active: selected == _SortMode.lowestPl,
          onTap: () => onChanged(_SortMode.lowestPl),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
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

// ─── Quote card ───────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.cdiRate,
    required this.inWatchlist,
  });

  final MarketQuoteEntity quote;
  final double cdiRate;
  final bool inWatchlist;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final double ratio = quote.dyVsCdi(cdiRate);
    final bool isUp = quote.changePercent >= 0;
    final Color changeColor = isUp ? AppColors.income : AppColors.expense;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Ticker + type badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(quote.ticker, style: AppTextStyles.bodyBold),
                  const Gap(2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: quote.isFii
                          ? AppColors.primaryLight.withValues(alpha: 0.15)
                          : AppColors.income.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      quote.isFii ? 'FII' : 'Ação',
                      style: AppTextStyles.caption.copyWith(
                        color:
                            quote.isFii ? AppColors.primaryLight : AppColors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bookmark
              GestureDetector(
                onTap: () {
                  if (inWatchlist) {
                    context.push('/watchlist');
                  } else {
                    context.read<WatchlistCubit>().addTicker(quote.ticker);
                  }
                },
                child: Icon(
                  inWatchlist ? Icons.bookmark : Icons.bookmark_outline,
                  size: 20,
                  color: inWatchlist ? AppColors.primary : AppColors.muted,
                ),
              ),
              const Gap(10),
              // Price + change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(brl.format(quote.price), style: AppTextStyles.bodyBold),
                  const Gap(2),
                  Row(
                    children: <Widget>[
                      Icon(
                        isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: changeColor,
                        size: 16,
                      ),
                      Text(
                        '${quote.changePercent.abs().toStringAsFixed(2)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Gap(10),
          // Name
          Text(
            quote.name,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(10),
          // Metrics row
          Row(
            children: <Widget>[
              _MetricCell(
                label: 'DY 12m',
                value: '${quote.dividendYield.toStringAsFixed(2)}%',
                highlight: quote.dividendYield > cdiRate,
              ),
              const Gap(16),
              _MetricCell(
                label: 'DY / CDI',
                value: '${ratio.toStringAsFixed(2)}×',
                highlight: ratio > 1,
              ),
              if (quote.priceEarnings != null) ...<Widget>[
                const Gap(16),
                _MetricCell(
                  label: 'P/L',
                  value: quote.priceEarnings!.toStringAsFixed(1),
                ),
              ],
              if (quote.sector.isNotEmpty) ...<Widget>[
                const Spacer(),
                Text(
                  quote.sector,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

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
        style: AppTextStyles.labelBold.copyWith(
          color: highlight ? AppColors.income : null,
        ),
      ),
    ],
  );
}
