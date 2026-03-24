import 'package:afc/domain/entity/transaction_entity.dart';
import 'package:afc/domain/usecase/transaction_grouper.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionEntity _tx(String title, {double amount = 10.0}) =>
    TransactionEntity(
      uuid: title,
      amount: amount,
      categoryUUid: '',
      typeUuid: 'expense',
      data: DateTime(2025, 3),
      title: title,
      userId: 'u1',
    );

void main() {
  group('TransactionGrouper.group', () {
    test('empty list → empty result', () {
      expect(TransactionGrouper.group(<TransactionEntity>[]), isEmpty);
    });

    test('UBER → Transporte por app', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('UBER * VIAGEM')]);
      expect(groups.length, 1);
      expect(groups.first.label, 'Transporte por app');
    });

    test('iFood → Delivery', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('IFOOD*LANCHES')]);
      expect(groups.first.label, 'Delivery');
    });

    test('PIX → Transferências PIX', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('PIX RECEBIDO')]);
      expect(groups.first.label, 'Transferências PIX');
    });

    test('Carrefour → Supermercado', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('CARREFOUR BAIRRO')]);
      expect(groups.first.label, 'Supermercado');
    });

    test('MERCADO LIVRE → Compras online (before generic MERCADO)', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[_tx('MERCADO LIVRE BR')],
      );
      expect(groups.first.label, 'Compras online');
    });

    test('MERCADO (generic) → Supermercado', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[_tx('SUPERMERCADO EXTRA')],
      );
      expect(groups.first.label, 'Supermercado');
    });

    test('Netflix → Assinaturas', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('NETFLIX.COM')]);
      expect(groups.first.label, 'Assinaturas');
    });

    test('FARMACIA → Saúde', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('FARMACIA POPULAR')]);
      expect(groups.first.label, 'Saúde');
    });

    test('CINEMA → Lazer', () {
      final List<TransactionGroup> groups =
          TransactionGrouper.group(<TransactionEntity>[_tx('CINEPOLIS CINEMA')]);
      expect(groups.first.label, 'Lazer');
    });

    test('unknown title → Outros', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[_tx('LOJA XYZ DESCONHECIDA')],
      );
      expect(groups.first.label, 'Outros');
    });

    test('groups are sorted by total descending', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[
          _tx('IFOOD LANCHE', amount: 30.0),
          _tx('UBER VIAGEM', amount: 50.0),
          _tx('NETFLIX', amount: 40.0),
        ],
      );
      expect(groups[0].total, greaterThanOrEqualTo(groups[1].total));
      expect(groups[1].total, greaterThanOrEqualTo(groups[2].total));
    });

    test('total is the sum of all transactions in the group', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[
          _tx('UBER TRIP 1', amount: 20.0),
          _tx('UBER TRIP 2', amount: 15.0),
        ],
      );
      expect(groups.length, 1);
      expect(groups.first.total, 35.0);
    });

    test('multiple groups split correctly', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[
          _tx('UBER TRIP', amount: 25.0),
          _tx('NETFLIX ASSINATURA', amount: 40.0),
          _tx('CARREFOUR COMPRAS', amount: 200.0),
        ],
      );
      expect(groups.length, 3);
      final List<String> labels =
          groups.map((TransactionGroup g) => g.label).toList();
      expect(labels, containsAll(<String>[
        'Transporte por app',
        'Assinaturas',
        'Supermercado',
      ]));
    });

    test('case-insensitive matching', () {
      final List<TransactionGroup> groups = TransactionGrouper.group(
        <TransactionEntity>[_tx('ifood pedido')],
      );
      expect(groups.first.label, 'Delivery');
    });
  });
}
