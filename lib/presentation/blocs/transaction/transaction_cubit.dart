import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../utils/logger.dart';

part 'transaction_state.dart';
part 'transaction_cubit.freezed.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const TransactionState.initial(<CategoryEntity>[]));

  final FirebaseFirestore _firestore;
  String _userId = '';

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
      await _firestore
          .collection('transaction')
          .add(transaction.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(TransactionState.success(transaction));
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> loadTransactions(String userId) async {
    try {
      _userId = userId;
      emit(const TransactionState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .get();
      final List<TransactionEntity> txs = snap.docs.map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          final dynamic rawDate = data['data'];
          final DateTime date;
          if (rawDate is Timestamp) {
            date = rawDate.toDate();
          } else if (rawDate is DateTime) {
            date = rawDate;
          } else {
            date = DateTime.parse(rawDate as String);
          }
          return TransactionEntity.fromJson(
            <String, dynamic>{...data, 'data': date.toIso8601String()},
          );
        },
      ).toList()
        ..sort(
          (TransactionEntity a, TransactionEntity b) =>
              b.data.compareTo(a.data),
        );
      emit(TransactionState.listed(txs));
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> deleteTransaction(String txUuid) async {
    try {
      emit(const TransactionState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('transaction')
          .where('uuid', isEqualTo: txUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      await loadTransactions(_userId);
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
        await snap.docs.first.reference.set(transaction.toJson());
      }
      emit(TransactionState.success(transaction));
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }
}
