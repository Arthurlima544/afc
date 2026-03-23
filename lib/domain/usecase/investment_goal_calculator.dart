import 'dart:math';

/// Result from `InvestmentGoalCalculator.calculate`.
class InvestmentGoalResult {
  const InvestmentGoalResult({
    required this.requiredMonthlyContribution,
    required this.totalContributed,
    required this.totalInterestEarned,
    required this.yearlyTimeline,
  });

  /// The monthly contribution required to reach `targetAmount` by the deadline.
  final double requiredMonthlyContribution;

  /// Total amount contributed over the investment period (PMT × months).
  final double totalContributed;

  /// Total interest / growth earned (targetAmount − currentAmount − totalContributed).
  final double totalInterestEarned;

  /// Portfolio value at the end of each year (index 0 = end of year 1).
  final List<double> yearlyTimeline;
}

/// Calculates the required monthly contribution to reach an investment goal.
///
/// Uses the future value of an annuity formula:
///   FV = PV × (1+r)^n + PMT × ((1+r)^n − 1) / r
/// Solved for PMT:
///   PMT = (FV − PV × (1+r)^n) × r / ((1+r)^n − 1)
///
/// When `annualReturnPercent` is 0, PMT = (target − current) / months.
class InvestmentGoalCalculator {
  const InvestmentGoalCalculator._();

  static InvestmentGoalResult calculate({
    required double targetAmount,
    required double currentAmount,
    required int months,
    required double annualReturnPercent,
  }) {
    assert(months > 0, 'months must be positive');
    assert(targetAmount > 0, 'targetAmount must be positive');

    final double r = pow(1 + annualReturnPercent / 100, 1 / 12).toDouble() - 1;
    final int n = months;

    double pmt;
    if (r == 0) {
      pmt = (targetAmount - currentAmount) / n;
    } else {
      final double growthFactor = pow(1 + r, n).toDouble();
      pmt = (targetAmount - currentAmount * growthFactor) *
          r /
          (growthFactor - 1);
    }

    pmt = pmt < 0 ? 0 : pmt;

    // Build yearly timeline
    final List<double> yearlyTimeline = <double>[];
    double portfolio = currentAmount;
    for (int month = 1; month <= n; month++) {
      portfolio = portfolio * (1 + r) + pmt;
      if (month % 12 == 0) {
        yearlyTimeline.add(portfolio);
      }
    }
    if (n % 12 != 0) {
      yearlyTimeline.add(portfolio);
    }

    final double totalContributed = pmt * n;
    final double totalInterest = targetAmount - currentAmount - totalContributed;

    return InvestmentGoalResult(
      requiredMonthlyContribution: pmt,
      totalContributed: totalContributed < 0 ? 0 : totalContributed,
      totalInterestEarned: totalInterest < 0 ? 0 : totalInterest,
      yearlyTimeline: yearlyTimeline,
    );
  }
}
