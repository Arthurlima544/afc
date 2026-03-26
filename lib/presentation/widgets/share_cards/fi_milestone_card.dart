import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../presentation/blocs/fi_score/fi_score_cubit.dart';
import 'share_card_wrapper.dart';

const Color _white = Color(0xFFFFFFFF);
const Color _muted = Color(0xFF9CA3AF);
const Color _surface = Color(0xFF1C1C1E);
const Color _primary = Color(0xFF0D9488);
const Color _primaryLight = Color(0xFF14B8A6);

/// Shareable tall card (1080 × 1440) for FI milestone moments (US-107).
///
/// Shown when the user taps the share icon on the FI Score dashboard card.
/// Renders the user's current FI score, highest achieved milestone label,
/// progress bar, and passive income vs expenses stats.
class FiMilestoneCard extends StatelessWidget {
  const FiMilestoneCard({required this.data, super.key});

  final FiScoreData data;

  String _milestoneLabel() {
    final double score = data.fiScore;
    if (score >= 100) {
      return 'Financeiramente independente! 🎉';
    }
    if (score >= 75) {
      return 'Quase lá! 💎';
    }
    if (score >= 50) {
      return 'Metade do caminho 🏆';
    }
    if (score >= 25) {
      return 'No caminho certo 🚀';
    }
    if (score >= 10) {
      return 'Primeiros passos 🌱';
    }
    return 'Começando a jornada ✨';
  }

  Color _scoreColor() {
    final double score = data.fiScore;
    if (score >= 75) {
      return _primary;
    }
    if (score >= 40) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat compact = NumberFormat.compactCurrency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    final double progress = (data.fiScore / 100).clamp(0.0, 1.0);
    final Color scoreColor = _scoreColor();
    const List<int> milestones = <int>[10, 25, 50, 75, 100];

    return ShareCardWrapper(
      accentColor: _primary,
      height: kShareCardTall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Title ─────────────────────────────────────────────────────
          const Text(
            'Independência\nFinanceira',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.4,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),

          // ── Hero score ────────────────────────────────────────────────
          Text(
            '${data.fiScore.toStringAsFixed(1)}%',
            style: TextStyle(
              color: scoreColor,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),

          // ── Milestone label ───────────────────────────────────────────
          Text(
            _milestoneLabel(),
            style: const TextStyle(
              color: _white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),

          // ── Progress bar with milestone markers ───────────────────────
          _MilestoneBar(
            progress: progress,
            milestones: milestones,
            color: scoreColor,
          ),
          const SizedBox(height: 20),

          // ── Stats row ─────────────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: 'Renda passiva',
                  value: '${compact.format(data.passiveIncomeMonthly)}/mês',
                  color: _primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Despesas',
                  value: '${compact.format(data.monthlyExpenses)}/mês',
                  color: _muted,
                ),
              ),
            ],
          ),
          const Spacer(),

          // ── Explanation ───────────────────────────────────────────────
          const Text(
            'Renda passiva ÷ despesas mensais × 100',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MilestoneBar extends StatelessWidget {
  const _MilestoneBar({
    required this.progress,
    required this.milestones,
    required this.color,
  });

  final double progress;
  final List<int> milestones;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      // Progress bar
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 10,
          child: Stack(
            children: <Widget>[
              const ColoredBox(color: _surface, child: SizedBox.expand()),
              FractionallySizedBox(
                widthFactor: progress,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 6),
      // Milestone labels
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (final int m in milestones)
            Text(
              '$m%',
              style: TextStyle(
                color: progress * 100 >= m ? color : _muted,
                fontSize: 10,
                fontWeight: progress * 100 >= m
                    ? FontWeight.bold
                    : FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
        ],
      ),
    ],
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
    ),
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
  );
}
