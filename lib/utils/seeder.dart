import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/entity/bill_entity.dart';
import '../domain/entity/calendar_entity.dart';
import '../domain/entity/category_entity.dart';
import '../domain/entity/frequency_entity.dart';
import '../domain/entity/goal_entity.dart';
import '../domain/entity/investment_entity.dart';
import '../domain/entity/limit_entity.dart';
import '../domain/entity/net_worth_snapshot_entity.dart';
import '../domain/entity/passive_income_entity.dart';
import '../domain/entity/recurring_entity.dart';
import '../domain/entity/template_entity.dart';
import '../domain/entity/transaction_entity.dart';
import '../domain/entity/type_entity.dart';
import '../domain/entity/watchlist_entity.dart';

/// Populates Firestore with realistic mock data for a given userId.
///
/// Covers every user-facing collection: categories, transactions, limits,
/// goals, investments, bills, recurring rules, templates, passive income,
/// net worth snapshots, and watchlist entries.
///
/// Call [clear] first then [seed] for a clean slate.
class DevSeeder {
  const DevSeeder._();

  static const Uuid _uuid = Uuid();

  // ── Collections cleared by [clear] ──────────────────────────────────────
  static const List<String> _userCollections = <String>[
    'transaction',
    'limit',
    'goal',
    'investment',
    'bill',
    'recurring',
    'template',
    'passive_income',
    'net_worth_snapshot',
    'watchlist',
    'raw_transaction',
    'connected_account',
    'categorisation_rule',
  ];

  // =========================================================================
  // seed
  // =========================================================================

