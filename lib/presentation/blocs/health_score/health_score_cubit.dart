import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/calendar_entity.dart';
import '../../../domain/entity/goal_entity.dart';
import '../../../domain/entity/type_entity.dart';
import '../../../domain/usecase/health_score.dart';
import '../../../utils/logger.dart';

part 'health_score_state.dart';
part 'health_score_cubit.freezed.dart';

class HealthScoreCubit extends Cubit<HealthScoreState> {
  HealthScoreCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const HealthScoreState.initial());

  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _txSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _limitSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _goalSub;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _txDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _limitDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _goalDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

  bool _txReady = false;
  bool _limitReady = false;
  bool _goalReady = false;

  Future<void> loadScore(String userId) async {
    if (userId.isEmpty) {
      return;
    }
    emit(const HealthScoreState.loading());

    await _txSub?.cancel();
    await _limitSub?.cancel();
    await _goalSub?.cancel();
    _txReady = false;
    _limitReady = false;
    _goalReady = false;

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
          onError: (Object e) => emit(HealthScoreState.error(e.toString())),
        );

    _limitSub = _firestore
        .collection('limit')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            _limitDocs = snap.docs;
            _limitReady = true;
            _tryRecompute();
          },
          onError: (Object e) => emit(HealthScoreState.error(e.toString())),
        );

    _goalSub = _firestore
        .collection('goal')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            _goalDocs = snap.docs;
            _goalReady = true;
            _tryRecompute();
          },
          onError: (Object e) => emit(HealthScoreState.error(e.toString())),
        );
  }

  void _tryRecompute() {
    if (!_txReady || !_limitReady || !_goalReady) {
      return;
    }
    try {
      _recompute();
    } on Exception catch (e) {
      logger.e('HealthScoreCubit error: $e');
      emit(HealthScoreState.error(e.toString()));
    }
  }

  void _recompute() {
    final DateTime now = DateTime.now();

    // ---------- Parse transactions ----------
    final List<_TxRecord> txRecords = <_TxRecord>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in _txDocs) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
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
      final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final String categoryUuid = data['categoryUUid'] as String? ?? '';
      txRecords.add(
        _TxRecord(
          date: date,
          typeUuid: typeUuid,
          amount: amount,
          categoryUuid: categoryUuid,
        ),
      );
    }

    // ---------- Current month aggregates ----------
    final double currentIncome = _sumForMonth(
      txRecords,
      now.year,
      now.month,
      TypeEntity.income.name,
    );
    final double currentExpenses = _sumForMonth(
      txRecords,
      now.year,
      now.month,
      TypeEntity.expense.name,
    );

    // ---------- Previous month aggregates ----------
    final DateTime prevMonth = DateTime(now.year, now.month - 1);
    final double prevExpenses = _sumForMonth(
      txRecords,
      prevMonth.year,
      prevMonth.month,
      TypeEntity.expense.name,
    );

    // ---------- Limit adherence ----------
    double avgLimitRatio = -1;
    if (_limitDocs.isNotEmpty) {
      final String currentMonthName = CalendarEntity.values[now.month - 1].name;
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> currentLimitDocs =
          _limitDocs
              .where(
                (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                    d.data()['month'] == currentMonthName,
              )
              .toList();

      if (currentLimitDocs.isNotEmpty) {
        final Map<String, double> spentByCategory = <String, double>{};
        for (final _TxRecord tx in txRecords) {
          if (tx.typeUuid != TypeEntity.expense.name) {
            continue;
          }
          if (tx.date.year != now.year || tx.date.month != now.month) {
            continue;
          }
          spentByCategory[tx.categoryUuid] =
              (spentByCategory[tx.categoryUuid] ?? 0.0) + tx.amount;
        }

        double ratioSum = 0;
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in currentLimitDocs) {
          final double limitAmount =
              (doc.data()['limitAmount'] as num?)?.toDouble() ?? 0.0;
          if (limitAmount <= 0) {
            continue;
          }
          final String catUuid = doc.data()['categoryUUid'] as String? ?? '';
          final double spent = spentByCategory[catUuid] ?? 0.0;
          ratioSum += spent / limitAmount;
        }
        avgLimitRatio = ratioSum / currentLimitDocs.length;
      }
    }

    // ---------- Goal progress ----------
    double avgGoalProgress = -1;
    if (_goalDocs.isNotEmpty) {
      final List<GoalEntity> goals = _goalDocs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
              final Map<String, dynamic> data =
                  Map<String, dynamic>.from(doc.data());
              final dynamic rawDeadline = data['deadline'];
              if (rawDeadline is Timestamp) {
                data['deadline'] = rawDeadline.toDate().toIso8601String();
              }
              return GoalEntity.fromJson(data);
            },
          )
          .toList();

      final List<GoalEntity> activeGoals =
          goals.where((GoalEntity g) => g.deadline.isAfter(now)).toList();

      if (activeGoals.isNotEmpty) {
        double progressSum = 0;
        for (final GoalEntity goal in activeGoals) {
          if (goal.targetAmount <= 0) {
            continue;
          }
          progressSum +=
              (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
        }
        avgGoalProgress = progressSum / activeGoals.length;
      }
    }

    // ---------- Current month score ----------
    final HealthScoreInput currentInput = HealthScoreInput(
      totalIncome: currentIncome,
      totalExpenses: currentExpenses,
      prevMonthExpenses: prevExpenses,
      avgLimitRatio: avgLimitRatio,
      avgGoalProgress: avgGoalProgress,
    );
    final int currentScore = computeHealthScore(currentInput);
    final int savingsPoints = savingsRateScore(currentIncome, currentExpenses);
    final int limitPoints = limitAdherenceScore(avgLimitRatio);
    final int goalPoints = goalProgressScore(avgGoalProgress);
    final int variancePoints =
        expenseVarianceScore(prevExpenses, currentExpenses);

    // ---------- Last 6 months sparkline ----------
    final List<int> last6 = <int>[];
    for (int i = 5; i >= 0; i--) {
      final DateTime month = DateTime(now.year, now.month - i);
      final double inc = _sumForMonth(
        txRecords,
        month.year,
        month.month,
        TypeEntity.income.name,
      );
      final double exp = _sumForMonth(
        txRecords,
        month.year,
        month.month,
        TypeEntity.expense.name,
      );
      final DateTime prevM = DateTime(month.year, month.month - 1);
      final double prevExp = _sumForMonth(
        txRecords,
        prevM.year,
        prevM.month,
        TypeEntity.expense.name,
      );
      final HealthScoreInput monthInput = HealthScoreInput(
        totalIncome: inc,
        totalExpenses: exp,
        prevMonthExpenses: prevExp,
        avgLimitRatio: avgLimitRatio,
        avgGoalProgress: avgGoalProgress,
      );
      last6.add(computeHealthScore(monthInput));
    }

    emit(
      HealthScoreState.success(
        HealthScoreData(
          score: currentScore,
          savingsPoints: savingsPoints,
          limitPoints: limitPoints,
          goalPoints: goalPoints,
          variancePoints: variancePoints,
          last6MonthScores: last6,
        ),
      ),
    );
  }

  double _sumForMonth(
    List<_TxRecord> records,
    int year,
    int month,
    String typeUuid,
  ) =>
      records
          .where(
            (_TxRecord r) =>
                r.date.year == year &&
                r.date.month == month &&
                r.typeUuid == typeUuid,
          )
          .fold(0.0, (double sum, _TxRecord r) => sum + r.amount);

  @override
  Future<void> close() {
    _txSub?.cancel();
    _limitSub?.cancel();
    _goalSub?.cancel();
    return super.close();
  }
}

class _TxRecord {
  const _TxRecord({
    required this.date,
    required this.typeUuid,
    required this.amount,
    required this.categoryUuid,
  });

  final DateTime date;
  final String typeUuid;
  final double amount;
  final String categoryUuid;
}
