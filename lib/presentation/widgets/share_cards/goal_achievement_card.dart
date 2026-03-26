import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'share_card_wrapper.dart';

const Color _white = Color(0xFFFFFFFF);
const Color _muted = Color(0xFF9CA3AF);
const Color _surface = Color(0xFF1C1C1E);
const Color _income = Color(0xFF22C55E);

/// Shareable 1080 × 1080 celebration card shown when a savings goal reaches
/// 100% (US-106).
///
/// Pass [icon] resolved from the goal's icon index at the call site so this
/// widget has no dependency on the screen-level icon list.
class GoalAchievementCard extends StatelessWidget {
  const GoalAchievementCard({
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.icon,
    super.key,
  });

  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final NumberFormat brl = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final String deadlineStr = DateFormat('dd/MM/yyyy').format(deadline);

    return ShareCardWrapper(
      accentColor: _income,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // ── Icon circle ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _income.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _income, width: 2),
            ),
            child: Icon(icon, color: _income, size: 48),
          ),
          const SizedBox(height: 18),

          // ── Congrats badge ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _income.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _income.withValues(alpha: 0.4)),
            ),
            child: const Text(
              '🎉  Meta alcançada!',
              style: TextStyle(
                color: _income,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Goal name ─────────────────────────────────────────────────
          Text(
            goalName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),

          // ── Amount achieved ───────────────────────────────────────────
          Text(
            brl.format(currentAmount),
            style: const TextStyle(
              color: _income,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'de ${brl.format(targetAmount)} alcançados',
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),

          // ── Deadline chip ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.calendar_today_outlined,
                  color: _muted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prazo: $deadlineStr',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
