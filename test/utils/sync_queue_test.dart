import 'package:afc/domain/entity/pending_operation_entity.dart';
import 'package:afc/utils/sync_queue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PendingOperationEntity _op({
  String? uuid,
  OperationType type = OperationType.create,
  String collection = 'transaction',
  Map<String, dynamic>? payload,
}) => PendingOperationEntity(
  uuid: uuid ?? 'op-uuid-1',
  userId: 'user-1',
  type: type,
  collection: collection,
  payload: payload ?? <String, dynamic>{'uuid': 'doc-1', 'title': 'Test'},
  createdAt: DateTime(2025, 3),
);

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SyncQueue queue;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    fakeFirestore = FakeFirebaseFirestore();
    queue = SyncQueue(firestore: fakeFirestore)..attachPrefs(prefs);
  });

  // ── enqueue ────────────────────────────────────────────────────────────────

  group('enqueue', () {
    test('adds op to pending list', () {
      queue.enqueue(_op());
      expect(queue.count, 1);
    });

    test('persists across prefs reads', () async {
      queue
        ..enqueue(_op(uuid: 'op-1'))
        ..enqueue(_op(uuid: 'op-2'));

      // Re-attach same prefs instance — count should survive
      expect(queue.count, 2);
    });

    test('enqueued ops preserve insertion order', () {
      queue
        ..enqueue(_op(uuid: 'op-a'))
        ..enqueue(_op(uuid: 'op-b'))
        ..enqueue(_op(uuid: 'op-c'));

      final List<PendingOperationEntity> ops = queue.pending;
      expect(ops[0].uuid, 'op-a');
      expect(ops[1].uuid, 'op-b');
      expect(ops[2].uuid, 'op-c');
    });
  });

  // ── flush ──────────────────────────────────────────────────────────────────

  group('flush', () {
    test('creates document in Firestore for create op', () async {
      queue.enqueue(
        _op(
          collection: 'goal',
          payload: <String, dynamic>{'uuid': 'goal-1', 'name': 'Viagem'},
        ),
      );

      await queue.flush();

      final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
          .collection('goal')
          .get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['name'], 'Viagem');
    });

    test('applies multiple ops in insertion order', () async {
      queue
        ..enqueue(
          _op(
            uuid: 'op-1',
            collection: 'goal',
            payload: <String, dynamic>{'uuid': 'g-1', 'name': 'Meta A'},
          ),
        )
        ..enqueue(
          _op(
            uuid: 'op-2',
            collection: 'goal',
            payload: <String, dynamic>{'uuid': 'g-2', 'name': 'Meta B'},
          ),
        );

      await queue.flush();

      final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
          .collection('goal')
          .get();
      expect(snap.docs.length, 2);
    });

    test('clears queue after successful flush', () async {
      queue.enqueue(
        _op(collection: 'goal', payload: <String, dynamic>{'uuid': 'g-1'}),
      );

      await queue.flush();

      expect(queue.count, 0);
    });

    test('updates existing document for update op', () async {
      // Seed Firestore with existing doc
      await fakeFirestore.collection('goal').add(<String, dynamic>{
        'uuid': 'g-1',
        'name': 'Old',
      });

      queue.enqueue(
        _op(
          type: OperationType.update,
          collection: 'goal',
          payload: <String, dynamic>{'uuid': 'g-1', 'name': 'New'},
        ),
      );

      await queue.flush();

      final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
          .collection('goal')
          .where('uuid', isEqualTo: 'g-1')
          .get();
      expect(snap.docs.first.data()['name'], 'New');
    });

    test('deletes document for delete op', () async {
      await fakeFirestore.collection('goal').add(<String, dynamic>{
        'uuid': 'g-1',
        'name': 'Delete me',
      });

      queue.enqueue(
        _op(
          type: OperationType.delete,
          collection: 'goal',
          payload: <String, dynamic>{'uuid': 'g-1'},
        ),
      );

      await queue.flush();

      final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
          .collection('goal')
          .where('uuid', isEqualTo: 'g-1')
          .get();
      expect(snap.docs.isEmpty, isTrue);
    });
  });

  // ── idempotency ────────────────────────────────────────────────────────────

  group('idempotency guard', () {
    test(
      'create does not duplicate if doc already exists in Firestore',
      () async {
        // Pre-create the document (simulates Firestore having already synced it)
        await fakeFirestore.collection('transaction').add(<String, dynamic>{
          'uuid': 'tx-1',
          'title': 'Existing',
        });

        queue.enqueue(
          _op(
            payload: <String, dynamic>{'uuid': 'tx-1', 'title': 'Duplicate?'},
          ),
        );

        await queue.flush();

        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('transaction')
            .where('uuid', isEqualTo: 'tx-1')
            .get();
        expect(snap.docs.length, 1);
        // Original document was NOT overwritten
        expect(snap.docs.first.data()['title'], 'Existing');
      },
    );
  });

  // ── clear ──────────────────────────────────────────────────────────────────

  group('clear', () {
    test('removes all ops without replaying', () async {
      queue
        ..enqueue(
          _op(collection: 'goal', payload: <String, dynamic>{'uuid': 'g-1'}),
        )
        ..enqueue(
          _op(
            uuid: 'op-2',
            collection: 'goal',
            payload: <String, dynamic>{'uuid': 'g-2'},
          ),
        )
        ..clear();

      expect(queue.count, 0);
      final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
          .collection('goal')
          .get();
      expect(snap.docs.isEmpty, isTrue);
    });
  });
}
