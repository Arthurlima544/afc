import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/passive_income_entity.dart';
import '../../../utils/logger.dart';

part 'passive_income_state.dart';
part 'passive_income_cubit.freezed.dart';

class PassiveIncomeCubit extends Cubit<PassiveIncomeState> {
  PassiveIncomeCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const PassiveIncomeState.initial());

  final FirebaseFirestore _firestore;
  String _userId = '';

  static const String _collection = 'passive_income';

  Future<void> loadStreams(String userId) async {
    _userId = userId;
    emit(const PassiveIncomeState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();
      final List<PassiveIncomeEntity> streams = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                PassiveIncomeEntity.fromJson(doc.data()),
          )
          .toList()
        ..sort(
          (PassiveIncomeEntity a, PassiveIncomeEntity b) =>
              b.amount.compareTo(a.amount),
        );
      emit(PassiveIncomeState.listed(streams));
    } on Exception catch (e) {
      logger.e('PassiveIncomeCubit.loadStreams failed', error: e);
      emit(PassiveIncomeState.error(e.toString()));
    }
  }

  Future<void> create(PassiveIncomeEntity stream) async {
    emit(const PassiveIncomeState.loading());
    try {
      await _firestore.collection(_collection).add(stream.toJson());
      await loadStreams(_userId);
    } on Exception catch (e) {
      logger.e('PassiveIncomeCubit.create failed', error: e);
      emit(PassiveIncomeState.error(e.toString()));
    }
  }

  Future<void> delete(String uuid) async {
    emit(const PassiveIncomeState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: uuid)
          .get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        await doc.reference.delete();
      }
      await loadStreams(_userId);
    } on Exception catch (e) {
      logger.e('PassiveIncomeCubit.delete failed', error: e);
      emit(PassiveIncomeState.error(e.toString()));
    }
  }

  Future<void> update(PassiveIncomeEntity stream) async {
    emit(const PassiveIncomeState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection(_collection)
          .where('uuid', isEqualTo: stream.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(stream.toJson());
      }
      await loadStreams(_userId);
    } on Exception catch (e) {
      logger.e('PassiveIncomeCubit.update failed', error: e);
      emit(PassiveIncomeState.error(e.toString()));
    }
  }

  /// Creates a [PassiveIncomeEntity] with a new UUID and saves it.
  Future<void> add({
    required String name,
    required String source,
    required double amount,
    required String frequency,
    String? assetUuid,
  }) =>
      create(
        PassiveIncomeEntity(
          uuid: const Uuid().v1(),
          userId: _userId,
          name: name,
          source: source,
          amount: amount,
          frequency: frequency,
          assetUuid: assetUuid,
        ),
      );
}
