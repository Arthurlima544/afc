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

### US-54 · Fix ProviderNotFoundException in Recorrências and Contas a Pagar ✅
- `lista_recorrentes.dart` and `lista_contas.dart` converted from `context.push()` to `showFormSheet` with `MultiBlocProvider` supplying required cubits inline
- `lista_recorrentes` provides `TransactionCubit()..getCategories()` + `RecurringCubit`
- `lista_contas` provides `BillCubit` + `CategoryCubit()..loadCategories()`

### US-55 · Self-contained form category loading ✅
- All four form screens (`cadastrar_transacao`, `cadastrar_limites`, `cadastrar_recorrente`, `cadastrar_conta`) trigger category loading in `initState` via lint-safe microtask pattern
- Forms work correctly regardless of caller (push route, `showFormSheet`, or test harness)

### US-56 · Category chip selector in all form screens ✅
- Replaced `DropdownButtonFormField` for categories with `Wrap` of tappable chips in all four form screens
- Matches the QuickAddSheet UX; inline "Nova" chip triggers `_showAddCategoryDialog()` (writes to Firestore, refreshes cubit, auto-selects new category)

### US-57 · Fix showInputDialog use-after-dispose crash ✅
- `showInputDialog` in `app_dialog.dart` now wraps content in `_InputDialog` (`StatefulWidget`) so `TextEditingController` is owned and disposed by `State.dispose()` — eliminates the "used after dispose" exception triggered by keyboard dismissal after dialog close

### US-58 · Home page "Estatísticas" — remove line chart, add savings summary ✅
- Removed `LineChartSample7` line chart (not useful to users)
- Replaced with "Resumo do mês" card: taxa de poupança %, receita do mês, gastos do mês, "Ver relatório" link
- New `_StatCell` helper widget used for the three stats columns

### US-59 · Recent transaction card styling improvement ✅
- `LastTransactions` widget redesigned: color-coded direction arrow (green ↓ income / red ↑ expense), category name, formatted amount — wrapped in `AppCard` for consistent surface treatment

---

## Sprint 12 — Financial Independence Engine (US-60–67)

> **Goal**: Elevate AFC from an expense tracker into a financial independence tool. Saving and controlling spending is not enough to build wealth — users need features that actively help them grow their assets, project their trajectory, understand the power of compounding, and spot real market opportunities in the Brazilian market before acting.

### US-60 · FIRE Calculator (Financial Independence, Retire Early) ✅
**As a** user, **I want** to know my FIRE number and how long it will take me to reach it,
**so that** I can understand exactly when I could stop relying on active income.

- [x] Pure `FireCalculator` use case with `FireResult` output: `fireNumber`, `monthsToFire?`, `retirementDate?`, `yearlyTimeline`
- [x] Formula: `fireNumber = (monthlyExpenses × 12) / SWR`; month-by-month compound growth loop to find crossing point
- [x] `FireCalculatorScreen` — inputs: monthly expenses, current portfolio, monthly savings, annual return %
- [x] Presets: Lean FIRE (3%), Padrão (4%), Fat FIRE (5%) — preset chips
- [x] Results card: FIRE number in BRL, time to FIRE ("X anos e Y meses"), estimated retirement date
- [x] `fl_chart` LineChart showing portfolio growth curve vs FIRE number (dashed horizontal reference line)
- [x] `_FireCard` on Dashboard home page linking to `/fire-calculadora`
- [x] 11 unit tests: FIRE number formula, SWR edge cases, months-to-FIRE, unreachable scenario, yearlyTimeline structure, retirementDate

---

### US-61 · Compound Interest Simulator ✅
**As a** user, **I want** to simulate how my investments grow over time given a monthly contribution and interest rate,
**so that** I can see the real impact of investing consistently.

- [x] `CompoundInterestCalculator` use case: `calculate()` and `compare()` static methods returning `CompoundResult` (`finalAmount`, `totalInvested`, `totalInterest`, `yearlyTimeline`)
- [x] Inputs: initial amount, monthly contribution, annual rate %, period in years
- [x] Results card: final amount, total invested, total interest + visual composition bar (capital vs rendimentos)
- [x] `fl_chart` LineChart with area fill for primary rate; dashed lines for comparison rates
- [x] "Comparar taxas" toggle — overlays 6%, 10%, 14% comparison curves with legend
- [x] `_CompoundInterestCard` on Dashboard linking to `/juros-compostos`
- [x] 11 unit tests: lump-sum formula, annuity formula, zero-rate, totalInvested/totalInterest invariants, timeline structure, compare ordering

