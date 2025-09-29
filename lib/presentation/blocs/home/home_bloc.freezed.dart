// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeEvent {

 String get userUuid;
/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeEventCopyWith<HomeEvent> get copyWith => _$HomeEventCopyWithImpl<HomeEvent>(this as HomeEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeEvent&&(identical(other.userUuid, userUuid) || other.userUuid == userUuid));
}


@override
int get hashCode => Object.hash(runtimeType,userUuid);

@override
String toString() {
  return 'HomeEvent(userUuid: $userUuid)';
}


}

/// @nodoc
abstract mixin class $HomeEventCopyWith<$Res>  {
  factory $HomeEventCopyWith(HomeEvent value, $Res Function(HomeEvent) _then) = _$HomeEventCopyWithImpl;
@useResult
$Res call({
 String userUuid
});




}
/// @nodoc
class _$HomeEventCopyWithImpl<$Res>
    implements $HomeEventCopyWith<$Res> {
  _$HomeEventCopyWithImpl(this._self, this._then);

  final HomeEvent _self;
  final $Res Function(HomeEvent) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userUuid = null,}) {
  return _then(_self.copyWith(
userUuid: null == userUuid ? _self.userUuid : userUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeEvent].
extension HomeEventPatterns on HomeEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadHome value)?  loadHome,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadHome() when loadHome != null:
return loadHome(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadHome value)  loadHome,}){
final _that = this;
switch (_that) {
case _LoadHome():
return loadHome(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadHome value)?  loadHome,}){
final _that = this;
switch (_that) {
case _LoadHome() when loadHome != null:
return loadHome(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String userUuid)?  loadHome,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadHome() when loadHome != null:
return loadHome(_that.userUuid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String userUuid)  loadHome,}) {final _that = this;
switch (_that) {
case _LoadHome():
return loadHome(_that.userUuid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String userUuid)?  loadHome,}) {final _that = this;
switch (_that) {
case _LoadHome() when loadHome != null:
return loadHome(_that.userUuid);case _:
  return null;

}
}

}

/// @nodoc


class _LoadHome implements HomeEvent {
  const _LoadHome(this.userUuid);
  

@override final  String userUuid;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadHomeCopyWith<_LoadHome> get copyWith => __$LoadHomeCopyWithImpl<_LoadHome>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadHome&&(identical(other.userUuid, userUuid) || other.userUuid == userUuid));
}


@override
int get hashCode => Object.hash(runtimeType,userUuid);

@override
String toString() {
  return 'HomeEvent.loadHome(userUuid: $userUuid)';
}


}

/// @nodoc
abstract mixin class _$LoadHomeCopyWith<$Res> implements $HomeEventCopyWith<$Res> {
  factory _$LoadHomeCopyWith(_LoadHome value, $Res Function(_LoadHome) _then) = __$LoadHomeCopyWithImpl;
@override @useResult
$Res call({
 String userUuid
});




}
/// @nodoc
class __$LoadHomeCopyWithImpl<$Res>
    implements _$LoadHomeCopyWith<$Res> {
  __$LoadHomeCopyWithImpl(this._self, this._then);

  final _LoadHome _self;
  final $Res Function(_LoadHome) _then;

/// Create a copy of HomeEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userUuid = null,}) {
  return _then(_LoadHome(
null == userUuid ? _self.userUuid : userUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$HomeState {

 LastTransactionState get transactionState; StatsState get statsState;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.transactionState, transactionState) || other.transactionState == transactionState)&&(identical(other.statsState, statsState) || other.statsState == statsState));
}


@override
int get hashCode => Object.hash(runtimeType,transactionState,statsState);

@override
String toString() {
  return 'HomeState(transactionState: $transactionState, statsState: $statsState)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 LastTransactionState transactionState, StatsState statsState
});


$LastTransactionStateCopyWith<$Res> get transactionState;$StatsStateCopyWith<$Res> get statsState;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionState = null,Object? statsState = null,}) {
  return _then(_self.copyWith(
transactionState: null == transactionState ? _self.transactionState : transactionState // ignore: cast_nullable_to_non_nullable
as LastTransactionState,statsState: null == statsState ? _self.statsState : statsState // ignore: cast_nullable_to_non_nullable
as StatsState,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastTransactionStateCopyWith<$Res> get transactionState {
  
  return $LastTransactionStateCopyWith<$Res>(_self.transactionState, (value) {
    return _then(_self.copyWith(transactionState: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsStateCopyWith<$Res> get statsState {
  
  return $StatsStateCopyWith<$Res>(_self.statsState, (value) {
    return _then(_self.copyWith(statsState: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LastTransactionState transactionState,  StatsState statsState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.transactionState,_that.statsState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LastTransactionState transactionState,  StatsState statsState)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.transactionState,_that.statsState);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LastTransactionState transactionState,  StatsState statsState)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.transactionState,_that.statsState);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({required this.transactionState, required this.statsState});
  

@override final  LastTransactionState transactionState;
@override final  StatsState statsState;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.transactionState, transactionState) || other.transactionState == transactionState)&&(identical(other.statsState, statsState) || other.statsState == statsState));
}


@override
int get hashCode => Object.hash(runtimeType,transactionState,statsState);

@override
String toString() {
  return 'HomeState(transactionState: $transactionState, statsState: $statsState)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 LastTransactionState transactionState, StatsState statsState
});


@override $LastTransactionStateCopyWith<$Res> get transactionState;@override $StatsStateCopyWith<$Res> get statsState;

}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionState = null,Object? statsState = null,}) {
  return _then(_HomeState(
transactionState: null == transactionState ? _self.transactionState : transactionState // ignore: cast_nullable_to_non_nullable
as LastTransactionState,statsState: null == statsState ? _self.statsState : statsState // ignore: cast_nullable_to_non_nullable
as StatsState,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastTransactionStateCopyWith<$Res> get transactionState {
  
  return $LastTransactionStateCopyWith<$Res>(_self.transactionState, (value) {
    return _then(_self.copyWith(transactionState: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatsStateCopyWith<$Res> get statsState {
  
  return $StatsStateCopyWith<$Res>(_self.statsState, (value) {
    return _then(_self.copyWith(statsState: value));
  });
}
}

// dart format on
