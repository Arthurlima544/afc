// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubAccountEntity {

 String get uuid; String get userId; String get name; SubAccountType get type; int get color; int get icon;
/// Create a copy of SubAccountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubAccountEntityCopyWith<SubAccountEntity> get copyWith => _$SubAccountEntityCopyWithImpl<SubAccountEntity>(this as SubAccountEntity, _$identity);

  /// Serializes this SubAccountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubAccountEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,color,icon);

@override
String toString() {
  return 'SubAccountEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $SubAccountEntityCopyWith<$Res>  {
  factory $SubAccountEntityCopyWith(SubAccountEntity value, $Res Function(SubAccountEntity) _then) = _$SubAccountEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String name, SubAccountType type, int color, int icon
});




}
/// @nodoc
class _$SubAccountEntityCopyWithImpl<$Res>
    implements $SubAccountEntityCopyWith<$Res> {
  _$SubAccountEntityCopyWithImpl(this._self, this._then);

  final SubAccountEntity _self;
  final $Res Function(SubAccountEntity) _then;

/// Create a copy of SubAccountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? color = null,Object? icon = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SubAccountType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubAccountEntity].
extension SubAccountEntityPatterns on SubAccountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubAccountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubAccountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubAccountEntity value)  $default,){
final _that = this;
switch (_that) {
case _SubAccountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubAccountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SubAccountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  SubAccountType type,  int color,  int icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubAccountEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.color,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  SubAccountType type,  int color,  int icon)  $default,) {final _that = this;
switch (_that) {
case _SubAccountEntity():
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.color,_that.icon);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String name,  SubAccountType type,  int color,  int icon)?  $default,) {final _that = this;
switch (_that) {
case _SubAccountEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.color,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubAccountEntity implements SubAccountEntity {
  const _SubAccountEntity({required this.uuid, required this.userId, required this.name, required this.type, this.color = 0xFF2196F3, this.icon = 0});
  factory _SubAccountEntity.fromJson(Map<String, dynamic> json) => _$SubAccountEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String name;
@override final  SubAccountType type;
@override@JsonKey() final  int color;
@override@JsonKey() final  int icon;

/// Create a copy of SubAccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubAccountEntityCopyWith<_SubAccountEntity> get copyWith => __$SubAccountEntityCopyWithImpl<_SubAccountEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubAccountEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubAccountEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,color,icon);

@override
String toString() {
  return 'SubAccountEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$SubAccountEntityCopyWith<$Res> implements $SubAccountEntityCopyWith<$Res> {
  factory _$SubAccountEntityCopyWith(_SubAccountEntity value, $Res Function(_SubAccountEntity) _then) = __$SubAccountEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String name, SubAccountType type, int color, int icon
});




}
/// @nodoc
class __$SubAccountEntityCopyWithImpl<$Res>
    implements _$SubAccountEntityCopyWith<$Res> {
  __$SubAccountEntityCopyWithImpl(this._self, this._then);

  final _SubAccountEntity _self;
  final $Res Function(_SubAccountEntity) _then;

/// Create a copy of SubAccountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? color = null,Object? icon = null,}) {
  return _then(_SubAccountEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SubAccountType,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
