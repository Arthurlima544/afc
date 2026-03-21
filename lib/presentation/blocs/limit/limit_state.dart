part of 'limit_cubit.dart';

/// Holds the computed progress for a single spending limit.
class LimitProgressItem {
  const LimitProgressItem({
    required this.categoryName,
    required this.iconType,
    required this.spent,
    required this.limitAmount,
  });

  final String categoryName;
  final int iconType;
  final double spent;
  final double limitAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitProgressItem &&
          runtimeType == other.runtimeType &&
          categoryName == other.categoryName &&
          iconType == other.iconType &&
          spent == other.spent &&
          limitAmount == other.limitAmount;

  @override
  int get hashCode =>
      Object.hash(categoryName, iconType, spent, limitAmount);
}

@freezed
class LimitState with _$LimitState {
  const factory LimitState.initial(List<CategoryEntity> categories) = _Initial;
  const factory LimitState.loading() = _Loading;
  const factory LimitState.loaded(List<LimitProgressItem> items) = _Loaded;
  const factory LimitState.error(String message) = _Error;
  const factory LimitState.success(LimitEntity limit) = _Success;
}
