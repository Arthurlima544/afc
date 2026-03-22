# AFC — Product Roadmap

## Objective

Build a complete personal finance management app where users can:
- Authenticate securely via Clerk
- Track income and expenses with custom categories
- Set and monitor monthly spending limits with overspend alerts
- View real-time financial trends through charts and summaries
- Import bank statements, connect bank accounts via Open Finance (Pluggy), and auto-sync transactions
- Track savings goals, investments, bill reminders, and a financial health score

---

## Sprint 1 — Auth Flow & Real Dashboard Data

### US-05 · Auto-redirect on app launch ✅
**As a** user, **I want** the app to automatically send me to the right screen on launch based on my auth state,
**so that** I don't have to manually navigate after opening the app.

- [x] `HomeScreen` shows a splash spinner while auth state is `initial`
- [x] Redirects to `/home` on `signedIn`
- [x] Redirects to `/login` on `signedOut`
- [x] Widget tests (5)

---

### US-06 · Auto-redirect after sign-in ✅
**As a** user, **I want** the app to automatically navigate me to the home page after I sign in,
**so that** I don't have to tap anything extra after authenticating.

- [x] `LoginScreen` navigates to `/home` on `AuthState.signedIn`
- [x] Stays on `/login` on `signedOut` or `unknown`
- [x] Widget tests (5)

---

### US-01 · Real financial summary on dashboard ✅
**As a** user, **I want** to see my real total income, total expenses, and balance on the home page,
**so that** I have an accurate snapshot of my finances.

- [x] `HomeBloc` loads transactions from Firestore for the current user
- [x] Computes `totalIncome`, `totalExpenses`, `balance`
- [x] `HomePage` displays real values (replacing hardcoded/empty state)
- [x] Unit tests for `HomeBloc` summary calculation

---

### US-02 · Real last transactions on dashboard ✅
**As a** user, **I want** to see my most recent transactions on the home page,
**so that** I can quickly review recent activity without opening the full list.

- [x] `HomeBloc` loads the last N transactions from Firestore
- [x] `HomePage` renders the transaction list (replacing empty state)
- [x] Unit tests for `HomeBloc` transaction fetching

---

## Sprint 2 — Limits & Charts

### US-03 · Spending limits progress ✅
**As a** user, **I want** to see how much of my monthly limit I've used per category,
**so that** I know when I'm approaching or exceeding my budget.

- [x] `LimitCubit.loadLimitsWithProgress` queries limits, categories, and transactions from Firestore
- [x] Computes `spent` per category for the current month (expense transactions only)
- [x] `MonthLimitWidget` uses `BlocBuilder<LimitCubit>` with real progress bars
- [x] Unit tests (6)

---

### US-04 · Real chart data ✅
**As a** user, **I want** the financial charts to reflect my actual transaction history,
**so that** I can see real spending trends over time.

- [x] `StatsWidget` uses `BlocBuilder<HomeBloc>` to read `StatsState.success`
- [x] `StatsEntity` list converted to `FlSpot` series (income / expense per month)
- [x] Dynamic y-axis interval based on max data value
- [x] Aggregation logic covered by existing `HomeBloc` unit tests

---

## Sprint 3 — CRUD Lists

### US-07 · Transaction list screen ✅
- [x] Screen listing all transactions for the current user (`lista_transacoes.dart`)
- [x] Fetches from Firestore via `TransactionCubit.loadTransactions`
- [x] Unit tests for `loadTransactions`

### US-08 · Delete transaction ✅
- [x] Delete action on transaction list items
- [x] Removes document from Firestore via `TransactionCubit.deleteTransaction`
- [x] Unit tests for `deleteTransaction`

### US-09 · Category list screen ✅
- [x] Screen listing all categories for the current user (`lista_categorias.dart`)
- [x] Fetches from Firestore via `CategoryCubit.loadCategories`
- [x] Unit tests for `loadCategories`

### US-10 · Delete category ✅
- [x] Delete action on category list
- [x] Removes document from Firestore via `CategoryCubit.deleteCategory`
- [x] Unit tests for `deleteCategory`

### US-11 · Limit list screen ✅
- [x] Screen listing all limits for the current user (`lista_limites.dart`)
- [x] Fetches from Firestore via `LimitCubit.loadLimits` (joins category names)
- [x] Unit tests for `loadLimits`

