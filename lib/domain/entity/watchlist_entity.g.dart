// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WatchlistEntity _$WatchlistEntityFromJson(Map<String, dynamic> json) =>
    _WatchlistEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      ticker: json['ticker'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      alertThreshold: (json['alertThreshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WatchlistEntityToJson(_WatchlistEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'ticker': instance.ticker,
      'addedAt': instance.addedAt.toIso8601String(),
      'alertThreshold': instance.alertThreshold,
    };
