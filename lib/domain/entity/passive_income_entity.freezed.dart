// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passive_income_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PassiveIncomeEntity {

 String get uuid; String get userId;/// Human-readable label (e.g. "Dividendos PETR4", "Aluguel Sala Comercial").
 String get name;/// Category: 'dividend', 'interest', 'rent', 'other'.
 String get source;/// Amount received per [frequency] cycle.
 double get amount;/// 'monthly', 'quarterly', 'annual'.
 String get frequency;/// Optional link to an investment UUID.
 String? get assetUuid;
/// Create a copy of PassiveIncomeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassiveIncomeEntityCopyWith<PassiveIncomeEntity> get copyWith => _$PassiveIncomeEntityCopyWithImpl<PassiveIncomeEntity>(this as PassiveIncomeEntity, _$identity);

  /// Serializes this PassiveIncomeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassiveIncomeEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.assetUuid, assetUuid) || other.assetUuid == assetUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,source,amount,frequency,assetUuid);

@override
String toString() {
  return 'PassiveIncomeEntity(uuid: $uuid, userId: $userId, name: $name, source: $source, amount: $amount, frequency: $frequency, assetUuid: $assetUuid)';
}


}

/// @nodoc
abstract mixin class $PassiveIncomeEntityCopyWith<$Res>  {
  factory $PassiveIncomeEntityCopyWith(PassiveIncomeEntity value, $Res Function(PassiveIncomeEntity) _then) = _$PassiveIncomeEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String name, String source, double amount, String frequency, String? assetUuid
});




}
/// @nodoc
class _$PassiveIncomeEntityCopyWithImpl<$Res>
    implements $PassiveIncomeEntityCopyWith<$Res> {
  _$PassiveIncomeEntityCopyWithImpl(this._self, this._then);

  final PassiveIncomeEntity _self;
  final $Res Function(PassiveIncomeEntity) _then;

/// Create a copy of PassiveIncomeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? source = null,Object? amount = null,Object? frequency = null,Object? assetUuid = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,assetUuid: freezed == assetUuid ? _self.assetUuid : assetUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassiveIncomeEntity].
extension PassiveIncomeEntityPatterns on PassiveIncomeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassiveIncomeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassiveIncomeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassiveIncomeEntity value)  $default,){
final _that = this;
switch (_that) {
case _PassiveIncomeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassiveIncomeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PassiveIncomeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  String source,  double amount,  String frequency,  String? assetUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassiveIncomeEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.source,_that.amount,_that.frequency,_that.assetUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  String source,  double amount,  String frequency,  String? assetUuid)  $default,) {final _that = this;
switch (_that) {
case _PassiveIncomeEntity():
return $default(_that.uuid,_that.userId,_that.name,_that.source,_that.amount,_that.frequency,_that.assetUuid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String name,  String source,  double amount,  String frequency,  String? assetUuid)?  $default,) {final _that = this;
switch (_that) {
case _PassiveIncomeEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.source,_that.amount,_that.frequency,_that.assetUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassiveIncomeEntity implements PassiveIncomeEntity {
  const _PassiveIncomeEntity({required this.uuid, required this.userId, required this.name, required this.source, required this.amount, required this.frequency, this.assetUuid});
  factory _PassiveIncomeEntity.fromJson(Map<String, dynamic> json) => _$PassiveIncomeEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
/// Human-readable label (e.g. "Dividendos PETR4", "Aluguel Sala Comercial").
@override final  String name;
/// Category: 'dividend', 'interest', 'rent', 'other'.
@override final  String source;
/// Amount received per [frequency] cycle.
@override final  double amount;
/// 'monthly', 'quarterly', 'annual'.
@override final  String frequency;
/// Optional link to an investment UUID.
@override final  String? assetUuid;

/// Create a copy of PassiveIncomeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassiveIncomeEntityCopyWith<_PassiveIncomeEntity> get copyWith => __$PassiveIncomeEntityCopyWithImpl<_PassiveIncomeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassiveIncomeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassiveIncomeEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.assetUuid, assetUuid) || other.assetUuid == assetUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,source,amount,frequency,assetUuid);

@override
String toString() {
  return 'PassiveIncomeEntity(uuid: $uuid, userId: $userId, name: $name, source: $source, amount: $amount, frequency: $frequency, assetUuid: $assetUuid)';
}


}

/// @nodoc
abstract mixin class _$PassiveIncomeEntityCopyWith<$Res> implements $PassiveIncomeEntityCopyWith<$Res> {
  factory _$PassiveIncomeEntityCopyWith(_PassiveIncomeEntity value, $Res Function(_PassiveIncomeEntity) _then) = __$PassiveIncomeEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String name, String source, double amount, String frequency, String? assetUuid
});




}
/// @nodoc
class __$PassiveIncomeEntityCopyWithImpl<$Res>
    implements _$PassiveIncomeEntityCopyWith<$Res> {
  __$PassiveIncomeEntityCopyWithImpl(this._self, this._then);

  final _PassiveIncomeEntity _self;
  final $Res Function(_PassiveIncomeEntity) _then;

/// Create a copy of PassiveIncomeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? source = null,Object? amount = null,Object? frequency = null,Object? assetUuid = freezed,}) {
  return _then(_PassiveIncomeEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,assetUuid: freezed == assetUuid ? _self.assetUuid : assetUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
