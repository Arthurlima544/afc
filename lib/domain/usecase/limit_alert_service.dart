import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/local_notification_service.dart';
import '../../utils/logger.dart';
import '../entity/limit_entity.dart';
import '../entity/transaction_entity.dart';

/// Shows a local notification. Defaults to [LocalNotificationService.instance.show].
typedef ShowNotification = Future<void> Function({
  required int id,
  required String title,
  required String body,
});

/// Checks spending limits after each transaction write.
///
/// Fires a local notification once per threshold crossing per category per
/// month. State is persisted in [SharedPreferences] using the key pattern
/// `limit_alert_<categoryUUid>_<month>_<threshold>` where threshold is either
/// `80` or `100`.
class LimitAlertService {
  LimitAlertService({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
    ShowNotification? showNotification,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs,
        _showNotification = showNotification ??
            (({required int id, required String title, required String body}) =>
                LocalNotificationService.instance.show(
                  id: id,
                  title: title,
                  body: body,
                ));

  final FirebaseFirestore _firestore;
  SharedPreferences? _prefs;
  final ShowNotification _showNotification;

  static const double _warningThreshold = 0.80;
  static const double _exceededThreshold = 1.00;

  static const int _warningNotifId = 2001;
  static const int _exceededNotifId = 2002;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Checks all active limits for [userId] and shows notifications if any
  /// threshold (80 % or 100 %) is crossed for the first time this month.
  Future<void> checkAfterTransaction(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    try {
      final DateTime now = DateTime.now();
      // month key format: "yyyy-MM" (matches LimitEntity.month)
      final String monthKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // Fetch limits for current month
      final QuerySnapshot<Map<String, dynamic>> limitSnap = await _firestore
          .collection('limit')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: monthKey)
          .get();

      if (limitSnap.docs.isEmpty) {
        return;
      }

      final List<LimitEntity> limits = limitSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                LimitEntity.fromJson(doc.data()),
          )
          .toList();

      // Fetch expenses for current month
      final QuerySnapshot<Map<String, dynamic>> txSnap = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .where('typeUuid', isEqualTo: 'expense')
          .get();

      final List<TransactionEntity> currentExpenses = txSnap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(doc.data());
            final dynamic rawDate = data['data'];
            if (rawDate is Timestamp) {
              data['data'] = rawDate.toDate().toIso8601String();
            }
            return TransactionEntity.fromJson(data);
          })
          .where(
            (TransactionEntity tx) =>
                tx.data.year == now.year && tx.data.month == now.month,
          )
          .toList();

      // Sum expenses by category
      final Map<String, double> spentByCategory = <String, double>{};
      for (final TransactionEntity tx in currentExpenses) {
        spentByCategory[tx.categoryUUid] =
            (spentByCategory[tx.categoryUUid] ?? 0.0) + tx.amount;
      }

      final SharedPreferences prefs = await _getPrefs();

      for (final LimitEntity limit in limits) {
        final double spent = spentByCategory[limit.categoryUUid] ?? 0.0;
        final double ratio = limit.limitAmount > 0 ? spent / limit.limitAmount : 0.0;

        await _checkThreshold(
          prefs: prefs,
          limit: limit,
          monthKey: monthKey,
          ratio: ratio,
          threshold: _exceededThreshold,
          thresholdLabel: '100',
          notifId: _exceededNotifId,
          title: 'Limite excedido',
          body: 'Você ultrapassou o limite de gasto desta categoria.',
        );

        await _checkThreshold(
          prefs: prefs,
          limit: limit,
          monthKey: monthKey,
          ratio: ratio,
          threshold: _warningThreshold,
          thresholdLabel: '80',
          notifId: _warningNotifId,
          title: 'Limite próximo',
          body: 'Você usou 80 % do limite de gasto desta categoria.',
        );
      }
    } on Exception catch (e) {
      logger.e('LimitAlertService error: $e');
    }
  }

  Future<void> _checkThreshold({
    required SharedPreferences prefs,
    required LimitEntity limit,
    required String monthKey,
    required double ratio,
    required double threshold,
    required String thresholdLabel,
    required int notifId,
    required String title,
    required String body,
  }) async {
    if (ratio < threshold) {
      return;
    }
    final String key =
        'limit_alert_${limit.categoryUUid}_${monthKey}_$thresholdLabel';
    if (prefs.getBool(key) ?? false) {
      return;
    }
    await prefs.setBool(key, true);
    try {
      await _showNotification(id: notifId, title: title, body: body);
    } on Exception catch (e) {
      // Notification service may not be initialised in dev — log and continue.
      logger.w('LimitAlertService notification error: $e');
    }
  }
}
