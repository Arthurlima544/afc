import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/import_candidate_entity.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../../domain/usecase/statement_parser.dart';
import '../../../utils/logger.dart';

part 'import_state.dart';
part 'import_cubit.freezed.dart';

class ImportCubit extends Cubit<ImportState> {
  ImportCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ImportState.initial());

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Pick file and parse
  // ---------------------------------------------------------------------------

  Future<void> pickFile(String userId) async {
    emit(const ImportState.loading());
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['ofx', 'csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        emit(const ImportState.initial());
        return;
      }

      final PlatformFile file = result.files.first;
      final String? extension = file.extension?.toLowerCase();
      String content;

      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        emit(const ImportState.error('Não foi possível ler o arquivo.'));
        return;
      }

      await parseContent(content, extension ?? 'csv', userId);
    } on Exception catch (e) {
      emit(ImportState.error(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Parse content (testable without file picker)
  // ---------------------------------------------------------------------------

  Future<void> parseContent(
    String content,
    String extension,
    String userId,
  ) async {
    emit(const ImportState.loading());

    final List<ImportCandidateEntity> parsed = extension == 'ofx'
        ? parseOfx(content)
        : parseCsv(content);

    if (parsed.isEmpty) {
      emit(
        const ImportState.error('Nenhuma transação encontrada no arquivo.'),
      );
      return;
    }

    final List<ImportCandidateEntity> candidates = <ImportCandidateEntity>[];
    for (final ImportCandidateEntity c in parsed) {
      final bool dup = await _isDuplicate(userId, c);
      candidates.add(c.copyWith(isDuplicate: dup));
    }

    emit(ImportState.reviewed(candidates: candidates, userId: userId));
  }

  // ---------------------------------------------------------------------------
  // Review actions
  // ---------------------------------------------------------------------------

  void accept(int index) => _update(
    index,
    (ImportCandidateEntity c) => c.copyWith(status: ImportStatus.accepted),
  );

  void reject(int index) => _update(
    index,
    (ImportCandidateEntity c) => c.copyWith(status: ImportStatus.rejected),
  );

  void recategorise(int index, String categoryUUid) => _update(
    index,
    (ImportCandidateEntity c) => c.copyWith(categoryUUid: categoryUUid),
  );

  void acceptAll() {
    final List<ImportCandidateEntity>? candidates = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> c, String _) => c,
    );
    final String? userId = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> _, String id) => id,
    );
    if (candidates == null || userId == null) {
      return;
    }
    emit(
      ImportState.reviewed(
        candidates: candidates
            .map(
              (ImportCandidateEntity c) => c.isDuplicate
                  ? c
                  : c.copyWith(status: ImportStatus.accepted),
            )
            .toList(),
        userId: userId,
      ),
    );
  }

  void _update(
    int index,
    ImportCandidateEntity Function(ImportCandidateEntity) fn,
  ) {
    final List<ImportCandidateEntity>? candidates = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> c, String _) => c,
    );
    final String? userId = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> _, String id) => id,
    );
    if (candidates == null || userId == null) {
      return;
    }
    final List<ImportCandidateEntity> updated =
        List<ImportCandidateEntity>.from(candidates);
    updated[index] = fn(updated[index]);
    emit(ImportState.reviewed(candidates: updated, userId: userId));
  }

  // ---------------------------------------------------------------------------
  // Save accepted candidates to Firestore
  // ---------------------------------------------------------------------------

  Future<void> saveAccepted() async {
    final List<ImportCandidateEntity>? candidates = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> c, String _) => c,
    );
    final String? userId = state.whenOrNull(
      reviewed: (List<ImportCandidateEntity> _, String id) => id,
    );
    if (candidates == null || userId == null) {
      return;
    }

    emit(const ImportState.saving());

    final List<ImportCandidateEntity> toSave = candidates
        .where((ImportCandidateEntity c) => c.status == ImportStatus.accepted)
        .toList();

    int saved = 0;
    try {
      for (final ImportCandidateEntity c in toSave) {
        await _firestore.collection('transaction').add(
          TransactionEntity(
            uuid: const Uuid().v1(),
            amount: c.amount,
            categoryUUid: c.categoryUUid ?? '',
            typeUuid: c.typeUuid,
            data: c.date,
            title: c.title,
            userId: userId,
          ).toJson(),
        );
        saved++;
        logger.d('Imported transaction: ${c.title}');
      }
      emit(ImportState.done(saved));
    } on Exception catch (e) {
      emit(ImportState.error(e.toString()));
    }
  }

  void reset() => emit(const ImportState.initial());

  // ---------------------------------------------------------------------------
  // Duplicate detection
  // ---------------------------------------------------------------------------

  Future<bool> _isDuplicate(
    String userId,
    ImportCandidateEntity candidate,
  ) async {
    try {
      final DateTime dayStart = DateTime(
        candidate.date.year,
        candidate.date.month,
        candidate.date.day,
      );
      final DateTime dayEnd = dayStart.add(const Duration(days: 1));

      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .where('amount', isEqualTo: candidate.amount)
          .get();

      return snap.docs.any((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final dynamic rawDate = doc.data()['data'];
        DateTime? txDate;
        if (rawDate is Timestamp) {
          txDate = rawDate.toDate();
        } else if (rawDate is String) {
          txDate = DateTime.tryParse(rawDate);
        }
        if (txDate == null) {
          return false;
        }
        return !txDate.isBefore(dayStart) && txDate.isBefore(dayEnd);
      });
    } on Exception catch (_) {
      return false;
    }
  }
}
