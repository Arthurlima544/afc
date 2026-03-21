part of 'category_cubit.dart';

@freezed
sealed class CategoryState with _$CategoryState {
  const factory CategoryState.initial(int index) = _Initial;
  const factory CategoryState.loading() = _Loading;
  const factory CategoryState.error(String message) = _Error;
  const factory CategoryState.success(CategoryEntity category) = _Success;
  const factory CategoryState.listed(List<CategoryEntity> categories) =
      _Listed;
}
