import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../utils/logger.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const CategoryState.initial(-1));

  final FirebaseFirestore _firestore;

  void changeSelectedCategory(int index) {
    if (state == CategoryState.initial(index)) {
      emit(const CategoryState.initial(-1));
      return;
    }
    emit(CategoryState.initial(index));
  }

  Future<void> saveCategory(CategoryEntity category) async {
    try {
      emit(const CategoryState.loading());
      await _firestore
          .collection('category')
          .add(category.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(CategoryState.success(category));
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }
}
