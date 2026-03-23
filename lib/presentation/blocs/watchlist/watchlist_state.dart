part of 'watchlist_cubit.dart';

@freezed
sealed class WatchlistState with _$WatchlistState {
  const factory WatchlistState.initial() = _Initial;
  const factory WatchlistState.loading() = _Loading;
  const factory WatchlistState.loaded({
    required List<WatchlistItem> items,
    required DateTime lastUpdated,
  }) = _Loaded;
  const factory WatchlistState.error(String message) = _Error;
}
