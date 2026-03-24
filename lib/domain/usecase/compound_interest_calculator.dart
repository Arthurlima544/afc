/// Pure compound interest simulation logic.
///
/// Supports monthly contributions and optional comparison scenarios.
class CompoundResult {
  const CompoundResult({
    required this.finalAmount,
    required this.totalInvested,
    required this.totalInterest,
    required this.yearlyTimeline,
  });

  /// Portfolio value at the end of the simulation period.
  final double finalAmount;

  /// Total capital actually deposited (initial + all monthly contributions).
  final double totalInvested;

  /// Total interest earned = [finalAmount] − [totalInvested].
  final double totalInterest;

  /// Portfolio value at the end of each year.
  /// Index 0 = initial value, index N = end of year N.
  final List<double> yearlyTimeline;
}

/// Calculates compound interest growth with optional monthly contributions.
class CompoundInterestCalculator {
  const CompoundInterestCalculator._();

  /// Simulates compound growth for [years] years.
  ///
  /// [annualRate] is in decimal form (e.g. 0.12 for 12 %).
  static CompoundResult calculate({
    required double initialAmount,
    required double monthlyContribution,
    required double annualRate,
    required int years,
  }) {
    final double monthlyRate = annualRate / 12;
    final List<double> yearlyTimeline = <double>[initialAmount];

    double portfolio = initialAmount;

    for (int month = 1; month <= years * 12; month++) {
      portfolio = portfolio * (1 + monthlyRate) + monthlyContribution;
      if (month % 12 == 0) {
        yearlyTimeline.add(portfolio);
      }
    }

    final double totalInvested =
        initialAmount + monthlyContribution * years * 12;
    final double totalInterest = portfolio - totalInvested;

    return CompoundResult(
      finalAmount: portfolio,
      totalInvested: totalInvested,
      totalInterest: totalInterest,
      yearlyTimeline: yearlyTimeline,
    );
  }

  /// Calculates [CompoundResult] for each rate in [rates] and returns the list
  /// in the same order, useful for "what-if" comparisons.
  static List<CompoundResult> compare({
    required double initialAmount,
    required double monthlyContribution,
    required List<double> rates,
    required int years,
  }) =>
      rates
          .map(
            (double r) => calculate(
              initialAmount: initialAmount,
              monthlyContribution: monthlyContribution,
              annualRate: r,
              years: years,
            ),
          )
          .toList();
}
