import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/recurring_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../utils/logger.dart';

part 'recurring_state.dart';
part 'recurring_cubit.freezed.dart';

/// Advances [current] by one period of [frequency].
DateTime nextDueAfter(String frequency, DateTime current) {
  switch (frequency) {
    case 'daily':
      return current.add(const Duration(days: 1));
    case 'weekly':
      return current.add(const Duration(days: 7));
    case 'monthly':
      final int year = current.month == 12 ? current.year + 1 : current.year;
      final int month = current.month == 12 ? 1 : current.month + 1;
      return DateTime(year, month, current.day);
    default:
      return current.add(const Duration(days: 30));
  }
}

class RecurringCubit extends Cubit<RecurringState> {
  RecurringCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const RecurringState.initial());

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  // ---------------------------------------------------------------------------
  // Load (stream)
  // ---------------------------------------------------------------------------

  Future<void> loadRecurring(String userId) async {
    emit(const RecurringState.loading());
    await _subscription?.cancel();
    _subscription = _firestore
        .collection('recurring')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final List<RecurringEntity> rules = snap.docs.map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  _parseDoc(doc.data()),
            ).toList()
              ..sort(
                (RecurringEntity a, RecurringEntity b) =>
                    a.nextDue.compareTo(b.nextDue),
              );
            emit(RecurringState.listed(rules));
          },
          onError: (Object e) => emit(RecurringState.error(e.toString())),
        );
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> create(RecurringEntity rule) async {
    try {
      emit(const RecurringState.loading());
      await _firestore.collection('recurring').add(rule.toJson()).then(
        (DocumentReference<Object> doc) =>
            logger.d('Recurring rule added with ID: ${doc.id}'),
      );
      emit(RecurringState.success(rule));
    } on Exception catch (e) {
      emit(RecurringState.error(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Pause / Resume
  // ---------------------------------------------------------------------------

  Future<void> pause(String uuid) => _setActive(uuid, active: false);

  Future<void> resume(String uuid) => _setActive(uuid, active: true);

  Future<void> _setActive(String uuid, {required bool active}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('recurring')
          .where('uuid', isEqualTo: uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update(<String, bool>{'active': active});
      }
    } on Exception catch (e) {
      emit(RecurringState.error(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> delete(String uuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('recurring')
          .where('uuid', isEqualTo: uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
    } on Exception catch (e) {
      emit(RecurringState.error(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Materialise due transactions on app open
  // ---------------------------------------------------------------------------

  Future<void> checkAndMaterialise(String userId) async {
    try {
      final DateTime now = DateTime.now();

      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('recurring')
          .where('userId', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snap.docs) {
        RecurringEntity rule = _parseDoc(doc.data());

        if (!rule.nextDue.isBefore(now)) {
          continue;
        }

        DateTime nextDue = rule.nextDue;

        while (nextDue.isBefore(now)) {
          final TransactionEntity tx = rule.templateTransaction.copyWith(
            uuid: const Uuid().v1(),
            data: nextDue,
          );
          await _firestore.collection('transaction').add(tx.toJson());
          logger.d('Materialised recurring tx: ${tx.uuid} for ${tx.data}');

          nextDue = nextDueAfter(rule.frequency, nextDue);
        }

        rule = rule.copyWith(nextDue: nextDue);
        await doc.reference.set(rule.toJson());
      }
    } on Exception catch (e) {
      logger.e('checkAndMaterialise error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  RecurringEntity _parseDoc(Map<String, dynamic> data) {
    final Map<String, dynamic> d = Map<String, dynamic>.from(data);

    // Normalise top-level nextDue
    final dynamic rawNextDue = d['nextDue'];
    if (rawNextDue is Timestamp) {
      d['nextDue'] = rawNextDue.toDate().toIso8601String();
    } else if (rawNextDue is DateTime) {
      d['nextDue'] = rawNextDue.toIso8601String();
    }

    // Normalise templateTransaction.data
    final dynamic rawTx = d['templateTransaction'];
    if (rawTx is Map) {
      final Map<String, dynamic> tx = Map<String, dynamic>.from(rawTx);
      final dynamic rawDate = tx['data'];
      if (rawDate is Timestamp) {
        tx['data'] = rawDate.toDate().toIso8601String();
      } else if (rawDate is DateTime) {
        tx['data'] = rawDate.toIso8601String();
      }
      d['templateTransaction'] = tx;
    }

    return RecurringEntity.fromJson(d);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
