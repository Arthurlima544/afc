// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watchlist_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WatchlistEntity {

 String get uuid; String get userId; String get ticker; DateTime get addedAt; double? get alertThreshold;
/// Create a copy of WatchlistEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WatchlistEntityCopyWith<WatchlistEntity> get copyWith => _$WatchlistEntityCopyWithImpl<WatchlistEntity>(this as WatchlistEntity, _$identity);

  /// Serializes this WatchlistEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WatchlistEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.alertThreshold, alertThreshold) || other.alertThreshold == alertThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,ticker,addedAt,alertThreshold);

@override
String toString() {
  return 'WatchlistEntity(uuid: $uuid, userId: $userId, ticker: $ticker, addedAt: $addedAt, alertThreshold: $alertThreshold)';
}


}

/// @nodoc
abstract mixin class $WatchlistEntityCopyWith<$Res>  {
  factory $WatchlistEntityCopyWith(WatchlistEntity value, $Res Function(WatchlistEntity) _then) = _$WatchlistEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String ticker, DateTime addedAt, double? alertThreshold
});




}
/// @nodoc
class _$WatchlistEntityCopyWithImpl<$Res>
    implements $WatchlistEntityCopyWith<$Res> {
  _$WatchlistEntityCopyWithImpl(this._self, this._then);

  final WatchlistEntity _self;
  final $Res Function(WatchlistEntity) _then;

/// Create a copy of WatchlistEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? ticker = null,Object? addedAt = null,Object? alertThreshold = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,alertThreshold: freezed == alertThreshold ? _self.alertThreshold : alertThreshold // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WatchlistEntity].
extension WatchlistEntityPatterns on WatchlistEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WatchlistEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WatchlistEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WatchlistEntity value)  $default,){
final _that = this;
switch (_that) {
case _WatchlistEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WatchlistEntity value)?  $default,){
final _that = this;
switch (_that) {
case _WatchlistEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String ticker,  DateTime addedAt,  double? alertThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WatchlistEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.ticker,_that.addedAt,_that.alertThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String ticker,  DateTime addedAt,  double? alertThreshold)  $default,) {final _that = this;
switch (_that) {
case _WatchlistEntity():
return $default(_that.uuid,_that.userId,_that.ticker,_that.addedAt,_that.alertThreshold);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String ticker,  DateTime addedAt,  double? alertThreshold)?  $default,) {final _that = this;
switch (_that) {
case _WatchlistEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.ticker,_that.addedAt,_that.alertThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WatchlistEntity implements WatchlistEntity {
  const _WatchlistEntity({required this.uuid, required this.userId, required this.ticker, required this.addedAt, this.alertThreshold});
  factory _WatchlistEntity.fromJson(Map<String, dynamic> json) => _$WatchlistEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String ticker;
@override final  DateTime addedAt;
@override final  double? alertThreshold;

/// Create a copy of WatchlistEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WatchlistEntityCopyWith<_WatchlistEntity> get copyWith => __$WatchlistEntityCopyWithImpl<_WatchlistEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WatchlistEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WatchlistEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.alertThreshold, alertThreshold) || other.alertThreshold == alertThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,ticker,addedAt,alertThreshold);

@override
String toString() {
  return 'WatchlistEntity(uuid: $uuid, userId: $userId, ticker: $ticker, addedAt: $addedAt, alertThreshold: $alertThreshold)';
}


}

/// @nodoc
abstract mixin class _$WatchlistEntityCopyWith<$Res> implements $WatchlistEntityCopyWith<$Res> {
  factory _$WatchlistEntityCopyWith(_WatchlistEntity value, $Res Function(_WatchlistEntity) _then) = __$WatchlistEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String ticker, DateTime addedAt, double? alertThreshold
});




}
/// @nodoc
class __$WatchlistEntityCopyWithImpl<$Res>
    implements _$WatchlistEntityCopyWith<$Res> {
  __$WatchlistEntityCopyWithImpl(this._self, this._then);

  final _WatchlistEntity _self;
  final $Res Function(_WatchlistEntity) _then;

/// Create a copy of WatchlistEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? ticker = null,Object? addedAt = null,Object? alertThreshold = freezed,}) {
  return _then(_WatchlistEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,alertThreshold: freezed == alertThreshold ? _self.alertThreshold : alertThreshold // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
