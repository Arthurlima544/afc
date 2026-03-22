import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
class SettingsState {
  const SettingsState({
    this.billReminders = true,
    this.overspendAlerts = true,
    this.weeklyDigest = false,
    this.currencySymbol = r'R$',
  });

  final bool billReminders;
  final bool overspendAlerts;
  final bool weeklyDigest;
  final String currencySymbol;

  SettingsState copyWith({
    bool? billReminders,
    bool? overspendAlerts,
    bool? weeklyDigest,
    String? currencySymbol,
  }) =>
      SettingsState(
        billReminders: billReminders ?? this.billReminders,
        overspendAlerts: overspendAlerts ?? this.overspendAlerts,
        weeklyDigest: weeklyDigest ?? this.weeklyDigest,
        currencySymbol: currencySymbol ?? this.currencySymbol,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          billReminders == other.billReminders &&
          overspendAlerts == other.overspendAlerts &&
          weeklyDigest == other.weeklyDigest &&
          currencySymbol == other.currencySymbol;

  @override
  int get hashCode => Object.hash(
    billReminders,
    overspendAlerts,
    weeklyDigest,
    currencySymbol,
  );
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const String _keyBillReminders = 'bill_reminders';
  static const String _keyOverspendAlerts = 'overspend_alerts';
  static const String _keyWeeklyDigest = 'weekly_digest';
  static const String _keyCurrencySymbol = 'currency_symbol';

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emit(
      SettingsState(
        billReminders: prefs.getBool(_keyBillReminders) ?? true,
        overspendAlerts: prefs.getBool(_keyOverspendAlerts) ?? true,
        weeklyDigest: prefs.getBool(_keyWeeklyDigest) ?? false,
        currencySymbol: prefs.getString(_keyCurrencySymbol) ?? r'R$',
      ),
    );
  }

  Future<void> setBillReminders({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBillReminders, value);
    emit(state.copyWith(billReminders: value));
  }

  Future<void> setOverspendAlerts({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOverspendAlerts, value);
    emit(state.copyWith(overspendAlerts: value));
  }

  Future<void> setWeeklyDigest({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWeeklyDigest, value);
    emit(state.copyWith(weeklyDigest: value));
  }

  Future<void> setCurrencySymbol(String symbol) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencySymbol, symbol);
    emit(state.copyWith(currencySymbol: symbol));
  }
}
