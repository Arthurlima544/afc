// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connected_account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectedAccountEntity {

 String get uuid; String get userId; String get pluggyItemId; String get institutionName; String get status; String? get institutionLogo; DateTime? get lastSyncedAt;
/// Create a copy of ConnectedAccountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectedAccountEntityCopyWith<ConnectedAccountEntity> get copyWith => _$ConnectedAccountEntityCopyWithImpl<ConnectedAccountEntity>(this as ConnectedAccountEntity, _$identity);

  /// Serializes this ConnectedAccountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectedAccountEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pluggyItemId, pluggyItemId) || other.pluggyItemId == pluggyItemId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.status, status) || other.status == status)&&(identical(other.institutionLogo, institutionLogo) || other.institutionLogo == institutionLogo)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,pluggyItemId,institutionName,status,institutionLogo,lastSyncedAt);

@override
String toString() {
  return 'ConnectedAccountEntity(uuid: $uuid, userId: $userId, pluggyItemId: $pluggyItemId, institutionName: $institutionName, status: $status, institutionLogo: $institutionLogo, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $ConnectedAccountEntityCopyWith<$Res>  {
  factory $ConnectedAccountEntityCopyWith(ConnectedAccountEntity value, $Res Function(ConnectedAccountEntity) _then) = _$ConnectedAccountEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String pluggyItemId, String institutionName, String status, String? institutionLogo, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$ConnectedAccountEntityCopyWithImpl<$Res>
    implements $ConnectedAccountEntityCopyWith<$Res> {
  _$ConnectedAccountEntityCopyWithImpl(this._self, this._then);

  final ConnectedAccountEntity _self;
  final $Res Function(ConnectedAccountEntity) _then;

/// Create a copy of ConnectedAccountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? pluggyItemId = null,Object? institutionName = null,Object? status = null,Object? institutionLogo = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pluggyItemId: null == pluggyItemId ? _self.pluggyItemId : pluggyItemId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,institutionLogo: freezed == institutionLogo ? _self.institutionLogo : institutionLogo // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectedAccountEntity].
extension ConnectedAccountEntityPatterns on ConnectedAccountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectedAccountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectedAccountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectedAccountEntity value)  $default,){
final _that = this;
switch (_that) {
case _ConnectedAccountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectedAccountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectedAccountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String pluggyItemId,  String institutionName,  String status,  String? institutionLogo,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectedAccountEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.pluggyItemId,_that.institutionName,_that.status,_that.institutionLogo,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String pluggyItemId,  String institutionName,  String status,  String? institutionLogo,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _ConnectedAccountEntity():
return $default(_that.uuid,_that.userId,_that.pluggyItemId,_that.institutionName,_that.status,_that.institutionLogo,_that.lastSyncedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String pluggyItemId,  String institutionName,  String status,  String? institutionLogo,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConnectedAccountEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.pluggyItemId,_that.institutionName,_that.status,_that.institutionLogo,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectedAccountEntity implements ConnectedAccountEntity {
  const _ConnectedAccountEntity({required this.uuid, required this.userId, required this.pluggyItemId, required this.institutionName, required this.status, this.institutionLogo, this.lastSyncedAt});
  factory _ConnectedAccountEntity.fromJson(Map<String, dynamic> json) => _$ConnectedAccountEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String pluggyItemId;
@override final  String institutionName;
@override final  String status;
@override final  String? institutionLogo;
@override final  DateTime? lastSyncedAt;

/// Create a copy of ConnectedAccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedAccountEntityCopyWith<_ConnectedAccountEntity> get copyWith => __$ConnectedAccountEntityCopyWithImpl<_ConnectedAccountEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectedAccountEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectedAccountEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pluggyItemId, pluggyItemId) || other.pluggyItemId == pluggyItemId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.status, status) || other.status == status)&&(identical(other.institutionLogo, institutionLogo) || other.institutionLogo == institutionLogo)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,pluggyItemId,institutionName,status,institutionLogo,lastSyncedAt);

@override
String toString() {
  return 'ConnectedAccountEntity(uuid: $uuid, userId: $userId, pluggyItemId: $pluggyItemId, institutionName: $institutionName, status: $status, institutionLogo: $institutionLogo, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$ConnectedAccountEntityCopyWith<$Res> implements $ConnectedAccountEntityCopyWith<$Res> {
  factory _$ConnectedAccountEntityCopyWith(_ConnectedAccountEntity value, $Res Function(_ConnectedAccountEntity) _then) = __$ConnectedAccountEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String pluggyItemId, String institutionName, String status, String? institutionLogo, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$ConnectedAccountEntityCopyWithImpl<$Res>
    implements _$ConnectedAccountEntityCopyWith<$Res> {
  __$ConnectedAccountEntityCopyWithImpl(this._self, this._then);

  final _ConnectedAccountEntity _self;
  final $Res Function(_ConnectedAccountEntity) _then;

/// Create a copy of ConnectedAccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? pluggyItemId = null,Object? institutionName = null,Object? status = null,Object? institutionLogo = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_ConnectedAccountEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pluggyItemId: null == pluggyItemId ? _self.pluggyItemId : pluggyItemId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,institutionLogo: freezed == institutionLogo ? _self.institutionLogo : institutionLogo // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