### US-12 · Delete limit ✅
- [x] Delete action on limit list
- [x] Removes document from Firestore via `LimitCubit.deleteLimit`
- [x] Unit tests for `deleteLimit`

### US-13 · Edit transaction / category / limit ✅
- [x] Pre-fill existing forms for editing (optional `initialXxx` param on each form screen)
- [x] Update Firestore document on save via `updateTransaction` / `updateCategory` / `updateLimit`
- [x] Unit tests for all update methods

---

## Sprint 4 — UI/UX Overhaul & Reactivity

> **Goal**: Make the app feel polished, responsive, and snappy. Fix the biggest pain points before adding new features.

### US-14 · Real-time dashboard reactivity ✅
**As a** user, **I want** the home page to automatically reflect new/edited/deleted data without manual refresh,
**so that** I always see accurate numbers after any change.

- [x] Replace one-shot `.get()` with Firestore `.snapshots()` streams in `HomeBloc` and `LimitCubit`
- [x] Dashboard updates live when transactions or limits change
- [x] List screens (`lista_transacoes`, `lista_categorias`, `lista_limites`) also use streams
- [x] Unit tests updated to use stream-based mocks

---

### US-15 · Bottom navigation bar ✅
**As a** user, **I want** persistent bottom navigation between the main sections of the app,
**so that** I can switch between Dashboard, Transactions, Categories, and Limits in one tap.

- [x] `ScaffoldShell` with `StatefulShellRoute` (GoRouter) wrapping the six main screens
- [x] Active tab highlighted; GoRouter state preserved per tab
- [x] Replace scattered "Ver Todas" buttons with navigation-bar equivalent routes
- [x] Widget tests for tab switching (6 tests — renders, labels, FAB, initial index, tap index 1, tap index 5)

---

### US-16 · Quick-add transaction FAB ✅
**As a** user, **I want** to add a transaction from anywhere in the app with as few taps as possible,
**so that** I can record spending the moment it happens without navigating through menus.

- [x] Floating Action Button visible on all main-section screens
- [x] Bottom sheet modal with: amount numpad, income/expense toggle, category picker, optional title
- [x] Saves transaction and dismisses — no full-screen navigation required
- [x] Haptic feedback on save

---

### US-17 · Design system refresh (Shadcn) ✅
**As a** user, **I want** a clean, consistent visual design,
**so that** the app feels professional and easy to navigate.

- [x] Define and apply a consistent color palette (primary, surface, error, success) via `ThemeData`
- [x] Replace all ad-hoc `TextStyle` calls with named theme text styles
- [x] Standardise spacing via a shared constants file (`AppSpacing`)
- [x] Add empty-state illustrations for lists with no data
- [x] Improve form screens: inline validation messages, better date/month pickers
- [x] Add loading skeletons (shimmer) instead of bare `CircularProgressIndicator`

---

### US-18 · Limit overspend alert ✅
**As a** user, **I want** a visual warning when I exceed a spending limit,
**so that** I can take action before going further over budget.

- [x] `MonthLimitWidget` displays a red badge and warning text when `spent > limitAmount`
- [x] In-app toast/snackbar on home page when any limit is exceeded
- [x] Unit tests for overspend detection logic (verifies `spent > limitAmount` on `LimitProgressItem`)

---

## Sprint 5 — Open Finance Integration

