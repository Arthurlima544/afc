part of 'net_worth_cubit.dart';

@freezed
sealed class NetWorthState with _$NetWorthState {
  const factory NetWorthState.initial() = _Initial;
  const factory NetWorthState.loading() = _Loading;
  const factory NetWorthState.listed(List<NetWorthSnapshotEntity> snapshots) =
      _Listed;
  const factory NetWorthState.error(String message) = _Error;
}
