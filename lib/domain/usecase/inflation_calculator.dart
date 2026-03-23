import 'dart:math';

/// Utilities for inflation-adjusting nominal financial projections.
class InflationCalculator {
  const InflationCalculator._();

  /// Default Brazil IPCA long-run average (percent per year).
  static const double defaultInflationPercent = 4.5;

  /// Converts a [nominalValue] n [years] from now to its purchasing-power
  /// equivalent in today's money.
  ///
  /// Formula: real = nominal / (1 + inflation/100)^years
  static double realValue({
    required double nominalValue,
    required double inflationPercent,
    required double years,
  }) {
    if (inflationPercent <= 0 || years <= 0) {
      return nominalValue;
    }
    return nominalValue / pow(1 + inflationPercent / 100, years);
  }

  /// Returns the real annual return rate when both nominal return and
  /// inflation are expressed as percentages.
  ///
  /// Formula: real = ((1 + nominal/100) / (1 + inflation/100)) - 1
  static double realAnnualReturnPercent({
    required double nominalReturnPercent,
    required double inflationPercent,
  }) {
    final double nominal = 1 + nominalReturnPercent / 100;
    final double inflation = 1 + inflationPercent / 100;
    return (nominal / inflation - 1) * 100;
  }

  /// Adjusts an entire yearly timeline of nominal values to real values.
  ///
  /// Each value at position [i] represents the end of year [i+1].
  static List<double> adjustTimeline({
    required List<double> nominalTimeline,
    required double inflationPercent,
  }) =>
      <double>[
        for (int i = 0; i < nominalTimeline.length; i++)
          realValue(
            nominalValue: nominalTimeline[i],
            inflationPercent: inflationPercent,
            years: (i + 1).toDouble(),
          ),
      ];
}
