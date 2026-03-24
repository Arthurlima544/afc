import 'package:afc/domain/usecase/investment_goal_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvestmentGoalCalculator', () {
    group('zero return rate', () {
      test('PMT = (target - current) / months when rate is 0%', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 120000.0,
          currentAmount: 0.0,
          months: 120,
          annualReturnPercent: 0,
        );
        // 120000 / 120 = 1000
        expect(result.requiredMonthlyContribution, closeTo(1000.0, 0.01));
      });

      test('PMT is reduced when currentAmount already contributes', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 120000.0,
          currentAmount: 60000.0,
          months: 120,
          annualReturnPercent: 0,
        );
        expect(result.requiredMonthlyContribution, closeTo(500.0, 0.01));
      });
    });

    group('with return rate', () {
      test('PMT is lower with 12% annual return vs 0%', () {
        final InvestmentGoalResult withReturn =
            InvestmentGoalCalculator.calculate(
          targetAmount: 1000000.0,
          currentAmount: 0.0,
          months: 240,
          annualReturnPercent: 12,
        );
        final InvestmentGoalResult noReturn =
            InvestmentGoalCalculator.calculate(
          targetAmount: 1000000.0,
          currentAmount: 0.0,
          months: 240,
          annualReturnPercent: 0,
        );
        expect(
          withReturn.requiredMonthlyContribution,
          lessThan(noReturn.requiredMonthlyContribution),
        );
      });

      test('PMT is 0 when currentAmount already exceeds target after growth',
          () {
        // 1M already in portfolio growing at 12% for 20 years will far exceed 1M
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 1000000.0,
          currentAmount: 2000000.0,
          months: 240,
          annualReturnPercent: 12,
        );
        expect(result.requiredMonthlyContribution, 0.0);
      });
    });

    group('totalContributed and totalInterestEarned', () {
      test('totalContributed = PMT * months', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 120000.0,
          currentAmount: 0.0,
          months: 120,
          annualReturnPercent: 0,
        );
        expect(
          result.totalContributed,
          closeTo(result.requiredMonthlyContribution * 120, 0.01),
        );
      });

      test('totalInterestEarned is 0 when rate is 0%', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 120000.0,
          currentAmount: 0.0,
          months: 120,
          annualReturnPercent: 0,
        );
        expect(result.totalInterestEarned, closeTo(0.0, 1.0));
      });

      test('totalInterestEarned > 0 when rate > 0%', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 1000000.0,
          currentAmount: 0.0,
          months: 240,
          annualReturnPercent: 10,
        );
        expect(result.totalInterestEarned, greaterThan(0));
      });
    });

    group('yearlyTimeline', () {
      test('timeline length equals years when months is multiple of 12', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 240000.0,
          currentAmount: 0.0,
          months: 120,
          annualReturnPercent: 0,
        );
        expect(result.yearlyTimeline.length, 10);
      });

      test('timeline is monotonically increasing with positive PMT', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 500000.0,
          currentAmount: 10000.0,
          months: 120,
          annualReturnPercent: 8,
        );
        for (int i = 1; i < result.yearlyTimeline.length; i++) {
          expect(
            result.yearlyTimeline[i],
            greaterThan(result.yearlyTimeline[i - 1]),
          );
        }
      });

      test('final timeline value approximates target', () {
        final InvestmentGoalResult result = InvestmentGoalCalculator.calculate(
          targetAmount: 1000000.0,
          currentAmount: 0.0,
          months: 120,
          annualReturnPercent: 10,
        );
        expect(result.yearlyTimeline.last, closeTo(1000000.0, 1000.0));
      });
    });
  });
}
