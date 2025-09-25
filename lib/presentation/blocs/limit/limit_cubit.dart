import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/limit_entity.dart';

part 'limit_state.dart';
part 'limit_cubit.freezed.dart';

class LimitCubit extends Cubit<LimitState> {
  LimitCubit() : super(const LimitState.initial(<CategoryEntity>[]));

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
    emit(LimitState.initial(categories));
  }

  Future<void> saveLimit(LimitEntity limit) async {
    try {
      emit(const LimitState.loading());
      await FirebaseFirestore.instance
          .collection('limit')
          .add(limit.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                print('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(LimitState.success(limit));
    } on Exception catch (e) {
      emit(LimitState.error(e.toString()));
    }
  }
}
