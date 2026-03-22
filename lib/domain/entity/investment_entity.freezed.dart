// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvestmentEntity {

 String get uuid; String get userId; String get name; String get type; double get quantity; double get avgCost; double get currentPrice; String? get ticker;
/// Create a copy of InvestmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestmentEntityCopyWith<InvestmentEntity> get copyWith => _$InvestmentEntityCopyWithImpl<InvestmentEntity>(this as InvestmentEntity, _$identity);

  /// Serializes this InvestmentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvestmentEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.avgCost, avgCost) || other.avgCost == avgCost)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.ticker, ticker) || other.ticker == ticker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,quantity,avgCost,currentPrice,ticker);

@override
String toString() {
  return 'InvestmentEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, quantity: $quantity, avgCost: $avgCost, currentPrice: $currentPrice, ticker: $ticker)';
}


}

/// @nodoc
abstract mixin class $InvestmentEntityCopyWith<$Res>  {
  factory $InvestmentEntityCopyWith(InvestmentEntity value, $Res Function(InvestmentEntity) _then) = _$InvestmentEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String name, String type, double quantity, double avgCost, double currentPrice, String? ticker
});




}
/// @nodoc
class _$InvestmentEntityCopyWithImpl<$Res>
    implements $InvestmentEntityCopyWith<$Res> {
  _$InvestmentEntityCopyWithImpl(this._self, this._then);

  final InvestmentEntity _self;
  final $Res Function(InvestmentEntity) _then;

/// Create a copy of InvestmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? quantity = null,Object? avgCost = null,Object? currentPrice = null,Object? ticker = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,avgCost: null == avgCost ? _self.avgCost : avgCost // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,ticker: freezed == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvestmentEntity].
extension InvestmentEntityPatterns on InvestmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvestmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvestmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvestmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _InvestmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvestmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _InvestmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  String type,  double quantity,  double avgCost,  double currentPrice,  String? ticker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvestmentEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.quantity,_that.avgCost,_that.currentPrice,_that.ticker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String name,  String type,  double quantity,  double avgCost,  double currentPrice,  String? ticker)  $default,) {final _that = this;
switch (_that) {
case _InvestmentEntity():
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.quantity,_that.avgCost,_that.currentPrice,_that.ticker);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String name,  String type,  double quantity,  double avgCost,  double currentPrice,  String? ticker)?  $default,) {final _that = this;
switch (_that) {
case _InvestmentEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.name,_that.type,_that.quantity,_that.avgCost,_that.currentPrice,_that.ticker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvestmentEntity implements InvestmentEntity {
  const _InvestmentEntity({required this.uuid, required this.userId, required this.name, required this.type, required this.quantity, required this.avgCost, required this.currentPrice, this.ticker});
  factory _InvestmentEntity.fromJson(Map<String, dynamic> json) => _$InvestmentEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String name;
@override final  String type;
@override final  double quantity;
@override final  double avgCost;
@override final  double currentPrice;
@override final  String? ticker;

/// Create a copy of InvestmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestmentEntityCopyWith<_InvestmentEntity> get copyWith => __$InvestmentEntityCopyWithImpl<_InvestmentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvestmentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvestmentEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.avgCost, avgCost) || other.avgCost == avgCost)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.ticker, ticker) || other.ticker == ticker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,name,type,quantity,avgCost,currentPrice,ticker);

@override
String toString() {
  return 'InvestmentEntity(uuid: $uuid, userId: $userId, name: $name, type: $type, quantity: $quantity, avgCost: $avgCost, currentPrice: $currentPrice, ticker: $ticker)';
}


}

/// @nodoc
abstract mixin class _$InvestmentEntityCopyWith<$Res> implements $InvestmentEntityCopyWith<$Res> {
  factory _$InvestmentEntityCopyWith(_InvestmentEntity value, $Res Function(_InvestmentEntity) _then) = __$InvestmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String name, String type, double quantity, double avgCost, double currentPrice, String? ticker
});




}
/// @nodoc
class __$InvestmentEntityCopyWithImpl<$Res>
    implements _$InvestmentEntityCopyWith<$Res> {
  __$InvestmentEntityCopyWithImpl(this._self, this._then);

  final _InvestmentEntity _self;
  final $Res Function(_InvestmentEntity) _then;

/// Create a copy of InvestmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? name = null,Object? type = null,Object? quantity = null,Object? avgCost = null,Object? currentPrice = null,Object? ticker = freezed,}) {
  return _then(_InvestmentEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,avgCost: null == avgCost ? _self.avgCost : avgCost // ignore: cast_nullable_to_non_nullable
as double,currentPrice: null == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double,ticker: freezed == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
