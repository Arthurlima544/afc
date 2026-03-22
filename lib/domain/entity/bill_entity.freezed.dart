// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillEntity {

 String get uuid; String get userId; String get name; double get amount; int get dueDay; String get categoryUuid;
/// Create a copy of BillEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillEntityCopyWith<BillEntity> get copyWith => _$BillEntityCopyWithImpl<BillEntity>(this as BillEntity, _$identity);

  /// Serializes this BillEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.categoryUuid, categoryUuid) || other.categoryUuid == categoryUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,amount,dueDay,categoryUuid);

@override
String toString() {
  return 'BillEntity(uuid: $uuid, userId: $userId, name: $name, amount: $amount, dueDay: $dueDay, categoryUuid: $categoryUuid)';
}


}

/// @nodoc
abstract mixin class $BillEntityCopyWith<$Res>  {
  factory $BillEntityCopyWith(BillEntity value, $Res Function(BillEntity) _then) = _$BillEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String name, double amount, int dueDay, String categoryUuid
});




}
/// @nodoc
class _$BillEntityCopyWithImpl<$Res>
    implements $BillEntityCopyWith<$Res> {
  _$BillEntityCopyWithImpl(this._self, this._then);

  final BillEntity _self;
  final $Res Function(BillEntity) _then;

/// Create a copy of BillEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? amount = null,Object? dueDay = null,Object? categoryUuid = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,categoryUuid: null == categoryUuid ? _self.categoryUuid : categoryUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BillEntity].
extension BillEntityPatterns on BillEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillEntity value)  $default,){
final _that = this;
switch (_that) {
case _BillEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BillEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  double amount,  int dueDay,  String categoryUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.amount,_that.dueDay,_that.categoryUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  double amount,  int dueDay,  String categoryUuid)  $default,) {final _that = this;
switch (_that) {
case _BillEntity():
return $default(_that.uuid,_that.userId,_that.name,_that.amount,_that.dueDay,_that.categoryUuid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String name,  double amount,  int dueDay,  String categoryUuid)?  $default,) {final _that = this;
switch (_that) {
case _BillEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.amount,_that.dueDay,_that.categoryUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillEntity implements BillEntity {
  const _BillEntity({required this.uuid, required this.userId, required this.name, required this.amount, required this.dueDay, required this.categoryUuid});
  factory _BillEntity.fromJson(Map<String, dynamic> json) => _$BillEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String name;
@override final  double amount;
@override final  int dueDay;
@override final  String categoryUuid;

/// Create a copy of BillEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillEntityCopyWith<_BillEntity> get copyWith => __$BillEntityCopyWithImpl<_BillEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.categoryUuid, categoryUuid) || other.categoryUuid == categoryUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,amount,dueDay,categoryUuid);

@override
String toString() {
  return 'BillEntity(uuid: $uuid, userId: $userId, name: $name, amount: $amount, dueDay: $dueDay, categoryUuid: $categoryUuid)';
}


}

/// @nodoc
abstract mixin class _$BillEntityCopyWith<$Res> implements $BillEntityCopyWith<$Res> {
  factory _$BillEntityCopyWith(_BillEntity value, $Res Function(_BillEntity) _then) = __$BillEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String name, double amount, int dueDay, String categoryUuid
});




}
/// @nodoc
class __$BillEntityCopyWithImpl<$Res>
    implements _$BillEntityCopyWith<$Res> {
  __$BillEntityCopyWithImpl(this._self, this._then);

  final _BillEntity _self;
  final $Res Function(_BillEntity) _then;

/// Create a copy of BillEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? amount = null,Object? dueDay = null,Object? categoryUuid = null,}) {
  return _then(_BillEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,categoryUuid: null == categoryUuid ? _self.categoryUuid : categoryUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
