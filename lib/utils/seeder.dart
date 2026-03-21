import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/entity/calendar_entity.dart';
import '../domain/entity/category_entity.dart';
import '../domain/entity/limit_entity.dart';
import '../domain/entity/transaction_entity.dart';
import '../domain/entity/type_entity.dart';

/// Populates Firestore with realistic mock data for a given userId.
///
/// Safe to call multiple times — each call appends a new set of seeded
/// documents (categories, transactions, limits) without removing existing data.
class DevSeeder {
  const DevSeeder._();

  static const Uuid _uuid = Uuid();

  static Future<void> seed(String userId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // ── Categories (shared, no userId) ────────────────────────────────────
    // iconType indices match the _categoryIcons list in home_page.dart:
    //  0:share  1:play  2:taxi  3:star  4:camera  5:calendar
    //  6:upload 7:coffee 8:savings 9:clock 10:heart 11:compare
    final List<CategoryEntity> categories = <CategoryEntity>[
      CategoryEntity(uuid: _uuid.v4(), name: 'Alimentação', iconType: 7),
      CategoryEntity(uuid: _uuid.v4(), name: 'Transporte', iconType: 2),
      CategoryEntity(uuid: _uuid.v4(), name: 'Saúde', iconType: 10),
      CategoryEntity(uuid: _uuid.v4(), name: 'Lazer', iconType: 1),
      CategoryEntity(uuid: _uuid.v4(), name: 'Salário', iconType: 8),
    ];

    final WriteBatch catBatch = db.batch();
    for (final CategoryEntity cat in categories) {
      catBatch.set(db.collection('category').doc(), cat.toJson());
    }
    await catBatch.commit();

    // ── Transactions ───────────────────────────────────────────────────────
    final String alimentacaoUuid = categories[0].uuid;
    final String transporteUuid = categories[1].uuid;
    final String saudeUuid = categories[2].uuid;
    final String lazerUuid = categories[3].uuid;
    final String salarioUuid = categories[4].uuid;

    final int year = DateTime.now().year;

    final List<TransactionEntity> transactions = <TransactionEntity>[
      // January
      _tx(userId, 'Salário Janeiro', 5500, salarioUuid, TypeEntity.income, DateTime(year, 1, 5)),
      _tx(userId, 'Supermercado', 420, alimentacaoUuid, TypeEntity.expense, DateTime(year, 1, 10)),
      _tx(userId, 'Ônibus mensal', 180, transporteUuid, TypeEntity.expense, DateTime(year, 1, 12)),
      // February
      _tx(userId, 'Salário Fevereiro', 5500, salarioUuid, TypeEntity.income, DateTime(year, 2, 5)),
      _tx(userId, 'Restaurante', 95, alimentacaoUuid, TypeEntity.expense, DateTime(year, 2, 14)),
      _tx(userId, 'Consulta médica', 250, saudeUuid, TypeEntity.expense, DateTime(year, 2, 20)),
      // March
      _tx(userId, 'Salário Março', 5500, salarioUuid, TypeEntity.income, DateTime(year, 3, 5)),
      _tx(userId, 'Supermercado', 380, alimentacaoUuid, TypeEntity.expense, DateTime(year, 3, 8)),
      _tx(userId, 'Uber', 45, transporteUuid, TypeEntity.expense, DateTime(year, 3, 15)),
      _tx(userId, 'Cinema', 60, lazerUuid, TypeEntity.expense, DateTime(year, 3, 22)),
      _tx(userId, 'Farmácia', 130, saudeUuid, TypeEntity.expense, DateTime(year, 3, 25)),
      // April
      _tx(userId, 'Salário Abril', 5500, salarioUuid, TypeEntity.income, DateTime(year, 4, 5)),
      _tx(userId, 'Supermercado', 450, alimentacaoUuid, TypeEntity.expense, DateTime(year, 4, 7)),
      _tx(userId, 'Academia', 80, saudeUuid, TypeEntity.expense, DateTime(year, 4, 10)),
      _tx(userId, 'Show de música', 120, lazerUuid, TypeEntity.expense, DateTime(year, 4, 18)),
    ];

    final WriteBatch txBatch = db.batch();
    for (final TransactionEntity tx in transactions) {
      txBatch.set(db.collection('transaction').doc(), tx.toJson());
    }
    await txBatch.commit();

    // ── Limits (current month) ─────────────────────────────────────────────
    final CalendarEntity currentMonth =
        CalendarEntity.values[DateTime.now().month - 1];

    final List<LimitEntity> limits = <LimitEntity>[
      _limit(userId, alimentacaoUuid, currentMonth, 600),
      _limit(userId, transporteUuid, currentMonth, 250),
      _limit(userId, saudeUuid, currentMonth, 300),
      _limit(userId, lazerUuid, currentMonth, 200),
    ];

    final WriteBatch limitBatch = db.batch();
    for (final LimitEntity limit in limits) {
      limitBatch.set(db.collection('limit').doc(), limit.toJson());
    }
    await limitBatch.commit();
  }

  /// Removes all seeded data for the given userId.
  ///
  /// Deletes all documents in `transaction` and `limit` for this user,
  /// and ALL documents in `category` (categories have no userId field).
  static Future<void> clear(String userId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    await _deleteCollection(db, 'category');
    await _deleteByUserId(db, 'transaction', userId);
    await _deleteByUserId(db, 'limit', userId);
  }

  static Future<void> _deleteCollection(
    FirebaseFirestore db,
    String collection,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await db.collection(collection).get();
    final WriteBatch batch = db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<void> _deleteByUserId(
    FirebaseFirestore db,
    String collection,
    String userId,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> snap = await db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();
    final WriteBatch batch = db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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
