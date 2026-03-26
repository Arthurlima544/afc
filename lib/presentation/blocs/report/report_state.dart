part of 'report_cubit.dart';

@freezed
sealed class ReportState with _$ReportState {
  const factory ReportState.initial() = _Initial;
  const factory ReportState.loading() = _Loading;
  const factory ReportState.success(ReportData data) = _Success;
  const factory ReportState.error(String message) = _Error;
}
