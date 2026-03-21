// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RawTransactionEntity {

 String get uuid; String get userId; String get pluggyTransactionId; String get accountId; double get amount; String get description; DateTime get date; String get type; String get status; String? get suggestedCategoryUuid;
/// Create a copy of RawTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawTransactionEntityCopyWith<RawTransactionEntity> get copyWith => _$RawTransactionEntityCopyWithImpl<RawTransactionEntity>(this as RawTransactionEntity, _$identity);

  /// Serializes this RawTransactionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawTransactionEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pluggyTransactionId, pluggyTransactionId) || other.pluggyTransactionId == pluggyTransactionId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.suggestedCategoryUuid, suggestedCategoryUuid) || other.suggestedCategoryUuid == suggestedCategoryUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,pluggyTransactionId,accountId,amount,description,date,type,status,suggestedCategoryUuid);

@override
String toString() {
  return 'RawTransactionEntity(uuid: $uuid, userId: $userId, pluggyTransactionId: $pluggyTransactionId, accountId: $accountId, amount: $amount, description: $description, date: $date, type: $type, status: $status, suggestedCategoryUuid: $suggestedCategoryUuid)';
}


}

/// @nodoc
abstract mixin class $RawTransactionEntityCopyWith<$Res>  {
  factory $RawTransactionEntityCopyWith(RawTransactionEntity value, $Res Function(RawTransactionEntity) _then) = _$RawTransactionEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, String pluggyTransactionId, String accountId, double amount, String description, DateTime date, String type, String status, String? suggestedCategoryUuid
});




}
/// @nodoc
class _$RawTransactionEntityCopyWithImpl<$Res>
    implements $RawTransactionEntityCopyWith<$Res> {
  _$RawTransactionEntityCopyWithImpl(this._self, this._then);

  final RawTransactionEntity _self;
  final $Res Function(RawTransactionEntity) _then;

/// Create a copy of RawTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? pluggyTransactionId = null,Object? accountId = null,Object? amount = null,Object? description = null,Object? date = null,Object? type = null,Object? status = null,Object? suggestedCategoryUuid = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pluggyTransactionId: null == pluggyTransactionId ? _self.pluggyTransactionId : pluggyTransactionId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,suggestedCategoryUuid: freezed == suggestedCategoryUuid ? _self.suggestedCategoryUuid : suggestedCategoryUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RawTransactionEntity].
extension RawTransactionEntityPatterns on RawTransactionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RawTransactionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RawTransactionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RawTransactionEntity value)  $default,){
final _that = this;
switch (_that) {
case _RawTransactionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RawTransactionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RawTransactionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  String pluggyTransactionId,  String accountId,  double amount,  String description,  DateTime date,  String type,  String status,  String? suggestedCategoryUuid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RawTransactionEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.pluggyTransactionId,_that.accountId,_that.amount,_that.description,_that.date,_that.type,_that.status,_that.suggestedCategoryUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  String pluggyTransactionId,  String accountId,  double amount,  String description,  DateTime date,  String type,  String status,  String? suggestedCategoryUuid)  $default,) {final _that = this;
switch (_that) {
case _RawTransactionEntity():
return $default(_that.uuid,_that.userId,_that.pluggyTransactionId,_that.accountId,_that.amount,_that.description,_that.date,_that.type,_that.status,_that.suggestedCategoryUuid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  String pluggyTransactionId,  String accountId,  double amount,  String description,  DateTime date,  String type,  String status,  String? suggestedCategoryUuid)?  $default,) {final _that = this;
switch (_that) {
case _RawTransactionEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.pluggyTransactionId,_that.accountId,_that.amount,_that.description,_that.date,_that.type,_that.status,_that.suggestedCategoryUuid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RawTransactionEntity implements RawTransactionEntity {
  const _RawTransactionEntity({required this.uuid, required this.userId, required this.pluggyTransactionId, required this.accountId, required this.amount, required this.description, required this.date, required this.type, required this.status, this.suggestedCategoryUuid});
  factory _RawTransactionEntity.fromJson(Map<String, dynamic> json) => _$RawTransactionEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  String pluggyTransactionId;
@override final  String accountId;
@override final  double amount;
@override final  String description;
@override final  DateTime date;
@override final  String type;
@override final  String status;
@override final  String? suggestedCategoryUuid;

/// Create a copy of RawTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RawTransactionEntityCopyWith<_RawTransactionEntity> get copyWith => __$RawTransactionEntityCopyWithImpl<_RawTransactionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RawTransactionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RawTransactionEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pluggyTransactionId, pluggyTransactionId) || other.pluggyTransactionId == pluggyTransactionId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.suggestedCategoryUuid, suggestedCategoryUuid) || other.suggestedCategoryUuid == suggestedCategoryUuid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,pluggyTransactionId,accountId,amount,description,date,type,status,suggestedCategoryUuid);

@override
String toString() {
  return 'RawTransactionEntity(uuid: $uuid, userId: $userId, pluggyTransactionId: $pluggyTransactionId, accountId: $accountId, amount: $amount, description: $description, date: $date, type: $type, status: $status, suggestedCategoryUuid: $suggestedCategoryUuid)';
}


}

/// @nodoc
abstract mixin class _$RawTransactionEntityCopyWith<$Res> implements $RawTransactionEntityCopyWith<$Res> {
  factory _$RawTransactionEntityCopyWith(_RawTransactionEntity value, $Res Function(_RawTransactionEntity) _then) = __$RawTransactionEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, String pluggyTransactionId, String accountId, double amount, String description, DateTime date, String type, String status, String? suggestedCategoryUuid
});




}
/// @nodoc
class __$RawTransactionEntityCopyWithImpl<$Res>
    implements _$RawTransactionEntityCopyWith<$Res> {
  __$RawTransactionEntityCopyWithImpl(this._self, this._then);

  final _RawTransactionEntity _self;
  final $Res Function(_RawTransactionEntity) _then;

/// Create a copy of RawTransactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? pluggyTransactionId = null,Object? accountId = null,Object? amount = null,Object? description = null,Object? date = null,Object? type = null,Object? status = null,Object? suggestedCategoryUuid = freezed,}) {
  return _then(_RawTransactionEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pluggyTransactionId: null == pluggyTransactionId ? _self.pluggyTransactionId : pluggyTransactionId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,suggestedCategoryUuid: freezed == suggestedCategoryUuid ? _self.suggestedCategoryUuid : suggestedCategoryUuid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
