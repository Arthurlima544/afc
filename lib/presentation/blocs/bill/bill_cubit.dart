import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/bill_entity.dart';
import '../../../domain/entity/pending_operation_entity.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'bill_state.dart';
part 'bill_cubit.freezed.dart';

class BillCubit extends Cubit<BillState> {
  BillCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const BillState.initial());

  final FirebaseFirestore _firestore;

  Future<void> loadBills(String userId) async {
    emit(const BillState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('bill')
          .where('userId', isEqualTo: userId)
          .get();

      final List<BillEntity> bills = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                BillEntity.fromJson(doc.data()),
          )
          .toList();

      emit(BillState.listed(bills));
    } on Exception catch (e) {
      emit(BillState.error(e.toString()));
    }
  }

  Future<void> create(BillEntity bill) async {
    try {
      emit(const BillState.loading());
      await _firestore
          .collection('bill')
          .add(bill.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('Bill added with ID: ${doc.id}'),
          );
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: bill.userId,
          type: OperationType.create,
          collection: 'bill',
          payload: bill.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(BillState.success(bill));
    } on Exception catch (e) {
      emit(BillState.error(e.toString()));
    }
  }

  Future<void> delete(String uuid, String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('bill')
          .where('uuid', isEqualTo: uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: '',
          type: OperationType.delete,
          collection: 'bill',
          payload: <String, dynamic>{'uuid': uuid},
          createdAt: DateTime.now(),
        ),
      );
      await loadBills(userId);
    } on Exception catch (e) {
      emit(BillState.error(e.toString()));
    }
  }

  Future<void> update(BillEntity bill) async {
    try {
      emit(const BillState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('bill')
          .where('uuid', isEqualTo: bill.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(bill.toJson());
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: bill.userId,
          type: OperationType.update,
          collection: 'bill',
          payload: bill.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(BillState.success(bill));
    } on Exception catch (e) {
      emit(BillState.error(e.toString()));
    }
  }
}