  static Future<void> seed(String userId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final int year = DateTime.now().year;
    final CalendarEntity currentMonth =
        CalendarEntity.values[DateTime.now().month - 1];

    // ── 1. Categories (shared, no userId) ──────────────────────────────────
    // iconType indices match _categoryIcons in design_system / home_page
    final List<CategoryEntity> categories = <CategoryEntity>[
      CategoryEntity(uuid: _uuid.v4(), name: 'Alimentação', iconType: 7),
      CategoryEntity(uuid: _uuid.v4(), name: 'Transporte', iconType: 2),
      CategoryEntity(uuid: _uuid.v4(), name: 'Saúde', iconType: 10),
      CategoryEntity(uuid: _uuid.v4(), name: 'Lazer', iconType: 1),
      CategoryEntity(uuid: _uuid.v4(), name: 'Salário', iconType: 8),
      CategoryEntity(uuid: _uuid.v4(), name: 'Moradia', iconType: 0),
      CategoryEntity(uuid: _uuid.v4(), name: 'Educação', iconType: 5),
      CategoryEntity(uuid: _uuid.v4(), name: 'Investimentos', iconType: 11),
    ];

    final WriteBatch catBatch = db.batch();
    for (final CategoryEntity cat in categories) {
      catBatch.set(db.collection('category').doc(), cat.toJson());
    }
    await catBatch.commit();

    final String alimentacaoId = categories[0].uuid;
    final String transporteId = categories[1].uuid;
    final String saudeId = categories[2].uuid;
    final String lazerId = categories[3].uuid;
    final String salarioId = categories[4].uuid;
    final String moradiaId = categories[5].uuid;
    final String educacaoId = categories[6].uuid;

    // ── 2. Transactions — 6 months of history ──────────────────────────────
    final List<TransactionEntity> transactions = <TransactionEntity>[
      // Month -5
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 5, 5)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month - 5, 10)),
      _tx(userId, 'Supermercado', 420, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 5, 12)),
      _tx(userId, 'Ônibus mensal', 180, transporteId, TypeEntity.expense, DateTime(year, DateTime.now().month - 5, 13)),
      // Month -4
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 4, 5)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month - 4, 10)),
      _tx(userId, 'Supermercado', 390, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 4, 11)),
      _tx(userId, 'Consulta médica', 250, saudeId, TypeEntity.expense, DateTime(year, DateTime.now().month - 4, 18)),
      _tx(userId, 'Curso online', 120, educacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 4, 22)),
      // Month -3
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 3, 5)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month - 3, 10)),
      _tx(userId, 'Supermercado', 450, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 3, 9)),
      _tx(userId, 'Uber', 65, transporteId, TypeEntity.expense, DateTime(year, DateTime.now().month - 3, 15)),
      _tx(userId, 'Cinema', 80, lazerId, TypeEntity.expense, DateTime(year, DateTime.now().month - 3, 20)),
      _tx(userId, 'Farmácia', 110, saudeId, TypeEntity.expense, DateTime(year, DateTime.now().month - 3, 24)),
      // Month -2
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 2, 5)),
      _tx(userId, 'Freelance', 1200, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 2, 20)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month - 2, 10)),
      _tx(userId, 'Supermercado', 480, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 2, 8)),
      _tx(userId, 'Restaurante', 95, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 2, 14)),
      _tx(userId, 'Academia', 80, saudeId, TypeEntity.expense, DateTime(year, DateTime.now().month - 2, 10)),
      _tx(userId, 'Show de música', 150, lazerId, TypeEntity.expense, DateTime(year, DateTime.now().month - 2, 18)),
      // Month -1
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month - 1, 5)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month - 1, 10)),
      _tx(userId, 'Supermercado', 410, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 1, 7)),
      _tx(userId, 'Uber', 45, transporteId, TypeEntity.expense, DateTime(year, DateTime.now().month - 1, 16)),
      _tx(userId, 'Plano de saúde', 220, saudeId, TypeEntity.expense, DateTime(year, DateTime.now().month - 1, 10)),
      _tx(userId, 'Livro técnico', 90, educacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month - 1, 21)),
      // Current month
      _tx(userId, 'Salário', 6500, salarioId, TypeEntity.income, DateTime(year, DateTime.now().month, 5)),
      _tx(userId, 'Aluguel', 1800, moradiaId, TypeEntity.expense, DateTime(year, DateTime.now().month, 10)),
      _tx(userId, 'Supermercado', 260, alimentacaoId, TypeEntity.expense, DateTime(year, DateTime.now().month, 8)),
      _tx(userId, 'Gasolina', 120, transporteId, TypeEntity.expense, DateTime(year, DateTime.now().month, 12)),
      _tx(userId, 'Academia', 80, saudeId, TypeEntity.expense, DateTime(year, DateTime.now().month, 10)),
      _tx(userId, 'Streaming', 45, lazerId, TypeEntity.expense, DateTime(year, DateTime.now().month, 5)),
    ];

    final WriteBatch txBatch = db.batch();
    for (final TransactionEntity tx in transactions) {
      txBatch.set(db.collection('transaction').doc(), tx.toJson());
    }
    await txBatch.commit();

    // ── 3. Limits (current month) ───────────────────────────────────────────
    final List<LimitEntity> limits = <LimitEntity>[
      _limit(userId, alimentacaoId, currentMonth, 700),
      _limit(userId, transporteId, currentMonth, 300),
      _limit(userId, saudeId, currentMonth, 350),
      _limit(userId, lazerId, currentMonth, 200),
      _limit(userId, moradiaId, currentMonth, 2000),
    ];

    final WriteBatch limitBatch = db.batch();
    for (final LimitEntity limit in limits) {
      limitBatch.set(db.collection('limit').doc(), limit.toJson());
    }
    await limitBatch.commit();

    // ── 4. Goals ───────────────────────────────────────────────────────────
    final List<GoalEntity> goals = <GoalEntity>[
      GoalEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Reserva de emergência',
        targetAmount: 30000,
        currentAmount: 18500,
        deadline: DateTime(year + 1, 6),
        icon: 8, // savings
      ),
      GoalEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Viagem Europa',
        targetAmount: 15000,
        currentAmount: 4200,
        deadline: DateTime(year + 1, 12),
        icon: 1, // flight/play
      ),
      GoalEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Carro novo',
        targetAmount: 60000,
        currentAmount: 12000,
        deadline: DateTime(year + 3),
        icon: 2, // car/taxi
      ),
    ];

    final WriteBatch goalBatch = db.batch();
    for (final GoalEntity goal in goals) {
      goalBatch.set(db.collection('goal').doc(), goal.toJson());
    }
    await goalBatch.commit();

    // ── 5. Investments ─────────────────────────────────────────────────────
    final List<InvestmentEntity> investments = <InvestmentEntity>[
      InvestmentEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Petrobras',
        type: 'Ações',
        quantity: 100,
        avgCost: 32.50,
        currentPrice: 38.20,
        ticker: 'PETR4',
      ),
      InvestmentEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Vale',
        type: 'Ações',
        quantity: 50,
        avgCost: 68.00,
        currentPrice: 72.80,
        ticker: 'VALE3',
      ),
      InvestmentEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Tesouro IPCA+ 2029',
        type: 'Renda Fixa',
        quantity: 1,
        avgCost: 5000,
        currentPrice: 5380,
      ),
      InvestmentEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'CDB Banco Inter 110% CDI',
        type: 'Renda Fixa',
        quantity: 1,
        avgCost: 8000,
        currentPrice: 8640,
      ),
      InvestmentEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Bitcoin',
        type: 'Cripto',
        quantity: 0.05,
        avgCost: 280000,
        currentPrice: 320000,
        ticker: 'BTC',
      ),
    ];

    final WriteBatch investBatch = db.batch();
    for (final InvestmentEntity inv in investments) {
      investBatch.set(db.collection('investment').doc(), inv.toJson());
    }
    await investBatch.commit();

    // ── 6. Bills ───────────────────────────────────────────────────────────
    final List<BillEntity> bills = <BillEntity>[
      BillEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Aluguel',
        amount: 1800,
        dueDay: 10,
        categoryUuid: moradiaId,
      ),
      BillEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Plano de saúde',
        amount: 220,
        dueDay: 15,
        categoryUuid: saudeId,
      ),
      BillEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Academia',
        amount: 80,
        dueDay: 10,
        categoryUuid: saudeId,
      ),
    ];

    final WriteBatch billBatch = db.batch();
    for (final BillEntity bill in bills) {
      billBatch.set(db.collection('bill').doc(), bill.toJson());
    }
    await billBatch.commit();

    // ── 7. Recurring rules ─────────────────────────────────────────────────
    final TransactionEntity salaryTemplate = _tx(
      userId,
      'Salário',
      6500,
      salarioId,
      TypeEntity.income,
      DateTime(year, DateTime.now().month + 1, 5),
    );
    final TransactionEntity rentTemplate = _tx(
      userId,
      'Aluguel',
      1800,
      moradiaId,
      TypeEntity.expense,
      DateTime(year, DateTime.now().month + 1, 10),
    );

    final List<RecurringEntity> recurring = <RecurringEntity>[
      RecurringEntity(
        uuid: _uuid.v4(),
        userId: userId,
        templateTransaction: salaryTemplate,
        frequency: FrequencyEntity.monthly.name,
        nextDue: DateTime(year, DateTime.now().month + 1, 5),
        active: true,
      ),
      RecurringEntity(
        uuid: _uuid.v4(),
        userId: userId,
        templateTransaction: rentTemplate,
        frequency: FrequencyEntity.monthly.name,
        nextDue: DateTime(year, DateTime.now().month + 1, 10),
        active: true,
      ),
    ];

    final WriteBatch recurringBatch = db.batch();
    for (final RecurringEntity rule in recurring) {
      recurringBatch.set(db.collection('recurring').doc(), rule.toJson());
    }
    await recurringBatch.commit();

    // ── 8. Templates ───────────────────────────────────────────────────────
    final List<TemplateEntity> templates = <TemplateEntity>[
      TemplateEntity(
        uuid: _uuid.v4(),
        userId: userId,
        title: 'Supermercado',
        amount: 400,
        categoryUUid: alimentacaoId,
        typeUuid: TypeEntity.expense.name,
      ),
      TemplateEntity(
        uuid: _uuid.v4(),
        userId: userId,
        title: 'Uber trabalho',
        amount: 25,
        categoryUUid: transporteId,
        typeUuid: TypeEntity.expense.name,
      ),
    ];

    final WriteBatch templateBatch = db.batch();
    for (final TemplateEntity tmpl in templates) {
      templateBatch.set(db.collection('template').doc(), tmpl.toJson());
    }
    await templateBatch.commit();

    // ── 9. Passive income ──────────────────────────────────────────────────
    final List<PassiveIncomeEntity> passiveIncomes = <PassiveIncomeEntity>[
      PassiveIncomeEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Dividendos PETR4',
        source: 'Ações',
        amount: 320,
        frequency: FrequencyEntity.monthly.name,
      ),
      PassiveIncomeEntity(
        uuid: _uuid.v4(),
        userId: userId,
        name: 'Rendimento CDB',
        source: 'Renda Fixa',
        amount: 120,
        frequency: FrequencyEntity.monthly.name,
      ),
    ];

    final WriteBatch passiveBatch = db.batch();
    for (final PassiveIncomeEntity pi in passiveIncomes) {
      passiveBatch.set(db.collection('passive_income').doc(), pi.toJson());
    }
    await passiveBatch.commit();

    // ── 10. Net worth snapshots — 6 months ─────────────────────────────────
    final List<NetWorthSnapshotEntity> snapshots = <NetWorthSnapshotEntity>[];
    for (int i = 5; i >= 0; i--) {
      final DateTime d = DateTime(year, DateTime.now().month - i);
      final String label = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      final double base = 28000 + (5 - i) * 2800.0;
      snapshots.add(
        NetWorthSnapshotEntity(
          uuid: _uuid.v4(),
          userId: userId,
          date: label,
          assets: base + 5000,
          liabilities: 4200 - i * 300.0,
          netWorth: base + 5000 - (4200 - i * 300.0),
        ),
      );
    }

    final WriteBatch snapshotBatch = db.batch();
    for (final NetWorthSnapshotEntity snap in snapshots) {
      snapshotBatch.set(
        db.collection('net_worth_snapshot').doc(),
        snap.toJson(),
      );
    }
    await snapshotBatch.commit();

    // ── 11. Watchlist ──────────────────────────────────────────────────────
    final List<WatchlistEntity> watchlist = <WatchlistEntity>[
      WatchlistEntity(
        uuid: _uuid.v4(),
        userId: userId,
        ticker: 'ITUB4',
        addedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WatchlistEntity(
        uuid: _uuid.v4(),
        userId: userId,
        ticker: 'WEGE3',
        addedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      WatchlistEntity(
        uuid: _uuid.v4(),
        userId: userId,
        ticker: 'MGLU3',
        addedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    final WriteBatch watchlistBatch = db.batch();
    for (final WatchlistEntity w in watchlist) {
      watchlistBatch.set(db.collection('watchlist').doc(), w.toJson());
    }
    await watchlistBatch.commit();
  }

  // =========================================================================
  // clear
  // =========================================================================

  /// Removes all data for [userId] across every collection, plus all shared
  /// category documents (categories have no userId field).
  static Future<void> clear(String userId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    await _deleteCollection(db, 'category');
    await Future.wait(
      _userCollections.map((String col) => _deleteByUserId(db, col, userId)),
    );
  }

  // =========================================================================
  // Private helpers
  // =========================================================================

  static Future<void> _deleteCollection(
    FirebaseFirestore db,
    String collection,
  ) async {
    QuerySnapshot<Map<String, dynamic>> snap =
        await db.collection(collection).limit(400).get();
    while (snap.docs.isNotEmpty) {
      final WriteBatch batch = db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      snap = await db.collection(collection).limit(400).get();
    }
  }

  static Future<void> _deleteByUserId(
    FirebaseFirestore db,
    String collection,
    String userId,
  ) async {
    QuerySnapshot<Map<String, dynamic>> snap = await db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .limit(400)
        .get();
    while (snap.docs.isNotEmpty) {
      final WriteBatch batch = db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      snap = await db
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .limit(400)
          .get();
    }
  }

  static TransactionEntity _tx(
    String userId,
    String title,
    double amount,
    String categoryUuid,
    TypeEntity type,
    DateTime date,
  ) => TransactionEntity(
    uuid: _uuid.v4(),
    userId: userId,
    title: title,
    amount: amount,
    categoryUUid: categoryUuid,
    typeUuid: type.name,
    data: date,
  );

  static LimitEntity _limit(
    String userId,
    String categoryUuid,
    CalendarEntity month,
    double limitAmount,
  ) => LimitEntity(
    uuid: _uuid.v4(),
    userId: userId,
    categoryUUid: categoryUuid,
    month: month.name,
    limitAmount: limitAmount,
  );
}
