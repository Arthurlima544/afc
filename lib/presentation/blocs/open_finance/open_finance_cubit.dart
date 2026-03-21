import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/connected_account_entity.dart';

part 'open_finance_state.dart';
part 'open_finance_cubit.freezed.dart';

class OpenFinanceCubit extends Cubit<OpenFinanceState> {
  OpenFinanceCubit({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance,
      super(const OpenFinanceState.initial());

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<void> loadAccounts(String userId) async {
    try {
      emit(const OpenFinanceState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('connected_account')
          .where('userId', isEqualTo: userId)
          .get();
      final List<ConnectedAccountEntity> accounts = snap.docs.map(
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          final dynamic rawSynced = data['lastSyncedAt'];
          if (rawSynced is Timestamp) {
            data['lastSyncedAt'] =
                rawSynced.toDate().toIso8601String();
          }
          return ConnectedAccountEntity.fromJson(data);
        },
      ).toList();
      emit(OpenFinanceState.listed(accounts));
    } on FirebaseFunctionsException catch (e) {
      emit(OpenFinanceState.error(e.message ?? e.toString()));
    } on Exception catch (e) {
      emit(OpenFinanceState.error(e.toString()));
    }
  }

  Future<void> createConnectToken(
    String userId, {
    String? itemId,
  }) async {
    try {
      emit(const OpenFinanceState.loading());
      final Map<String, dynamic> params = <String, dynamic>{
        'clerkUserId': userId,
      };
      if (itemId != null) {
        params['itemId'] = itemId;
      }
      final HttpsCallableResult<dynamic> result = await _functions
          .httpsCallable('createConnectToken')
          .call<dynamic>(params);
      final String connectToken =
          (result.data as Map<dynamic, dynamic>)['connectToken'] as String;
      emit(OpenFinanceState.tokenReady(connectToken));
    } on FirebaseFunctionsException catch (e) {
      emit(OpenFinanceState.error(e.message ?? e.toString()));
    } on Exception catch (e) {
      emit(OpenFinanceState.error(e.toString()));
    }
  }

  Future<void> saveConnectedAccount(
    String itemId,
    String userId,
  ) async {
    try {
      emit(const OpenFinanceState.loading());
      await _functions
          .httpsCallable('saveConnectedAccount')
          .call<dynamic>(<String, dynamic>{
            'itemId': itemId,
            'clerkUserId': userId,
          });
      await loadAccounts(userId);
    } on FirebaseFunctionsException catch (e) {
      emit(OpenFinanceState.error(e.message ?? e.toString()));
    } on Exception catch (e) {
      emit(OpenFinanceState.error(e.toString()));
    }
  }

  Future<void> disconnectAccount(
    String accountUuid,
    String userId,
  ) async {
    try {
      emit(const OpenFinanceState.loading());
      await _functions
          .httpsCallable('deleteConnectedAccount')
          .call<dynamic>(<String, dynamic>{
            'accountUuid': accountUuid,
            'clerkUserId': userId,
          });
      await loadAccounts(userId);
    } on FirebaseFunctionsException catch (e) {
      emit(OpenFinanceState.error(e.message ?? e.toString()));
    } on Exception catch (e) {
      emit(OpenFinanceState.error(e.toString()));
    }
  }

  Future<void> syncNow(String userId) async {
    try {
      emit(const OpenFinanceState.loading());
      await _functions
          .httpsCallable('syncUserItems')
          .call<dynamic>(<String, dynamic>{
            'clerkUserId': userId,
          });
      await loadAccounts(userId);
    } on FirebaseFunctionsException catch (e) {
      emit(OpenFinanceState.error(e.message ?? e.toString()));
    } on Exception catch (e) {
      emit(OpenFinanceState.error(e.toString()));
    }
  }
}
