// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'net_worth_snapshot_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NetWorthSnapshotEntity {

 String get uuid; String get userId;/// ISO-8601 date string ('yyyy-MM-dd') for the month this snapshot covers.
 String get date;/// Total value of all assets (portfolio + goal balances).
 double get assets;/// Total liabilities at snapshot time.
 double get liabilities;/// Computed: assets − liabilities.
 double get netWorth;
/// Create a copy of NetWorthSnapshotEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetWorthSnapshotEntityCopyWith<NetWorthSnapshotEntity> get copyWith => _$NetWorthSnapshotEntityCopyWithImpl<NetWorthSnapshotEntity>(this as NetWorthSnapshotEntity, _$identity);

  /// Serializes this NetWorthSnapshotEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetWorthSnapshotEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&(identical(other.assets, assets) || other.assets == assets)&&(identical(other.liabilities, liabilities) || other.liabilities == liabilities)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,date,assets,liabilities,netWorth);

@override
String toString() {
  return 'NetWorthSnapshotEntity(uuid: $uuid, userId: $userId, date: $date, assets: $assets, liabilities: $liabilities, netWorth: $netWorth)';
}


}

/// @nodoc
abstract mixin class $NetWorthSnapshotEntityCopyWith<$Res>  {
  factory $NetWorthSnapshotEntityCopyWith(NetWorthSnapshotEntity value, $Res Function(NetWorthSnapshotEntity) _then) = _$NetWorthSnapshotEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String date, double assets, double liabilities, double netWorth
});




}
/// @nodoc
class _$NetWorthSnapshotEntityCopyWithImpl<$Res>
    implements $NetWorthSnapshotEntityCopyWith<$Res> {
  _$NetWorthSnapshotEntityCopyWithImpl(this._self, this._then);

  final NetWorthSnapshotEntity _self;
  final $Res Function(NetWorthSnapshotEntity) _then;

/// Create a copy of NetWorthSnapshotEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? date = null,Object? assets = null,Object? liabilities = null,Object? netWorth = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as double,liabilities: null == liabilities ? _self.liabilities : liabilities // ignore: cast_nullable_to_non_nullable
as double,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NetWorthSnapshotEntity].
extension NetWorthSnapshotEntityPatterns on NetWorthSnapshotEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetWorthSnapshotEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetWorthSnapshotEntity value)  $default,){
final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetWorthSnapshotEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String date,  double assets,  double liabilities,  double netWorth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.date,_that.assets,_that.liabilities,_that.netWorth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String date,  double assets,  double liabilities,  double netWorth)  $default,) {final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity():
return $default(_that.uuid,_that.userId,_that.date,_that.assets,_that.liabilities,_that.netWorth);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String date,  double assets,  double liabilities,  double netWorth)?  $default,) {final _that = this;
switch (_that) {
case _NetWorthSnapshotEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.date,_that.assets,_that.liabilities,_that.netWorth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NetWorthSnapshotEntity implements NetWorthSnapshotEntity {
  const _NetWorthSnapshotEntity({required this.uuid, required this.userId, required this.date, required this.assets, required this.liabilities, required this.netWorth});
  factory _NetWorthSnapshotEntity.fromJson(Map<String, dynamic> json) => _$NetWorthSnapshotEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
/// ISO-8601 date string ('yyyy-MM-dd') for the month this snapshot covers.
@override final  String date;
/// Total value of all assets (portfolio + goal balances).
@override final  double assets;
/// Total liabilities at snapshot time.
@override final  double liabilities;
/// Computed: assets − liabilities.
@override final  double netWorth;

/// Create a copy of NetWorthSnapshotEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetWorthSnapshotEntityCopyWith<_NetWorthSnapshotEntity> get copyWith => __$NetWorthSnapshotEntityCopyWithImpl<_NetWorthSnapshotEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetWorthSnapshotEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetWorthSnapshotEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&(identical(other.assets, assets) || other.assets == assets)&&(identical(other.liabilities, liabilities) || other.liabilities == liabilities)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,date,assets,liabilities,netWorth);

@override
String toString() {
  return 'NetWorthSnapshotEntity(uuid: $uuid, userId: $userId, date: $date, assets: $assets, liabilities: $liabilities, netWorth: $netWorth)';
}


}

/// @nodoc
abstract mixin class _$NetWorthSnapshotEntityCopyWith<$Res> implements $NetWorthSnapshotEntityCopyWith<$Res> {
  factory _$NetWorthSnapshotEntityCopyWith(_NetWorthSnapshotEntity value, $Res Function(_NetWorthSnapshotEntity) _then) = __$NetWorthSnapshotEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String date, double assets, double liabilities, double netWorth
});




}
/// @nodoc
class __$NetWorthSnapshotEntityCopyWithImpl<$Res>
    implements _$NetWorthSnapshotEntityCopyWith<$Res> {
  __$NetWorthSnapshotEntityCopyWithImpl(this._self, this._then);

  final _NetWorthSnapshotEntity _self;
  final $Res Function(_NetWorthSnapshotEntity) _then;

/// Create a copy of NetWorthSnapshotEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? date = null,Object? assets = null,Object? liabilities = null,Object? netWorth = null,}) {
  return _then(_NetWorthSnapshotEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as double,liabilities: null == liabilities ? _self.liabilities : liabilities // ignore: cast_nullable_to_non_nullable
as double,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
