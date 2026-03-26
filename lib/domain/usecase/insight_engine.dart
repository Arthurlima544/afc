import '../entity/spending_insight.dart';
import '../entity/transaction_entity.dart';

/// Generates a list of actionable spending insights from two months of data.
class InsightEngine {
  static List<SpendingInsight> generate({
    required List<TransactionEntity> currentMonth,
    required List<TransactionEntity> prevMonth,
    required Map<String, String> categoryNames,
  }) {
    final List<SpendingInsight> insights = <SpendingInsight>[];

    final List<TransactionEntity> currExpenses =
        currentMonth.where((TransactionEntity tx) => tx.typeUuid == 'expense').toList();
    final List<TransactionEntity> currIncome =
        currentMonth.where((TransactionEntity tx) => tx.typeUuid == 'income').toList();
    final List<TransactionEntity> prevExpenses =
        prevMonth.where((TransactionEntity tx) => tx.typeUuid == 'expense').toList();
    final List<TransactionEntity> prevIncome =
        prevMonth.where((TransactionEntity tx) => tx.typeUuid == 'income').toList();

    final double currTotal =
        currExpenses.fold(0.0, (double s, TransactionEntity tx) => s + tx.amount);
    final double prevTotal =
        prevExpenses.fold(0.0, (double s, TransactionEntity tx) => s + tx.amount);
    final double currIncomeTotal =
        currIncome.fold(0.0, (double s, TransactionEntity tx) => s + tx.amount);
    final double prevIncomeTotal =
        prevIncome.fold(0.0, (double s, TransactionEntity tx) => s + tx.amount);

    // 1. Top expense category
    if (currExpenses.isNotEmpty) {
      final Map<String, double> byCategory = <String, double>{};
      for (final TransactionEntity tx in currExpenses) {
        byCategory[tx.categoryUUid] =
            (byCategory[tx.categoryUUid] ?? 0.0) + tx.amount;
      }
      final String topId = byCategory.entries
          .reduce(
            (MapEntry<String, double> a, MapEntry<String, double> b) =>
                a.value >= b.value ? a : b,
          )
          .key;
      insights.add(
        SpendingInsight(
          type: InsightType.topCategory,
          title: 'Maior categoria',
          subtitle: categoryNames[topId] ?? topId,
        ),
      );
    }

    // 2. Biggest single expense
    if (currExpenses.isNotEmpty) {
      final TransactionEntity biggest = currExpenses.reduce(
        (TransactionEntity a, TransactionEntity b) =>
            a.amount >= b.amount ? a : b,
      );
      insights.add(
        SpendingInsight(
          type: InsightType.biggestExpense,
          title: 'Maior despesa',
          subtitle: biggest.title,
        ),
      );
    }

    // 3. Month-over-month delta
    if (prevTotal > 0) {
      final double delta = (currTotal - prevTotal) / prevTotal * 100;
      final String sign = delta >= 0 ? '+' : '';
      insights.add(
        SpendingInsight(
          type: InsightType.monthOverMonthDelta,
          title: 'Vs. mês anterior',
          subtitle: '$sign${delta.toStringAsFixed(1)}%',
        ),
      );
    }

    // 4. Savings rate trend
    if (currIncomeTotal > 0 && prevIncomeTotal > 0) {
      final double currRate =
          (currIncomeTotal - currTotal) / currIncomeTotal * 100;
      final double prevRate =
          (prevIncomeTotal - prevTotal) / prevIncomeTotal * 100;
      final bool improving = currRate >= prevRate;
      insights.add(
        SpendingInsight(
          type: InsightType.savingsRateTrend,
          title: 'Taxa de poupança',
          subtitle: improving ? '↑ Melhorando' : '↓ Piorando',
        ),
      );
    }

    return insights;
  }
}
