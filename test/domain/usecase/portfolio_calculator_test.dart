import 'package:afc/domain/entity/investment_entity.dart';
import 'package:afc/domain/usecase/portfolio_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

InvestmentEntity _inv({
  String uuid = 'uuid-1',
  String name = 'Test',
  String type = 'stock',
  double quantity = 10,
  double avgCost = 100,
  double currentPrice = 120,
}) =>
    InvestmentEntity(
      uuid: uuid,
      userId: 'user-1',
      name: name,
      type: type,
      quantity: quantity,
      avgCost: avgCost,
      currentPrice: currentPrice,
    );

void main() {
  group('PortfolioCalculator', () {
    // ── empty portfolio ───────────────────────────────────────────────────────

    test('returns zeros for empty list', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[],
      );
      expect(s.totalCost, 0);
      expect(s.totalValue, 0);
      expect(s.totalProfit, 0);
      expect(s.overallRoiPercent, 0);
      expect(s.positions, isEmpty);
      expect(s.bestPerformer, isNull);
      expect(s.worstPerformer, isNull);
    });

    // ── single position ───────────────────────────────────────────────────────

    test('computes position metrics correctly', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(),
        ],
      );
      final PortfolioPosition p = s.positions.first;
      expect(p.totalCost, closeTo(1000, 0.01));
      expect(p.currentValue, closeTo(1200, 0.01));
      expect(p.profit, closeTo(200, 0.01));
      expect(p.roiPercent, closeTo(20, 0.01));
    });

    test('handles negative profit (loss) correctly', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(currentPrice: 80),
        ],
      );
      expect(s.totalProfit, closeTo(-200, 0.01));
      expect(s.overallRoiPercent, closeTo(-20, 0.01));
    });

    // ── overall metrics ───────────────────────────────────────────────────────

    test('totalValue, totalCost, totalProfit, overallRoi sum correctly', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(uuid: '1'),
          _inv(uuid: '2', quantity: 5, avgCost: 200, currentPrice: 180),
        ],
      );
      // Position 1: cost=1000, value=1200, profit=200
      // Position 2: cost=1000, value=900, profit=-100
      expect(s.totalCost, closeTo(2000, 0.01));
      expect(s.totalValue, closeTo(2100, 0.01));
      expect(s.totalProfit, closeTo(100, 0.01));
      expect(s.overallRoiPercent, closeTo(5, 0.01));
    });

    // ── allocation ───────────────────────────────────────────────────────────

    test('allocationByType sums value by type', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(uuid: '1', currentPrice: 100),
          _inv(uuid: '2', quantity: 5, currentPrice: 200),
          _inv(uuid: '3', type: 'fixed', quantity: 1, currentPrice: 5000),
        ],
      );
      expect(s.allocationByType['stock'], closeTo(2000, 0.01));
      expect(s.allocationByType['fixed'], closeTo(5000, 0.01));
    });

    // ── best / worst ─────────────────────────────────────────────────────────

    test('bestPerformer has highest ROI', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(uuid: '1', name: 'A', currentPrice: 150), // +50%
          _inv(uuid: '2', name: 'B', currentPrice: 110), // +10%
          _inv(uuid: '3', name: 'C', currentPrice: 80),  // -20%
        ],
      );
      expect(s.bestPerformer?.entity.name, 'A');
      expect(s.worstPerformer?.entity.name, 'C');
    });

    test('single position: bestPerformer == worstPerformer', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[_inv()],
      );
      expect(s.bestPerformer, equals(s.worstPerformer));
    });

    // ── edge cases ───────────────────────────────────────────────────────────

    test('zero avgCost does not throw — roi is 0', () {
      final PortfolioSummary s = PortfolioCalculator.calculate(
        <InvestmentEntity>[
          _inv(avgCost: 0, currentPrice: 50),
        ],
      );
      expect(s.positions.first.roiPercent, 0);
    });
  });
}
