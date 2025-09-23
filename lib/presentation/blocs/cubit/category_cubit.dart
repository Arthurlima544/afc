import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

class CategoryCubit extends Cubit<int> {
  CategoryCubit() : super(-1);

  void changeSelectedCategory(int index) {
    if (state == index) {
      emit(-1);
    }
    emit(index);
  }

  void saveCategory(int index, String category) {
    if (state == index) {
      emit(-1);
    }
    emit(index);
  }
}
