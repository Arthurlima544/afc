// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatsEntity {

 TypeEntity get type; double get total; CalendarEntity get date;
/// Create a copy of StatsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsEntityCopyWith<StatsEntity> get copyWith => _$StatsEntityCopyWithImpl<StatsEntity>(this as StatsEntity, _$identity);

  /// Serializes this StatsEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,total,date);

@override
String toString() {
  return 'StatsEntity(type: $type, total: $total, date: $date)';
}


}

/// @nodoc
abstract mixin class $StatsEntityCopyWith<$Res>  {
  factory $StatsEntityCopyWith(StatsEntity value, $Res Function(StatsEntity) _then) = _$StatsEntityCopyWithImpl;
@useResult
$Res call({
 TypeEntity type, double total, CalendarEntity date
});




}
/// @nodoc
class _$StatsEntityCopyWithImpl<$Res>
    implements $StatsEntityCopyWith<$Res> {
  _$StatsEntityCopyWithImpl(this._self, this._then);

  final StatsEntity _self;
  final $Res Function(StatsEntity) _then;

/// Create a copy of StatsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? total = null,Object? date = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TypeEntity,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CalendarEntity,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsEntity].
extension StatsEntityPatterns on StatsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsEntity value)  $default,){
final _that = this;
switch (_that) {
case _StatsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _StatsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TypeEntity type,  double total,  CalendarEntity date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsEntity() when $default != null:
return $default(_that.type,_that.total,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TypeEntity type,  double total,  CalendarEntity date)  $default,) {final _that = this;
switch (_that) {
case _StatsEntity():
return $default(_that.type,_that.total,_that.date);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TypeEntity type,  double total,  CalendarEntity date)?  $default,) {final _that = this;
switch (_that) {
case _StatsEntity() when $default != null:
return $default(_that.type,_that.total,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsEntity implements StatsEntity {
  const _StatsEntity({required this.type, required this.total, required this.date});
  factory _StatsEntity.fromJson(Map<String, dynamic> json) => _$StatsEntityFromJson(json);

@override final  TypeEntity type;
@override final  double total;
@override final  CalendarEntity date;

/// Create a copy of StatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsEntityCopyWith<_StatsEntity> get copyWith => __$StatsEntityCopyWithImpl<_StatsEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,total,date);

@override
String toString() {
  return 'StatsEntity(type: $type, total: $total, date: $date)';
}


}

/// @nodoc
abstract mixin class _$StatsEntityCopyWith<$Res> implements $StatsEntityCopyWith<$Res> {
  factory _$StatsEntityCopyWith(_StatsEntity value, $Res Function(_StatsEntity) _then) = __$StatsEntityCopyWithImpl;
@override @useResult
$Res call({
 TypeEntity type, double total, CalendarEntity date
});




}
/// @nodoc
class __$StatsEntityCopyWithImpl<$Res>
    implements _$StatsEntityCopyWith<$Res> {
  __$StatsEntityCopyWithImpl(this._self, this._then);

  final _StatsEntity _self;
  final $Res Function(_StatsEntity) _then;

/// Create a copy of StatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? total = null,Object? date = null,}) {
  return _then(_StatsEntity(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TypeEntity,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CalendarEntity,
  ));
}


}

// dart format on
