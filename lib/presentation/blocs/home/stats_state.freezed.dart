// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StatsState()';
}


}

/// @nodoc
class $StatsStateCopyWith<$Res>  {
$StatsStateCopyWith(StatsState _, $Res Function(StatsState) __);
}


/// Adds pattern-matching-related methods to [StatsState].
extension StatsStatePatterns on StatsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _StatsInitial value)?  initial,TResult Function( _StatsLoading value)?  loading,TResult Function( _StatsSuccess value)?  success,TResult Function( _StatsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsInitial() when initial != null:
return initial(_that);case _StatsLoading() when loading != null:
return loading(_that);case _StatsSuccess() when success != null:
return success(_that);case _StatsError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _StatsInitial value)  initial,required TResult Function( _StatsLoading value)  loading,required TResult Function( _StatsSuccess value)  success,required TResult Function( _StatsError value)  error,}){
final _that = this;
switch (_that) {
case _StatsInitial():
return initial(_that);case _StatsLoading():
return loading(_that);case _StatsSuccess():
return success(_that);case _StatsError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _StatsInitial value)?  initial,TResult? Function( _StatsLoading value)?  loading,TResult? Function( _StatsSuccess value)?  success,TResult? Function( _StatsError value)?  error,}){
final _that = this;
switch (_that) {
case _StatsInitial() when initial != null:
return initial(_that);case _StatsLoading() when loading != null:
return loading(_that);case _StatsSuccess() when success != null:
return success(_that);case _StatsError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<StatsEntity> stats)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsInitial() when initial != null:
return initial();case _StatsLoading() when loading != null:
return loading();case _StatsSuccess() when success != null:
return success(_that.stats);case _StatsError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<StatsEntity> stats)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _StatsInitial():
return initial();case _StatsLoading():
return loading();case _StatsSuccess():
return success(_that.stats);case _StatsError():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<StatsEntity> stats)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _StatsInitial() when initial != null:
return initial();case _StatsLoading() when loading != null:
return loading();case _StatsSuccess() when success != null:
return success(_that.stats);case _StatsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _StatsInitial implements StatsState {
  const _StatsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StatsState.initial()';
}


}




/// @nodoc


class _StatsLoading implements StatsState {
  const _StatsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StatsState.loading()';
}


}




/// @nodoc


class _StatsSuccess implements StatsState {
  const _StatsSuccess(final  List<StatsEntity> stats): _stats = stats;
  

 final  List<StatsEntity> _stats;
 List<StatsEntity> get stats {
  if (_stats is EqualUnmodifiableListView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stats);
}


/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsSuccessCopyWith<_StatsSuccess> get copyWith => __$StatsSuccessCopyWithImpl<_StatsSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsSuccess&&const DeepCollectionEquality().equals(other._stats, _stats));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_stats));

@override
String toString() {
  return 'StatsState.success(stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$StatsSuccessCopyWith<$Res> implements $StatsStateCopyWith<$Res> {
  factory _$StatsSuccessCopyWith(_StatsSuccess value, $Res Function(_StatsSuccess) _then) = __$StatsSuccessCopyWithImpl;
@useResult
$Res call({
 List<StatsEntity> stats
});




}
/// @nodoc
class __$StatsSuccessCopyWithImpl<$Res>
    implements _$StatsSuccessCopyWith<$Res> {
  __$StatsSuccessCopyWithImpl(this._self, this._then);

  final _StatsSuccess _self;
  final $Res Function(_StatsSuccess) _then;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stats = null,}) {
  return _then(_StatsSuccess(
null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as List<StatsEntity>,
  ));
}


}

/// @nodoc


class _StatsError implements StatsState {
  const _StatsError(this.message);
  

 final  String message;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsErrorCopyWith<_StatsError> get copyWith => __$StatsErrorCopyWithImpl<_StatsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'StatsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$StatsErrorCopyWith<$Res> implements $StatsStateCopyWith<$Res> {
  factory _$StatsErrorCopyWith(_StatsError value, $Res Function(_StatsError) _then) = __$StatsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$StatsErrorCopyWithImpl<$Res>
    implements _$StatsErrorCopyWith<$Res> {
  __$StatsErrorCopyWithImpl(this._self, this._then);

  final _StatsError _self;
  final $Res Function(_StatsError) _then;

/// Create a copy of StatsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_StatsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
