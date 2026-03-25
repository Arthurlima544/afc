import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/pending_operation_entity.dart';
import '../../../domain/entity/template_entity.dart';
import '../../../utils/logger.dart';
import '../../../utils/sync_queue.dart';

part 'template_state.dart';
part 'template_cubit.freezed.dart';

class TemplateCubit extends Cubit<TemplateState> {
  TemplateCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const TemplateState.initial());

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  // ---------------------------------------------------------------------------
  // Load (stream)
  // ---------------------------------------------------------------------------

  Future<void> loadTemplates(String userId) async {
    emit(const TemplateState.loading());
    await _subscription?.cancel();
    _subscription = _firestore
        .collection('template')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snap) {
            final List<TemplateEntity> templates = snap.docs
                .map(
                  (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                      TemplateEntity.fromJson(doc.data()),
                )
                .toList()
              ..sort(
                (TemplateEntity a, TemplateEntity b) =>
                    a.title.compareTo(b.title),
              );
            emit(TemplateState.listed(templates));
          },
          onError: (Object e) => emit(TemplateState.error(e.toString())),
        );
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> save(TemplateEntity template) async {
    try {
      emit(const TemplateState.loading());
      await _firestore.collection('template').add(template.toJson()).then(
        (DocumentReference<Object> doc) =>
            logger.d('Template saved with ID: ${doc.id}'),
      );
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: template.userId,
          type: OperationType.create,
          collection: 'template',
          payload: template.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      emit(TemplateState.success(template));
    } on Exception catch (e) {
      emit(TemplateState.error(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> delete(String uuid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('template')
          .where('uuid', isEqualTo: uuid)
          .get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      SyncQueue.enqueueIfOffline(
        PendingOperationEntity(
          uuid: const Uuid().v1(),
          userId: '',
          type: OperationType.delete,
          collection: 'template',
          payload: <String, dynamic>{'uuid': uuid},
          createdAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(TemplateState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
