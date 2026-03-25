import 'goal_entity.dart';
import 'investment_entity.dart';
import 'transaction_entity.dart';

/// Summary of income/expenses for a single calendar month.
class MonthSummary {
  const MonthSummary({
    required this.year,
    required this.month,
    required this.income,
    required this.expenses,
  });

  final int year;
  final int month;
  final double income;
  final double expenses;

  double get savingsRate =>
      income > 0 ? (income - expenses) / income * 100 : 0;
}

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
    this.userName = '',
    this.transactions = const <TransactionEntity>[],
    this.goals = const <GoalEntity>[],
    this.investments = const <InvestmentEntity>[],
    this.monthHistory = const <MonthSummary>[],
  });

  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory; // categoryUuid → amount
  final Map<String, String> categoryNames;       // categoryUuid → name
  final double prevMonthIncome;
  final double prevMonthExpenses;
  final Map<String, double> prevExpensesByCategory;

  // Enhanced fields for PDF export
  final String userName;
  final List<TransactionEntity> transactions;
  final List<GoalEntity> goals;
  final List<InvestmentEntity> investments;
  final List<MonthSummary> monthHistory; // most-recent first, up to 3 months

  double get savingsRate =>
      totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome * 100 : 0;
}
