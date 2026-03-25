import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entity/pending_operation_entity.dart';
import 'connectivity_service.dart';
import 'logger.dart';

/// Persists offline write operations to [SharedPreferences] and replays them
/// against Firestore when the device comes back online.
///
/// Register once via [SyncQueue.register], then access the singleton with
/// [SyncQueue.instance].
class SyncQueue {
  SyncQueue({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _kKey = 'sync_queue_ops';

  static SyncQueue get instance => GetIt.I<SyncQueue>();

  final FirebaseFirestore _firestore;
  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Must be called once after registering (pass the already-initialised prefs).
  void attachPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// All currently queued operations.
  List<PendingOperationEntity> get pending {
    final String? raw = _prefs?.getString(_kKey);
    if (raw == null) {
      return <PendingOperationEntity>[];
    }
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (dynamic e) =>
              PendingOperationEntity.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Number of queued operations.
  int get count => pending.length;

  /// Adds [op] to the persistent queue.
  void enqueue(PendingOperationEntity op) {
    final List<PendingOperationEntity> ops = pending..add(op);
    _persist(ops);
    logger.d('SyncQueue: enqueued ${op.type.name} on ${op.collection} '
        '(total: ${ops.length})');
  }

  /// Replays all pending operations against Firestore in insertion order.
  ///
  /// Each operation is skipped (idempotency guard) if the document is already
  /// up-to-date in Firestore.  Failed operations have their retries counter
  /// incremented and are kept in the queue.
  Future<void> flush() async {
    final List<PendingOperationEntity> ops = pending;
    if (ops.isEmpty) {
      return;
    }

    final List<PendingOperationEntity> remaining =
        <PendingOperationEntity>[];

    for (final PendingOperationEntity op in ops) {
      try {
        await _replay(op);
        logger.d('SyncQueue: flushed ${op.type.name} on ${op.collection}');
      } on Exception catch (e) {
        logger.w('SyncQueue: flush failed for ${op.uuid}: $e');
        remaining.add(op.copyWith(retries: op.retries + 1));
      }
    }

    _persist(remaining);
    logger.d(
      'SyncQueue: ${ops.length - remaining.length} flushed, '
      '${remaining.length} remaining',
    );
  }

  /// Removes all queued operations without replaying them.
  void clear() {
    _persist(<PendingOperationEntity>[]);
  }

  // ---------------------------------------------------------------------------
  // Replay logic
  // ---------------------------------------------------------------------------

  Future<void> _replay(PendingOperationEntity op) async {
    switch (op.type) {
      case OperationType.create:
        await _replayCreate(op);
      case OperationType.update:
        await _replayUpdate(op);
      case OperationType.delete:
        await _replayDelete(op);
    }
  }

  Future<void> _replayCreate(PendingOperationEntity op) async {
    final String? entityUuid = op.payload['uuid'] as String?;
    if (entityUuid != null) {
      // Idempotency guard: skip if a document with this UUID already exists.
      final QuerySnapshot<Map<String, dynamic>> existing = await _firestore
          .collection(op.collection)
          .where('uuid', isEqualTo: entityUuid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        logger.d(
          'SyncQueue: skipping create — ${op.collection}/$entityUuid '
          'already exists',
        );
        return;
      }
    }
    await _firestore.collection(op.collection).add(op.payload);
  }

  Future<void> _replayUpdate(PendingOperationEntity op) async {
    final String? entityUuid = op.payload['uuid'] as String?;
    if (entityUuid == null) {
      return;
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection(op.collection)
        .where('uuid', isEqualTo: entityUuid)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.set(op.payload);
    }
  }

  Future<void> _replayDelete(PendingOperationEntity op) async {
    final String? entityUuid = op.payload['uuid'] as String?;
    if (entityUuid == null) {
      return;
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection(op.collection)
        .where('uuid', isEqualTo: entityUuid)
        .limit(1)
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  void _persist(List<PendingOperationEntity> ops) {
    _prefs?.setString(
      _kKey,
      jsonEncode(
        ops.map((PendingOperationEntity o) => o.toJson()).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience helper for cubits
  // ---------------------------------------------------------------------------

  /// Enqueues [op] only when the device is offline.
  ///
  /// Safe to call even when GetIt singletons are not registered (e.g. in unit
  /// tests) — the error is swallowed silently.
  static void enqueueIfOffline(PendingOperationEntity op) {
    try {
      if (!ConnectivityService.instance.isOnline) {
        SyncQueue.instance.enqueue(op);
      }
    } catch (_) {
      // GetIt not configured — skip silently.
    }
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  static void register() {
    GetIt.I.registerLazySingleton<SyncQueue>(SyncQueue.new);
  }
}
