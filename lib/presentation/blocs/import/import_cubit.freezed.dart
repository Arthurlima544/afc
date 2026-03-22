// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState()';
}


}

/// @nodoc
class $ImportStateCopyWith<$Res>  {
$ImportStateCopyWith(ImportState _, $Res Function(ImportState) __);
}


/// Adds pattern-matching-related methods to [ImportState].
extension ImportStatePatterns on ImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Reviewed value)?  reviewed,TResult Function( _Saving value)?  saving,TResult Function( _Done value)?  done,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Reviewed() when reviewed != null:
return reviewed(_that);case _Saving() when saving != null:
return saving(_that);case _Done() when done != null:
return done(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Reviewed value)  reviewed,required TResult Function( _Saving value)  saving,required TResult Function( _Done value)  done,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Reviewed():
return reviewed(_that);case _Saving():
return saving(_that);case _Done():
return done(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Reviewed value)?  reviewed,TResult? Function( _Saving value)?  saving,TResult? Function( _Done value)?  done,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Reviewed() when reviewed != null:
return reviewed(_that);case _Saving() when saving != null:
return saving(_that);case _Done() when done != null:
return done(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ImportCandidateEntity> candidates,  String userId)?  reviewed,TResult Function()?  saving,TResult Function( int savedCount)?  done,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Reviewed() when reviewed != null:
return reviewed(_that.candidates,_that.userId);case _Saving() when saving != null:
return saving();case _Done() when done != null:
return done(_that.savedCount);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ImportCandidateEntity> candidates,  String userId)  reviewed,required TResult Function()  saving,required TResult Function( int savedCount)  done,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Reviewed():
return reviewed(_that.candidates,_that.userId);case _Saving():
return saving();case _Done():
return done(_that.savedCount);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ImportCandidateEntity> candidates,  String userId)?  reviewed,TResult? Function()?  saving,TResult? Function( int savedCount)?  done,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Reviewed() when reviewed != null:
return reviewed(_that.candidates,_that.userId);case _Saving() when saving != null:
return saving();case _Done() when done != null:
return done(_that.savedCount);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ImportState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState.initial()';
}


}




/// @nodoc


class _Loading implements ImportState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState.loading()';
}


}




/// @nodoc


class _Reviewed implements ImportState {
  const _Reviewed({required final  List<ImportCandidateEntity> candidates, required this.userId}): _candidates = candidates;
  

 final  List<ImportCandidateEntity> _candidates;
 List<ImportCandidateEntity> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

 final  String userId;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewedCopyWith<_Reviewed> get copyWith => __$ReviewedCopyWithImpl<_Reviewed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reviewed&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates),userId);

@override
String toString() {
  return 'ImportState.reviewed(candidates: $candidates, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ReviewedCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory _$ReviewedCopyWith(_Reviewed value, $Res Function(_Reviewed) _then) = __$ReviewedCopyWithImpl;
@useResult
$Res call({
 List<ImportCandidateEntity> candidates, String userId
});




}
/// @nodoc
class __$ReviewedCopyWithImpl<$Res>
    implements _$ReviewedCopyWith<$Res> {
  __$ReviewedCopyWithImpl(this._self, this._then);

  final _Reviewed _self;
  final $Res Function(_Reviewed) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,Object? userId = null,}) {
  return _then(_Reviewed(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ImportCandidateEntity>,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Saving implements ImportState {
  const _Saving();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Saving);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImportState.saving()';
}


}




/// @nodoc


class _Done implements ImportState {
  const _Done(this.savedCount);
  

 final  int savedCount;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoneCopyWith<_Done> get copyWith => __$DoneCopyWithImpl<_Done>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Done&&(identical(other.savedCount, savedCount) || other.savedCount == savedCount));
}


@override
int get hashCode => Object.hash(runtimeType,savedCount);

@override
String toString() {
  return 'ImportState.done(savedCount: $savedCount)';
}


}

/// @nodoc
abstract mixin class _$DoneCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory _$DoneCopyWith(_Done value, $Res Function(_Done) _then) = __$DoneCopyWithImpl;
@useResult
$Res call({
 int savedCount
});




}
/// @nodoc
class __$DoneCopyWithImpl<$Res>
    implements _$DoneCopyWith<$Res> {
  __$DoneCopyWithImpl(this._self, this._then);

  final _Done _self;
  final $Res Function(_Done) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? savedCount = null,}) {
  return _then(_Done(
null == savedCount ? _self.savedCount : savedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Error implements ImportState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of ImportState
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
  return 'ImportState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
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

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
