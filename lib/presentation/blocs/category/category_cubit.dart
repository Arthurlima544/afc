import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/category_entity.dart';
import '../../../domain/entity/pending_operation_entity.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'category_state.dart';
part 'category_cubit.freezed.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const CategoryState.initial(-1));

  final FirebaseFirestore _firestore;

  void changeSelectedCategory(int index) {
    if (state == CategoryState.initial(index)) {
      emit(const CategoryState.initial(-1));
      return;
    }
    emit(CategoryState.initial(index));
  }

  Future<void> saveCategory(CategoryEntity category) async {
    try {
      emit(const CategoryState.loading());
      final Future<DocumentReference<Map<String, dynamic>>> addFuture =
          _firestore.collection('category').add(category.toJson());
      if (ConnectivityService.isOnlineSafe) {
        await addFuture.then(
          (DocumentReference<Object> doc) =>
              logger.d('DocumentSnapshot added with ID: ${doc.id}'),
        );
      } else {
        unawaited(addFuture);
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: '',
          type: OperationType.create,
          collection: 'category',
          payload: category.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(CategoryState.success(category));
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }

  Future<void> loadCategories() async {
    try {
      emit(const CategoryState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _firestore.collection('category').get();
      final List<CategoryEntity> cats = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                CategoryEntity.fromJson(doc.data()),
          )
          .toList();
      emit(CategoryState.listed(cats));
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }

  Future<void> deleteCategory(String catUuid) async {
    try {
      emit(const CategoryState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('category')
          .where('uuid', isEqualTo: catUuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
        SyncQueue.enqueueIfOffline(
          PendingOperationEntity(
            uuid: const Uuid().v1(),
            userId: '',
            type: OperationType.delete,
            collection: 'category',
            payload: <String, dynamic>{'uuid': catUuid},
            createdAt: DateTime.now(),
          ),
        );
      }
      await loadCategories();
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    try {
      emit(const CategoryState.loading());
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('category')
          .where('uuid', isEqualTo: category.uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        final Future<void> setFuture =
            snap.docs.first.reference.set(category.toJson());
        if (ConnectivityService.isOnlineSafe) {
          await setFuture;
        } else {
          unawaited(setFuture);
        }
        SyncQueue.enqueueIfOffline(
          PendingOperationEntity(
            uuid: const Uuid().v1(),
            userId: '',
            type: OperationType.update,
            collection: 'category',
            payload: category.toJson(),
            createdAt: DateTime.now(),
          ),
        );
      }
      emit(CategoryState.success(category));
    } on Exception catch (e) {
      emit(CategoryState.error(e.toString()));
    }
  }
}