---

### US-62 · Portfolio Performance Dashboard ✅
**As a** user, **I want** to see my portfolio's overall ROI, allocation breakdown, and performance over time,
**so that** I can evaluate whether my investments are on track.

- [x] `PortfolioCalculator` use case — `PortfolioPosition` per investment (totalCost, currentValue, profit, roiPercent) and `PortfolioSummary` (totals, allocationByType, bestPerformer, worstPerformer)
- [x] `PortfolioDashboardScreen` — overall ROI card, allocation donut (PieChart), best/worst highlight tiles, position list sorted by value
- [x] Color coding per type: Ações (blue), Renda Fixa (green), Cripto (orange), Outros (purple)
- [x] `_PortfolioCard` on Dashboard linking to `/portfolio-dashboard`
- [x] 8 unit tests: empty portfolio, position metrics, losses, overall totals, allocation grouping, best/worst, zero avgCost guard

---

### US-63 · Passive Income Tracker ✅
**As a** user, **I want** to track my passive income streams (dividends, interest, rental income),
**so that** I can monitor how close I am to covering my expenses with passive income.

- [x] `PassiveIncomeEntity` — `uuid`, `userId`, `source` (dividend / interest / rent / other), `amount`, `frequency` (monthly/quarterly/annual), `assetUuid?` (Freezed + JSON)
- [x] `PassiveIncomeCubit` — `loadStreams`, `add`, `create`, `update`, `delete`; sorted by amount desc
- [x] Passive income screen: swipe-to-delete stream cards, total monthly equivalent summary card
- [x] `_AddStreamSheet` bottom sheet form with source and frequency dropdowns
- [x] `_PassiveIncomeCard` on Dashboard → `/renda-passiva`
- [x] `monthlyEquivalent()` helper: monthly×1, quarterly÷3, annual÷12
- [x] 13 unit tests: `monthlyEquivalent` (4 cases) + `PassiveIncomeCubit` (9 cases — load/filter/sort/add/delete/update)

---

### US-64 · Net Worth Evolution Chart ✅
**As a** user, **I want** to see how my net worth (assets minus liabilities) has grown over time,
**so that** I can track my wealth-building progress month by month.

- [x] `NetWorthSnapshotEntity` — `uuid`, `userId`, `date`, `assets: double`, `liabilities: double`, `netWorth: double` (Freezed + JSON)
- [x] `NetWorthCubit` — `loadSnapshots`, `recordSnapshot` (upserts by month), `delete`; snapshots sorted by date asc
- [x] `/patrimonio` screen: line chart (fl_chart) showing last 13 months, summary card with assets/liabilities/monthly delta, history list
- [x] `_RecordSnapshotSheet` bottom sheet to manually enter assets and liabilities
- [x] `_PatrimonioCard` on Dashboard → `/patrimonio`
- [x] 8 unit tests: initial state, load/filter/sort, recordSnapshot persists and upserts, delete

---

### US-65 · Investment Goal Planner ✅
**As a** user, **I want** to set an investment target (e.g. "R$ 1 million by 2040") and see the required monthly contribution,
**so that** I know exactly how much to invest each month to reach my goal.

- [x] `InvestmentGoalCalculator` pure-Dart use case — FV annuity formula solved for PMT; r=0 fallback to linear
- [x] `InvestmentGoalResult` — `requiredMonthlyContribution`, `totalContributed`, `totalInterestEarned`, `yearlyTimeline`
- [x] `/meta-investimento` screen: 4-input form (target, current, years, return%), required monthly contribution card, composition bar chart, line chart
- [x] `_InvestmentGoalCard` on Dashboard → `/meta-investimento`
- [x] 10 unit tests: zero-rate PMT, reduced PMT with current amount, lower PMT with returns, PMT=0 when already exceeds, contribution totals, timeline length/monotonicity/accuracy

---

