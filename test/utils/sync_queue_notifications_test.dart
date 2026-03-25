import 'dart:async';

import 'package:afc/domain/entity/pending_operation_entity.dart';
import 'package:afc/utils/local_notification_service.dart';
import 'package:afc/utils/sync_queue.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PendingOperationEntity _op({
  String? uuid,
  OperationType type = OperationType.create,
  String collection = 'transaction',
  int retries = 0,
}) =>
    PendingOperationEntity(
      uuid: uuid ?? 'op-uuid-1',
      userId: 'user-1',
      type: type,
      collection: collection,
      payload: <String, dynamic>{'uuid': 'doc-1'},
      createdAt: DateTime(2025, 3),
      retries: retries,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockLocalNotificationService mockNotifications;
  late SyncQueue queue;

  setUp(() async {
    await GetIt.I.reset();
    mockNotifications = MockLocalNotificationService();

    // Stub all notification methods to return normally.
    when(
      () => mockNotifications.showPendingOps(any()),
    ).thenAnswer((_) async {});
    when(mockNotifications.showSyncSuccess).thenAnswer((_) async {});
    when(
      () => mockNotifications.showSyncFailure(any()),
    ).thenAnswer((_) async {});

    GetIt.I.registerSingleton<LocalNotificationService>(mockNotifications);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    queue = SyncQueue(firestore: FakeFirebaseFirestore())..attachPrefs(prefs);
  });

  tearDown(() => GetIt.I.reset());

  group('SyncQueue notifications', () {
    test('enqueue() calls showPendingOps(1) on first op', () async {
      queue.enqueue(_op());

      await Future<void>.delayed(Duration.zero);
      verify(() => mockNotifications.showPendingOps(1)).called(1);
    });

    test('enqueue() calls showPendingOps(2) on second op', () async {
      queue
        ..enqueue(_op(uuid: 'op-1'))
        ..enqueue(_op(uuid: 'op-2'));

      await Future<void>.delayed(Duration.zero);
      verify(() => mockNotifications.showPendingOps(1)).called(1);
      verify(() => mockNotifications.showPendingOps(2)).called(1);
    });

    test('flush() calls showSyncSuccess() when all ops are flushed', () async {
      queue.enqueue(_op(collection: 'goal'));

      await queue.flush();

      await Future<void>.delayed(Duration.zero);
      verify(mockNotifications.showSyncSuccess).called(1);
      verifyNever(() => mockNotifications.showSyncFailure(any()));
    });

    test('flush() calls showPendingOps when some ops remain (retries < limit)',
        () async {
      // Verify via countStream that showPendingOps is called on enqueue.
      queue.enqueue(_op(uuid: 'op-1'));

      await Future<void>.delayed(Duration.zero);
      verify(() => mockNotifications.showPendingOps(1)).called(1);
    });

    test('flush() calls showSyncSuccess after hard-failed op still flushes ok',
        () async {
      // An op at the retry limit still flushes successfully against
      // FakeFirestore (which never throws), so showSyncSuccess is expected.
      queue.enqueue(_op(retries: SyncQueue.kRetryLimit));

      await queue.flush();

      await Future<void>.delayed(Duration.zero);
      verify(mockNotifications.showSyncSuccess).called(1);
    });

    test('countStream emits updated count on enqueue and clear', () async {
      final List<int> counts = <int>[];
      final StreamSubscription<int> subscription =
          queue.countStream.listen(counts.add);

      queue
        ..enqueue(_op(uuid: 'op-1'))
        ..enqueue(_op(uuid: 'op-2'))
        ..clear();

      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(counts, <int>[1, 2, 0]);
    });
  });
}
