// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackEntity _$FeedbackEntityFromJson(Map<String, dynamic> json) =>
    _FeedbackEntity(
      uuid: json['uuid'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      message: json['message'] as String? ?? '',
      appVersion: json['appVersion'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
    );

Map<String, dynamic> _$FeedbackEntityToJson(_FeedbackEntity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'userId': instance.userId,
      'rating': instance.rating,
      'createdAt': instance.createdAt.toIso8601String(),
      'message': instance.message,
      'appVersion': instance.appVersion,
      'platform': instance.platform,
    };
