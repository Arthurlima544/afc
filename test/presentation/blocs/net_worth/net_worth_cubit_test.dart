import 'package:afc/domain/entity/net_worth_snapshot_entity.dart';
import 'package:afc/presentation/blocs/net_worth/net_worth_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetWorthCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const NetWorthSnapshotEntity tSnapshot = NetWorthSnapshotEntity(
      uuid: 'nw-1',
      userId: 'user-1',
      date: '2026-01-01',
      assets: 100000.0,
      liabilities: 20000.0,
      netWorth: 80000.0,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is NetWorthState.initial', () {
      final NetWorthCubit cubit = NetWorthCubit(firestore: fakeFirestore);
      expect(cubit.state, const NetWorthState.initial());
      cubit.close();
    });

    // ── loadSnapshots ──────────────────────────────────────────────────────

    group('loadSnapshots', () {
      blocTest<NetWorthCubit, NetWorthState>(
        'emits [loading, listed([])] when no snapshots exist',
        build: () => NetWorthCubit(firestore: fakeFirestore),
        act: (NetWorthCubit cubit) => cubit.loadSnapshots('user-1'),
        expect: () => <NetWorthState>[
          const NetWorthState.loading(),
          const NetWorthState.listed(<NetWorthSnapshotEntity>[]),
        ],
      );

      blocTest<NetWorthCubit, NetWorthState>(
        'emits listed with seeded snapshots sorted by date asc',
        setUp: () async {
          await fakeFirestore
              .collection('net_worth_snapshot')
              .add(tSnapshot.toJson());
          await fakeFirestore.collection('net_worth_snapshot').add(
            tSnapshot
                .copyWith(uuid: 'nw-2', date: '2026-02-01', netWorth: 85000.0)
                .toJson(),
          );
        },
        build: () => NetWorthCubit(firestore: fakeFirestore),
        act: (NetWorthCubit cubit) => cubit.loadSnapshots('user-1'),
        verify: (NetWorthCubit cubit) {
          final NetWorthState state = cubit.state;
          final List<NetWorthSnapshotEntity> snapshots = state.whenOrNull(
                listed: (List<NetWorthSnapshotEntity> s) => s,
              ) ??
              <NetWorthSnapshotEntity>[];
          expect(snapshots.length, 2);
          expect(snapshots.first.date, '2026-01-01');
          expect(snapshots.last.date, '2026-02-01');
        },
      );

      blocTest<NetWorthCubit, NetWorthState>(
        'does not include snapshots for other users',
        setUp: () async {
          await fakeFirestore.collection('net_worth_snapshot').add(
            tSnapshot.copyWith(userId: 'other-user').toJson(),
          );
        },
        build: () => NetWorthCubit(firestore: fakeFirestore),
        act: (NetWorthCubit cubit) => cubit.loadSnapshots('user-1'),
        expect: () => <NetWorthState>[
          const NetWorthState.loading(),
          const NetWorthState.listed(<NetWorthSnapshotEntity>[]),
        ],
      );
    });

    // ── recordSnapshot ─────────────────────────────────────────────────────

    group('recordSnapshot', () {
      blocTest<NetWorthCubit, NetWorthState>(
        'persists new snapshot and reloads list',
        build: () => NetWorthCubit(firestore: fakeFirestore),
        act: (NetWorthCubit cubit) async {
          await cubit.loadSnapshots('user-1');
          await cubit.recordSnapshot(assets: 200000.0, liabilities: 30000.0);
        },
        verify: (NetWorthCubit cubit) {
          final NetWorthState state = cubit.state;
          final List<NetWorthSnapshotEntity> snapshots = state.whenOrNull(
                listed: (List<NetWorthSnapshotEntity> s) => s,
              ) ??
              <NetWorthSnapshotEntity>[];
          expect(snapshots.length, 1);
          expect(snapshots.first.assets, 200000.0);
          expect(snapshots.first.liabilities, 30000.0);
          expect(snapshots.first.netWorth, 170000.0);
        },
      );

      test('persists snapshot to Firestore collection', () async {
        final NetWorthCubit cubit = NetWorthCubit(firestore: fakeFirestore);
        await cubit.loadSnapshots('user-1');
        await cubit.recordSnapshot(assets: 50000.0, liabilities: 10000.0);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('net_worth_snapshot').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['assets'], 50000.0);
        expect(snap.docs.first.data()['netWorth'], 40000.0);
        await cubit.close();
      });

      test('replaces existing snapshot for same month', () async {
        final NetWorthCubit cubit = NetWorthCubit(firestore: fakeFirestore);
        await cubit.loadSnapshots('user-1');
        await cubit.recordSnapshot(assets: 100000.0, liabilities: 0.0);
        await cubit.recordSnapshot(assets: 120000.0, liabilities: 5000.0);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('net_worth_snapshot').get();
        // Should still be 1 document (replaced, not added)
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['assets'], 120000.0);
        await cubit.close();
      });
    });

    // ── delete ────────────────────────────────────────────────────────────

    group('delete', () {
      blocTest<NetWorthCubit, NetWorthState>(
        'removes snapshot and reloads empty list',
        setUp: () async {
          await fakeFirestore
              .collection('net_worth_snapshot')
              .add(tSnapshot.toJson());
        },
        build: () => NetWorthCubit(firestore: fakeFirestore),
        act: (NetWorthCubit cubit) async {
          await cubit.loadSnapshots('user-1');
          await cubit.delete('nw-1');
        },
        verify: (NetWorthCubit cubit) {
          final NetWorthState state = cubit.state;
          final List<NetWorthSnapshotEntity> snapshots = state.whenOrNull(
                listed: (List<NetWorthSnapshotEntity> s) => s,
              ) ??
              <NetWorthSnapshotEntity>[tSnapshot];
          expect(snapshots, isEmpty);
        },
      );
    });
  });
}
