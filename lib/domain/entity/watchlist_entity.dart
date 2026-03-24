import 'package:freezed_annotation/freezed_annotation.dart';

part 'watchlist_entity.freezed.dart';
part 'watchlist_entity.g.dart';

@freezed
sealed class WatchlistEntity with _$WatchlistEntity {
  const factory WatchlistEntity({
    required String uuid,
    required String userId,
    required String ticker,
    required DateTime addedAt,
    double? alertThreshold,
  }) = _WatchlistEntity;

  factory WatchlistEntity.fromJson(Map<String, Object?> json) =>
      _$WatchlistEntityFromJson(json);
}
