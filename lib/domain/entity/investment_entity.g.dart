// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvestmentEntity _$InvestmentEntityFromJson(Map<String, dynamic> json) =>
    _InvestmentEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      avgCost: (json['avgCost'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      ticker: json['ticker'] as String?,
    );

Map<String, dynamic> _$InvestmentEntityToJson(_InvestmentEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'name': instance.name,
      'type': instance.type,
      'quantity': instance.quantity,
      'avgCost': instance.avgCost,
      'currentPrice': instance.currentPrice,
      'ticker': instance.ticker,
    };
