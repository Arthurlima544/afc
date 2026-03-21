// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_finance_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenFinanceState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenFinanceState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OpenFinanceState()';
}


}

/// @nodoc
class $OpenFinanceStateCopyWith<$Res>  {
$OpenFinanceStateCopyWith(OpenFinanceState _, $Res Function(OpenFinanceState) __);
}


/// Adds pattern-matching-related methods to [OpenFinanceState].
extension OpenFinanceStatePatterns on OpenFinanceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Listed value)?  listed,TResult Function( _TokenReady value)?  tokenReady,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Listed() when listed != null:
return listed(_that);case _TokenReady() when tokenReady != null:
return tokenReady(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Listed value)  listed,required TResult Function( _TokenReady value)  tokenReady,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Listed():
return listed(_that);case _TokenReady():
return tokenReady(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Listed value)?  listed,TResult? Function( _TokenReady value)?  tokenReady,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Listed() when listed != null:
return listed(_that);case _TokenReady() when tokenReady != null:
return tokenReady(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ConnectedAccountEntity> accounts)?  listed,TResult Function( String connectToken)?  tokenReady,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Listed() when listed != null:
return listed(_that.accounts);case _TokenReady() when tokenReady != null:
return tokenReady(_that.connectToken);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ConnectedAccountEntity> accounts)  listed,required TResult Function( String connectToken)  tokenReady,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Listed():
return listed(_that.accounts);case _TokenReady():
return tokenReady(_that.connectToken);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ConnectedAccountEntity> accounts)?  listed,TResult? Function( String connectToken)?  tokenReady,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Listed() when listed != null:
return listed(_that.accounts);case _TokenReady() when tokenReady != null:
return tokenReady(_that.connectToken);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements OpenFinanceState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OpenFinanceState.initial()';
}


}




/// @nodoc


class _Loading implements OpenFinanceState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OpenFinanceState.loading()';
}


}




/// @nodoc


class _Listed implements OpenFinanceState {
  const _Listed(final  List<ConnectedAccountEntity> accounts): _accounts = accounts;
  

 final  List<ConnectedAccountEntity> _accounts;
 List<ConnectedAccountEntity> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}


/// Create a copy of OpenFinanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListedCopyWith<_Listed> get copyWith => __$ListedCopyWithImpl<_Listed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listed&&const DeepCollectionEquality().equals(other._accounts, _accounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_accounts));

@override
String toString() {
  return 'OpenFinanceState.listed(accounts: $accounts)';
}


}

/// @nodoc
abstract mixin class _$ListedCopyWith<$Res> implements $OpenFinanceStateCopyWith<$Res> {
  factory _$ListedCopyWith(_Listed value, $Res Function(_Listed) _then) = __$ListedCopyWithImpl;
@useResult
$Res call({
 List<ConnectedAccountEntity> accounts
});




}
/// @nodoc
class __$ListedCopyWithImpl<$Res>
    implements _$ListedCopyWith<$Res> {
  __$ListedCopyWithImpl(this._self, this._then);

  final _Listed _self;
  final $Res Function(_Listed) _then;

/// Create a copy of OpenFinanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? accounts = null,}) {
  return _then(_Listed(
null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<ConnectedAccountEntity>,
  ));
}


}

/// @nodoc


class _TokenReady implements OpenFinanceState {
  const _TokenReady(this.connectToken);
  

 final  String connectToken;

/// Create a copy of OpenFinanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenReadyCopyWith<_TokenReady> get copyWith => __$TokenReadyCopyWithImpl<_TokenReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenReady&&(identical(other.connectToken, connectToken) || other.connectToken == connectToken));
}


@override
int get hashCode => Object.hash(runtimeType,connectToken);

@override
String toString() {
  return 'OpenFinanceState.tokenReady(connectToken: $connectToken)';
}


}

/// @nodoc
abstract mixin class _$TokenReadyCopyWith<$Res> implements $OpenFinanceStateCopyWith<$Res> {
  factory _$TokenReadyCopyWith(_TokenReady value, $Res Function(_TokenReady) _then) = __$TokenReadyCopyWithImpl;
@useResult
$Res call({
 String connectToken
});




}
/// @nodoc
class __$TokenReadyCopyWithImpl<$Res>
    implements _$TokenReadyCopyWith<$Res> {
  __$TokenReadyCopyWithImpl(this._self, this._then);

  final _TokenReady _self;
  final $Res Function(_TokenReady) _then;

/// Create a copy of OpenFinanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? connectToken = null,}) {
  return _then(_TokenReady(
null == connectToken ? _self.connectToken : connectToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements OpenFinanceState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of OpenFinanceState
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
  return 'OpenFinanceState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $OpenFinanceStateCopyWith<$Res> {
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

/// Create a copy of OpenFinanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
