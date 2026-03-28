import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setup_checklist_cubit.freezed.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@freezed
sealed class SetupChecklistState with _$SetupChecklistState {
  /// Not yet loaded.
  const factory SetupChecklistState.initial() = _Initial;

  /// User dismissed the checklist or all tasks are complete.
  const factory SetupChecklistState.hidden() = _Hidden;

  /// Checklist is visible with current task completion statuses.
  const factory SetupChecklistState.visible({
    required bool hasCategory,
    required bool hasTransaction,
    required bool hasLimit,
    required bool hasGoal,
    required bool hasInvestment,
  }) = _Visible;
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class SetupChecklistCubit extends Cubit<SetupChecklistState> {
  SetupChecklistCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const SetupChecklistState.initial());

  final FirebaseFirestore _firestore;

  static const String _dismissedKey = 'setup_checklist_dismissed';

  Future<void> load(String userId) async {
    if (userId.isEmpty) {
      emit(const SetupChecklistState.hidden());
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dismissedKey) == true) {
      emit(const SetupChecklistState.hidden());
      return;
    }

    final List<bool> results = await Future.wait(<Future<bool>>[
      _hasAny('category', 'userId', userId),
      _hasAny('transaction', 'userId', userId),
      _hasAny('limit', 'userId', userId),
      _hasAny('goal', 'userId', userId),
      _hasAny('investment', 'userId', userId),
    ]);

    final bool hasCategory = results[0];
    final bool hasTransaction = results[1];
    final bool hasLimit = results[2];
    final bool hasGoal = results[3];
    final bool hasInvestment = results[4];

    if (hasCategory && hasTransaction && hasLimit && hasGoal && hasInvestment) {
      emit(const SetupChecklistState.hidden());
      return;
    }

    emit(
      SetupChecklistState.visible(
        hasCategory: hasCategory,
        hasTransaction: hasTransaction,
        hasLimit: hasLimit,
        hasGoal: hasGoal,
        hasInvestment: hasInvestment,
      ),
    );
  }

  Future<void> dismiss() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, true);
    emit(const SetupChecklistState.hidden());
  }

  Future<bool> _hasAny(
    String collection,
    String field,
    String userId,
  ) async {
    // For 'category', records are not filtered by userId.
    final Query<Map<String, dynamic>> query = collection == 'category'
        ? _firestore.collection(collection).limit(1)
        : _firestore
              .collection(collection)
              .where(field, isEqualTo: userId)
              .limit(1);
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    return snap.docs.isNotEmpty;
  }
}
