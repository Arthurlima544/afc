// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_candidate_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportCandidateEntity {

 String get title; double get amount; DateTime get date; String get typeUuid; String? get categoryUUid; ImportStatus get status; bool get isDuplicate; double get categoryConfidence;
/// Create a copy of ImportCandidateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportCandidateEntityCopyWith<ImportCandidateEntity> get copyWith => _$ImportCandidateEntityCopyWithImpl<ImportCandidateEntity>(this as ImportCandidateEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportCandidateEntity&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.typeUuid, typeUuid) || other.typeUuid == typeUuid)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence));
}


@override
int get hashCode => Object.hash(runtimeType,title,amount,date,typeUuid,categoryUUid,status,isDuplicate,categoryConfidence);

@override
String toString() {
  return 'ImportCandidateEntity(title: $title, amount: $amount, date: $date, typeUuid: $typeUuid, categoryUUid: $categoryUUid, status: $status, isDuplicate: $isDuplicate, categoryConfidence: $categoryConfidence)';
}


}

/// @nodoc
abstract mixin class $ImportCandidateEntityCopyWith<$Res>  {
  factory $ImportCandidateEntityCopyWith(ImportCandidateEntity value, $Res Function(ImportCandidateEntity) _then) = _$ImportCandidateEntityCopyWithImpl;
@useResult
$Res call({
 String title, double amount, DateTime date, String typeUuid, String? categoryUUid, ImportStatus status, bool isDuplicate, double categoryConfidence
});




}
/// @nodoc
class _$ImportCandidateEntityCopyWithImpl<$Res>
    implements $ImportCandidateEntityCopyWith<$Res> {
  _$ImportCandidateEntityCopyWithImpl(this._self, this._then);

  final ImportCandidateEntity _self;
  final $Res Function(ImportCandidateEntity) _then;

/// Create a copy of ImportCandidateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? amount = null,Object? date = null,Object? typeUuid = null,Object? categoryUUid = freezed,Object? status = null,Object? isDuplicate = null,Object? categoryConfidence = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,typeUuid: null == typeUuid ? _self.typeUuid : typeUuid // ignore: cast_nullable_to_non_nullable
as String,categoryUUid: freezed == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportStatus,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,categoryConfidence: null == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportCandidateEntity].
extension ImportCandidateEntityPatterns on ImportCandidateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportCandidateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportCandidateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportCandidateEntity value)  $default,){
final _that = this;
switch (_that) {
case _ImportCandidateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportCandidateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ImportCandidateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  double amount,  DateTime date,  String typeUuid,  String? categoryUUid,  ImportStatus status,  bool isDuplicate,  double categoryConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportCandidateEntity() when $default != null:
return $default(_that.title,_that.amount,_that.date,_that.typeUuid,_that.categoryUUid,_that.status,_that.isDuplicate,_that.categoryConfidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  double amount,  DateTime date,  String typeUuid,  String? categoryUUid,  ImportStatus status,  bool isDuplicate,  double categoryConfidence)  $default,) {final _that = this;
switch (_that) {
case _ImportCandidateEntity():
return $default(_that.title,_that.amount,_that.date,_that.typeUuid,_that.categoryUUid,_that.status,_that.isDuplicate,_that.categoryConfidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  double amount,  DateTime date,  String typeUuid,  String? categoryUUid,  ImportStatus status,  bool isDuplicate,  double categoryConfidence)?  $default,) {final _that = this;
switch (_that) {
case _ImportCandidateEntity() when $default != null:
return $default(_that.title,_that.amount,_that.date,_that.typeUuid,_that.categoryUUid,_that.status,_that.isDuplicate,_that.categoryConfidence);case _:
  return null;

}
}

}

/// @nodoc


class _ImportCandidateEntity implements ImportCandidateEntity {
  const _ImportCandidateEntity({required this.title, required this.amount, required this.date, required this.typeUuid, this.categoryUUid, this.status = ImportStatus.pending, this.isDuplicate = false, this.categoryConfidence = 0.0});
  

@override final  String title;
@override final  double amount;
@override final  DateTime date;
@override final  String typeUuid;
@override final  String? categoryUUid;
@override@JsonKey() final  ImportStatus status;
@override@JsonKey() final  bool isDuplicate;
@override@JsonKey() final  double categoryConfidence;

/// Create a copy of ImportCandidateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportCandidateEntityCopyWith<_ImportCandidateEntity> get copyWith => __$ImportCandidateEntityCopyWithImpl<_ImportCandidateEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportCandidateEntity&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.typeUuid, typeUuid) || other.typeUuid == typeUuid)&&(identical(other.categoryUUid, categoryUUid) || other.categoryUUid == categoryUUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence));
}


@override
int get hashCode => Object.hash(runtimeType,title,amount,date,typeUuid,categoryUUid,status,isDuplicate,categoryConfidence);

@override
String toString() {
  return 'ImportCandidateEntity(title: $title, amount: $amount, date: $date, typeUuid: $typeUuid, categoryUUid: $categoryUUid, status: $status, isDuplicate: $isDuplicate, categoryConfidence: $categoryConfidence)';
}


}

/// @nodoc
abstract mixin class _$ImportCandidateEntityCopyWith<$Res> implements $ImportCandidateEntityCopyWith<$Res> {
  factory _$ImportCandidateEntityCopyWith(_ImportCandidateEntity value, $Res Function(_ImportCandidateEntity) _then) = __$ImportCandidateEntityCopyWithImpl;
@override @useResult
$Res call({
 String title, double amount, DateTime date, String typeUuid, String? categoryUUid, ImportStatus status, bool isDuplicate, double categoryConfidence
});




}
/// @nodoc
class __$ImportCandidateEntityCopyWithImpl<$Res>
    implements _$ImportCandidateEntityCopyWith<$Res> {
  __$ImportCandidateEntityCopyWithImpl(this._self, this._then);

  final _ImportCandidateEntity _self;
  final $Res Function(_ImportCandidateEntity) _then;

/// Create a copy of ImportCandidateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? amount = null,Object? date = null,Object? typeUuid = null,Object? categoryUUid = freezed,Object? status = null,Object? isDuplicate = null,Object? categoryConfidence = null,}) {
  return _then(_ImportCandidateEntity(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,typeUuid: null == typeUuid ? _self.typeUuid : typeUuid // ignore: cast_nullable_to_non_nullable
as String,categoryUUid: freezed == categoryUUid ? _self.categoryUUid : categoryUUid // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportStatus,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,categoryConfidence: null == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
