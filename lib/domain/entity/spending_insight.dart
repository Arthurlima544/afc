enum InsightType { topCategory, biggestExpense, monthOverMonthDelta, savingsRateTrend }

class SpendingInsight {
  const SpendingInsight({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final InsightType type;
  final String title;
  final String subtitle;
}
