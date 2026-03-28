// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'setup_checklist_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SetupChecklistState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupChecklistState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SetupChecklistState()';
}


}

/// @nodoc
class $SetupChecklistStateCopyWith<$Res>  {
$SetupChecklistStateCopyWith(SetupChecklistState _, $Res Function(SetupChecklistState) __);
}


/// Adds pattern-matching-related methods to [SetupChecklistState].
extension SetupChecklistStatePatterns on SetupChecklistState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Hidden value)?  hidden,TResult Function( _Visible value)?  visible,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Hidden() when hidden != null:
return hidden(_that);case _Visible() when visible != null:
return visible(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Hidden value)  hidden,required TResult Function( _Visible value)  visible,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Hidden():
return hidden(_that);case _Visible():
return visible(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Hidden value)?  hidden,TResult? Function( _Visible value)?  visible,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Hidden() when hidden != null:
return hidden(_that);case _Visible() when visible != null:
return visible(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  hidden,TResult Function( bool hasCategory,  bool hasTransaction,  bool hasLimit,  bool hasGoal,  bool hasInvestment)?  visible,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Hidden() when hidden != null:
return hidden();case _Visible() when visible != null:
return visible(_that.hasCategory,_that.hasTransaction,_that.hasLimit,_that.hasGoal,_that.hasInvestment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  hidden,required TResult Function( bool hasCategory,  bool hasTransaction,  bool hasLimit,  bool hasGoal,  bool hasInvestment)  visible,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Hidden():
return hidden();case _Visible():
return visible(_that.hasCategory,_that.hasTransaction,_that.hasLimit,_that.hasGoal,_that.hasInvestment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  hidden,TResult? Function( bool hasCategory,  bool hasTransaction,  bool hasLimit,  bool hasGoal,  bool hasInvestment)?  visible,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Hidden() when hidden != null:
return hidden();case _Visible() when visible != null:
return visible(_that.hasCategory,_that.hasTransaction,_that.hasLimit,_that.hasGoal,_that.hasInvestment);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements SetupChecklistState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SetupChecklistState.initial()';
}


}




/// @nodoc


class _Hidden implements SetupChecklistState {
  const _Hidden();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hidden);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SetupChecklistState.hidden()';
}


}




/// @nodoc


class _Visible implements SetupChecklistState {
  const _Visible({required this.hasCategory, required this.hasTransaction, required this.hasLimit, required this.hasGoal, required this.hasInvestment});
  

 final  bool hasCategory;
 final  bool hasTransaction;
 final  bool hasLimit;
 final  bool hasGoal;
 final  bool hasInvestment;

/// Create a copy of SetupChecklistState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisibleCopyWith<_Visible> get copyWith => __$VisibleCopyWithImpl<_Visible>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visible&&(identical(other.hasCategory, hasCategory) || other.hasCategory == hasCategory)&&(identical(other.hasTransaction, hasTransaction) || other.hasTransaction == hasTransaction)&&(identical(other.hasLimit, hasLimit) || other.hasLimit == hasLimit)&&(identical(other.hasGoal, hasGoal) || other.hasGoal == hasGoal)&&(identical(other.hasInvestment, hasInvestment) || other.hasInvestment == hasInvestment));
}


@override
int get hashCode => Object.hash(runtimeType,hasCategory,hasTransaction,hasLimit,hasGoal,hasInvestment);

@override
String toString() {
  return 'SetupChecklistState.visible(hasCategory: $hasCategory, hasTransaction: $hasTransaction, hasLimit: $hasLimit, hasGoal: $hasGoal, hasInvestment: $hasInvestment)';
}


}

/// @nodoc
abstract mixin class _$VisibleCopyWith<$Res> implements $SetupChecklistStateCopyWith<$Res> {
  factory _$VisibleCopyWith(_Visible value, $Res Function(_Visible) _then) = __$VisibleCopyWithImpl;
@useResult
$Res call({
 bool hasCategory, bool hasTransaction, bool hasLimit, bool hasGoal, bool hasInvestment
});




}
/// @nodoc
class __$VisibleCopyWithImpl<$Res>
    implements _$VisibleCopyWith<$Res> {
  __$VisibleCopyWithImpl(this._self, this._then);

  final _Visible _self;
  final $Res Function(_Visible) _then;

/// Create a copy of SetupChecklistState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hasCategory = null,Object? hasTransaction = null,Object? hasLimit = null,Object? hasGoal = null,Object? hasInvestment = null,}) {
  return _then(_Visible(
hasCategory: null == hasCategory ? _self.hasCategory : hasCategory // ignore: cast_nullable_to_non_nullable
as bool,hasTransaction: null == hasTransaction ? _self.hasTransaction : hasTransaction // ignore: cast_nullable_to_non_nullable
as bool,hasLimit: null == hasLimit ? _self.hasLimit : hasLimit // ignore: cast_nullable_to_non_nullable
as bool,hasGoal: null == hasGoal ? _self.hasGoal : hasGoal // ignore: cast_nullable_to_non_nullable
as bool,hasInvestment: null == hasInvestment ? _self.hasInvestment : hasInvestment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
