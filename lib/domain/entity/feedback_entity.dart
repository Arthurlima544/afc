import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_entity.freezed.dart';
part 'feedback_entity.g.dart';

@freezed
sealed class FeedbackEntity with _$FeedbackEntity {
  const factory FeedbackEntity({
    required String uuid,
    required String userId,
    required int rating,
    required DateTime createdAt,
    @Default('') String message,
    @Default('') String appVersion,
    @Default('') String platform,
  }) = _FeedbackEntity;

  factory FeedbackEntity.fromJson(Map<String, Object?> json) =>
      _$FeedbackEntityFromJson(json);
}
