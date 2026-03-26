import 'package:afc/domain/entity/spending_insight.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/usecase/insight_engine.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionEntity _tx({
  required String type,
  required double amount,
  String categoryUUid = 'cat-1',
  String title = 'tx',
}) =>
    TransactionEntity(
      uuid: 'u',
      amount: amount,
      categoryUUid: categoryUUid,
      typeUuid: type,
      data: DateTime(2025, 3),
      title: title,
      userId: 'user-1',
    );

const Map<String, String> _cats = <String, String>{
  'cat-1': 'Alimentação',
  'cat-2': 'Transporte',
};

void main() {
  group('InsightEngine.generate', () {
    test('returns empty list when no transactions', () {
      final List<SpendingInsight> result = InsightEngine.generate(
        currentMonth: <TransactionEntity>[],
        prevMonth: <TransactionEntity>[],
        categoryNames: _cats,
      );
      expect(result, isEmpty);
    });

    group('topCategory', () {
      test('identifies category with highest total expense', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 200),
            _tx(type: 'expense', amount: 500, categoryUUid: 'cat-2'),
            _tx(type: 'expense', amount: 100),
          ],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.topCategory,
        );
        expect(insight.subtitle, 'Transporte'); // cat-2 has 500
      });

      test('falls back to uuid when category name unknown', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 100, categoryUUid: 'cat-unknown'),
          ],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.topCategory,
        );
        expect(insight.subtitle, 'cat-unknown');
      });

      test('not produced when no expense transactions', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
          ],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        expect(
          result.any((SpendingInsight i) => i.type == InsightType.topCategory),
          isFalse,
        );
      });
    });

    group('biggestExpense', () {
      test('identifies single largest expense transaction', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 100, title: 'Pequeno'),
            _tx(type: 'expense', amount: 800, title: 'Grande'),
            _tx(type: 'expense', amount: 50, title: 'Mínimo'),
          ],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.biggestExpense,
        );
        expect(insight.subtitle, 'Grande');
      });

      test('not produced when no expense transactions', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        expect(
          result.any(
            (SpendingInsight i) => i.type == InsightType.biggestExpense,
          ),
          isFalse,
        );
      });
    });

    group('monthOverMonthDelta', () {
      test('computes positive delta when expenses increased', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 1500),
          ],
          prevMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 1000),
          ],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.monthOverMonthDelta,
        );
        expect(insight.subtitle, '+50.0%');
      });

      test('computes negative delta when expenses decreased', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 800),
          ],
          prevMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 1000),
          ],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.monthOverMonthDelta,
        );
        expect(insight.subtitle, '-20.0%');
      });

      test('not produced when previous month has no expenses', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 500),
          ],
          prevMonth: <TransactionEntity>[],
          categoryNames: _cats,
        );
        expect(
          result.any(
            (SpendingInsight i) => i.type == InsightType.monthOverMonthDelta,
          ),
          isFalse,
        );
      });
    });

    group('savingsRateTrend', () {
      test('shows improving when savings rate increased', () {
        // curr: income=5000, expenses=1000 → rate=80%
        // prev: income=5000, expenses=3000 → rate=40%
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
            _tx(type: 'expense', amount: 1000),
          ],
          prevMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
            _tx(type: 'expense', amount: 3000),
          ],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.savingsRateTrend,
        );
        expect(insight.subtitle, '↑ Melhorando');
      });

      test('shows worsening when savings rate decreased', () {
        // curr: income=5000, expenses=3000 → rate=40%
        // prev: income=5000, expenses=1000 → rate=80%
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
            _tx(type: 'expense', amount: 3000),
          ],
          prevMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
            _tx(type: 'expense', amount: 1000),
          ],
          categoryNames: _cats,
        );
        final SpendingInsight insight = result.firstWhere(
          (SpendingInsight i) => i.type == InsightType.savingsRateTrend,
        );
        expect(insight.subtitle, '↓ Piorando');
      });

      test('not produced when either month has no income', () {
        final List<SpendingInsight> result = InsightEngine.generate(
          currentMonth: <TransactionEntity>[
            _tx(type: 'expense', amount: 500),
          ],
          prevMonth: <TransactionEntity>[
            _tx(type: 'income', amount: 5000),
          ],
          categoryNames: _cats,
        );
        expect(
          result.any(
            (SpendingInsight i) => i.type == InsightType.savingsRateTrend,
          ),
          isFalse,
        );
      });
    });

    test('all four insights produced with full data', () {
      final List<SpendingInsight> result = InsightEngine.generate(
        currentMonth: <TransactionEntity>[
          _tx(type: 'income', amount: 5000),
          _tx(type: 'expense', amount: 1000),
          _tx(type: 'expense', amount: 300, categoryUUid: 'cat-2', title: 'Ônibus'),
        ],
        prevMonth: <TransactionEntity>[
          _tx(type: 'income', amount: 4000),
          _tx(type: 'expense', amount: 1200),
        ],
        categoryNames: _cats,
      );
      expect(result.length, 4);
      expect(
        result.map((SpendingInsight i) => i.type),
        containsAll(<InsightType>[
          InsightType.topCategory,
          InsightType.biggestExpense,
          InsightType.monthOverMonthDelta,
          InsightType.savingsRateTrend,
        ]),
      );
    });
  });
}
