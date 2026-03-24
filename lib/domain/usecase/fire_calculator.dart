/// Pure FIRE (Financial Independence, Retire Early) calculation logic.
///
/// No Flutter dependencies — testable in isolation.
class FireResult {
  const FireResult({
    required this.fireNumber,
    required this.monthsToFire,
    required this.retirementDate,
    required this.yearlyTimeline,
  });

  /// Target portfolio size needed to retire (annual expenses ÷ SWR).
  final double fireNumber;

  /// Months from today to reach [fireNumber]; null if not achieved in 50 years.
  final int? monthsToFire;

  /// Approximate retirement date; null when [monthsToFire] is null.
  final DateTime? retirementDate;

  /// Portfolio value at the end of each simulated year.
  /// Index 0 = current value, index 1 = end of year 1, …
  final List<double> yearlyTimeline;

  /// Whole years to FIRE (ceiling of [monthsToFire] / 12).
  int? get yearsToFire =>
      monthsToFire == null ? null : (monthsToFire! / 12).ceil();
}

/// Calculates FIRE projections given the user's financial inputs.
class FireCalculator {
  const FireCalculator._();

  static const int _maxYears = 50;

  /// Returns a [FireResult] for the supplied parameters.
  ///
  /// All rate inputs are in decimal form (e.g. 0.07 for 7 %).
  static FireResult calculate({
    required double monthlyExpenses,
    required double annualReturnRate,
    required double safeWithdrawalRate,
    required double currentPortfolio,
    required double monthlySavings,
  }) {
    final double annualExpenses = monthlyExpenses * 12;
    final double fireNumber = safeWithdrawalRate > 0
        ? annualExpenses / safeWithdrawalRate
        : double.infinity;

    final double monthlyRate = annualReturnRate / 12;

    final List<double> yearlyTimeline = <double>[currentPortfolio];
    double portfolio = currentPortfolio;
    int? monthsToFire = currentPortfolio >= fireNumber ? 0 : null;

    for (int month = 1; month <= _maxYears * 12; month++) {
      portfolio = portfolio * (1 + monthlyRate) + monthlySavings;
      if (monthsToFire == null && portfolio >= fireNumber) {
        monthsToFire = month;
      }
      if (month % 12 == 0) {
        yearlyTimeline.add(portfolio);
      }
    }

    DateTime? retirementDate;
    if (monthsToFire != null) {
      final DateTime now = DateTime.now();
      final int addYears = monthsToFire ~/ 12;
      final int addMonths = monthsToFire % 12;
      retirementDate = DateTime(
        now.year + addYears,
        now.month + addMonths,
      );
    }

    return FireResult(
      fireNumber: fireNumber,
      monthsToFire: monthsToFire,
      retirementDate: retirementDate,
      yearlyTimeline: yearlyTimeline,
    );
  }
}
