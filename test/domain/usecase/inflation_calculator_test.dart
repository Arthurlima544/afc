import 'package:afc/domain/usecase/inflation_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InflationCalculator', () {
    // ── realValue ────────────────────────────────────────────────────────────

    group('realValue', () {
      test('returns nominal value when inflationPercent is zero', () {
        expect(
          InflationCalculator.realValue(
            nominalValue: 1000,
            inflationPercent: 0,
            years: 10,
          ),
          equals(1000),
        );
      });

      test('returns nominal value when years is zero', () {
        expect(
          InflationCalculator.realValue(
            nominalValue: 1000,
            inflationPercent: 4.5,
            years: 0,
          ),
          equals(1000),
        );
      });

      test('discounts value with positive inflation and years', () {
        // 1 000 / (1.045)^10 ≈ 643.93
        expect(
          InflationCalculator.realValue(
            nominalValue: 1000,
            inflationPercent: 4.5,
            years: 10,
          ),
          closeTo(643.93, 0.1),
        );
      });

      test('real value is strictly less than nominal for positive inputs', () {
        expect(
          InflationCalculator.realValue(
            nominalValue: 5000,
            inflationPercent: 6.0,
            years: 20,
          ),
          lessThan(5000),
        );
      });
    });

    // ── realAnnualReturnPercent ───────────────────────────────────────────────

    group('realAnnualReturnPercent', () {
      test('Fisher equation: 10 % nominal – 4.5 % inflation ≈ 5.26 %', () {
        // ((1.10 / 1.045) − 1) × 100 ≈ 5.263
        expect(
          InflationCalculator.realAnnualReturnPercent(
            nominalReturnPercent: 10,
            inflationPercent: 4.5,
          ),
          closeTo(5.263, 0.01),
        );
      });

      test('returns approximately zero when nominal equals inflation', () {
        expect(
          InflationCalculator.realAnnualReturnPercent(
            nominalReturnPercent: 5,
            inflationPercent: 5,
          ),
          closeTo(0, 0.01),
        );
      });

      test('returns negative real return when inflation exceeds nominal', () {
        expect(
          InflationCalculator.realAnnualReturnPercent(
            nominalReturnPercent: 3,
            inflationPercent: 5,
          ),
          isNegative,
        );
      });
    });

    // ── adjustTimeline ────────────────────────────────────────────────────────

    group('adjustTimeline', () {
      test('returns empty list for empty timeline', () {
        expect(
          InflationCalculator.adjustTimeline(
            nominalTimeline: <double>[],
            inflationPercent: 4.5,
          ),
          isEmpty,
        );
      });

      test('adjusts single value at year 1', () {
        // 1 000 / 1.045^1 ≈ 956.94
        final List<double> result = InflationCalculator.adjustTimeline(
          nominalTimeline: <double>[1000],
          inflationPercent: 4.5,
        );
        expect(result.first, closeTo(956.94, 0.1));
      });

      test('equal nominals produce strictly decreasing real values', () {
        final List<double> result = InflationCalculator.adjustTimeline(
          nominalTimeline: <double>[1000, 1000, 1000],
          inflationPercent: 4.5,
        );
        expect(result[0], greaterThan(result[1]));
        expect(result[1], greaterThan(result[2]));
      });

      test('output length matches input length', () {
        const List<double> nominal = <double>[100, 200, 300, 400, 500];
        expect(
          InflationCalculator.adjustTimeline(
            nominalTimeline: nominal,
            inflationPercent: 3,
          ).length,
          equals(nominal.length),
        );
      });
    });
  });
}
