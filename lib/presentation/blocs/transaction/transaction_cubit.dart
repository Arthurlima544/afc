import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/transaction_entity.dart';

part 'transaction_state.dart';
part 'transaction_cubit.freezed.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit()
    : super(const TransactionState.initial(<CategoryEntity>[]));

  Future<void> getCategories() async {
    final QuerySnapshot<Map<String, dynamic>> res = await FirebaseFirestore
        .instance
        .collection('category')
        .get();

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
      await FirebaseFirestore.instance
          .collection('transaction')
          .add(transaction.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                print('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(TransactionState.success(transaction));
    } on Exception catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }
}
