import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/raw_transaction_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../domain/entity/type_entity.dart';
import '../../../utils/categorization.dart';

part 'review_queue_state.dart';
part 'review_queue_cubit.freezed.dart';

class ReviewQueueCubit extends Cubit<ReviewQueueState> {
  ReviewQueueCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ReviewQueueState.initial());

  final FirebaseFirestore _firestore;
  List<CategoryEntity> _categories = <CategoryEntity>[];

  List<CategoryEntity> get categories => _categories;

  Future<void> loadQueue(String userId) async {
    try {
      emit(const ReviewQueueState.loading());

      final QuerySnapshot<Map<String, dynamic>> txSnap = await _firestore
          .collection('raw_transaction')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('date', descending: true)
          .get();

      final QuerySnapshot<Map<String, dynamic>> catSnap =
          await _firestore.collection('category').get();

      _categories = catSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                CategoryEntity.fromJson(doc.data()),
          )
          .toList();

      final List<ReviewItem> items = txSnap.docs.map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          final dynamic rawDate = data['date'];
          if (rawDate is Timestamp) {
            data['date'] = rawDate.toDate().toIso8601String();
          }
          final RawTransactionEntity rawTx =
              RawTransactionEntity.fromJson(data);
          final String? suggested =
              suggestCategoryUuid(rawTx.description, _categories);
          final String? suggestedName = suggested == null
              ? null
              : _categories
                    .where(
                      (CategoryEntity c) => c.uuid == suggested,
                    )
                    .map((CategoryEntity c) => c.name)
                    .firstOrNull;
          return ReviewItem(
            rawTransaction: rawTx,
            selectedCategoryUuid: suggested,
            selectedCategoryName: suggestedName,
          );
        },
      ).toList();

      emit(ReviewQueueState.listed(items));
    } on Exception catch (e) {
      emit(ReviewQueueState.error(e.toString()));
    }
  }

  void updateItemCategory(
    String rawTxUuid,
    String categoryUuid,
    String categoryName,
  ) {
    final ReviewQueueState current = state;
    if (current is! _Listed) {
      return;
    }
    final List<ReviewItem> updated = current.items.map((ReviewItem item) {
      if (item.rawTransaction.uuid == rawTxUuid) {
        return item.copyWith(
          selectedCategoryUuid: categoryUuid,
          selectedCategoryName: categoryName,
        );
      }
      return item;
    }).toList();
    emit(ReviewQueueState.listed(updated));
  }

  Future<void> confirmTransaction(ReviewItem item, String userId) async {
    try {
      final String newUuid = const Uuid().v4();
      final TransactionEntity tx = TransactionEntity(
        uuid: newUuid,
        amount: item.rawTransaction.amount,
        categoryUUid: item.selectedCategoryUuid ?? '',
        typeUuid: item.rawTransaction.type == 'debit'
            ? TypeEntity.expense.name
            : TypeEntity.income.name,
        data: item.rawTransaction.date,
        title: item.rawTransaction.description,
        userId: userId,
      );

      await _firestore.collection('transaction').add(tx.toJson());

      final QuerySnapshot<Map<String, dynamic>> rawSnap = await _firestore
          .collection('raw_transaction')
          .where(
            'pluggyTransactionId',
            isEqualTo: item.rawTransaction.pluggyTransactionId,
          )
          .limit(1)
          .get();
      if (rawSnap.docs.isNotEmpty) {
        await rawSnap.docs.first.reference
            .update(<String, dynamic>{'status': 'confirmed'});
      }

      final ReviewQueueState current = state;
      if (current is _Listed) {
        final List<ReviewItem> updated = current.items
            .where(
              (ReviewItem i) =>
                  i.rawTransaction.uuid != item.rawTransaction.uuid,
            )
            .toList();
        emit(ReviewQueueState.listed(updated));
      }
    } on Exception catch (e) {
      emit(ReviewQueueState.error(e.toString()));
    }
  }

  Future<void> ignoreTransaction(String rawTxUuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('raw_transaction')
          .where('uuid', isEqualTo: rawTxUuid)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference
            .update(<String, dynamic>{'status': 'ignored'});
      }

      final ReviewQueueState current = state;
      if (current is _Listed) {
        final List<ReviewItem> updated = current.items
            .where(
              (ReviewItem i) => i.rawTransaction.uuid != rawTxUuid,
            )
            .toList();
        emit(ReviewQueueState.listed(updated));
      }
    } on Exception catch (e) {
      emit(ReviewQueueState.error(e.toString()));
    }
  }
}
