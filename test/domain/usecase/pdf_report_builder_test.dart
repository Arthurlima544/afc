import 'dart:typed_data';

import 'package:afc/domain/entity/goal_entity.dart';
import 'package:afc/domain/entity/investment_entity.dart';
import 'package:afc/domain/entity/report_data.dart';
import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/usecase/pdf_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PdfReportBuilder', () {
    const ReportData emptyData = ReportData(
      year: 2025,
      month: 3,
      totalIncome: 0,
      totalExpenses: 0,
      expensesByCategory: <String, double>{},
      categoryNames: <String, String>{},
      prevMonthIncome: 0,
      prevMonthExpenses: 0,
      prevExpensesByCategory: <String, double>{},
    );

    final ReportData richData = ReportData(
      year: 2025,
      month: 3,
      totalIncome: 5000,
      totalExpenses: 3200,
      expensesByCategory: const <String, double>{
        'cat-food': 800,
        'cat-transport': 400,
        'cat-health': 200,
      },
      categoryNames: const <String, String>{
        'cat-food': 'Alimentação',
        'cat-transport': 'Transporte',
        'cat-health': 'Saúde',
      },
      prevMonthIncome: 4800,
      prevMonthExpenses: 3100,
      prevExpensesByCategory: const <String, double>{
        'cat-food': 750,
        'cat-transport': 350,
      },
      userName: 'João Silva',
      transactions: <TransactionEntity>[
        TransactionEntity(
          uuid: 'tx-1',
          amount: 5000,
          categoryUUid: 'cat-food',
          typeUuid: 'income',
          data: DateTime(2025, 3, 5),
          title: 'Salário',
          userId: 'user-1',
        ),
        TransactionEntity(
          uuid: 'tx-2',
          amount: 800,
          categoryUUid: 'cat-food',
          typeUuid: 'expense',
          data: DateTime(2025, 3, 10),
          title: 'Supermercado',
          userId: 'user-1',
        ),
        TransactionEntity(
          uuid: 'tx-3',
          amount: 400,
          categoryUUid: 'cat-transport',
          typeUuid: 'expense',
          data: DateTime(2025, 3, 15),
          title: 'Combustível',
          userId: 'user-1',
        ),
      ],
      goals: <GoalEntity>[
        GoalEntity(
          uuid: 'goal-1',
          userId: 'user-1',
          name: 'Reserva de emergência',
          targetAmount: 20000,
          currentAmount: 8000,
          deadline: DateTime(2026, 12, 31),
          icon: 0,
        ),
      ],
      investments: <InvestmentEntity>[
        const InvestmentEntity(
          uuid: 'inv-1',
          userId: 'user-1',
          name: 'Tesouro SELIC',
          type: 'fixed_income',
          quantity: 1,
          avgCost: 10000,
          currentPrice: 10500,
        ),
      ],
      monthHistory: <MonthSummary>[
        const MonthSummary(
          year: 2025,
          month: 3,
          income: 5000,
          expenses: 3200,
        ),
        const MonthSummary(
          year: 2025,
          month: 2,
          income: 4800,
          expenses: 3100,
        ),
        const MonthSummary(
          year: 2025,
          month: 1,
          income: 4600,
          expenses: 3000,
        ),
      ],
    );

    test('returns non-empty bytes for empty report data', () async {
      final Uint8List bytes = await PdfReportBuilder.build(emptyData);
      expect(bytes.isNotEmpty, isTrue);
    });

    test('output starts with PDF magic header (%PDF-)', () async {
      final Uint8List bytes = await PdfReportBuilder.build(emptyData);
      // PDF files start with: %PDF- (0x25 0x50 0x44 0x46 0x2D)
      expect(bytes[0], equals(0x25)); // %
      expect(bytes[1], equals(0x50)); // P
      expect(bytes[2], equals(0x44)); // D
      expect(bytes[3], equals(0x46)); // F
    });

    test('builds successfully with rich report data', () async {
      final Uint8List bytes = await PdfReportBuilder.build(richData);
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes[0], equals(0x25)); // % — valid PDF header
    });

    test('returns more bytes for rich data than empty data', () async {
      final Uint8List emptyBytes = await PdfReportBuilder.build(emptyData);
      final Uint8List richBytes = await PdfReportBuilder.build(richData);
      expect(richBytes.length, greaterThan(emptyBytes.length));
    });

    test('MonthSummary savingsRate is 0 when income is 0', () {
      const MonthSummary summary =
          MonthSummary(year: 2025, month: 1, income: 0, expenses: 500);
      expect(summary.savingsRate, equals(0));
    });

    test('MonthSummary savingsRate computed correctly', () {
      const MonthSummary summary =
          MonthSummary(year: 2025, month: 1, income: 4000, expenses: 3000);
      expect(summary.savingsRate, closeTo(25.0, 0.001));
    });
  });
}
