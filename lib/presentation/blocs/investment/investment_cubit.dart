import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/investment_entity.dart';
import '../../../utils/logger.dart';

part 'investment_state.dart';
part 'investment_cubit.freezed.dart';

class InvestmentCubit extends Cubit<InvestmentState> {
  InvestmentCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const InvestmentState.initial());

  final FirebaseFirestore _firestore;

  Future<void> loadInvestments(String userId) async {
    emit(const InvestmentState.loading());
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('investment')
          .where('userId', isEqualTo: userId)
          .get();

      final List<InvestmentEntity> investments = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                InvestmentEntity.fromJson(doc.data()),
          )
          .toList();

      emit(InvestmentState.listed(investments));
    } on Exception catch (e) {
      emit(InvestmentState.error(e.toString()));
    }
  }

  Future<void> create(InvestmentEntity inv) async {
    try {
      emit(const InvestmentState.loading());
      await _firestore
          .collection('investment')
          .add(inv.toJson())
          .then(
            (DocumentReference<Object> doc) =>
                logger.d('Investment added with ID: ${doc.id}'),
          );
      emit(InvestmentState.success(inv));
    } on Exception catch (e) {
      emit(InvestmentState.error(e.toString()));
    }
  }

  Future<void> updatePrice(String uuid, double newPrice) async {
    try {
      emit(const InvestmentState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('investment')
          .where('uuid', isEqualTo: uuid)
          .get();

      if (snap.docs.isEmpty) {
        emit(const InvestmentState.error('Investimento não encontrado.'));
        return;
      }

      final QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs.first;
      final InvestmentEntity current = InvestmentEntity.fromJson(doc.data());
      final InvestmentEntity updated = current.copyWith(
        currentPrice: newPrice,
      );
      await doc.reference.set(updated.toJson());
      emit(InvestmentState.success(updated));
    } on Exception catch (e) {
      emit(InvestmentState.error(e.toString()));
    }
  }

  Future<void> delete(String uuid, String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('investment')
          .where('uuid', isEqualTo: uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      await loadInvestments(userId);
    } on Exception catch (e) {
      emit(InvestmentState.error(e.toString()));
    }
  }

  Future<void> update(InvestmentEntity inv) async {
    try {
      emit(const InvestmentState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('investment')
          .where('uuid', isEqualTo: inv.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.set(inv.toJson());
      }
      emit(InvestmentState.success(inv));
    } on Exception catch (e) {
      emit(InvestmentState.error(e.toString()));
    }
  }
}
