import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/pending_operation_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../domain/usecase/limit_alert_service.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'transaction_state.dart';
part 'transaction_cubit.freezed.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({FirebaseFirestore? firestore, LimitAlertService? limitAlertService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _limitAlertService = limitAlertService,
      super(const TransactionState.initial(<CategoryEntity>[]));

  final FirebaseFirestore _firestore;
  final LimitAlertService? _limitAlertService;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _txSubscription;

  Future<void> getCategories() async {
    final QuerySnapshot<Map<String, dynamic>> res =
        await _firestore.collection('category').get();

    final List<CategoryEntity> categories = res.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CategoryEntity.fromJson(doc.data()),
        )
        .toList();
    emit(TransactionState.initial(categories));
  }

  Future<void> saveTransaction(TransactionEntity transaction) async {
    try {
      emit(const TransactionState.loading());
      final Future<DocumentReference<Map<String, dynamic>>> addFuture =
          _firestore.collection('transaction').add(transaction.toJson());
      if (ConnectivityService.isOnlineSafe) {
        await addFuture.then(
          (DocumentReference<Object> doc) =>
              logger.d('DocumentSnapshot added with ID: ${doc.id}'),
        );
      } else {
        unawaited(addFuture);
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: transaction.userId,
          type: OperationType.create,
          collection: 'transaction',
          payload: transaction.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(TransactionState.success(transaction));
      unawaited(
        _limitAlertService?.checkAfterTransaction(transaction.userId),
      );
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> loadTransactions(String userId) async {
    emit(const TransactionState.loading());
    await _txSubscription?.cancel();
    _txSubscription = _firestore
        .collection('transaction')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final List<TransactionEntity> txs = snap.docs.map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                final Map<String, dynamic> data =
                    Map<String, dynamic>.from(doc.data());
                final dynamic rawDate = data['data'];
                if (rawDate is Timestamp) {
                  data['data'] = rawDate.toDate().toIso8601String();
                } else if (rawDate is DateTime) {
                  data['data'] = rawDate.toIso8601String();
                }
                return TransactionEntity.fromJson(data);
              },
            ).toList()
              ..sort(
                (TransactionEntity a, TransactionEntity b) =>
                    b.data.compareTo(a.data),
              );
            emit(TransactionState.listed(txs));
          },
          onError: (Object e) => emit(TransactionState.error(e.toString())),
        );
  }

  @override
  Future<void> close() {
    _txSubscription?.cancel();
    return super.close();
  }

  Future<void> deleteTransaction(String txUuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('transaction')
          .where('uuid', isEqualTo: txUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
        SyncQueue.enqueueIfOffline(
          PendingOperationEntity(
            uuid: const Uuid().v1(),
            userId: '',
            type: OperationType.delete,
            collection: 'transaction',
            payload: <String, dynamic>{'uuid': txUuid},
            createdAt: DateTime.now(),
          ),
        );
      }
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      emit(const TransactionState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('transaction')
          .where('uuid', isEqualTo: transaction.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        final Future<void> setFuture =
            snap.docs.first.reference.set(transaction.toJson());
        if (ConnectivityService.isOnlineSafe) {
          await setFuture;
        } else {
          unawaited(setFuture);
        }
        SyncQueue.enqueueIfOffline(
          PendingOperationEntity(
            uuid: const Uuid().v1(),
            userId: transaction.userId,
            type: OperationType.update,
            collection: 'transaction',
            payload: transaction.toJson(),
            createdAt: DateTime.now(),
          ),
        );
      }
      emit(TransactionState.success(transaction));
      unawaited(
        _limitAlertService?.checkAfterTransaction(transaction.userId),
      );
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }
}
