import '../entity/investment_entity.dart';

/// Per-investment computed performance metrics.
class PortfolioPosition {
  const PortfolioPosition({
    required this.entity,
    required this.totalCost,
    required this.currentValue,
    required this.profit,
    required this.roiPercent,
  });

  final InvestmentEntity entity;

  /// Total amount invested = quantity × avgCost.
  final double totalCost;

  /// Current portfolio value = quantity × currentPrice.
  final double currentValue;

  /// Absolute gain/loss = currentValue − totalCost.
  final double profit;

  /// Return on investment in percent = (profit / totalCost) × 100.
  final double roiPercent;
}

/// Aggregated portfolio analytics returned by [PortfolioCalculator].
class PortfolioSummary {
  const PortfolioSummary({
    required this.positions,
    required this.totalCost,
    required this.totalValue,
    required this.totalProfit,
    required this.overallRoiPercent,
    required this.allocationByType,
    required this.bestPerformer,
    required this.worstPerformer,
  });

  final List<PortfolioPosition> positions;
  final double totalCost;
  final double totalValue;
  final double totalProfit;
  final double overallRoiPercent;

  /// Maps asset type (e.g. 'stock', 'fixed', 'crypto', 'other') → current value.
  final Map<String, double> allocationByType;

  /// Position with highest [PortfolioPosition.roiPercent]; null when empty.
  final PortfolioPosition? bestPerformer;

  /// Position with lowest [PortfolioPosition.roiPercent]; null when empty.
  final PortfolioPosition? worstPerformer;
}

/// Pure portfolio performance calculation — no Flutter dependencies.
class PortfolioCalculator {
  const PortfolioCalculator._();

  static PortfolioSummary calculate(List<InvestmentEntity> investments) {
    if (investments.isEmpty) {
      return const PortfolioSummary(
        positions: <PortfolioPosition>[],
        totalCost: 0,
        totalValue: 0,
        totalProfit: 0,
        overallRoiPercent: 0,
        allocationByType: <String, double>{},
        bestPerformer: null,
        worstPerformer: null,
      );
    }

    final List<PortfolioPosition> positions = investments.map(
      (InvestmentEntity e) {
        final double cost = e.quantity * e.avgCost;
        final double value = e.quantity * e.currentPrice;
        final double profit = value - cost;
        final double roi = cost > 0 ? (profit / cost) * 100 : 0;
        return PortfolioPosition(
          entity: e,
          totalCost: cost,
          currentValue: value,
          profit: profit,
          roiPercent: roi,
        );
      },
    ).toList();

    final double totalCost =
        positions.fold(0, (double s, PortfolioPosition p) => s + p.totalCost);
    final double totalValue =
        positions.fold(0, (double s, PortfolioPosition p) => s + p.currentValue);
    final double totalProfit = totalValue - totalCost;
    final double overallRoi = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0;

    // Build allocation map.
    final Map<String, double> allocation = <String, double>{};
    for (final PortfolioPosition p in positions) {
      final String type = p.entity.type;
      allocation[type] = (allocation[type] ?? 0) + p.currentValue;
    }

    // Sort by ROI to find best/worst.
    final List<PortfolioPosition> sorted = List<PortfolioPosition>.of(positions)
      ..sort(
        (PortfolioPosition a, PortfolioPosition b) =>
            b.roiPercent.compareTo(a.roiPercent),
      );

    return PortfolioSummary(
      positions: positions,
      totalCost: totalCost,
      totalValue: totalValue,
      totalProfit: totalProfit,
      overallRoiPercent: overallRoi,
      allocationByType: allocation,
      bestPerformer: sorted.first,
      worstPerformer: sorted.last,
    );
  }
}
