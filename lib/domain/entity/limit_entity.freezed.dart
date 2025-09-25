// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'limit_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LimitEntity {

 String get uuid; String get categoryUUid; String get month; double get limitAmount; String get userId;
/// Create a copy of LimitEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LimitEntityCopyWith<LimitEntity> get copyWith => _$LimitEntityCopyWithImpl<LimitEntity>(this as LimitEntity, _$identity);

  /// Serializes this LimitEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LimitEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,categoryUUid,month,limitAmount,userId);

@override
String toString() {
  return 'LimitEntity(uuid: $uuid, categoryUUid: $categoryUUid, month: $month, limitAmount: $limitAmount, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $LimitEntityCopyWith<$Res>  {
  factory $LimitEntityCopyWith(LimitEntity value, $Res Function(LimitEntity) _then) = _$LimitEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String categoryUUid, String month, double limitAmount, String userId
});




}
/// @nodoc
class _$LimitEntityCopyWithImpl<$Res>
    implements $LimitEntityCopyWith<$Res> {
  _$LimitEntityCopyWithImpl(this._self, this._then);

  final LimitEntity _self;
  final $Res Function(LimitEntity) _then;

/// Create a copy of LimitEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? categoryUUid = null,Object? month = null,Object? limitAmount = null,Object? userId = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,categoryUUid: null == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as double,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LimitEntity].
extension LimitEntityPatterns on LimitEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LimitEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LimitEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LimitEntity value)  $default,){
final _that = this;
switch (_that) {
case _LimitEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LimitEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LimitEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String categoryUUid,  String month,  double limitAmount,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LimitEntity() when $default != null:
return $default(_that.uuid,_that.categoryUUid,_that.month,_that.limitAmount,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String categoryUUid,  String month,  double limitAmount,  String userId)  $default,) {final _that = this;
switch (_that) {
case _LimitEntity():
return $default(_that.uuid,_that.categoryUUid,_that.month,_that.limitAmount,_that.userId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String categoryUUid,  String month,  double limitAmount,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _LimitEntity() when $default != null:
return $default(_that.uuid,_that.categoryUUid,_that.month,_that.limitAmount,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LimitEntity implements LimitEntity {
  const _LimitEntity({required this.uuid, required this.categoryUUid, required this.month, required this.limitAmount, required this.userId});
  factory _LimitEntity.fromJson(Map<String, dynamic> json) => _$LimitEntityFromJson(json);

@override final  String uuid;
@override final  String categoryUUid;
@override final  String month;
@override final  double limitAmount;
@override final  String userId;

/// Create a copy of LimitEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LimitEntityCopyWith<_LimitEntity> get copyWith => __$LimitEntityCopyWithImpl<_LimitEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LimitEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LimitEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.month, month) || other.month == month)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,categoryUUid,month,limitAmount,userId);

@override
String toString() {
  return 'LimitEntity(uuid: $uuid, categoryUUid: $categoryUUid, month: $month, limitAmount: $limitAmount, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$LimitEntityCopyWith<$Res> implements $LimitEntityCopyWith<$Res> {
  factory _$LimitEntityCopyWith(_LimitEntity value, $Res Function(_LimitEntity) _then) = __$LimitEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String categoryUUid, String month, double limitAmount, String userId
});




}
/// @nodoc
class __$LimitEntityCopyWithImpl<$Res>
    implements _$LimitEntityCopyWith<$Res> {
  __$LimitEntityCopyWithImpl(this._self, this._then);

  final _LimitEntity _self;
  final $Res Function(_LimitEntity) _then;

/// Create a copy of LimitEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? categoryUUid = null,Object? month = null,Object? limitAmount = null,Object? userId = null,}) {
  return _then(_LimitEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,categoryUUid: null == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as double,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
