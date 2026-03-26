import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/report_data.dart';
import 'share_card_wrapper.dart';

// Explicit colour constants — no Theme dependency.
const Color _white = Color(0xFFFFFFFF);
const Color _muted = Color(0xFF9CA3AF);
const Color _surface = Color(0xFF1C1C1E);
const Color _income = Color(0xFF22C55E);
const Color _expense = Color(0xFFEF4444);
const Color _primary = Color(0xFF0D9488);

const List<String> _kMonths = <String>[
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// Shareable 1080 × 1080 card for the monthly financial summary (US-105).
class MonthlySnapshotCard extends StatelessWidget {
  const MonthlySnapshotCard({required this.data, super.key});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );
    final double balance = data.totalIncome - data.totalExpenses;
    final double savingsRate = data.savingsRate.clamp(0.0, 100.0);

    // Top 3 expense categories by amount.
    final List<MapEntry<String, double>> top3 =
        (data.expensesByCategory.entries.toList()
              ..sort(
                (MapEntry<String, double> a, MapEntry<String, double> b) =>
                    b.value.compareTo(a.value),
              ))
            .take(3)
            .toList();
    final double maxCat = top3.isEmpty ? 1 : top3.first.value;

    return ShareCardWrapper(
      accentColor: _primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${_kMonths[(data.month - 1).clamp(0, 11)]} ${data.year}',
                  style: const TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const Text(
                'Resumo do mês',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Stat bubbles ──────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatBubble(
                    label: 'Receitas',
                    value: brl.format(data.totalIncome),
                    color: _income,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatBubble(
                    label: 'Despesas',
                    value: brl.format(data.totalExpenses),
                    color: _expense,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatBubble(
                    label: 'Saldo',
                    value: brl.format(balance),
                    color: balance >= 0 ? _income : _expense,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Savings rate ──────────────────────────────────────────────
          _SavingsRateRow(rate: savingsRate),
          const SizedBox(height: 14),

          // ── Top categories ────────────────────────────────────────────
          if (top3.isNotEmpty) ...<Widget>[
            const Text(
              'TOP CATEGORIAS',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                letterSpacing: 0.8,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            for (final MapEntry<String, double> entry in top3)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _CategoryBar(
                  name: data.categoryNames[entry.key] ?? 'Outros',
                  amount: entry.value,
                  fraction: maxCat > 0 ? entry.value / maxCat : 0,
                  formatted: brl.format(entry.value),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SavingsRateRow extends StatelessWidget {
  const _SavingsRateRow({required this.rate});

  final double rate;

  String _label() {
    if (rate >= 30) {
      return 'Excelente';
    }
    if (rate >= 15) {
      return 'Boa';
    }
    return 'Atenção';
  }

  Color _color() {
    if (rate >= 30) {
      return _income;
    }
    if (rate >= 15) {
      return const Color(0xFFF59E0B);
    }
    return _expense;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          const Text(
            'Taxa de poupança',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Text(
            '${rate.toStringAsFixed(1)}%  ${_label()}',
            style: TextStyle(
              color: _color(),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          height: 6,
          child: Stack(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const SizedBox.expand(),
              ),
              FractionallySizedBox(
                widthFactor: (rate / 100).clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _color(),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.name,
    required this.amount,
    required this.fraction,
    required this.formatted,
  });

  final String name;
  final double amount;
  final double fraction;
  final String formatted;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      SizedBox(
        width: 80,
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _white,
            fontSize: 11,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: Stack(
              children: <Widget>[
                const ColoredBox(color: _surface, child: SizedBox.expand()),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: _expense),
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        formatted,
        style: const TextStyle(
          color: _muted,
          fontSize: 10,
          decoration: TextDecoration.none,
        ),
      ),
    ],
  );
}
