import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/benefit_entity.dart';
import '../../../domain/entity/pending_operation_entity.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'benefit_state.dart';
part 'benefit_cubit.freezed.dart';

class BenefitCubit extends Cubit<BenefitState> {
  BenefitCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const BenefitState.initial());

  final FirebaseFirestore _firestore;

  static const String _collection = 'benefit';

  Future<void> loadBenefits(String userId) async {
    emit(const BenefitState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final List<BenefitEntity> benefits = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                BenefitEntity.fromJson(doc.data()),
          )
          .toList();

      emit(BenefitState.listed(benefits));
    } on Exception catch (e) {
      emit(BenefitState.error(e.toString()));
    }
  }

  Future<void> create(BenefitEntity benefit) async {
    try {
      emit(const BenefitState.loading());
      await _firestore
          .collection(_collection)
          .add(benefit.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('Benefit added with ID: ${doc.id}'),
          );
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: benefit.userId,
          type: OperationType.create,
          collection: _collection,
          payload: benefit.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(BenefitState.success(benefit));
    } on Exception catch (e) {
      emit(BenefitState.error(e.toString()));
    }
  }

  Future<void> update(BenefitEntity benefit) async {
    try {
      emit(const BenefitState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: benefit.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(benefit.toJson());
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: benefit.userId,
          type: OperationType.update,
          collection: _collection,
          payload: benefit.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(BenefitState.success(benefit));
    } on Exception catch (e) {
      emit(BenefitState.error(e.toString()));
    }
  }

  Future<void> delete(String benefitUuid, String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: benefitUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: userId,
          type: OperationType.delete,
          collection: _collection,
          payload: <String, dynamic>{'uuid': benefitUuid},
          createdAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(BenefitState.error(e.toString()));
    }
  }

  /// Deducts [amount] from the benefit's current balance.
  Future<void> deduct(BenefitEntity benefit, double amount) async {
    final BenefitEntity updated = benefit.copyWith(
      balance: (benefit.balance - amount).clamp(0.0, double.infinity),
    );
    await update(updated);
  }

  /// Resets [benefit] balance back to its [BenefitEntity.monthlyCredit] if
  /// the current month differs from the last reset month.
  Future<void> resetMonthIfNeeded(BenefitEntity benefit) async {
    final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    if (benefit.resetMonth == currentMonth) {
      return;
    }
    final BenefitEntity reset = benefit.copyWith(
      balance: benefit.monthlyCredit,
      resetMonth: currentMonth,
    );
    await update(reset);
  }
}
