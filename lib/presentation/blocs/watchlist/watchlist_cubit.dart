import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/market_quote_entity.dart';
import '../../../domain/entity/watchlist_entity.dart';
import '../../../domain/usecase/brapi_service.dart';
import '../../../utils/logger.dart';
import 'watchlist_item.dart';

part 'watchlist_state.dart';
part 'watchlist_cubit.freezed.dart';

/// Manages the user's stock/FII watchlist.
///
/// Tickers are persisted in Firestore (`watchlist` collection).
/// Live quotes are fetched from Brapi and refreshed every 60 seconds
/// while the cubit is alive (i.e. while the screen is open).
/// The polling timer is automatically cancelled in [close].
class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({FirebaseFirestore? firestore, BrapiService? service})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _service = service ?? BrapiService(),
        super(const WatchlistState.initial());

  final FirebaseFirestore _firestore;
  final BrapiService _service;

  Timer? _pollTimer;
  String _userId = '';

  static const Duration _pollInterval = Duration(seconds: 60);
  // Brapi free tier: up to 10 tickers per batch request comfortably.
  static const int _batchSize = 10;

  // ─── Public API ──────────────────────────────────────────────────────────────

  Future<void> loadWatchlist(String userId) async {
    _userId = userId;
    emit(const WatchlistState.loading());
    try {
      final List<WatchlistEntity> entities = await _fetchEntities(userId);
      final List<WatchlistItem> items = await _buildItems(entities);
      _emitLoaded(items);
      _startPolling();
      // Fetch sparklines in background without blocking UI.
      unawaited(_loadSparklines());
    } on Exception catch (e) {
      logger.e('WatchlistCubit.loadWatchlist failed', error: e);
      emit(WatchlistState.error(e.toString()));
    }
  }

  Future<void> addTicker(String ticker, {double? alertThreshold}) async {
    emit(const WatchlistState.loading());
    final WatchlistEntity entity = WatchlistEntity(
      uuid: const Uuid().v1(),
      userId: _userId,
      ticker: ticker.toUpperCase().trim(),
      addedAt: DateTime.now(),
      alertThreshold: alertThreshold,
    );
    await _firestore.collection('watchlist').add(entity.toJson());
    await loadWatchlist(_userId);
  }

  Future<void> removeTicker(String uuid) async {
    emit(const WatchlistState.loading());
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection('watchlist')
        .where('uuid', isEqualTo: uuid)
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      await doc.reference.delete();
    }
    await loadWatchlist(_userId);
  }

  Future<void> setAlert(String uuid, double? threshold) async {
    emit(const WatchlistState.loading());
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection('watchlist')
        .where('uuid', isEqualTo: uuid)
        .get();
    if (snap.docs.isEmpty) {
      return;
    }
    final WatchlistEntity current =
        WatchlistEntity.fromJson(snap.docs.first.data());
    final WatchlistEntity updated =
        current.copyWith(alertThreshold: threshold);
    await snap.docs.first.reference.set(updated.toJson());
    await loadWatchlist(_userId);
  }

  Future<void> refresh() => _refreshQuotes();

  // ─── Internals ────────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refreshQuotes());
  }

  Future<void> _refreshQuotes() async {
    final WatchlistState current = state;
    final List<WatchlistEntity> entities =
        current.whenOrNull(
          loaded: (List<WatchlistItem> items, DateTime _) =>
              items.map((WatchlistItem i) => i.entity).toList(),
        ) ??
        <WatchlistEntity>[];
    if (entities.isEmpty) {
      return;
    }
    try {
      final List<WatchlistItem> updated = await _buildItems(entities);
      // Restore sparklines from the current state so they survive a refresh.
      final List<WatchlistItem> existing =
          current.whenOrNull(
            loaded: (List<WatchlistItem> items, DateTime _) => items,
          ) ??
          <WatchlistItem>[];
      final Map<String, List<double>> sparklines = <String, List<double>>{
        for (final WatchlistItem item in existing)
          item.ticker: item.sparkline,
      };
      final List<WatchlistItem> merged = updated
          .map(
            (WatchlistItem item) => item.copyWith(
              sparkline: sparklines[item.ticker] ?? <double>[],
            ),
          )
          .toList();
      _emitLoaded(merged);
    } on Exception catch (e) {
      logger.w('WatchlistCubit.refresh failed — keeping current state', error: e);
    }
  }

  Future<List<WatchlistEntity>> _fetchEntities(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection('watchlist')
        .where('userId', isEqualTo: userId)
        .get();
    final List<WatchlistEntity> entities = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              WatchlistEntity.fromJson(doc.data()),
        )
        .toList()
      ..sort(
        (WatchlistEntity a, WatchlistEntity b) =>
            b.addedAt.compareTo(a.addedAt),
      );
    return entities;
  }

  Future<List<WatchlistItem>> _buildItems(
    List<WatchlistEntity> entities,
  ) async {
    if (entities.isEmpty) {
      return <WatchlistItem>[];
    }
    final List<String> tickers =
        entities.map((WatchlistEntity e) => e.ticker).toList();

    // Batch-fetch quotes, respecting the free-tier batch size limit.
    final Map<String, MarketQuoteEntity> quotes = <String, MarketQuoteEntity>{};
    for (int i = 0; i < tickers.length; i += _batchSize) {
      final List<String> batch =
          tickers.sublist(i, min(i + _batchSize, tickers.length));
      final List<MarketQuoteEntity> fetched =
          await _service.fetchQuotes(batch);
      for (final MarketQuoteEntity q in fetched) {
        quotes[q.ticker] = q;
      }
    }

    return entities
        .map(
          (WatchlistEntity e) => WatchlistItem(
            entity: e,
            quote: quotes[e.ticker],
          ),
        )
        .toList();
  }

  /// Loads 5-day sparklines sequentially with a delay between requests
  /// to stay within Brapi free-tier rate limits.
  Future<void> _loadSparklines() async {
    final WatchlistState current = state;
    final List<WatchlistItem> items =
        current.whenOrNull(
          loaded: (List<WatchlistItem> i, DateTime _) => i,
        ) ??
        <WatchlistItem>[];
    if (items.isEmpty) {
      return;
    }

    final List<WatchlistItem> updated = List<WatchlistItem>.of(items);
    for (int i = 0; i < updated.length; i++) {
      if (isClosed) {
        return;
      }
      final List<double> sparkline =
          await _service.fetchHistory(updated[i].ticker);
      updated[i] = updated[i].copyWith(sparkline: sparkline);
      _emitLoaded(List<WatchlistItem>.of(updated));
      if (i < updated.length - 1) {
        // Brief pause between sparkline requests.
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  void _emitLoaded(List<WatchlistItem> items) {
    if (!isClosed) {
      emit(WatchlistState.loaded(items: items, lastUpdated: DateTime.now()));
    }
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    return super.close();
  }
}
