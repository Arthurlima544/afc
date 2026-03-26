import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entity/feedback_entity.dart';

part 'feedback_state.dart';
part 'feedback_cubit.freezed.dart';

const String _kFirstLaunchKey = 'feedback_first_launch_ms';
const String _kPromptShownKey = 'feedback_nps_shown';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _firestoreOverride = firestore,
        _prefsOverride = prefs,
        super(const FeedbackState.initial());

  final FirebaseFirestore? _firestoreOverride;
  final SharedPreferences? _prefsOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  /// Submits a [FeedbackEntity] to Firestore.
  Future<void> submit({
    required String userId,
    required int rating,
    String message = '',
  }) async {
    emit(const FeedbackState.loading());
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final FeedbackEntity entity = FeedbackEntity(
        uuid: const Uuid().v4(),
        userId: userId,
        rating: rating,
        message: message,
        appVersion: info.version,
        platform: Platform.operatingSystem,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('feedback').add(entity.toJson());
      final SharedPreferences p = await _prefs;
      await p.setBool(_kPromptShownKey, true);
      emit(const FeedbackState.success());
    } on Exception catch (e) {
      emit(FeedbackState.error(e.toString()));
    }
  }

  /// Records the first-launch timestamp if not already set.
  Future<void> recordFirstLaunch() async {
    final SharedPreferences p = await _prefs;
    if (p.getInt(_kFirstLaunchKey) == null) {
      await p.setInt(
        _kFirstLaunchKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Returns `true` when the NPS prompt should be shown:
  /// - at least 7 days since first launch
  /// - prompt has not been shown before
  Future<bool> shouldShowNpsPrompt() async {
    final SharedPreferences p = await _prefs;
    final bool alreadyShown = p.getBool(_kPromptShownKey) ?? false;
    if (alreadyShown) {
      return false;
    }
    final int? firstMs = p.getInt(_kFirstLaunchKey);
    if (firstMs == null) {
      return false;
    }
    final DateTime firstLaunch =
        DateTime.fromMillisecondsSinceEpoch(firstMs);
    return DateTime.now().difference(firstLaunch).inDays >= 7;
  }

  /// Marks the NPS prompt as dismissed without submitting feedback.
  Future<void> dismissNpsPrompt() async {
    final SharedPreferences p = await _prefs;
    await p.setBool(_kPromptShownKey, true);
  }
}
