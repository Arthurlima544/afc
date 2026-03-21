// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LastTransactionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastTransactionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LastTransactionState()';
}


}

/// @nodoc
class $LastTransactionStateCopyWith<$Res>  {
$LastTransactionStateCopyWith(LastTransactionState _, $Res Function(LastTransactionState) __);
}


/// Adds pattern-matching-related methods to [LastTransactionState].
extension LastTransactionStatePatterns on LastTransactionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TransactionInitial value)?  initial,TResult Function( _TransactionLoading value)?  loading,TResult Function( _TransactionSuccess value)?  success,TResult Function( _TransactionError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionInitial() when initial != null:
return initial(_that);case _TransactionLoading() when loading != null:
return loading(_that);case _TransactionSuccess() when success != null:
return success(_that);case _TransactionError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TransactionInitial value)  initial,required TResult Function( _TransactionLoading value)  loading,required TResult Function( _TransactionSuccess value)  success,required TResult Function( _TransactionError value)  error,}){
final _that = this;
switch (_that) {
case _TransactionInitial():
return initial(_that);case _TransactionLoading():
return loading(_that);case _TransactionSuccess():
return success(_that);case _TransactionError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TransactionInitial value)?  initial,TResult? Function( _TransactionLoading value)?  loading,TResult? Function( _TransactionSuccess value)?  success,TResult? Function( _TransactionError value)?  error,}){
final _that = this;
switch (_that) {
case _TransactionInitial() when initial != null:
return initial(_that);case _TransactionLoading() when loading != null:
return loading(_that);case _TransactionSuccess() when success != null:
return success(_that);case _TransactionError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<TransactionEntity> transactions)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionInitial() when initial != null:
return initial();case _TransactionLoading() when loading != null:
return loading();case _TransactionSuccess() when success != null:
return success(_that.transactions);case _TransactionError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<TransactionEntity> transactions)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _TransactionInitial():
return initial();case _TransactionLoading():
return loading();case _TransactionSuccess():
return success(_that.transactions);case _TransactionError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<TransactionEntity> transactions)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _TransactionInitial() when initial != null:
return initial();case _TransactionLoading() when loading != null:
return loading();case _TransactionSuccess() when success != null:
return success(_that.transactions);case _TransactionError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionInitial implements LastTransactionState {
  const _TransactionInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LastTransactionState.initial()';
}


}




/// @nodoc


class _TransactionLoading implements LastTransactionState {
  const _TransactionLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LastTransactionState.loading()';
}


}




/// @nodoc


class _TransactionSuccess implements LastTransactionState {
  const _TransactionSuccess(final  List<TransactionEntity> transactions): _transactions = transactions;
  

 final  List<TransactionEntity> _transactions;
 List<TransactionEntity> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of LastTransactionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionSuccessCopyWith<_TransactionSuccess> get copyWith => __$TransactionSuccessCopyWithImpl<_TransactionSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSuccess&&const DeepCollectionEquality().equals(other._transactions, _transactions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transactions));

@override
String toString() {
  return 'LastTransactionState.success(transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$TransactionSuccessCopyWith<$Res> implements $LastTransactionStateCopyWith<$Res> {
  factory _$TransactionSuccessCopyWith(_TransactionSuccess value, $Res Function(_TransactionSuccess) _then) = __$TransactionSuccessCopyWithImpl;
@useResult
$Res call({
 List<TransactionEntity> transactions
});




}
/// @nodoc
class __$TransactionSuccessCopyWithImpl<$Res>
    implements _$TransactionSuccessCopyWith<$Res> {
  __$TransactionSuccessCopyWithImpl(this._self, this._then);

  final _TransactionSuccess _self;
  final $Res Function(_TransactionSuccess) _then;

/// Create a copy of LastTransactionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transactions = null,}) {
  return _then(_TransactionSuccess(
null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionEntity>,
  ));
}


}

/// @nodoc


class _TransactionError implements LastTransactionState {
  const _TransactionError(this.message);
  

 final  String message;

/// Create a copy of LastTransactionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionErrorCopyWith<_TransactionError> get copyWith => __$TransactionErrorCopyWithImpl<_TransactionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LastTransactionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TransactionErrorCopyWith<$Res> implements $LastTransactionStateCopyWith<$Res> {
  factory _$TransactionErrorCopyWith(_TransactionError value, $Res Function(_TransactionError) _then) = __$TransactionErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$TransactionErrorCopyWithImpl<$Res>
    implements _$TransactionErrorCopyWith<$Res> {
  __$TransactionErrorCopyWithImpl(this._self, this._then);

  final _TransactionError _self;
  final $Res Function(_TransactionError) _then;

/// Create a copy of LastTransactionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_TransactionError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