> **Goal**: Let users connect their real bank accounts so transactions arrive automatically, eliminating the need to log expenses manually.
>
> **Recommended aggregator**: [Pluggy](https://pluggy.ai) — the leading Open Finance aggregator in Brazil. It handles the regulatory consent flow (Open Finance Brasil / Banco Central Resolution 32), normalises data across 200+ institutions, and delivers webhooks when new transactions land. The app never touches bank credentials directly; everything goes through Pluggy's OAuth-based Connect Widget.
>
> **Architecture**: A thin Cloud Functions proxy holds Pluggy API credentials server-side. The Flutter app calls the proxy, never Pluggy directly, so keys are never shipped in the APK.

```
User ──► Connect Widget (Pluggy SDK) ──► Bank consent ──► Pluggy
                                                              │
                              webhook ◄── Cloud Function ◄───┘
                                 │
                           Firestore (raw_transaction)
                                 │
                    Review queue in Flutter app
                                 │
                        Confirmed → transaction collection
```

---

### US-28 · Connect a bank account via Open Finance ✅
**As a** user, **I want** to link my bank account to the app using Open Finance,
**so that** my transactions are fetched automatically without me typing anything.

- [x] Cloud Function `createPluggyItem` — calls Pluggy `/items` endpoint and returns a `connectToken`
- [x] `ConnectedAccountEntity` — `uuid`, `userId`, `pluggyItemId`, `institutionName`, `institutionLogo`, `lastSyncedAt`, `status` (active / consent_expired / error)
- [x] Firestore collection `connected_account` scoped by `userId`
- [x] Flutter side embeds Pluggy Connect Widget via `webview_flutter` (or `url_launcher` for the OAuth redirect)
- [x] On successful connection, stores `ConnectedAccountEntity` in Firestore
- [x] Unit tests for Cloud Function item-creation logic

---

### US-29 · Automatic transaction sync from connected accounts ✅
**As a** user, **I want** new transactions from my bank to appear in the app automatically,
**so that** my balance and spending are always up to date without any manual action.

- [x] Cloud Function `onPluggyWebhook` — receives Pluggy `TRANSACTION_CREATED` / `UPDATED` events
- [x] Fetches full transaction detail from Pluggy `/transactions/{id}` and writes to Firestore `raw_transaction` collection (scoped by `userId`)
- [x] `RawTransactionEntity` mirrors Pluggy's payload: `pluggyTransactionId`, `userId`, `accountId`, `amount`, `description`, `date`, `type` (debit/credit), `status` (pending/posted)
- [x] Duplicate guard: skip if `pluggyTransactionId` already exists in `raw_transaction`
- [x] Scheduled Cloud Function (`syncAllItems`) runs nightly to catch missed webhooks
- [x] Unit tests for webhook handler and deduplication logic

---

### US-30 · Transaction review & auto-categorisation queue ✅
**As a** user, **I want** to review and confirm imported transactions before they're saved,
**so that** I can correct categories and ignore irrelevant entries (e.g. internal transfers).

- [x] `ReviewScreen` — lists pending `raw_transaction` documents for the current user
- [x] Each row shows: bank description, amount, date, and a suggested category (auto-assigned by rule engine)
- [x] Auto-categorisation rule engine: keyword → category mapping (e.g. "UBER" → Transporte, "IFOOD" → Alimentação); user corrections are persisted as learned rules in Firestore `categorisation_rule`
- [x] Actions per row: **Confirm** (moves to `transaction` collection), **Edit category**, **Ignore** (marks as dismissed)
- [x] Bulk confirm all button for fast review
- [x] Badge on bottom nav showing count of pending items
- [x] Unit tests for the categorisation rule engine

---

### US-31 · Manage connected accounts ✅
**As a** user, **I want** to see which bank accounts I've connected and be able to disconnect or re-authorise them,
**so that** I'm in full control of what data the app accesses.

- [x] `ConnectedAccountsScreen` — lists all `ConnectedAccountEntity` records for the user
- [x] Each row shows institution logo, name, last synced time, and connection status badge
- [x] **Reconnect** action for items with `status = consent_expired` — re-opens the Connect Widget
- [x] **Disconnect** action — calls Cloud Function `deletePluggyItem`, removes document from Firestore
- [x] Add new account button — triggers a fresh Connect Widget flow

---

### US-32 · Sync status indicator on dashboard ✅
**As a** user, **I want** to see at a glance when my accounts were last synced and whether any need attention,
**so that** I know my data is fresh without opening the connected accounts screen.

- [x] Small "Last synced X minutes ago" label on the dashboard header when at least one account is connected
- [x] Warning chip (yellow) when any account has `status = consent_expired`
- [x] Error chip (red) when sync failed; tapping navigates to `ConnectedAccountsScreen`
- [x] Manual "Sync now" pull-to-refresh on the dashboard triggers Cloud Function `syncAllItems` for the user

---

## Sprint 6 — Smart Transactions & Recurring Expenses

> **Goal**: Reduce the remaining manual effort for users who don't use Open Finance or want to supplement it.

### US-19 · Recurring transactions ✅
**As a** user, **I want** to mark a transaction as recurring (daily / weekly / monthly),
**so that** predictable expenses like rent and subscriptions are logged automatically.

- [x] `RecurringEntity` — `uuid`, `userId`, `templateTransaction`, `frequency` (daily/weekly/monthly), `nextDue`, `active`
- [x] `RecurringCubit` — create, list, pause, delete recurring rules
- [x] Background function (Cloud Functions) or on-app-open check that materialises due transactions
- [x] List screen with toggle to pause/resume each rule
- [x] Unit tests for due-date calculation logic

---

### US-20 · Transaction templates (quick-fill) ✅
**As a** user, **I want** to save frequently used transactions as templates,
**so that** I can log a repeat expense (e.g. "Coffee R$8") in two taps.

- [x] "Save as template" option on the transaction form
- [x] Templates shelf in the quick-add FAB modal (horizontal scroll)
- [x] Tapping a template pre-fills the form; user only confirms amount if needed
- [x] Unit tests for template storage and retrieval

---

### US-21 · Bank statement import (OFX / CSV) ✅
**As a** user, **I want** to import my bank statement file,
**so that** I don't have to manually enter transactions I've already made.

- [x] File picker accepting `.ofx` and `.csv` formats
- [x] Parser maps statement rows → `TransactionEntity` candidates
- [x] Review screen: user confirms, rejects, or re-categorises each import row before saving
- [x] Duplicate detection (same date + amount + description → skip or warn)
- [x] Unit tests for OFX and CSV parsing logic

---

### US-21b · Bank-specific import profiles ✅
**As a** user, **I want** to select my bank and statement type before importing,
**so that** the app parses my file correctly regardless of each bank's proprietary format.

- [x] Bank selector + statement type selector shown before file picker (bank: Nubank; type: Extrato or Fatura)
- [x] `parseNubankExtrato` — columns `Data/Valor/Descrição`, DD/MM/YYYY, standard polarity
- [x] `parseNubankFatura` — columns `date/title/amount`, ISO date, inverted polarity (positive = expense), quoted-field support
- [x] Unit tests for both Nubank parsers with real-format sample data

---

### US-22 · Receipt photo & auto-fill ✅
**As a** user, **I want** to photograph a receipt and have the amount and merchant pre-filled,
**so that** logging a transaction takes seconds.

- [x] Camera / gallery picker in the quick-add modal
- [x] Image sent to Gemini 2.0 Flash API to extract total amount and merchant name
- [x] Extracted values pre-fill the form; user reviews and confirms
- [x] Falls back gracefully if extraction fails (error state + null fields)

---

## Sprint 7 — Financial Intelligence & Investments

> **Goal**: Give users actionable insights and basic investment tracking, turning AFC into a true financial companion.

### US-23 · Monthly spending report ✅
**As a** user, **I want** a monthly report showing my spending by category with trends,
**so that** I can understand where my money went and compare months.

- [x] `ReportScreen` with a selectable month/year picker
- [x] Pie chart of expenses by category for the selected month
- [x] Month-over-month comparison bar chart (current vs previous month per category)
- [x] Summary row: total income, total expenses, savings rate %
- [x] Export to PDF via `pdf` package

---

### US-24 · Savings goals ✅
**As a** user, **I want** to create savings goals with a target amount and deadline,
**so that** I can track progress towards things I'm saving for (e.g. travel, emergency fund).

- [x] `GoalEntity` — `uuid`, `userId`, `name`, `targetAmount`, `currentAmount`, `deadline`, `icon`
- [x] `GoalCubit` — create, update progress, delete
- [x] Goals screen with progress bars and days-remaining countdown
- [x] Manual "add contribution" action that increments `currentAmount`
- [x] Unit tests for contribution and progress calculation

---

### US-25 · Investment portfolio tracker ✅
**As a** user, **I want** to register my investments (stocks, fixed income, crypto) and see my total portfolio value,
**so that** I can monitor my net worth alongside my spending.

- [x] `InvestmentEntity` — `uuid`, `userId`, `name`, `ticker` (optional), `type` (stock/fixed/crypto/other), `quantity`, `avgCost`, `currentPrice`
- [x] `InvestmentCubit` — CRUD for investments
- [x] Manual price update per investment
- [x] Portfolio screen: total invested, current value, overall gain/loss %
- [x] Net-worth card on dashboard (portfolio value, navigates to investments)
- [x] Unit tests for gain/loss calculation

---

### US-26 · Bill reminders & push notifications ✅
**As a** user, **I want** to set reminders for upcoming bills,
**so that** I never miss a due date or incur a late fee.

- [x] `BillEntity` — `uuid`, `userId`, `name`, `amount`, `dueDay` (day of month), `categoryUuid`
- [x] `BillCubit` — CRUD for bills
- [x] Bills list screen with upcoming-this-month highlight (amber) and overdue (red)
- [x] Firebase Cloud Messaging stub + `FcmService` architecture documented
- [x] Cloud Function scheduled trigger (`billReminders.ts`) — daily at 09:00 UTC, sends FCM 3 days before due date

---

### US-27 · Financial health score ✅
**As a** user, **I want** a simple score that summarises my financial health,
**so that** I have a single number to track and improve over time.

- [x] Score (0–100) computed from: savings rate, limit adherence, goal progress, expense variance month-over-month
- [x] Score card on dashboard with colour coding (red / yellow / green)
- [x] Breakdown tooltip explaining each contributing factor (4 sub-scores of 25 pts each)
- [x] Historical score trend (last 6 months) as a small sparkline chart
- [x] Unit tests for scoring formula (37 tests)

---

## Sprint 8 — Brand Identity & Visual Language (US-33–37)

### US-33 · Brand color system & typography scale ✅
- Primary color (`#10B981` emerald), full colour palette, typography scale defined in `app_theme.dart`

### US-34 · Custom app icon & branded splash screen ✅
- App icons (dev/prod) via `flutter_launcher_icons`; native splash screen configured

### US-35 · Consistent iconography system ✅
- `AppIcons` constants class; icon list for goals/categories; `cupertino_icons` + Material Icons

### US-36 · Dark mode & theme toggle ✅
- `ThemeCubit` (light / dark / system); `ThemeMode` propagated through `MyApp`

### US-37 · Branded empty states ✅
- `EmptyState` widget with icon + message; applied to all list screens

---

## Sprint 9 — User Experience & Interaction Design (US-38–44)

### US-38 · Onboarding flow (first-time user) ✅
- `OnboardingScreen` (4-page `PageView`, dot indicators); `SharedPreferences` `onboarding_done` flag; `HomeScreen` routes to `/onboarding` on first launch

### US-39 · Skeleton loading screens ✅
- `SkeletonList` with shimmer animation (`AnimationController` + `LinearGradient`); respects `MediaQuery.disableAnimations`

### US-40 · Micro-animations & page transitions ✅
- `transitions.dart` (`slideUpTransition`, `fadeScaleTransition`); FAB `ScaleTransition` pop-in; haptic `lightImpact` on tab taps

### US-41 · User profile & settings screen ✅
- `SettingsCubit` + `SettingsScreen` (`/settings`); Profile, Appearance, Notifications, Data, About sections; gear icon on dashboard

### US-42 · Contextual error states with retry ✅
- `ErrorState` widget with retry button; replaces bare error text on all 5 list screens

### US-43 · Pull-to-refresh on all list screens ✅
- `RefreshIndicator` on transactions, categories, limits, recurring, goals list screens

### US-44 · Accessibility & inclusive design ✅
- `Semantics` labels on FAB + settings button; `tooltip` on all `NavigationDestination`s; `docs/accessibility_checklist.md`

---

## Sprint 10 — Remove Shadcn & Establish AFC Design System (US-33b–44b)

Full migration from `shadcn_flutter` to a custom Material 3 design system:

- `AppCard`, `AppButton`, `AppIconButton`, `AppTextField`, `AppDialog`, `Gap` widgets
- `AppColors`, `AppTextStyles`, `AppSpacing` constants
- `design_system.dart` barrel export
- All 25 screens migrated — `hide Column, Row, Expanded` clauses removed
- `ColorScheme.fromSeed()` with `useMaterial3: true`
- `shadcn_flutter` removed from `pubspec.yaml`

---

## Sprint 11 — Design Polish & Navigation Overhaul (US-45–53)

### US-45 · Fix primary color propagation ✅
- Explicit `primary: AppColors.primary, onPrimary: AppColors.onPrimary` overrides in `ColorScheme.fromSeed()` (both light and dark themes)

### US-46 · Fix HomeCard internal layout ✅
- Added `padding: const EdgeInsets.all(16)` to `AppCard` in `HomeCard`; corrected icon circle sizing

### US-47 · Fix light/dark mode card adaptation ✅
- `AppCard` and `AppIconButton` now use `Theme.of(context).brightness` (responds to `ThemeCubit`-driven theme changes, not just system brightness)

### US-48 · Scaffold wrapper for all push-route screens ✅
- Every `context.push()` screen wrapped in `Scaffold` (Material surface + background colour); form screens get `AppBar` with `BackButton`

### US-49 · Fix OFX/CSV encoding (Latin-1 fallback) ✅
- `ImportCubit` tries `utf8.decode` first; falls back to `latin1.decode` on `FormatException`; fixes garbled "transferência" from Nubank exports

### US-50 · Bottom nav reorganisation (6→4 tabs) ✅
- Tabs: Home | Transactions | Limits | Goals
- Categories moved to Settings screen ("Gerenciar categorias" tile)
- Recurring moved to Transactions header (repeat icon button)
- `lista_categorias.dart` and `lista_recorrentes.dart` converted to push routes with back button

### US-51 · Form screens as BottomSheet ✅
- `showFormSheet<T>()` utility (`DraggableScrollableSheet`, 90% initial, 50–95% range)
- All create/edit forms shown as draggable bottom sheets; each form gets its own `BlocProvider` inline

### US-52 · Fix Edit Transaction & Edit Limit dropdown assertion ✅
- Guard `_typeValue` against values not present in `TypeEntity.values` (set to `null` if not found)
- Guard `_monthValue` in `CadastrarLimites` against values not in `CalendarEntity.values`

### US-53 · Fix "Ver Todas" navigation ✅
- Confirmed `context.go('/lista-transacoes')` correctly switches to the Transactions tab in `StatsWidget`

---

## Technical Debt & Cross-cutting

These items are not user stories but are necessary for long-term quality.

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Firestore streams (replace `.get()`) | High | ✅ Done | All list screens and dashboard use `.snapshots()` |
| Widget test coverage for key screens | High | ✅ Done | home_screen, login_screen, scaffold_shell (268 total tests) |
| Cloud Functions project setup | High | ✅ Done | Pluggy proxy + webhooks + bill reminders in `functions/src/` |
| Offline support (`persistenceEnabled`) | Medium | ✅ Done | Both `main_dev.dart` and `main_prod.dart` configure `CACHE_SIZE_UNLIMITED` |
| CI: separate lint / test / build jobs | Low | ✅ Done | 3 jobs: lint → test (coverage artifact) → build (APK artifact) |
| Pluggy sandbox account & API keys | High | ⏳ Pending | Register at pluggy.ai; add API keys to Cloud Functions env |
| Integration tests (golden tests) | Medium | ⏳ Pending | Catch regressions on UI redesign; complex setup required |
| Repository layer abstraction | Medium | ⏳ Pending | BLoCs call Firestore directly — major refactor, risky |
| Accessibility audit (semantics, contrast) | Medium | ⏳ Pending | Required for app store compliance; needs manual device testing |
| Error boundary widget | Low | ⏳ Pending | Catch unhandled exceptions and show user-friendly screen |

---

## Branch Strategy

| Sprint / Work | Branch | Status |
|--------------|--------|--------|
| Sprint 1 (US-05, US-06) | `feat/us-05-06-auth-navigation` | ✅ Merged |
| Sprint 1 (US-01, US-02) | `feat/us-01-02-dashboard-data` | ✅ Merged |
| Sprint 2 (US-03, US-04) | `feat/us-03-04-limits-charts` | ✅ Merged |
| Sprint 3 (US-07–13) | `feat/us-07-13-crud-lists` | ✅ Merged |
| Sprint 4 (US-14–18) | `feat/us-14-18-ux-reactivity` | ✅ Merged |
| Sprint 5 (US-28–32) | `feat/us-28-32-open-finance` | ✅ Merged |
| Sprint 6 (US-19–22) | `feat/us-19-22-smart-transactions` | ✅ Merged |
| Sprint 7 (US-23–27) | `feat/us-23-27-financial-intelligence` | ✅ Merged |
| Technical debt (tests, offline, CI) | `chore/technical-debt` | ⏳ Open PR |
| Sprint 8 (US-33–37) | `feat/us-33-37-brand-identity` | ✅ Merged |
| Sprint 9 (US-38–44) | `feat/us-38-44-ux-polish` | ✅ Merged |
| Sprint 10 (design system migration) | `feat/sprint10-design-system` | ✅ Merged |
| Sprint 11 (US-45–53) | `feat/sprint11-polish` | ⏳ Open |
