import '../entity/transaction_entity.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A named bucket of transactions with a pre-computed total.
class TransactionGroup {
  const TransactionGroup({
    required this.label,
    required this.transactions,
    required this.total,
  });

  final String label;
  final List<TransactionEntity> transactions;

  /// Sum of [TransactionEntity.amount] for all transactions in the group.
  final double total;
}

// ---------------------------------------------------------------------------
// Grouper
// ---------------------------------------------------------------------------

/// Groups a flat list of transactions into labelled buckets
/// by matching the title against well-known Brazilian merchant patterns.
///
/// The matching is case-insensitive and uses substring search. The first
/// matching rule wins. Unmatched transactions fall into "Outros".
class TransactionGrouper {
  const TransactionGrouper._();

  // Order matters: more-specific patterns must come before generic ones
  // (e.g. 'MERCADO LIVRE' before 'MERCADO').
  static const List<({String keyword, String label})> _kRules =
      <({String keyword, String label})>[
    // Transfers
    (keyword: 'PIX', label: 'Transferências PIX'),
    (keyword: 'TED', label: 'Transferências bancárias'),
    (keyword: 'DOC', label: 'Transferências bancárias'),
    // Ride-sharing
    (keyword: 'UBER', label: 'Transporte por app'),
    (keyword: '99POP', label: 'Transporte por app'),
    (keyword: 'CABIFY', label: 'Transporte por app'),
    (keyword: 'INDRIVER', label: 'Transporte por app'),
    // Food delivery
    (keyword: 'IFOOD', label: 'Delivery'),
    (keyword: 'RAPPI', label: 'Delivery'),
    (keyword: 'UBER EATS', label: 'Delivery'),
    (keyword: 'DELIVERY', label: 'Delivery'),
    // Supermarkets (specific before generic)
    (keyword: 'MERCADO LIVRE', label: 'Compras online'),
    (keyword: 'MERCADOPAGO', label: 'Compras online'),
    (keyword: 'PÃO DE AÇÚCAR', label: 'Supermercado'),
    (keyword: 'CARREFOUR', label: 'Supermercado'),
    (keyword: 'ATACADÃO', label: 'Supermercado'),
    (keyword: 'ATACADAO', label: 'Supermercado'),
    (keyword: 'ASSAI', label: 'Supermercado'),
    (keyword: 'SUPERMERCADO', label: 'Supermercado'),
    (keyword: 'MERCADO', label: 'Supermercado'),
    // Subscriptions
    (keyword: 'NETFLIX', label: 'Assinaturas'),
    (keyword: 'SPOTIFY', label: 'Assinaturas'),
    (keyword: 'AMAZON PRIME', label: 'Assinaturas'),
    (keyword: 'DISNEY', label: 'Assinaturas'),
    (keyword: 'HBO', label: 'Assinaturas'),
    (keyword: 'GLOBOPLAY', label: 'Assinaturas'),
    (keyword: 'YOUTUBE PREMIUM', label: 'Assinaturas'),
    // Health
    (keyword: 'FARMACIA', label: 'Saúde'),
    (keyword: 'FARMÁCIA', label: 'Saúde'),
    (keyword: 'DROGARIA', label: 'Saúde'),
    (keyword: 'HOSPITAL', label: 'Saúde'),
    (keyword: 'ACADEMIA', label: 'Saúde'),
    // Restaurants
    (keyword: 'RESTAURANTE', label: 'Restaurantes'),
    (keyword: 'LANCHONETE', label: 'Restaurantes'),
    (keyword: 'PADARIA', label: 'Restaurantes'),
    (keyword: 'PIZZA', label: 'Restaurantes'),
    // Fuel
    (keyword: 'COMBUSTIVEL', label: 'Combustível'),
    (keyword: 'COMBUSTÍVEL', label: 'Combustível'),
    (keyword: 'GASOLINA', label: 'Combustível'),
    // Entertainment
    (keyword: 'CINEMA', label: 'Lazer'),
    (keyword: 'TEATRO', label: 'Lazer'),
    (keyword: 'SHOPPING', label: 'Lazer'),
  ];

  static String _labelFor(TransactionEntity tx) {
    final String upper = tx.title.toUpperCase();
    for (final ({String keyword, String label}) rule in _kRules) {
      if (upper.contains(rule.keyword)) {
        return rule.label;
      }
    }
    return 'Outros';
  }

  /// Returns groups sorted by [TransactionGroup.total] descending.
  static List<TransactionGroup> group(List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> map =
        <String, List<TransactionEntity>>{};

    for (final TransactionEntity tx in transactions) {
      map.putIfAbsent(_labelFor(tx), () => <TransactionEntity>[]).add(tx);
    }

    final List<TransactionGroup> groups = map.entries
        .map(
          (MapEntry<String, List<TransactionEntity>> e) => TransactionGroup(
            label: e.key,
            transactions: e.value,
            total: e.value.fold(
              0.0,
              (double sum, TransactionEntity tx) => sum + tx.amount,
            ),
          ),
        )
        .toList()
      ..sort(
        (TransactionGroup a, TransactionGroup b) =>
            b.total.compareTo(a.total),
      );

    return groups;
  }
}
