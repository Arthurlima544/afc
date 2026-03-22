import 'package:afc/domain/usecase/health_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // savingsRateScore
  // -------------------------------------------------------------------------
  group('savingsRateScore', () {
    test('income == 0 → 0 pts', () {
      expect(savingsRateScore(0, 0), 0);
    });

    test('negative income → 0 pts', () {
      expect(savingsRateScore(-100, 50), 0);
    });

    test('savings rate exactly 0% → 6 pts', () {
      // income == expenses → rate == 0
      expect(savingsRateScore(1000, 1000), 6);
    });

    test('savings rate 4% → 6 pts', () {
      // (1000 - 960) / 1000 * 100 == 4%
      expect(savingsRateScore(1000, 960), 6);
    });

    test('savings rate 5% → 12 pts', () {
      expect(savingsRateScore(1000, 950), 12);
    });

    test('savings rate 9% → 12 pts', () {
      expect(savingsRateScore(1000, 910), 12);
    });

    test('savings rate 10% → 18 pts', () {
      expect(savingsRateScore(1000, 900), 18);
    });

    test('savings rate 19% → 18 pts', () {
      expect(savingsRateScore(1000, 810), 18);
    });

    test('savings rate 20% → 25 pts', () {
      expect(savingsRateScore(1000, 800), 25);
    });

    test('savings rate > 20% → 25 pts', () {
      expect(savingsRateScore(1000, 500), 25);
    });

    test('expenses > income (negative savings) → 0 pts', () {
      // rate = (500 - 600) / 500 * 100 = -20%
      expect(savingsRateScore(500, 600), 0);
    });
  });

  // -------------------------------------------------------------------------
  // limitAdherenceScore
  // -------------------------------------------------------------------------
  group('limitAdherenceScore', () {
    test('no limits (-1) → 12 pts neutral', () {
      expect(limitAdherenceScore(-1), 12);
    });

    test('avgRatio 0.0 → 25 pts', () {
      expect(limitAdherenceScore(0.0), 25);
    });

    test('avgRatio 0.7 → 25 pts', () {
      expect(limitAdherenceScore(0.7), 25);
    });

    test('avgRatio 0.71 → 18 pts', () {
      expect(limitAdherenceScore(0.71), 18);
    });

    test('avgRatio 0.9 → 18 pts', () {
      expect(limitAdherenceScore(0.9), 18);
    });

    test('avgRatio 0.91 → 10 pts', () {
      expect(limitAdherenceScore(0.91), 10);
    });

    test('avgRatio 1.0 → 10 pts', () {
      expect(limitAdherenceScore(1.0), 10);
    });

    test('avgRatio > 1.0 → 0 pts', () {
      expect(limitAdherenceScore(1.01), 0);
    });

    test('avgRatio 2.0 → 0 pts', () {
      expect(limitAdherenceScore(2.0), 0);
    });
  });

  // -------------------------------------------------------------------------
  // goalProgressScore
  // -------------------------------------------------------------------------
  group('goalProgressScore', () {
    test('no goals (-1) → 12 pts neutral', () {
      expect(goalProgressScore(-1), 12);
    });

    test('avgProgress 0.0 → 6 pts', () {
      expect(goalProgressScore(0.0), 6);
    });

    test('avgProgress 0.19 → 6 pts', () {
      expect(goalProgressScore(0.19), 6);
    });

    test('avgProgress 0.2 → 12 pts', () {
      expect(goalProgressScore(0.2), 12);
    });

    test('avgProgress 0.49 → 12 pts', () {
      expect(goalProgressScore(0.49), 12);
    });

    test('avgProgress 0.5 → 18 pts', () {
      expect(goalProgressScore(0.5), 18);
    });

    test('avgProgress 0.79 → 18 pts', () {
      expect(goalProgressScore(0.79), 18);
    });

    test('avgProgress 0.8 → 25 pts', () {
      expect(goalProgressScore(0.8), 25);
    });

    test('avgProgress 1.0 → 25 pts', () {
      expect(goalProgressScore(1.0), 25);
    });
  });

  // -------------------------------------------------------------------------
  // expenseVarianceScore
  // -------------------------------------------------------------------------
  group('expenseVarianceScore', () {
    test('prevExpenses == 0 → 12 pts neutral', () {
      expect(expenseVarianceScore(0, 500), 12);
    });

    test('spending down ≥ 10% → 25 pts', () {
      // prev=1000, curr=800 → variance=(1000-800)/1000*100=20% improvement
      expect(expenseVarianceScore(1000, 800), 25);
    });

    test('spending down exactly 10% → 25 pts', () {
      expect(expenseVarianceScore(1000, 900), 25);
    });

    test('spending stable (same) → 18 pts', () {
      expect(expenseVarianceScore(1000, 1000), 18);
    });

    test('spending up 5% → 18 pts', () {
      // variance = (1000-1050)/1000*100 = -5% (within -10% to +10%)
      expect(expenseVarianceScore(1000, 1050), 18);
    });

    test('spending up 10% boundary → 18 pts', () {
      // variance = (1000-1100)/1000*100 = -10% (boundary, should be 18)
      expect(expenseVarianceScore(1000, 1100), 18);
    });

    test('spending up 11% → 10 pts', () {
      // variance = (1000-1110)/1000*100 = -11%
      expect(expenseVarianceScore(1000, 1110), 10);
    });

    test('spending up 30% → 10 pts', () {
      expect(expenseVarianceScore(1000, 1300), 10);
    });

    test('spending up > 30% → 0 pts', () {
      // variance = (1000-1310)/1000*100 = -31%
      expect(expenseVarianceScore(1000, 1310), 0);
    });
  });

  // -------------------------------------------------------------------------
  // computeHealthScore — integration
  // -------------------------------------------------------------------------
  group('computeHealthScore', () {
    test('maximum score (perfect inputs) == 100', () {
      const HealthScoreInput input = HealthScoreInput(
        totalIncome: 1000,
        totalExpenses: 750, // savings 25% → 25 pts
        prevMonthExpenses: 900, // variance +16.7% → 25 pts
        avgLimitRatio: 0.5, // ≤0.7 → 25 pts
        avgGoalProgress: 0.9, // ≥0.8 → 25 pts
      );
      expect(computeHealthScore(input), 100);
    });

    test('minimum-ish score (worst inputs) == 0', () {
      const HealthScoreInput input = HealthScoreInput(
        totalIncome: 0, // 0 pts savings
        totalExpenses: 1000,
        prevMonthExpenses: 500, // curr > prev by >30% → 0 pts
        avgLimitRatio: 2.0, // >1.0 → 0 pts
        avgGoalProgress: 0.0, // <0.2 → 6 pts (minimum non-zero)
      );
      // 0 + 0 + 6 + 0 = 6
      expect(computeHealthScore(input), 6);
    });

    test('neutral score (no limits, no goals, no prev data, zero income)', () {
      const HealthScoreInput input = HealthScoreInput(
        totalIncome: 0,
        totalExpenses: 0,
        prevMonthExpenses: 0,
        avgLimitRatio: -1,
        avgGoalProgress: -1,
      );
      // savings=0, limits=12, goals=12, variance=12 → 36
      expect(computeHealthScore(input), 36);
    });

    test('known composite example', () {
      const HealthScoreInput input = HealthScoreInput(
        totalIncome: 2000,
        totalExpenses: 1600, // savings 20% → 25 pts
        prevMonthExpenses: 1700, // variance=(1700-1600)/1700*100≈5.9% (stable) → 18 pts
        avgLimitRatio: 0.85, // 0.71-0.9 → 18 pts
        avgGoalProgress: 0.6, // 0.5-0.79 → 18 pts
      );
      // 25 + 18 + 18 + 18 = 79
      expect(computeHealthScore(input), 79);
    });
  });
}
