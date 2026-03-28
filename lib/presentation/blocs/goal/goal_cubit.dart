import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/goal_entity.dart';
import '../../../domain/entity/pending_operation_entity.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/review_service.dart';
import '../../../utils/sync_queue.dart';

part 'goal_state.dart';
part 'goal_cubit.freezed.dart';

class GoalCubit extends Cubit<GoalState> {
  GoalCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const GoalState.initial());

  final FirebaseFirestore _firestore;

  Future<void> loadGoals(String userId) async {
    emit(const GoalState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('goal')
          .where('userId', isEqualTo: userId)
          .get();

      final List<GoalEntity> goals = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                GoalEntity.fromJson(doc.data()),
          )
          .toList();

      emit(GoalState.listed(goals));
    } on Exception catch (e) {
      emit(GoalState.error(e.toString()));
    }
  }

  Future<void> create(GoalEntity goal) async {
    try {
      emit(const GoalState.loading());
      final Future<DocumentReference<Map<String, dynamic>>> addFuture =
          _firestore.collection('goal').add(goal.toJson());
      if (ConnectivityService.isOnlineSafe) {
        await addFuture.then(
          (DocumentReference<Object> doc) =>
              logger.d('Goal added with ID: ${doc.id}'),
        );
      } else {
        unawaited(addFuture);
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: goal.userId,
          type: OperationType.create,
          collection: 'goal',
          payload: goal.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(GoalState.success(goal));
    } on Exception catch (e) {
      emit(GoalState.error(e.toString()));
    }
  }

  Future<void> contribute(String goalUuid, double amount) async {
    try {
      emit(const GoalState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('goal')
          .where('uuid', isEqualTo: goalUuid)
          .get();

      if (snap.docs.isEmpty) {
        emit(const GoalState.error('Meta não encontrada.'));
        return;
      }

      final QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs.first;
      final GoalEntity current = GoalEntity.fromJson(doc.data());
      final GoalEntity updated = current.copyWith(
        currentAmount: current.currentAmount + amount,
      );
      final Future<void> setFutureContrib = doc.reference.set(updated.toJson());
      if (ConnectivityService.isOnlineSafe) {
        await setFutureContrib;
      } else {
        unawaited(setFutureContrib);
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: '',
          type: OperationType.update,
          collection: 'goal',
          payload: updated.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(GoalState.success(updated));

      // Prompt for a store review on the first goal completion.
      if (updated.currentAmount >= updated.targetAmount) {
        unawaited(ReviewService.maybeRequest());
      }
    } on Exception catch (e) {
      emit(GoalState.error(e.toString()));
    }
  }

  Future<void> delete(String goalUuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('goal')
          .where('uuid', isEqualTo: goalUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: '',
          type: OperationType.delete,
          collection: 'goal',
          payload: <String, dynamic>{'uuid': goalUuid},
          createdAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(GoalState.error(e.toString()));
    }
  }

  Future<void> update(GoalEntity goal) async {
    try {
      emit(const GoalState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('goal')
          .where('uuid', isEqualTo: goal.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        final Future<void> setFuture =
            snap.docs.first.reference.set(goal.toJson());
        if (ConnectivityService.isOnlineSafe) {
          await setFuture;
        } else {
          unawaited(setFuture);
        }
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: goal.userId,
          type: OperationType.update,
          collection: 'goal',
          payload: goal.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(GoalState.success(goal));
    } on Exception catch (e) {
      emit(GoalState.error(e.toString()));
    }
  }
}
