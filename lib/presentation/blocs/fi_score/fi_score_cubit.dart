import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/passive_income_entity.dart';
import '../../../domain/entity/type_entity.dart';
import '../../../utils/logger.dart';

part 'fi_score_state.dart';
part 'fi_score_cubit.freezed.dart';

// ---------------------------------------------------------------------------
// Data class
// ---------------------------------------------------------------------------

/// Snapshot of the user's financial independence progress.
class FiScoreData {
  const FiScoreData({
    required this.fiScore,
    required this.passiveIncomeMonthly,
    required this.monthlyExpenses,
    required this.last6Scores,
  });

  /// FI score 0–100: (passiveIncome / expenses) × 100, capped at 100.
  final double fiScore;

  /// Total monthly passive income equivalent across all streams.
  final double passiveIncomeMonthly;

  /// Current month's total expense transactions.
  final double monthlyExpenses;

  /// FI score for each of the last 6 months, oldest first.
  final List<double> last6Scores;

  /// Milestone thresholds that the user has reached (10 / 25 / 50 / 75 / 100).
  List<int> get achievedMilestones =>
      <int>[10, 25, 50, 75, 100]
          .where((int m) => fiScore >= m)
          .toList();
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class FiScoreCubit extends Cubit<FiScoreState> {
  FiScoreCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const FiScoreState.initial());

  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _piSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _txSub;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _piDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _txDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

  bool _piReady = false;
  bool _txReady = false;

  Future<void> load(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    emit(const FiScoreState.loading());

    await _piSub?.cancel();
    await _txSub?.cancel();
    _piReady = false;
    _txReady = false;

    _piSub = _firestore
        .collection('passive_income')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            _piDocs = snap.docs;
            _piReady = true;
            _tryRecompute();
          },
          onError: (Object e) => emit(FiScoreState.error(e.toString())),
        );

    _txSub = _firestore
        .collection('transaction')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            _txDocs = snap.docs;
            _txReady = true;
            _tryRecompute();
          },
          onError: (Object e) => emit(FiScoreState.error(e.toString())),
        );
  }

  void _tryRecompute() {
    if (!_piReady || !_txReady) {
      return;
    }
    try {
      _recompute();
    } on Exception catch (e) {
      logger.e('FiScoreCubit error: $e');
      emit(FiScoreState.error(e.toString()));
    }
  }

  void _recompute() {
    // ── Compute total monthly passive income ──────────────────────────────
    double totalMonthlyPassive = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in _piDocs) {
      final Map<String, dynamic> data = doc.data();
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final String frequency = data['frequency'] as String? ?? 'monthly';
      totalMonthlyPassive += monthlyEquivalent(amount, frequency);
    }

    // ── Parse expense transactions ────────────────────────────────────────
    final List<_TxRecord> txRecords = <_TxRecord>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in _txDocs) {
      final Map<String, dynamic> data = doc.data();
      final dynamic rawDate = data['data'];
      final DateTime date;
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is String) {
        date = DateTime.parse(rawDate);
      } else if (rawDate is DateTime) {
        date = rawDate;
      } else {
        continue;
      }
      final String typeUuid = data['typeUuid'] as String? ?? '';
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0;
      txRecords.add(
        _TxRecord(date: date, typeUuid: typeUuid, amount: amount),
      );
    }

    final DateTime now = DateTime.now();

    // ── Current month FI score ─────────────────────────────────────────────
    final double currentExpenses = _sumExpenses(txRecords, now.year, now.month);
    final double fiScore = _computeScore(totalMonthlyPassive, currentExpenses);

    // ── Last 6 months sparkline ────────────────────────────────────────────
    final List<double> last6 = <double>[];
    for (int i = 5; i >= 0; i--) {
      final DateTime month = DateTime(now.year, now.month - i);
      final double expenses = _sumExpenses(txRecords, month.year, month.month);
      last6.add(_computeScore(totalMonthlyPassive, expenses));
    }

    emit(
      FiScoreState.success(
        FiScoreData(
          fiScore: fiScore,
          passiveIncomeMonthly: totalMonthlyPassive,
          monthlyExpenses: currentExpenses,
          last6Scores: last6,
        ),
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  double _computeScore(double passiveIncome, double expenses) {
    if (expenses <= 0) {
      return passiveIncome > 0 ? 100.0 : 0.0;
    }
    return (passiveIncome / expenses * 100).clamp(0.0, 100.0);
  }

  double _sumExpenses(List<_TxRecord> records, int year, int month) =>
      records
          .where(
            (_TxRecord r) =>
                r.date.year == year &&
                r.date.month == month &&
                r.typeUuid == TypeEntity.expense.name,
          )
          .fold(0.0, (double sum, _TxRecord r) => sum + r.amount);

  @override
  Future<void> close() {
    _piSub?.cancel();
    _txSub?.cancel();
    return super.close();
  }
}

class _TxRecord {
  const _TxRecord({
    required this.date,
    required this.typeUuid,
    required this.amount,
  });

  final DateTime date;
  final String typeUuid;
  final double amount;
}
