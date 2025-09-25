part of 'limit_cubit.dart';

@freezed
class LimitState with _$LimitState {
  const factory LimitState.initial(List<CategoryEntity> categories) = _Initial;
  const factory LimitState.loading() = _Loading;
  const factory LimitState.error(String message) = _Error;
  const factory LimitState.success(LimitEntity limit) = _Success;
}
