part of 'report_cubit.dart';

/// Computed data for a single month's financial report.
class ReportData {
  const ReportData({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.categoryNames,
    required this.prevMonthIncome,
    required this.prevMonthExpenses,
    required this.prevExpensesByCategory,
  });

  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory; // categoryUuid -> amount
  final Map<String, String> categoryNames;       // categoryUuid -> name
  final double prevMonthIncome;
  final double prevMonthExpenses;
  final Map<String, double> prevExpensesByCategory;

  double get savingsRate =>
      totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome * 100 : 0;
}

@freezed
sealed class ReportState with _$ReportState {
  const factory ReportState.initial() = _Initial;
  const factory ReportState.loading() = _Loading;
  const factory ReportState.success(ReportData data) = _Success;
  const factory ReportState.error(String message) = _Error;
}
