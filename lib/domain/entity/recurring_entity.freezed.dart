// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringEntity {

 String get uuid; String get userId; TransactionEntity get templateTransaction; String get frequency; DateTime get nextDue; bool get active;
/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringEntityCopyWith<RecurringEntity> get copyWith => _$RecurringEntityCopyWithImpl<RecurringEntity>(this as RecurringEntity, _$identity);

  /// Serializes this RecurringEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.templateTransaction, templateTransaction) || other.templateTransaction == templateTransaction)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextDue, nextDue) || other.nextDue == nextDue)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,templateTransaction,frequency,nextDue,active);

@override
String toString() {
  return 'RecurringEntity(uuid: $uuid, userId: $userId, templateTransaction: $templateTransaction, frequency: $frequency, nextDue: $nextDue, active: $active)';
}


}

/// @nodoc
abstract mixin class $RecurringEntityCopyWith<$Res>  {
  factory $RecurringEntityCopyWith(RecurringEntity value, $Res Function(RecurringEntity) _then) = _$RecurringEntityCopyWithImpl;
@useResult
$Res call({
 String uuid, String userId, TransactionEntity templateTransaction, String frequency, DateTime nextDue, bool active
});


$TransactionEntityCopyWith<$Res> get templateTransaction;

}
/// @nodoc
class _$RecurringEntityCopyWithImpl<$Res>
    implements $RecurringEntityCopyWith<$Res> {
  _$RecurringEntityCopyWithImpl(this._self, this._then);

  final RecurringEntity _self;
  final $Res Function(RecurringEntity) _then;

/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? userId = null,Object? templateTransaction = null,Object? frequency = null,Object? nextDue = null,Object? active = null,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,templateTransaction: null == templateTransaction ? _self.templateTransaction : templateTransaction // ignore: cast_nullable_to_non_nullable
as TransactionEntity,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextDue: null == nextDue ? _self.nextDue : nextDue // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionEntityCopyWith<$Res> get templateTransaction {
  
  return $TransactionEntityCopyWith<$Res>(_self.templateTransaction, (value) {
    return _then(_self.copyWith(templateTransaction: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecurringEntity].
extension RecurringEntityPatterns on RecurringEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringEntity value)  $default,){
final _that = this;
switch (_that) {
case _RecurringEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String userId,  TransactionEntity templateTransaction,  String frequency,  DateTime nextDue,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.templateTransaction,_that.frequency,_that.nextDue,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String userId,  TransactionEntity templateTransaction,  String frequency,  DateTime nextDue,  bool active)  $default,) {final _that = this;
switch (_that) {
case _RecurringEntity():
return $default(_that.uuid,_that.userId,_that.templateTransaction,_that.frequency,_that.nextDue,_that.active);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String userId,  TransactionEntity templateTransaction,  String frequency,  DateTime nextDue,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _RecurringEntity() when $default != null:
return $default(_that.uuid,_that.userId,_that.templateTransaction,_that.frequency,_that.nextDue,_that.active);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RecurringEntity implements RecurringEntity {
  const _RecurringEntity({required this.uuid, required this.userId, required this.templateTransaction, required this.frequency, required this.nextDue, required this.active});
  factory _RecurringEntity.fromJson(Map<String, dynamic> json) => _$RecurringEntityFromJson(json);

@override final  String uuid;
@override final  String userId;
@override final  TransactionEntity templateTransaction;
@override final  String frequency;
@override final  DateTime nextDue;
@override final  bool active;

/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringEntityCopyWith<_RecurringEntity> get copyWith => __$RecurringEntityCopyWithImpl<_RecurringEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringEntity&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.templateTransaction, templateTransaction) || other.templateTransaction == templateTransaction)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextDue, nextDue) || other.nextDue == nextDue)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,userId,templateTransaction,frequency,nextDue,active);

@override
String toString() {
  return 'RecurringEntity(uuid: $uuid, userId: $userId, templateTransaction: $templateTransaction, frequency: $frequency, nextDue: $nextDue, active: $active)';
}


}

/// @nodoc
abstract mixin class _$RecurringEntityCopyWith<$Res> implements $RecurringEntityCopyWith<$Res> {
  factory _$RecurringEntityCopyWith(_RecurringEntity value, $Res Function(_RecurringEntity) _then) = __$RecurringEntityCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String userId, TransactionEntity templateTransaction, String frequency, DateTime nextDue, bool active
});


@override $TransactionEntityCopyWith<$Res> get templateTransaction;

}
/// @nodoc
class __$RecurringEntityCopyWithImpl<$Res>
    implements _$RecurringEntityCopyWith<$Res> {
  __$RecurringEntityCopyWithImpl(this._self, this._then);

  final _RecurringEntity _self;
  final $Res Function(_RecurringEntity) _then;

/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? userId = null,Object? templateTransaction = null,Object? frequency = null,Object? nextDue = null,Object? active = null,}) {
  return _then(_RecurringEntity(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,templateTransaction: null == templateTransaction ? _self.templateTransaction : templateTransaction // ignore: cast_nullable_to_non_nullable
as TransactionEntity,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextDue: null == nextDue ? _self.nextDue : nextDue // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RecurringEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionEntityCopyWith<$Res> get templateTransaction {
  
  return $TransactionEntityCopyWith<$Res>(_self.templateTransaction, (value) {
    return _then(_self.copyWith(templateTransaction: value));
  });
}
}

// dart format on
