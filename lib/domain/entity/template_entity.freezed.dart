// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateEntity {

 String get uuid; String get userId; String get title; double get amount; String get categoryUUid; String get typeUuid;
/// Create a copy of TemplateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateEntityCopyWith<TemplateEntity> get copyWith => _$TemplateEntityCopyWithImpl<TemplateEntity>(this as TemplateEntity, _$identity);

  /// Serializes this TemplateEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.typeUuid, typeUuid) || other.typeUuid == typeUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,title,amount,categoryUUid,typeUuid);

@override
String toString() {
  return 'TemplateEntity(uuid: $uuid, userId: $userId, title: $title, amount: $amount, categoryUUid: $categoryUUid, typeUuid: $typeUuid)';
}


}

/// @nodoc
abstract mixin class $TemplateEntityCopyWith<$Res>  {
  factory $TemplateEntityCopyWith(TemplateEntity value, $Res Function(TemplateEntity) _then) = _$TemplateEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String title, double amount, String categoryUUid, String typeUuid
});




}
/// @nodoc
class _$TemplateEntityCopyWithImpl<$Res>
    implements $TemplateEntityCopyWith<$Res> {
  _$TemplateEntityCopyWithImpl(this._self, this._then);

  final TemplateEntity _self;
  final $Res Function(TemplateEntity) _then;

/// Create a copy of TemplateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? title = null,Object? amount = null,Object? categoryUUid = null,Object? typeUuid = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryUUid: null == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String,typeUuid: null == typeUuid ? _self.typeUuid : typeUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateEntity].
extension TemplateEntityPatterns on TemplateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateEntity value)  $default,){
final _that = this;
switch (_that) {
case _TemplateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String title,  double amount,  String categoryUUid,  String typeUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.title,_that.amount,_that.categoryUUid,_that.typeUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String title,  double amount,  String categoryUUid,  String typeUuid)  $default,) {final _that = this;
switch (_that) {
case _TemplateEntity():
return $default(_that.uuid,_that.userId,_that.title,_that.amount,_that.categoryUUid,_that.typeUuid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String title,  double amount,  String categoryUUid,  String typeUuid)?  $default,) {final _that = this;
switch (_that) {
case _TemplateEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.title,_that.amount,_that.categoryUUid,_that.typeUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateEntity implements TemplateEntity {
  const _TemplateEntity({required this.uuid, required this.userId, required this.title, required this.amount, required this.categoryUUid, required this.typeUuid});
  factory _TemplateEntity.fromJson(Map<String, dynamic> json) => _$TemplateEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String title;
@override final  double amount;
@override final  String categoryUUid;
@override final  String typeUuid;

/// Create a copy of TemplateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateEntityCopyWith<_TemplateEntity> get copyWith => __$TemplateEntityCopyWithImpl<_TemplateEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.typeUuid, typeUuid) || other.typeUuid == typeUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,title,amount,categoryUUid,typeUuid);

@override
String toString() {
  return 'TemplateEntity(uuid: $uuid, userId: $userId, title: $title, amount: $amount, categoryUUid: $categoryUUid, typeUuid: $typeUuid)';
}


}

/// @nodoc
abstract mixin class _$TemplateEntityCopyWith<$Res> implements $TemplateEntityCopyWith<$Res> {
  factory _$TemplateEntityCopyWith(_TemplateEntity value, $Res Function(_TemplateEntity) _then) = __$TemplateEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String title, double amount, String categoryUUid, String typeUuid
});




}
/// @nodoc
class __$TemplateEntityCopyWithImpl<$Res>
    implements _$TemplateEntityCopyWith<$Res> {
  __$TemplateEntityCopyWithImpl(this._self, this._then);

  final _TemplateEntity _self;
  final $Res Function(_TemplateEntity) _then;

/// Create a copy of TemplateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? title = null,Object? amount = null,Object? categoryUUid = null,Object? typeUuid = null,}) {
  return _then(_TemplateEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryUUid: null == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String,typeUuid: null == typeUuid ? _self.typeUuid : typeUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
