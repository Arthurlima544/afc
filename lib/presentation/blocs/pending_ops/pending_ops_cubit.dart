import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/pending_operation_entity.dart';
import '../../../utils/sync_queue.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
class PendingOpsState {
  const PendingOpsState({
    this.groups = const <String, int>{},
    this.ops = const <PendingOperationEntity>[],
  });

  /// Count per collection, e.g. `{'transaction': 3, 'goal': 1}`.
  final Map<String, int> groups;

  /// Flat list of all pending ops in insertion order.
  final List<PendingOperationEntity> ops;

  int get total => ops.length;
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class PendingOpsCubit extends Cubit<PendingOpsState> {
  PendingOpsCubit({SyncQueue? queue})
    : _queue = queue ?? SyncQueue.instance,
      super(const PendingOpsState());

  final SyncQueue _queue;

  /// Reads current pending ops and groups them by collection.
  void load() {
    final List<PendingOperationEntity> ops = _queue.pending;
    final Map<String, int> groups = <String, int>{};
    for (final PendingOperationEntity op in ops) {
      groups[op.collection] = (groups[op.collection] ?? 0) + 1;
    }
    emit(PendingOpsState(groups: groups, ops: ops));
  }

  /// Flushes the queue against Firestore then reloads the state.
  Future<void> retryNow() async {
    await _queue.flush();
    load();
  }

  /// Clears all pending ops without replaying them, then reloads.
  void clear() {
    _queue.clear();
    load();
  }
}
