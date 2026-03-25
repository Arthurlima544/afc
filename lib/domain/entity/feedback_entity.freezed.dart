// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackEntity {

 String get uuid; String get userId; int get rating; DateTime get createdAt; String get message; String get appVersion; String get platform;
/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackEntityCopyWith<FeedbackEntity> get copyWith => _$FeedbackEntityCopyWithImpl<FeedbackEntity>(this as FeedbackEntity, _$identity);

  /// Serializes this FeedbackEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.message, message) || other.message == message)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,rating,createdAt,message,appVersion,platform);

@override
String toString() {
  return 'FeedbackEntity(uuid: $uuid, userId: $userId, rating: $rating, createdAt: $createdAt, message: $message, appVersion: $appVersion, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $FeedbackEntityCopyWith<$Res>  {
  factory $FeedbackEntityCopyWith(FeedbackEntity value, $Res Function(FeedbackEntity) _then) = _$FeedbackEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, int rating, DateTime createdAt, String message, String appVersion, String platform
});




}
/// @nodoc
class _$FeedbackEntityCopyWithImpl<$Res>
    implements $FeedbackEntityCopyWith<$Res> {
  _$FeedbackEntityCopyWithImpl(this._self, this._then);

  final FeedbackEntity _self;
  final $Res Function(FeedbackEntity) _then;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? rating = null,Object? createdAt = null,Object? message = null,Object? appVersion = null,Object? platform = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackEntity].
extension FeedbackEntityPatterns on FeedbackEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackEntity value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntity():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackEntity value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  int rating,  DateTime createdAt,  String message,  String appVersion,  String platform)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.rating,_that.createdAt,_that.message,_that.appVersion,_that.platform);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  int rating,  DateTime createdAt,  String message,  String appVersion,  String platform)  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntity():
return $default(_that.uuid,_that.userId,_that.rating,_that.createdAt,_that.message,_that.appVersion,_that.platform);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  int rating,  DateTime createdAt,  String message,  String appVersion,  String platform)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.rating,_that.createdAt,_that.message,_that.appVersion,_that.platform);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackEntity implements FeedbackEntity {
  const _FeedbackEntity({required this.uuid, required this.userId, required this.rating, required this.createdAt, this.message = '', this.appVersion = '', this.platform = ''});
  factory _FeedbackEntity.fromJson(Map<String, dynamic> json) => _$FeedbackEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  int rating;
@override final  DateTime createdAt;
@override@JsonKey() final  String message;
@override@JsonKey() final  String appVersion;
@override@JsonKey() final  String platform;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackEntityCopyWith<_FeedbackEntity> get copyWith => __$FeedbackEntityCopyWithImpl<_FeedbackEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.message, message) || other.message == message)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,rating,createdAt,message,appVersion,platform);

@override
String toString() {
  return 'FeedbackEntity(uuid: $uuid, userId: $userId, rating: $rating, createdAt: $createdAt, message: $message, appVersion: $appVersion, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$FeedbackEntityCopyWith<$Res> implements $FeedbackEntityCopyWith<$Res> {
  factory _$FeedbackEntityCopyWith(_FeedbackEntity value, $Res Function(_FeedbackEntity) _then) = __$FeedbackEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, int rating, DateTime createdAt, String message, String appVersion, String platform
});




}
/// @nodoc
class __$FeedbackEntityCopyWithImpl<$Res>
    implements _$FeedbackEntityCopyWith<$Res> {
  __$FeedbackEntityCopyWithImpl(this._self, this._then);

  final _FeedbackEntity _self;
  final $Res Function(_FeedbackEntity) _then;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? rating = null,Object? createdAt = null,Object? message = null,Object? appVersion = null,Object? platform = null,}) {
  return _then(_FeedbackEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
