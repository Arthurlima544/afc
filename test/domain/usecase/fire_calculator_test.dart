import 'package:afc/domain/usecase/fire_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FireCalculator', () {
    // ── FIRE number ──────────────────────────────────────────────────────────

    test('calculates FIRE number correctly with 4% SWR', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 5000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 0,
        monthlySavings: 0,
      );
      // FIRE number = (5000 * 12) / 0.04 = 1_500_000
      expect(r.fireNumber, closeTo(1500000, 0.01));
    });

    test('calculates FIRE number correctly with 3% SWR (Lean FIRE)', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 4000,
        annualReturnRate: 0.08,
        safeWithdrawalRate: 0.03,
        currentPortfolio: 0,
        monthlySavings: 0,
      );
      // (4000 * 12) / 0.03 = 1_600_000
      expect(r.fireNumber, closeTo(1600000, 0.01));
    });

    test('returns infinity when SWR is zero', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 5000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0,
        currentPortfolio: 0,
        monthlySavings: 0,
      );
      expect(r.fireNumber.isInfinite, isTrue);
      expect(r.monthsToFire, isNull);
      expect(r.retirementDate, isNull);
    });

    // ── months to FIRE ───────────────────────────────────────────────────────

    test('portfolio already above FIRE number → monthsToFire is 0', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 1000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 500000, // FIRE = 300_000; already over
        monthlySavings: 0,
      );
      expect(r.monthsToFire, 0);
    });

    test('returns monthsToFire for typical scenario', () {
      // With R$100k portfolio, R$2k/month savings, 10% annual return,
      // FIRE number = R$300k → should be reached in reasonable time.
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 1000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 100000,
        monthlySavings: 2000,
      );
      expect(r.monthsToFire, isNotNull);
      expect(r.monthsToFire, lessThan(50 * 12));
    });

    test('returns null when goal is unreachable in 50 years', () {
      // Zero savings, zero portfolio, no return → never reaches FIRE
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 10000,
        annualReturnRate: 0,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 0,
        monthlySavings: 0,
      );
      expect(r.monthsToFire, isNull);
      expect(r.retirementDate, isNull);
    });

    // ── yearsToFire ──────────────────────────────────────────────────────────

    test('yearsToFire rounds up to whole years', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 1000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 100000,
        monthlySavings: 2000,
      );
      if (r.monthsToFire != null) {
        expect(r.yearsToFire, (r.monthsToFire! / 12).ceil());
      }
    });

    // ── yearlyTimeline ───────────────────────────────────────────────────────

    test('yearlyTimeline first entry equals currentPortfolio', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 5000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 75000,
        monthlySavings: 1000,
      );
      expect(r.yearlyTimeline.first, closeTo(75000, 0.01));
    });

    test('yearlyTimeline has 51 entries (year 0 through year 50)', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 5000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 0,
        monthlySavings: 1000,
      );
      expect(r.yearlyTimeline.length, 51);
    });

    test('yearlyTimeline grows monotonically with positive savings and return',
        () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 5000,
        annualReturnRate: 0.08,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 10000,
        monthlySavings: 1500,
      );
      for (int i = 1; i < r.yearlyTimeline.length; i++) {
        expect(
          r.yearlyTimeline[i],
          greaterThan(r.yearlyTimeline[i - 1]),
          reason: 'Portfolio should grow each year',
        );
      }
    });

    // ── retirementDate ───────────────────────────────────────────────────────

    test('retirementDate is in the future when monthsToFire > 0', () {
      final FireResult r = FireCalculator.calculate(
        monthlyExpenses: 3000,
        annualReturnRate: 0.10,
        safeWithdrawalRate: 0.04,
        currentPortfolio: 50000,
        monthlySavings: 3000,
      );
      if (r.retirementDate != null) {
        expect(r.retirementDate!.isAfter(DateTime.now()), isTrue);
      }
    });
  });
}
