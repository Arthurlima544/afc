import 'package:flutter/material.dart' show IconData, Icons;

/// Centralised icon registry for AFC.
///
/// All screen and component code should reference [AppIcons] semantic names
/// rather than `Icons.xxx` directly, so the entire icon vocabulary can be
/// changed or swapped from one place.
abstract final class AppIcons {
  // ── Navigation (bottom bar) ────────────────────────────────────────────────

  static const IconData home = Icons.home_outlined;
  static const IconData homeSelected = Icons.home;

  static const IconData transactions = Icons.receipt_long_outlined;
  static const IconData transactionsSelected = Icons.receipt_long;

  static const IconData categories = Icons.category_outlined;
  static const IconData categoriesSelected = Icons.category;

  static const IconData limits = Icons.tune_outlined;
  static const IconData limitsSelected = Icons.tune;

  static const IconData recurring = Icons.repeat_outlined;
  static const IconData recurringSelected = Icons.repeat;

  static const IconData goals = Icons.savings_outlined;
  static const IconData goalsSelected = Icons.savings;

  // ── Actions ────────────────────────────────────────────────────────────────

  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.check;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData more = Icons.more_vert;
  static const IconData refresh = Icons.refresh;
  static const IconData share = Icons.share_outlined;
  static const IconData export = Icons.download_outlined;
  static const IconData importFile = Icons.upload_file_outlined;
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData gallery = Icons.photo_library_outlined;

  // ── Financial ──────────────────────────────────────────────────────────────

  static const IconData income = Icons.arrow_downward;
  static const IconData expense = Icons.arrow_upward;
  static const IconData balance = Icons.account_balance_wallet_outlined;
  static const IconData investment = Icons.candlestick_chart_outlined;
  static const IconData goal = Icons.savings_outlined;
  static const IconData bill = Icons.calendar_today_outlined;
  static const IconData limit = Icons.tune_outlined;
  static const IconData health = Icons.favorite_outline;
  static const IconData report = Icons.bar_chart_outlined;
  static const IconData template = Icons.bookmark_outline;

  // ── Sync ───────────────────────────────────────────────────────────────────

  static const IconData sync = Icons.sync_outlined;
  static const IconData syncPending = Icons.sync_problem_outlined;

  // ── Status & Feedback ──────────────────────────────────────────────────────

  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData success = Icons.check_circle_outline;
  static const IconData info = Icons.info_outline;
  static const IconData overspend = Icons.warning_rounded;

  // ── Settings & Account ─────────────────────────────────────────────────────

  static const IconData settings = Icons.settings_outlined;
  static const IconData profile = Icons.person_outline;
  static const IconData logout = Icons.logout;
  static const IconData theme = Icons.dark_mode_outlined;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData bank = Icons.account_balance_outlined;
  static const IconData connect = Icons.link;
  static const IconData disconnect = Icons.link_off;

  // ── Empty States ───────────────────────────────────────────────────────────

  static const IconData emptyTransactions = Icons.receipt_long_outlined;
  static const IconData emptyCategories = Icons.label_outline;
  static const IconData emptyLimits = Icons.tune_outlined;
  static const IconData emptyGoals = Icons.savings_outlined;
  static const IconData emptyInvestments = Icons.candlestick_chart_outlined;
  static const IconData emptyBills = Icons.calendar_today_outlined;
  static const IconData emptyRecurring = Icons.repeat_outlined;
  static const IconData emptyReview = Icons.inbox_outlined;
  static const IconData emptyReport = Icons.bar_chart_outlined;
  static const IconData emptyDefault = Icons.inbox_outlined;
}
