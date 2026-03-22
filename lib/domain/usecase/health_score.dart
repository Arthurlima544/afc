// Pure Dart scoring logic for the Financial Health Score feature (US-27).
// No Flutter imports — safe to unit-test without a widget tree.

/// Input data required to compute the health score.
class HealthScoreInput {
  const HealthScoreInput({
    required this.totalIncome,
    required this.totalExpenses,
    required this.prevMonthExpenses,
    required this.avgLimitRatio,
    required this.avgGoalProgress,
  });

  /// Current-month income.
  final double totalIncome;

  /// Current-month expenses.
  final double totalExpenses;

  /// Previous-month expenses (used for variance sub-score).
  final double prevMonthExpenses;

  /// Average spent/limit ratio across all limits.
  /// Pass -1 when no limits are configured (neutral score).
  final double avgLimitRatio;

  /// Average currentAmount/targetAmount across active goals.
  /// Pass -1 when no goals exist (neutral score).
  final double avgGoalProgress;
}

/// Breakdown result returned alongside the total score.
class HealthScoreData {
  const HealthScoreData({
    required this.score,
    required this.savingsPoints,
    required this.limitPoints,
    required this.goalPoints,
    required this.variancePoints,
    required this.last6MonthScores,
  });

  /// Total score 0–100.
  final int score;

  /// Sub-score for savings rate (0–25).
  final int savingsPoints;

  /// Sub-score for limit adherence (0–25).
  final int limitPoints;

  /// Sub-score for goal progress (0–25).
  final int goalPoints;

  /// Sub-score for expense variance (0–25).
  final int variancePoints;

  /// Historical scores for the last 6 months, oldest first.
  final List<int> last6MonthScores;
}

// ---------------------------------------------------------------------------
// Sub-score functions
// ---------------------------------------------------------------------------

/// Savings-rate sub-score (0–25 pts).
int savingsRateScore(double income, double expenses) {
  if (income <= 0) {
    return 0;
  }
  final double rate = (income - expenses) / income * 100;
  if (rate >= 20) {
    return 25;
  }
  if (rate >= 10) {
    return 18;
  }
  if (rate >= 5) {
    return 12;
  }
  if (rate >= 0) {
    return 6;
  }
  return 0;
}

/// Limit-adherence sub-score (0–25 pts).
/// Pass [avgRatio] = -1 when no limits are configured → neutral 12 pts.
int limitAdherenceScore(double avgRatio) {
  if (avgRatio < 0) {
    return 12;
  }
  if (avgRatio <= 0.7) {
    return 25;
  }
  if (avgRatio <= 0.9) {
    return 18;
  }
  if (avgRatio <= 1.0) {
    return 10;
  }
  return 0;
}

/// Goal-progress sub-score (0–25 pts).
/// Pass [avgProgress] = -1 when no goals exist → neutral 12 pts.
int goalProgressScore(double avgProgress) {
  if (avgProgress < 0) {
    return 12;
  }
  if (avgProgress >= 0.8) {
    return 25;
  }
  if (avgProgress >= 0.5) {
    return 18;
  }
  if (avgProgress >= 0.2) {
    return 12;
  }
  return 6;
}

/// Expense-variance sub-score (0–25 pts).
/// Positive variance means spending decreased (improvement).
/// Pass [prevExpenses] = 0 → neutral 12 pts.
int expenseVarianceScore(double prevExpenses, double currentExpenses) {
  if (prevExpenses <= 0) {
    return 12;
  }
  final double variance =
      (prevExpenses - currentExpenses) / prevExpenses * 100;
  if (variance >= 10) {
    return 25;
  }
  if (variance >= -10) {
    return 18;
  }
  if (variance >= -30) {
    return 10;
  }
  return 0;
}

/// Computes the total health score (0–100) from [input].
int computeHealthScore(HealthScoreInput input) =>
    savingsRateScore(input.totalIncome, input.totalExpenses) +
    limitAdherenceScore(input.avgLimitRatio) +
    goalProgressScore(input.avgGoalProgress) +
    expenseVarianceScore(input.prevMonthExpenses, input.totalExpenses);
