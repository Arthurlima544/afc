part of 'import_cubit.dart';

@freezed
sealed class ImportState with _$ImportState {
  const factory ImportState.initial() = _Initial;
  const factory ImportState.loading() = _Loading;
  const factory ImportState.reviewed({
    required List<ImportCandidateEntity> candidates,
    required String userId,
  }) = _Reviewed;
  const factory ImportState.saving() = _Saving;
  const factory ImportState.done(int savedCount) = _Done;
  const factory ImportState.error(String message) = _Error;
}
