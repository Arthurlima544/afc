import 'package:freezed_annotation/freezed_annotation.dart';

part 'net_worth_snapshot_entity.freezed.dart';
part 'net_worth_snapshot_entity.g.dart';

/// A monthly snapshot of the user's net worth (assets − liabilities).
@freezed
sealed class NetWorthSnapshotEntity with _$NetWorthSnapshotEntity {
  const factory NetWorthSnapshotEntity({
    required String uuid,
    required String userId,

    /// ISO-8601 date string ('yyyy-MM-dd') for the month this snapshot covers.
    required String date,

    /// Total value of all assets (portfolio + goal balances).
    required double assets,

    /// Total liabilities at snapshot time.
    required double liabilities,

    /// Computed: assets − liabilities.
    required double netWorth,
  }) = _NetWorthSnapshotEntity;

  factory NetWorthSnapshotEntity.fromJson(Map<String, Object?> json) =>
      _$NetWorthSnapshotEntityFromJson(json);
}
