import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/net_worth_snapshot_entity.dart';
import '../../../utils/logger.dart';

part 'net_worth_state.dart';
part 'net_worth_cubit.freezed.dart';

class NetWorthCubit extends Cubit<NetWorthState> {
  NetWorthCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const NetWorthState.initial());

  final FirebaseFirestore _firestore;
  String _userId = '';

  static const String _collection = 'net_worth_snapshot';

  /// Loads the last 13 monthly snapshots for [userId], ordered by date desc.
  Future<void> loadSnapshots(String userId) async {
    _userId = userId;
    emit(const NetWorthState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(13)
          .get();
      final List<NetWorthSnapshotEntity> snapshots = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                NetWorthSnapshotEntity.fromJson(doc.data()),
          )
          .toList()
        ..sort(
          (NetWorthSnapshotEntity a, NetWorthSnapshotEntity b) =>
              a.date.compareTo(b.date),
        );
      emit(NetWorthState.listed(snapshots));
    } on Exception catch (e) {
      logger.e('NetWorthCubit.loadSnapshots failed', error: e);
      emit(NetWorthState.error(e.toString()));
    }
  }

  /// Records a snapshot for the current month.
  /// If a snapshot already exists for this month, it is replaced.
  Future<void> recordSnapshot({
    required double assets,
    required double liabilities,
  }) async {
    final String date =
        '${DateFormat('yyyy-MM-dd').format(DateTime.now()).substring(0, 7)}-01';
    try {
      final QuerySnapshot<Map<String, dynamic>> existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .where('date', isEqualTo: date)
          .get();

      final NetWorthSnapshotEntity snapshot = NetWorthSnapshotEntity(
        uuid: const Uuid().v1(),
        userId: _userId,
        date: date,
        assets: assets,
        liabilities: liabilities,
        netWorth: assets - liabilities,
      );

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.set(snapshot.toJson());
      } else {
        await _firestore.collection(_collection).add(snapshot.toJson());
      }
      await loadSnapshots(_userId);
    } on Exception catch (e) {
      logger.e('NetWorthCubit.recordSnapshot failed', error: e);
      emit(NetWorthState.error(e.toString()));
    }
  }

  Future<void> delete(String uuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: uuid)
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        await doc.reference.delete();
      }
      await loadSnapshots(_userId);
    } on Exception catch (e) {
      logger.e('NetWorthCubit.delete failed', error: e);
      emit(NetWorthState.error(e.toString()));
    }
  }
}
