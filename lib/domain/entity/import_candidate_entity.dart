import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_candidate_entity.freezed.dart';

enum ImportStatus { pending, accepted, rejected }

@freezed
sealed class ImportCandidateEntity with _$ImportCandidateEntity {
  const factory ImportCandidateEntity({
    required String title,
    required double amount,
    required DateTime date,
    required String typeUuid,
    String? categoryUUid,
    @Default(ImportStatus.pending) ImportStatus status,
    @Default(false) bool isDuplicate,
    @Default(0.0) double categoryConfidence,
  }) = _ImportCandidateEntity;
}