### US-66 · Inflation-Adjusted Projections ✅
**As a** user, **I want** all long-term projections (FIRE, compound interest, goals) to show real (inflation-adjusted) values,
**so that** I understand what my money will actually buy in the future.

- [x] `InflationCalculator` pure use case — `realValue()`, `realAnnualReturnPercent()`, `adjustTimeline()` with default IPCA 4.5%
- [x] "Ajuste de Inflação" toggle card on FIRE Calculator — inflation rate input (default 4.5%), "Valor real hoje" row in result card, dashed real timeline on chart
- [x] "Ajuste de Inflação" toggle card on Compound Interest — "Poder de compra hoje" row in result card, dashed real timeline on chart
- [x] 10 unit tests for `InflationCalculator` (realValue, realAnnualReturnPercent, adjustTimeline)

---

### US-68 · Brazilian Market Opportunities Feed ✅
**As a** user, **I want** to see top dividend-paying Brazilian stocks and compare their yield against fixed-income benchmarks (CDI, Selic, Tesouro Direto),
**so that** I can spot attractive investment opportunities without leaving the app.

- [x] **Data source**: [Brapi](https://brapi.dev) free tier — `/api/quote/{tickers}?fundamental=true` for DY/P/L, `/api/v2/prime-rate?country=brazil` for CDI rate. No API key required.
- [x] `BrapiService` — `fetchQuotes(List<String>)`, `fetchCdiRate()`, `fetchHistory(String)` with graceful fallbacks on error
- [x] `MarketQuoteEntity` — plain Dart class (display-only, not stored in Firestore): `ticker`, `name`, `price`, `changePercent`, `dividendYield`, `isFii`, `priceEarnings?`, `sector`; factory `fromJson` detects FII via `quoteType == 'MUTUALFUND'`; `dyVsCdi(double cdiRate)` helper
- [x] `MarketOpportunityCubit` — fetches 15 curated equities + 12 curated FIIs sequentially; fetches CDI rate; sorts by DY descending; 30-min in-memory TTL; `forceRefresh` flag for pull-to-refresh
- [x] `OportunidadesScreen` — filter chips (Todos / Ações / FIIs) + sort chips (Maior DY / DY vs CDI / Menor P/L)
- [x] `_QuoteCard` — ticker, type badge (Ação/FII), price, change% with arrow icon, DY%, DY×CDI ratio, P/L, sector
- [x] `_BenchmarkBanner` — CDI % and Selic approximation (CDI + 0.1) as reference
- [x] Pull-to-refresh triggers `forceRefresh`; "Atualizado X min atrás" timestamp shown
- [x] Dashboard card (`_MarketOpportunitiesCard`) — top 3 DY stocks with "Ver todas" link; own `BlocProvider`
- [x] 10 unit tests: `fromJson` parsing, FII detection, name fallbacks, `dyVsCdi`, zero CDI, load/sort, cache TTL, `forceRefresh`, error state

---

### US-69 · Stock Watchlist with Near Real-Time Quotes ✅
**As a** user, **I want** to save a list of Brazilian stocks and track their prices in near real-time,
**so that** I can monitor opportunities I'm watching without opening a brokerage app.

- [x] **Data source**: Brapi `/api/quote/{tickers}?fundamental=true` (batch ≤10) + `/api/quote/{ticker}?range=5d&interval=1d` for sparklines; 60-second `Timer.periodic` poll
- [x] `WatchlistEntity` (Freezed + Firestore) — `uuid`, `userId`, `ticker`, `addedAt`, `alertThreshold?`
- [x] `WatchlistItem` — plain Dart class combining entity + live `MarketQuoteEntity?` + `sparkline: List<double>`; `alertTriggered` computed property; manual `copyWith`
- [x] `WatchlistCubit` — `loadWatchlist`, `addTicker`, `removeTicker`, `setAlert`, `refresh`; batched quote fetching; background sparkline loading with 600ms inter-request delay; `isClosed` guard; timer cancelled in `close()`
- [x] `ListaWatchlist` — swipe-to-delete (`Dismissible`), alert bell icon when threshold triggered, 36px `fl_chart` sparkline (green/red), DY%/P/L metrics, `_AlertChip` showing threshold price
- [x] Bookmark icon on `OportunidadesScreen` cards — filled if already in watchlist; tap adds ticker or navigates to watchlist
- [x] `/watchlist` route added to `router.dart`; `/oportunidades` upgraded to `MultiBlocProvider` (both cubits)
- [x] Free-tier guardrails: batches of 10, 60s poll, 600ms sparkline delay
- [x] 13 unit tests: `WatchlistItem` behavior, load/filter by userId, add/remove/setAlert CRUD, no-op refresh

---

### US-67 · Financial Independence Score & Milestones ✅
**As a** user, **I want** a clear score showing how close I am to financial independence,
**so that** I have a single motivating number to grow.

- [x] FI Score (0–100): formula `(monthly_passive_income / monthly_expenses) × 100`, capped at 100
- [x] `FiScoreCubit` — fetches `passive_income` + `transaction` collections; computes score + 6-month sparkline
- [x] `FiScoreData` — `fiScore`, `passiveIncomeMonthly`, `monthlyExpenses`, `last6Scores`, `achievedMilestones` computed property
- [x] Milestone badges (10 / 25 / 50 / 75 / 100%) on Dashboard card — filled/highlighted when achieved
- [x] `_FiScoreCard` on Dashboard augmenting `_HealthScoreCard` — score %, label, sparkline, progress bar, milestone row, passive income vs expenses caption
- [x] 11 unit tests: `FiScoreData` milestone detection (3) + `FiScoreCubit` (8 — zero data, score formula, 100% cap, income exclusion, userId filter, empty userId)

---

## Sprint 13 — Bug Fixes & State Management (US-70–76) ✅

> **Goal**: Eliminate the most impactful bugs that make the app feel unreliable. Every write operation must give clear feedback, every list must stay live, and no screen should silently fail.

### US-70 · Success/error feedback on all write operations ✅
**As a** user, **I want** to see a confirmation or error message after every create, update, or delete action,
**so that** I know whether my action was recorded or whether I need to retry.

- [x] `GoalCubit`, `BillCubit`, `RecurringCubit` listeners show `SnackBar` on error state
- [x] Unit tests: verify success and error snackbar triggers on state transitions

---

### US-71 · Fix goal card disappearing after contribution ✅
**As a** user, **I want** the goal card to remain visible immediately after I add a contribution,
**so that** I can see the updated progress without restarting the app.

- [x] Root cause: after `contribute`/`edit`/`delete`, the list cubit was never reloaded
- [x] Fix: capture `GoalCubit` and `userId` refs before the async gap, then call `loadGoals(userId)` after each mutation
- [x] `success` state in list screen now shows `SkeletonList` (transient) while reload is in flight
- [x] Regression tests in `sprint13_regression_test.dart`

---

### US-72 · Fix recurring transactions not being saved ✅
**As a** user, **I want** recurring rules I create to be persisted so they materialise on schedule,
**so that** my automatic expenses are actually logged.

- [x] Root cause: `CadastrarRecorrente` had no `BlocListener` on `RecurringCubit` — the form never closed after save, making it look like nothing was saved
- [x] Fix: added `BlocListener<RecurringCubit, RecurringState>` wrapping the form body; pops on `success`
- [x] `RecurringCubit.create` already wrote to Firestore correctly — the issue was purely UI (form not closing)

---

### US-73 · Fix bottom sheets not closing after save ✅
**As a** user, **I want** form bottom sheets to dismiss automatically when I tap Save,
**so that** I don't have to manually swipe them away after a successful action.

- [x] `CadastrarRecorrente` was the only form missing a `BlocListener` — fixed by adding `BlocListener<RecurringCubit, RecurringState>` with `success: (_) => context.pop()`
- [x] All other forms (`CadastrarMeta`, `CadastrarConta`, etc.) already had close-on-success listeners

---

### US-74 · Fix contas (bills) list not refreshing after save ✅
**As a** user, **I want** the bills list to update immediately when I add or edit a bill,
**so that** I don't have to close and reopen the screen to see changes.

- [x] Fix: capture `BillCubit` and `userId` refs before `await showFormSheet`; call `loadBills(userId)` after sheet closes
- [x] Applied to both the "add" button in `ListaContas` and the "edit" button in `_BillItem`
- [x] `BlocBuilder` → `BlocConsumer` to show error snackbar on `error` state
- [x] Regression tests in `sprint13_regression_test.dart`

---

### US-75 · Fix login flicker (Clerk UI shown briefly when already authenticated) ✅
**As a** user, **I want** the app to go directly to the home screen when I'm already logged in,
**so that** I never see the Clerk login form flash on screen unexpectedly.

- [x] Root cause: `_ClerkAuthObserver.signedOutBuilder` dispatched `AuthEvent.signOut` while Clerk was still initialising (before env/client were loaded)
- [x] Fix: guard dispatch with `if (!authState.isNotAvailable)` — only signOut when Clerk has fully resolved its state

---

### US-76 · Auto-refresh all lists after any mutation ✅
**As a** user, **I want** every list screen to reflect changes immediately after a create, update, or delete,
**so that** I never need to pull-to-refresh or navigate away to see updated data.

- [x] Goal list: reloads after contribute, edit, delete (US-71)
- [x] Bill list: reloads after add and edit sheet closes (US-74)
- [x] Transaction list and Recurring list already use `.snapshots()` streams — self-updating ✅
- [x] All regression tests added to `sprint13_regression_test.dart`

---

## Sprint 14 — Privacy & Discoverability (US-77–78) ✅

> **Goal**: Give users control over what they expose in public, and make complex financial concepts approachable for users who aren't finance experts.

### US-77 · Privacy mode — hide sensitive values ✅
**As a** user, **I want** to tap an eye icon to instantly hide all monetary values on screen,
**so that** I can use the app in public without showing my financial data to bystanders.

- [x] `PrivacyCubit` — simple `bool` toggle (hidden/visible), resets on app restart
- [x] `PrivacyText` widget — wraps any monetary string; shows `"•••••"` with `AnimatedSwitcher` when hidden
- [x] Eye icon (`Icons.visibility_outlined` / `Icons.visibility_off_outlined`) added to dashboard header
- [x] `PrivacyCubit` injected at root in `MyApp` `MultiBlocProvider`
- [x] `PrivacyText` applied to: balance, income, expenses cards (`HomeCard`), recent transactions (`LastTransactions`), month limits (`MonthLimit`), stats widget income/expenses, portfolio value (`_NetWorthCard`), FI Score passive income/expenses caption

---

### US-78 · Tooltips for complex financial concepts ✅
**As a** user, **I want** a help icon next to terms I don't understand (FIRE, FI Score, taxa de poupança),
**so that** I can learn what they mean without leaving the app.

- [x] `AppTooltipIcon` widget — tappable ⓘ icon using `Tooltip` with `triggerMode: tap` and 4s display duration
- [x] Exported via `design_system.dart` barrel
- [x] Applied to FIRE calculator: "Número FIRE", "Valor real hoje"
- [x] Applied to Compound Interest: "Montante final", "Juros ganhos", "Poder de compra hoje"
- [x] Applied to FI Score card: "Independência Financeira" title
- [x] Applied to Health Score sub-factors: replaced `Tooltip` wrapper with inline `AppTooltipIcon` in `_ScoreRow`
- [x] Applied to Investment Goal: "Aporte mensal necessário"

---

## Sprint 15 — Smart Data & Defaults (US-79–81)

> **Goal**: Reduce friction for new users and improve data quality by providing sensible defaults and smarter automatic categorisation.

### US-79 · Default categories seeded on first login ✅
**As a** new user, **I want** to see a useful set of categories already available when I open the app,
**so that** I can start logging transactions immediately without configuring anything.

- [x] On first successful sign-in, check Firestore `category` collection; if empty, write a default set:
  Alimentação, Transporte, Moradia, Saúde, Lazer, Educação, Vestuário, Assinaturas, Restaurantes, Viagem, Investimentos, Salário, Freelance, Outros
- [x] Each default category has a pre-assigned `iconType` matching existing icon constants
- [x] Seeding is idempotent: guarded by a `user_meta/seeded_categories` flag in Firestore so it runs only once per account
- [x] Unit test: seeding logic writes exactly N documents when collection is empty, writes 0 when flag already set

---

### US-80 · Transaction grouping on list screens ✅
**As a** user, **I want** my transaction list to group similar entries (e.g. all PIX transfers, all supermarket purchases),
**so that** I can quickly see patterns and totals for each type of spending.

- [x] `TransactionGroup` — `label: String`, `transactions: List<TransactionEntity>`, `total: double`
- [x] `TransactionGrouper` use case — rule-based pattern matching on `title` field:
  - `PIX` → "Transferências PIX"
  - `TED` / `DOC` → "Transferências bancárias"
  - `UBER` / `99` / `CABIFY` → "Transporte por app"
  - `IFOOD` / `RAPPI` / `DELIVERY` → "Delivery"
  - `MERCADO` / `SUPERMERCADO` / `PÃO DE AÇÚCAR` / `CARREFOUR` → "Supermercado"
  - `NETFLIX` / `SPOTIFY` / `AMAZON` / `APPLE` → "Assinaturas"
  - Remaining → "Outros"
- [x] Toggle in `ListaTransacoes` header: "Por data" ↔ "Por grupo"
- [x] Group header shows label + count + total amount for the group
- [x] Unit tests for `TransactionGrouper` pattern matching (≥ 10 cases)

---

### US-81 · Smarter CSV/OFX import auto-categorisation ✅
**As a** user, **I want** imported bank transactions to be automatically assigned to the right category based on their description,
**so that** I spend less time manually re-categorising after an import.

- [x] `CategorizationMatcher` use case with 50+ Brazilian merchant patterns (iFood, Uber, Carrefour, Drogasil, Netflix, IPVA, Cemig, Udemy, etc.)
- [x] Add confidence score to `ImportCandidateEntity`: `categoryConfidence: double` (0–1)
- [x] `ImportCubit.parseContent` runs matcher after parsing; resolved category UUID written to each candidate
- [x] In review screen, show confidence badge: green ≥ 0.8 ("Auto"), amber 0.5–0.8 ("Revisar"), red < 0.5 ("Manual")
- [x] Duplicate rows show "Duplicata" badge; non-duplicate with confidence > 0 show confidence badge
- [x] Unit tests: keyword matcher coverage for top 22 patterns

---

## Sprint 16 — Offline-First Architecture (US-82–83)

> **Goal**: Make the app fully usable without internet and keep users clearly informed when a feature needs connectivity, rather than silently failing or showing a spinner forever.

### US-82 · Offline indicator and local operation queue ✅
**As a** user, **I want** to create and modify data even when I have no internet connection,
**so that** I can log expenses on the go and trust they'll sync when I'm back online.

- [x] Add `connectivity_plus` package; `ConnectivityService` singleton (via GetIt) exposes `Stream<bool> isOnline`
- [x] `OfflineBanner` widget — amber sticky banner "Sem conexão — dados serão sincronizados quando a internet voltar"; shown at top of `ScaffoldShell` when offline
- [x] `PendingOperationEntity` — `uuid`, `userId`, `type` (create/update/delete), `collection`, `payload: Map`, `createdAt`, `retries: int`; stored in `SharedPreferences` (local, not Firestore)
- [x] `SyncQueue` service — `enqueue(op)`, `flush()` (replays ops against Firestore when online), `clear()`
- [x] All cubit write operations: when offline → enqueue op + optimistically update local state; when online → write directly to Firestore
- [x] Features that are **read-only and require internet** (BrapiService quotes, Watchlist live prices, Open Finance sync): show a `_OfflineUnavailableCard` placeholder instead of a loading spinner
- [x] `ConnectivityService` triggers `SyncQueue.flush()` automatically when transitioning offline → online
- [x] Unit tests: enqueue, flush (applies ops in order), idempotency guard (skip if Firestore doc already up-to-date)

---

### US-83 · Pending sync notifications page ⏳
**As a** user, **I want** to see a list of operations waiting to sync and be notified when they complete,
**so that** I always know the state of my data and can trust the app.

- [ ] `flutter_local_notifications` package; `LocalNotificationService` initialised in both entry points
- [ ] When `SyncQueue` has ≥ 1 pending op: schedule a persistent local notification "X operações aguardando sincronização — toque para ver"
- [ ] When `SyncQueue.flush()` completes successfully: show "Dados sincronizados com sucesso" notification + clear the persistent one
- [ ] When flush fails after 3 retries: show "Falha ao sincronizar X operações — verifique sua conexão" notification
- [ ] `PendingOpsScreen` (`/pendencias`) — list of queued operations grouped by collection (e.g. "3 transações", "1 meta"), each showing description + timestamp + retry button
- [ ] Badge on Settings icon when pending ops > 0
- [ ] Unit tests: notification scheduling on enqueue, clear on flush success, retry increment on flush failure

---

## Sprint 17 — Benefits & Sub-accounts (US-84–85)

> **Goal**: Support the financial reality of both CLT employees (who receive non-cash benefits like VA/VT) and PJ contractors (who manage company expenses separately from personal finances).

### US-84 · Benefits wallet (CLT — VA, VT, VR) ⏳
**As a** CLT employee, **I want** to track my Vale Alimentação, Vale Transporte, and Vale Refeição balances separately from my main account,
**so that** I know how much benefit credit I've used and what's left this month.

- [ ] `BenefitEntity` — `uuid`, `userId`, `name`, `type` (va / vt / vr / other), `monthlyCredit: double`, `balance: double`, `color: int`
- [ ] `BenefitCubit` — CRUD + `deduct(amount)` to record a benefit expense
- [ ] Transactions can be optionally tagged `benefitUuid` (nullable) to link to a benefit wallet
- [ ] `BenefitWalletScreen` (`/carteiras`) — card per benefit showing balance bar, monthly credit, deductions list
- [ ] `_BenefitsCard` on Dashboard — total benefit balance + quick deduct FAB
- [ ] Unit tests for balance deduction and monthly reset logic

---

### US-85 · Company / sub-account tracking (PJ) ⏳
**As a** PJ contractor or anyone managing multiple spending contexts, **I want** to tag expenses to different "accounts" (e.g. Pessoal, Empresa, Cartão PJ),
**so that** I can see separate totals per context without mixing personal and business finances.

- [ ] `SubAccountEntity` — `uuid`, `userId`, `name`, `type` (personal / company / benefit), `color: int`, `icon: int`
- [ ] `TransactionEntity` extended with optional `subAccountUuid` field (nullable, backwards-compatible)
- [ ] Sub-account selector chip row in `CadastrarTransacao` and `QuickAddSheet` (only shown when ≥ 1 sub-account exists)
- [ ] `SubAccountsScreen` (`/sub-contas`) — list with per-account totals (income, expenses, balance); accessible from Settings
- [ ] `SubAccountCubit` — CRUD + aggregate totals per account
- [ ] Filter chip in `ListaTransacoes` to filter by sub-account
- [ ] Unit tests for per-account aggregation

---

## Sprint 18 — Quality, Reporting & Growth (US-86–89)

> **Goal**: Make the app production-ready: richer reports users actually want to export, stability monitoring via Crashlytics, and a feedback loop to drive future improvements.

### US-86 · Enhanced PDF spending report ⏳
**As a** user, **I want** my exported PDF to contain all the financial data I care about in one place,
**so that** I can share it with an accountant or review it away from the app.

- [ ] PDF cover page: period, user name, generation date, summary table (income / expenses / savings rate / balance)
- [ ] Section 1 — Top expenses: ranked list of categories with amount + % of total + bar chart
- [ ] Section 2 — Full transaction list: sorted by date, grouped by category, with running total per category
- [ ] Section 3 — Goals snapshot: each goal name, target, current amount, progress %, days remaining
- [ ] Section 4 — Month-over-month comparison table: last 3 months side-by-side (income, expenses, savings rate)
- [ ] Section 5 — Investment summary: total invested, current value, overall gain/loss %
- [ ] Page numbers, header with AFC logo text, footer with generation timestamp
- [ ] Unit tests: PDF builder produces correct section count and non-zero byte output

---

### US-87 · In-app user feedback ⏳
**As a** user, **I want** to send feedback about the app directly from within it,
**so that** I can report problems or suggest improvements without leaving the app.

- [ ] `FeedbackEntity` — `uuid`, `userId`, `rating: int` (1–5), `message: String?`, `appVersion`, `platform`, `createdAt`
- [ ] `FeedbackCubit` — `submit(rating, message)` → writes to Firestore `feedback` collection
- [ ] `FeedbackSheet` — star rating row (1–5) + optional text field + submit button; accessible from Settings ("Enviar feedback")
- [ ] NPS-style prompt: after 7 days since first login (stored in `SharedPreferences`), show a one-time bottom sheet "Está gostando do AFC? ⭐"
- [ ] Unit test: submit writes correct document, prompt shows only once

---

### US-88 · Firebase Crashlytics ⏳
**As a** developer, **I want** all unhandled exceptions and fatal crashes automatically reported,
**so that** I can identify and fix stability issues before users stop using the app.

- [ ] Add `firebase_crashlytics` to `pubspec.yaml`
- [ ] In both `main_dev.dart` and `main_prod.dart`: wrap `runApp` with `runZonedGuarded`, set `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
- [ ] In each cubit `catch` block: call `FirebaseCrashlytics.instance.recordError(e, stack, fatal: false)` in addition to `logger.e`
- [ ] Crashlytics disabled in dev flavor (`FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode)`)
- [ ] Test: throw a test exception in dev and verify it appears in the Firebase Crashlytics console

---

### US-89 · Firestore Security Rules ⏳
**As a** developer, **I want** Firestore to enforce that users can only read and write their own documents,
**so that** no user can access another user's financial data even if they call the API directly.

- [ ] Upgrade auth from `signInAnonymously()` to `signInWithCustomToken(clerkToken)` — Cloud Function `getFirebaseToken` exchanges a Clerk session token for a Firebase custom token; `auth.uid` then equals the Clerk user ID
- [ ] `firestore.rules` — `isOwner(userId)` helper checks `request.auth.uid == userId`; applied to all per-user collections (transaction, limit, goal, investment, bill, recurring, template, passive\_income, net\_worth\_snapshot, watchlist, connected\_account, raw\_transaction, categorisation\_rule, pending\_operation, feedback)
- [ ] `category` collection: authenticated read (global), authenticated write (global — categories are shared)
- [ ] Cloud Functions continue to use Admin SDK (bypasses rules)
- [ ] `firebase.json` updated to include `firestore.rules` and `firestore.indexes.json`
- [ ] Deploy rules to both dev and prod projects

---

## Technical Debt & Cross-cutting

These items are not user stories but are necessary for long-term quality.

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Firestore streams (replace `.get()`) | High | ✅ Done | All list screens and dashboard use `.snapshots()` |
| Widget test coverage for key screens | High | ✅ Done | home_screen, login_screen, scaffold_shell (373 total tests) |
| Cloud Functions project setup | High | ✅ Done | Pluggy proxy + webhooks + bill reminders in `functions/src/` |
| Offline persistence (`persistenceEnabled`) | Medium | ✅ Done | Both entry points configure `CACHE_SIZE_UNLIMITED` |
| CI: separate lint / test / build jobs | Low | ✅ Done | 3 jobs: lint → test (coverage artifact) → build (APK artifact) |
| `initializeDateFormatting('pt_BR')` | High | ✅ Done | Called in both entry points before `runApp()` |
| Pluggy sandbox account & API keys | High | ⏳ Pending | Register at pluggy.ai; add API keys to Cloud Functions env |
| Firestore security rules + custom token auth | High | ⏳ Pending | Tracked as US-89 in Sprint 18 |
| Integration tests (golden tests) | Medium | ⏳ Pending | Catch regressions on UI redesign; complex setup required |
| Repository layer abstraction | Low | ⏳ Pending | BLoCs call Firestore directly — major refactor, lower ROI |
| Accessibility audit (semantics, contrast) | Medium | ⏳ Pending | Required for app store compliance; needs manual device testing |

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
| Sprint 11 (US-45–59) | `feat/sprint11-polish` | ✅ Merged |
| Sprint 12 (US-60–69) | `feat/sprint12-financial-independence` | ✅ Merged |
| Sprint 13 (US-70–76) | `fix/sprint13-bugs-state` | ✅ Merged |
| Sprint 14 (US-77–78) | `feat/sprint14-privacy-tooltips` | 🔄 In Progress |
| Sprint 15 (US-79–81) | `feat/sprint15-smart-data` | ✅ Merged |
| Sprint 16 (US-82–83) | `feat/sprint16-offline-first` | 🔄 In Progress |
| Sprint 17 (US-84–85) | `feat/sprint17-benefits-accounts` | ⏳ Planned |
| Sprint 18 (US-86–89) | `feat/sprint18-quality` | ⏳ Planned |
