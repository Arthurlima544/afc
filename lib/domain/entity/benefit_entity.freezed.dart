// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenefitEntity {

 String get uuid; String get userId; String get name; BenefitType get type; double get monthlyCredit; int get color; double get balance; String get resetMonth;
/// Create a copy of BenefitEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitEntityCopyWith<BenefitEntity> get copyWith => _$BenefitEntityCopyWithImpl<BenefitEntity>(this as BenefitEntity, _$identity);

  /// Serializes this BenefitEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.monthlyCredit, monthlyCredit) || other.monthlyCredit == monthlyCredit)&&(identical(other.color, color) || other.color == color)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.resetMonth, resetMonth) || other.resetMonth == resetMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,monthlyCredit,color,balance,resetMonth);

@override
String toString() {
  return 'BenefitEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, monthlyCredit: $monthlyCredit, color: $color, balance: $balance, resetMonth: $resetMonth)';
}


}

/// @nodoc
abstract mixin class $BenefitEntityCopyWith<$Res>  {
  factory $BenefitEntityCopyWith(BenefitEntity value, $Res Function(BenefitEntity) _then) = _$BenefitEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String name, BenefitType type, double monthlyCredit, int color, double balance, String resetMonth
});




}
/// @nodoc
class _$BenefitEntityCopyWithImpl<$Res>
    implements $BenefitEntityCopyWith<$Res> {
  _$BenefitEntityCopyWithImpl(this._self, this._then);

  final BenefitEntity _self;
  final $Res Function(BenefitEntity) _then;

/// Create a copy of BenefitEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? monthlyCredit = null,Object? color = null,Object? balance = null,Object? resetMonth = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BenefitType,monthlyCredit: null == monthlyCredit ? _self.monthlyCredit : monthlyCredit // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,resetMonth: null == resetMonth ? _self.resetMonth : resetMonth // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BenefitEntity].
extension BenefitEntityPatterns on BenefitEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenefitEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenefitEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenefitEntity value)  $default,){
final _that = this;
switch (_that) {
case _BenefitEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenefitEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BenefitEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  BenefitType type,  double monthlyCredit,  int color,  double balance,  String resetMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.monthlyCredit,_that.color,_that.balance,_that.resetMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  BenefitType type,  double monthlyCredit,  int color,  double balance,  String resetMonth)  $default,) {final _that = this;
switch (_that) {
case _BenefitEntity():
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.monthlyCredit,_that.color,_that.balance,_that.resetMonth);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String name,  BenefitType type,  double monthlyCredit,  int color,  double balance,  String resetMonth)?  $default,) {final _that = this;
switch (_that) {
case _BenefitEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.monthlyCredit,_that.color,_that.balance,_that.resetMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitEntity implements BenefitEntity {
  const _BenefitEntity({required this.uuid, required this.userId, required this.name, required this.type, required this.monthlyCredit, required this.color, this.balance = 0.0, this.resetMonth = ''});
  factory _BenefitEntity.fromJson(Map<String, dynamic> json) => _$BenefitEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String name;
@override final  BenefitType type;
@override final  double monthlyCredit;
@override final  int color;
@override@JsonKey() final  double balance;
@override@JsonKey() final  String resetMonth;

/// Create a copy of BenefitEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitEntityCopyWith<_BenefitEntity> get copyWith => __$BenefitEntityCopyWithImpl<_BenefitEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.monthlyCredit, monthlyCredit) || other.monthlyCredit == monthlyCredit)&&(identical(other.color, color) || other.color == color)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.resetMonth, resetMonth) || other.resetMonth == resetMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,monthlyCredit,color,balance,resetMonth);

@override
String toString() {
  return 'BenefitEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, monthlyCredit: $monthlyCredit, color: $color, balance: $balance, resetMonth: $resetMonth)';
}


}

/// @nodoc
abstract mixin class _$BenefitEntityCopyWith<$Res> implements $BenefitEntityCopyWith<$Res> {
  factory _$BenefitEntityCopyWith(_BenefitEntity value, $Res Function(_BenefitEntity) _then) = __$BenefitEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String name, BenefitType type, double monthlyCredit, int color, double balance, String resetMonth
});




}
/// @nodoc
class __$BenefitEntityCopyWithImpl<$Res>
    implements _$BenefitEntityCopyWith<$Res> {
  __$BenefitEntityCopyWithImpl(this._self, this._then);

  final _BenefitEntity _self;
  final $Res Function(_BenefitEntity) _then;

/// Create a copy of BenefitEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? monthlyCredit = null,Object? color = null,Object? balance = null,Object? resetMonth = null,}) {
  return _then(_BenefitEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BenefitType,monthlyCredit: null == monthlyCredit ? _self.monthlyCredit : monthlyCredit // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,resetMonth: null == resetMonth ? _self.resetMonth : resetMonth // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
