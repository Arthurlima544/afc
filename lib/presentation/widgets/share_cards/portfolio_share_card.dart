import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/usecase/portfolio_calculator.dart';
import 'share_card_wrapper.dart';

const Color _white = Color(0xFFFFFFFF);
const Color _muted = Color(0xFF9CA3AF);
const Color _surface = Color(0xFF1C1C1E);
const Color _income = Color(0xFF22C55E);
const Color _expense = Color(0xFFEF4444);
const Color _accent = Color(0xFF42A5F5); // blue — investment context

const Map<String, String> _typeLabels = <String, String>{
  'stock': 'Ações',
  'fixed': 'Renda Fixa',
  'crypto': 'Cripto',
  'other': 'Outros',
};

const Map<String, Color> _typeColors = <String, Color>{
  'stock': Color(0xFF42A5F5),
  'fixed': Color(0xFF66BB6A),
  'crypto': Color(0xFFFFB74D),
  'other': Color(0xFFAB47BC),
};

/// Shareable 1080 × 1080 card for portfolio performance (US-108).
class PortfolioShareCard extends StatelessWidget {
  const PortfolioShareCard({required this.summary, super.key});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    final bool isGain = summary.totalProfit >= 0;
    final Color profitColor = isGain ? _income : _expense;
    final String gainSign = isGain ? '+' : '';

    // Top 3 positions by current value.
    final List<PortfolioPosition> top3 =
        (List<PortfolioPosition>.of(summary.positions)
              ..sort(
                (PortfolioPosition a, PortfolioPosition b) =>
                    b.currentValue.compareTo(a.currentValue),
              ))
            .take(3)
            .toList();

    // Month label.
    final DateTime now = DateTime.now();
    final List<String> months = <String>[
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final String monthLabel = '${months[now.month - 1]} ${now.year}';

    return ShareCardWrapper(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Portfólio',
                  style: TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Hero: total value + gain ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Valor atual',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brl.format(summary.totalValue),
                  style: const TextStyle(
                    color: _white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(
                      isGain
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: profitColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$gainSign${compact.format(summary.totalProfit)}  '
                      '($gainSign${summary.overallRoiPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Top positions ─────────────────────────────────────────────
          if (top3.isNotEmpty) ...<Widget>[
            const Text(
              'TOP POSIÇÕES',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                letterSpacing: 0.8,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            for (final PortfolioPosition pos in top3)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _PositionRow(pos: pos, compact: compact),
              ),
            const SizedBox(height: 10),
          ],

          // ── Allocation chips ──────────────────────────────────────────
          if (summary.allocationByType.isNotEmpty)
            _AllocationRow(
              allocation: summary.allocationByType,
              totalValue: summary.totalValue,
            ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.pos, required this.compact});

  final PortfolioPosition pos;
  final NumberFormat compact;

  @override
  Widget build(BuildContext context) {
    final bool gain = pos.profit >= 0;
    final Color c = gain ? _income : _expense;
    final String sign = gain ? '+' : '';
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            pos.entity.ticker?.isNotEmpty == true
                ? pos.entity.ticker!
                : pos.entity.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Text(
          compact.format(pos.currentValue),
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$sign${pos.roiPercent.toStringAsFixed(1)}%',
            style: TextStyle(
              color: c,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({
    required this.allocation,
    required this.totalValue,
  });

  final Map<String, double> allocation;
  final double totalValue;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children: <Widget>[
      for (final MapEntry<String, double> e in allocation.entries)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (_typeColors[e.key] ?? _muted).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: (_typeColors[e.key] ?? _muted).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${_typeLabels[e.key] ?? e.key}  '
            '${totalValue > 0 ? (e.value / totalValue * 100).toStringAsFixed(0) : 0}%',
            style: TextStyle(
              color: _typeColors[e.key] ?? _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
    ],
  );
}
