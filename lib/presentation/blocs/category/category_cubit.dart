import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/category_entity.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryState.initial(-1));

  void changeSelectedCategory(int index) {
    if (state == index) {
      emit(const CategoryState.initial(-1));
    }
    emit(CategoryState.initial(index));
  }

  Future<void> saveCategory(CategoryEntity category) async {
    try {
      emit(const CategoryState.loading());
      await FirebaseFirestore.instance
          .collection('category')
          .add(category.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                print('DocumentSnapshot added with ID: ${doc.id}'),
          );
      emit(CategoryState.success(category));
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }
}
