// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RecurringState()';
}


}

/// @nodoc
class $RecurringStateCopyWith<$Res>  {
$RecurringStateCopyWith(RecurringState _, $Res Function(RecurringState) __);
}


/// Adds pattern-matching-related methods to [RecurringState].
extension RecurringStatePatterns on RecurringState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Listed value)?  listed,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Listed() when listed != null:
return listed(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Listed value)  listed,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Listed():
return listed(_that);case _Success():
return success(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Listed value)?  listed,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Listed() when listed != null:
return listed(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<RecurringEntity> rules)?  listed,TResult Function( RecurringEntity rule)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Listed() when listed != null:
return listed(_that.rules);case _Success() when success != null:
return success(_that.rule);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<RecurringEntity> rules)  listed,required TResult Function( RecurringEntity rule)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Listed():
return listed(_that.rules);case _Success():
return success(_that.rule);case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<RecurringEntity> rules)?  listed,TResult? Function( RecurringEntity rule)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Listed() when listed != null:
return listed(_that.rules);case _Success() when success != null:
return success(_that.rule);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements RecurringState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RecurringState.initial()';
}


}




/// @nodoc


class _Loading implements RecurringState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RecurringState.loading()';
}


}




/// @nodoc


class _Listed implements RecurringState {
  const _Listed(final  List<RecurringEntity> rules): _rules = rules;
  

 final  List<RecurringEntity> _rules;
 List<RecurringEntity> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListedCopyWith<_Listed> get copyWith => __$ListedCopyWithImpl<_Listed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listed&&const DeepCollectionEquality().equals(other._rules, _rules));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'RecurringState.listed(rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$ListedCopyWith<$Res> implements $RecurringStateCopyWith<$Res> {
  factory _$ListedCopyWith(_Listed value, $Res Function(_Listed) _then) = __$ListedCopyWithImpl;
@useResult
$Res call({
 List<RecurringEntity> rules
});




}
/// @nodoc
class __$ListedCopyWithImpl<$Res>
    implements _$ListedCopyWith<$Res> {
  __$ListedCopyWithImpl(this._self, this._then);

  final _Listed _self;
  final $Res Function(_Listed) _then;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rules = null,}) {
  return _then(_Listed(
null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<RecurringEntity>,
  ));
}


}

/// @nodoc


class _Success implements RecurringState {
  const _Success(this.rule);
  

 final  RecurringEntity rule;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.rule, rule) || other.rule == rule));
}


@override
int get hashCode => Object.hash(runtimeType,rule);

@override
String toString() {
  return 'RecurringState.success(rule: $rule)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $RecurringStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 RecurringEntity rule
});


$RecurringEntityCopyWith<$Res> get rule;

}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rule = null,}) {
  return _then(_Success(
null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RecurringEntity,
  ));
}

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringEntityCopyWith<$Res> get rule {
  
  return $RecurringEntityCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}

/// @nodoc


class _Error implements RecurringState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RecurringState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $RecurringStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of RecurringState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
