import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/pending_operation_entity.dart';
import '../../../domain/entity/sub_account_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'sub_account_state.dart';
part 'sub_account_cubit.freezed.dart';

class SubAccountCubit extends Cubit<SubAccountState> {
  SubAccountCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const SubAccountState.initial());

  final FirebaseFirestore _firestore;

  static const String _collection = 'sub_account';
  static const String _txCollection = 'transaction';

  Future<void> loadAccounts(String userId) async {
    emit(const SubAccountState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final List<SubAccountEntity> accounts = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                SubAccountEntity.fromJson(doc.data()),
          )
          .toList();

      emit(SubAccountState.listed(accounts, const <String, SubAccountTotals>{}));
    } on Exception catch (e) {
      emit(SubAccountState.error(e.toString()));
    }
  }

  Future<void> loadWithTotals(String userId) async {
    emit(const SubAccountState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> accSnap = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final List<SubAccountEntity> accounts = accSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                SubAccountEntity.fromJson(doc.data()),
          )
          .toList();

      final QuerySnapshot<Map<String, dynamic>> txSnap = await _firestore
          .collection(_txCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final List<TransactionEntity> txs = txSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                TransactionEntity.fromJson(doc.data()),
          )
          .toList();

      final Map<String, SubAccountTotals> totals = _computeTotals(
        accounts: accounts,
        transactions: txs,
      );

      emit(SubAccountState.listed(accounts, totals));
    } on Exception catch (e) {
      emit(SubAccountState.error(e.toString()));
    }
  }

  Future<void> create(SubAccountEntity account) async {
    try {
      emit(const SubAccountState.loading());
      await _firestore
          .collection(_collection)
          .add(account.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('SubAccount added: ${doc.id}'),
          );
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: account.userId,
          type: OperationType.create,
          collection: _collection,
          payload: account.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(SubAccountState.success(account));
    } on Exception catch (e) {
      emit(SubAccountState.error(e.toString()));
    }
  }

  Future<void> update(SubAccountEntity account) async {
    try {
      emit(const SubAccountState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: account.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(account.toJson());
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: account.userId,
          type: OperationType.update,
          collection: _collection,
          payload: account.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(SubAccountState.success(account));
    } on Exception catch (e) {
      emit(SubAccountState.error(e.toString()));
    }
  }

  Future<void> delete(String accountUuid, String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: accountUuid)
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
          payload: <String, dynamic>{'uuid': accountUuid},
          createdAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(SubAccountState.error(e.toString()));
    }
  }

  static Map<String, SubAccountTotals> _computeTotals({
    required List<SubAccountEntity> accounts,
    required List<TransactionEntity> transactions,
  }) {
    final Map<String, double> income = <String, double>{};
    final Map<String, double> expenses = <String, double>{};

    for (final SubAccountEntity acc in accounts) {
      income[acc.uuid] = 0.0;
      expenses[acc.uuid] = 0.0;
    }

    for (final TransactionEntity tx in transactions) {
      final String? uuid = tx.subAccountUuid;
      if (uuid == null || !income.containsKey(uuid)) {
        continue;
      }
      if (tx.typeUuid == 'income') {
        income[uuid] = (income[uuid] ?? 0.0) + tx.amount;
      } else {
        expenses[uuid] = (expenses[uuid] ?? 0.0) + tx.amount;
      }
    }

    return <String, SubAccountTotals>{
      for (final SubAccountEntity acc in accounts)
        acc.uuid: SubAccountTotals(
          income: income[acc.uuid] ?? 0.0,
          expenses: expenses[acc.uuid] ?? 0.0,
        ),
    };
  }
}
