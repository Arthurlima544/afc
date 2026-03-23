import 'package:afc/domain/usecase/compound_interest_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompoundInterestCalculator', () {
    // ── finalAmount ──────────────────────────────────────────────────────────

    test('single lump sum, no monthly contribution, 1 year at 12%', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 12000,
        monthlyContribution: 0,
        annualRate: 0.12,
        years: 1,
      );
      // 12000 * (1 + 0.01)^12 ≈ 13521.90
      expect(r.finalAmount, closeTo(13521.90, 1));
    });

    test('zero initial, monthly contribution of 1000 for 1 year at 12%', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 0,
        monthlyContribution: 1000,
        annualRate: 0.12,
        years: 1,
      );
      // Future value of annuity: 1000 * ((1.01^12 - 1) / 0.01) ≈ 12682.50
      expect(r.finalAmount, closeTo(12682.5, 1));
    });

    test('zero rate — growth equals deposits only', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 5000,
        monthlyContribution: 500,
        annualRate: 0,
        years: 10,
      );
      // 5000 + 500 * 120 = 65000
      expect(r.finalAmount, closeTo(65000, 0.01));
      expect(r.totalInterest, closeTo(0, 0.01));
    });

    // ── totalInvested ────────────────────────────────────────────────────────

    test('totalInvested = initialAmount + monthlyContribution * years * 12',
        () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 10000,
        monthlyContribution: 500,
        annualRate: 0.08,
        years: 5,
      );
      expect(r.totalInvested, closeTo(10000 + 500 * 60, 0.01));
    });

    // ── totalInterest ────────────────────────────────────────────────────────

    test('totalInterest = finalAmount - totalInvested', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 20000,
        monthlyContribution: 1000,
        annualRate: 0.10,
        years: 10,
      );
      expect(
        r.totalInterest,
        closeTo(r.finalAmount - r.totalInvested, 0.01),
      );
    });

    test('totalInterest is positive with positive rate', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 1000,
        monthlyContribution: 100,
        annualRate: 0.06,
        years: 3,
      );
      expect(r.totalInterest, greaterThan(0));
    });

    // ── yearlyTimeline ───────────────────────────────────────────────────────

    test('yearlyTimeline first entry equals initialAmount', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 30000,
        monthlyContribution: 0,
        annualRate: 0.10,
        years: 5,
      );
      expect(r.yearlyTimeline.first, closeTo(30000, 0.01));
    });

    test('yearlyTimeline has years + 1 entries', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 0,
        monthlyContribution: 1000,
        annualRate: 0.10,
        years: 10,
      );
      expect(r.yearlyTimeline.length, 11);
    });

    test('yearlyTimeline last entry equals finalAmount', () {
      final CompoundResult r = CompoundInterestCalculator.calculate(
        initialAmount: 5000,
        monthlyContribution: 500,
        annualRate: 0.08,
        years: 8,
      );
      expect(r.yearlyTimeline.last, closeTo(r.finalAmount, 0.01));
    });

    // ── compare ──────────────────────────────────────────────────────────────

    test('compare returns one result per rate', () {
      final List<CompoundResult> results = CompoundInterestCalculator.compare(
        initialAmount: 10000,
        monthlyContribution: 500,
        rates: <double>[0.06, 0.10, 0.14],
        years: 20,
      );
      expect(results.length, 3);
    });

    test('compare: higher rate produces higher final amount', () {
      final List<CompoundResult> results = CompoundInterestCalculator.compare(
        initialAmount: 10000,
        monthlyContribution: 500,
        rates: <double>[0.06, 0.10, 0.14],
        years: 20,
      );
      expect(results[1].finalAmount, greaterThan(results[0].finalAmount));
      expect(results[2].finalAmount, greaterThan(results[1].finalAmount));
    });
  });
}
