import 'package:afc/domain/entity/pending_operation_entity.dart';
import 'package:afc/presentation/blocs/pending_ops/pending_ops_cubit.dart';
import 'package:afc/utils/sync_queue.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PendingOperationEntity _op({
  String? uuid,
  String collection = 'transaction',
  OperationType type = OperationType.create,
}) =>
    PendingOperationEntity(
      uuid: uuid ?? 'op-uuid-1',
      userId: 'user-1',
      type: type,
      collection: collection,
      payload: <String, dynamic>{'uuid': 'doc-1'},
      createdAt: DateTime(2025, 3),
    );

void main() {
  late SyncQueue queue;
  late PendingOpsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    queue = SyncQueue(firestore: FakeFirebaseFirestore());
    queue.attachPrefs(prefs);
    cubit = PendingOpsCubit(queue: queue);
  });

  tearDown(() => cubit.close());

  group('PendingOpsCubit', () {
    test('load() emits empty state when queue is empty', () {
      cubit.load();

      expect(cubit.state.ops, isEmpty);
      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.total, 0);
    });

    test('load() groups ops by collection correctly', () {
      queue.enqueue(_op(uuid: 'op-1', collection: 'transaction'));
      queue.enqueue(_op(uuid: 'op-2', collection: 'transaction'));
      queue.enqueue(_op(uuid: 'op-3', collection: 'goal'));

      cubit.load();

      expect(cubit.state.total, 3);
      expect(cubit.state.groups['transaction'], 2);
      expect(cubit.state.groups['goal'], 1);
    });

    test('load() preserves insertion order in ops list', () {
      queue.enqueue(_op(uuid: 'op-a', collection: 'goal'));
      queue.enqueue(_op(uuid: 'op-b', collection: 'transaction'));

      cubit.load();

      expect(cubit.state.ops[0].uuid, 'op-a');
      expect(cubit.state.ops[1].uuid, 'op-b');
    });

    test('retryNow() flushes queue and reloads state', () async {
      queue.enqueue(
        _op(
          uuid: 'op-1',
          collection: 'goal',
        ).copyWith(),
      );

      cubit.load();
      expect(cubit.state.total, 1);

      await cubit.retryNow();

      // After flush against fake Firestore (should succeed), queue is empty.
      expect(cubit.state.total, 0);
    });

    test('clear() empties queue and emits empty state', () {
      queue.enqueue(_op(uuid: 'op-1'));
      queue.enqueue(_op(uuid: 'op-2'));

      cubit.load();
      expect(cubit.state.total, 2);

      cubit.clear();

      expect(cubit.state.total, 0);
      expect(queue.count, 0);
    });
  });
}
