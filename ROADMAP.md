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

### US-83 · Pending sync notifications page ✅
**As a** user, **I want** to see a list of operations waiting to sync and be notified when they complete,
**so that** I always know the state of my data and can trust the app.

- [x] `flutter_local_notifications` package; `LocalNotificationService` initialised in both entry points
- [x] When `SyncQueue` has ≥ 1 pending op: schedule a persistent local notification "X operações aguardando sincronização — toque para ver"
- [x] When `SyncQueue.flush()` completes successfully: show "Dados sincronizados com sucesso" notification + clear the persistent one
- [x] When flush fails after 3 retries: show "Falha ao sincronizar X operações — verifique sua conexão" notification
- [x] `PendingOpsScreen` (`/pendencias`) — list of queued operations grouped by collection (e.g. "3 transações", "1 meta"), each showing description + timestamp + retry button
- [x] Badge on Settings icon when pending ops > 0
- [x] Unit tests: notification scheduling on enqueue, clear on flush success, retry increment on flush failure

---

## Sprint 17 — Benefits & Sub-accounts (US-84–85)

> **Goal**: Support the financial reality of both CLT employees (who receive non-cash benefits like VA/VT) and PJ contractors (who manage company expenses separately from personal finances).

### US-84 · Benefits wallet (CLT — VA, VT, VR) ✅
**As a** CLT employee, **I want** to track my Vale Alimentação, Vale Transporte, and Vale Refeição balances separately from my main account,
**so that** I know how much benefit credit I've used and what's left this month.

- [x] `BenefitEntity` — `uuid`, `userId`, `name`, `type` (va / vt / vr / other), `monthlyCredit: double`, `balance: double`, `color: int`
- [x] `BenefitCubit` — CRUD + `deduct(amount)` to record a benefit expense
- [x] `BenefitWalletScreen` (`/carteiras`) — card per benefit showing balance bar, monthly credit, deduct/edit/delete
- [x] `_BenefitsCard` on Dashboard — total benefit balance, hidden when empty
- [x] Unit tests for balance deduction and monthly reset logic (12 tests)

---

### US-85 · Company / sub-account tracking (PJ) ✅
**As a** PJ contractor or anyone managing multiple spending contexts, **I want** to tag expenses to different "accounts" (e.g. Pessoal, Empresa, Cartão PJ),
**so that** I can see separate totals per context without mixing personal and business finances.

- [x] `SubAccountEntity` — `uuid`, `userId`, `name`, `type` (personal / company / benefit), `color: int`, `icon: int`
- [x] `TransactionEntity` extended with optional `subAccountUuid` field (nullable, backwards-compatible)
- [x] Sub-account selector chip row in `CadastrarTransacao` and `QuickAddSheet` (only shown when ≥ 1 sub-account exists)
- [x] `SubAccountsScreen` (`/sub-contas`) — list with per-account totals (income, expenses, balance); accessible from Settings
- [x] `SubAccountCubit` — CRUD + aggregate totals per account (`loadWithTotals`)
- [x] Filter chip in `ListaTransacoes` to filter by sub-account
- [x] Unit tests for per-account aggregation (11 tests)

---

## Sprint 18 — Quality, Reporting & Growth (US-86–89)

> **Goal**: Make the app production-ready: richer reports users actually want to export, stability monitoring via Crashlytics, and a feedback loop to drive future improvements.

### US-86 · Enhanced PDF spending report ✅
**As a** user, **I want** my exported PDF to contain all the financial data I care about in one place,
**so that** I can share it with an accountant or review it away from the app.

- [x] PDF cover page: period, user name, generation date, summary table (income / expenses / savings rate / balance)
- [x] Section 1 — Top expenses: ranked list of categories with amount + % of total
- [x] Section 2 — Full transaction list: sorted by date, grouped by category, with running total per category
- [x] Section 3 — Goals snapshot: each goal name, target, current amount, progress %, days remaining
- [x] Section 4 — Month-over-month comparison table: last 3 months side-by-side (income, expenses, savings rate)
- [x] Section 5 — Investment summary: total cost, current value, overall gain/loss %
- [x] Page numbers, header with AFC logo text, footer with generation timestamp
- [x] `PdfReportBuilder` in domain layer; `relatorio.dart` delegates to it; `userName` read from `AuthBloc`
- [x] Unit tests: PDF builder produces valid PDF magic header, non-zero bytes, `MonthSummary` savings rate

---

### US-87 · In-app user feedback ✅
**As a** user, **I want** to send feedback about the app directly from within it,
**so that** I can report problems or suggest improvements without leaving the app.

- [x] `FeedbackEntity` — `uuid`, `userId`, `rating: int`, `message`, `appVersion`, `platform`, `createdAt`
- [x] `FeedbackCubit` — `submit(rating, message)` → writes to Firestore `feedback` collection
- [x] `FeedbackSheet` — 5-star rating row + optional text field + submit button; accessible from Settings
- [x] NPS-style prompt: after 7 days since first launch (stored in SharedPreferences), shown once via `NpsFeedbackPrompt` in `ScaffoldShell.initState`
- [x] `dismissNpsPrompt()` marks prompt shown without submitting
- [x] 11 unit tests: submit, persist, NPS logic (7-day check, already-shown guard, dismiss)

---

### US-88 · Firebase Crashlytics ✅
**As a** developer, **I want** all unhandled exceptions and fatal crashes automatically reported,
**so that** I can identify and fix stability issues before users stop using the app.

- [x] Added `firebase_crashlytics: ^5.1.0` to `pubspec.yaml`
- [x] `main_prod.dart`: `FlutterError.onError = recordFlutterFatalError`, `PlatformDispatcher.instance.onError` + `runZonedGuarded` wrapping `runApp`
- [x] `main_dev.dart`: `setCrashlyticsCollectionEnabled(false)` — no data sent from dev builds

---

### US-89 · Firestore Security Rules ✅
**As a** developer, **I want** Firestore to enforce that users can only read and write their own documents,
**so that** no user can access another user's financial data even if they call the API directly.

- [x] `getFirebaseToken` Cloud Function — `onCall` that takes `clerkUserId` and returns a custom Firebase Auth token; `auth.uid` equals the Clerk user ID after sign-in
- [x] `AuthBloc.onFirebaseSignIn` upgraded to `Future<void> Function(String clerkUserId)` — calls `getFirebaseToken` then `signInWithCustomToken`; falls back to anonymous sign-in on error
- [x] `my_app.dart` wired to call `_firebaseSignIn(clerkUserId)` on Clerk sign-in
- [x] Firestore security rules (`isOwner` helper) managed directly in Firebase console

---

## Sprint 19 — Search, Export & Insights (US-90–93)

> **Goal**: Make the app feel complete for daily power users — find any transaction instantly, get data out in spreadsheet-friendly form, and surface actionable insights without the user having to dig.

### US-90 · Transaction search & filter ✅
**As a** user, **I want** to search and filter my transactions by keyword, date range, and type,
**so that** I can quickly locate any transaction without scrolling through the full list.

- [x] Search bar at the top of `lista_transacoes.dart` — filters by `title` (case-insensitive substring)
- [x] Date range picker (start / end) — chip row opens a `DateRangePicker` dialog
- [x] Type filter chips: Todas / Receitas / Despesas
- [x] All three filters compose (AND logic) on the already-loaded in-memory list
- [x] Clear all filters button shown when any filter is active
- [x] Unit tests: search, date range, type filter, combined filters, clear

---

### US-91 · CSV transaction export ✅
**As a** user, **I want** to export my transactions to a CSV file,
**so that** I can analyse my data in a spreadsheet without leaving the app.

- [x] `CsvExporter` use-case in `lib/domain/usecase/` — pure Dart, converts `List<TransactionEntity>` + `Map<String,String> categoryNames` to RFC-4180 CSV bytes
- [x] CSV columns: Data, Título, Categoria, Tipo, Valor
- [x] Export button added to the Report screen (next to the PDF button) — uses the same loaded `ReportData.transactions`
- [x] `Share.shareXFiles` via `share_plus` to open system share sheet
- [x] Unit tests: header row correct, data rows correct, special characters escaped

---

### US-92 · Spending insights on dashboard ✅
**As a** user, **I want** to see smart insight cards on my dashboard,
**so that** I can spot unusual spending without manually reviewing reports.

- [x] `InsightEngine` use-case — takes current-month and previous-month transaction lists, returns `List<SpendingInsight>`
- [x] Insight types: `topCategory` (highest spend category), `biggestExpense` (single largest transaction), `monthOverMonthDelta` (% change in total expenses vs prev month), `savingsRateTrend` (improving/worsening)
- [x] `InsightsCard` widget on `home_page.dart` — horizontal `PageView` of insight chips (hidden when no transactions)
- [x] Unit tests: each insight type computed correctly, empty list when no data

---

### US-93 · Limit overspend push alert ✅
**As a** user, **I want** to receive a push notification when I am approaching or have exceeded a spending limit,
**so that** I can adjust my spending before the month ends.

- [x] `LimitAlertService` — checks all limits after every transaction create/update; calls `LocalNotificationService.show` when `spent / limitAmount >= 0.80` (warning) or `>= 1.0` (exceeded)
- [x] Alert fires once per threshold crossing per category per month (tracks last-alerted month in `SharedPreferences`)
- [x] `TransactionCubit.saveTransaction` and `updateTransaction` call `LimitAlertService.checkAfterTransaction(userId)`
- [x] Unit tests: alert fires at 80 %, fires at 100 %, does not fire twice in same month, does not fire below 80 %

---

## Sprint 20 — Fixes, Resilience & Polish (US-94–101)

> **Goal**: Eliminate every crash, infinite-loader, and data-staleness bug reported in user testing. Harden offline writes across all forms, make financial scores react to new data, unify the card design language, and fix all visual polish issues.

### US-94 · Offline write resilience — no more infinite loading ✅
**As a** user, **I want** adding transactions, limits, metas, categories, recurring rules, and importing extracts to complete immediately even without internet,
**so that** the form sheet always closes and I am never left staring at a spinner.

**Root cause**: Firestore `.add()` / `.set()` Futures only resolve once the server ACKs the write. When offline the Future never resolves → the cubit stays in `loading` state forever.

**Fix required in each cubit that uses `emit(loading)` before a Firestore write**:
- `TransactionCubit.saveTransaction` and `updateTransaction`
- `LimitCubit.saveLimit` and `updateLimit`
- `GoalCubit.createGoal` and `updateGoal`
- `CategoryCubit.saveCategory` and `updateCategory`
- `RecurringCubit.saveRecurring`

**Implementation rule** (apply consistently to every write method):
```dart
if (ConnectivityService.instance.isOnline) {
  await _firestore.collection('x').add(data);    // await only when online
} else {
  unawaited(_firestore.collection('x').add(data)); // fire-and-forget; Firestore buffers locally
}
SyncQueue.enqueueIfOffline(...);
emit(State.success(entity));                      // always emit success
```

**Offline confirmation**: when `!ConnectivityService.instance.isOnline` at the time of save, the form sheet must show a `SnackBar` (or equivalent) saying "Salvo localmente — será sincronizado quando a internet voltar" before popping. This confirmation must appear for **all** forms affected above, plus:
- `ImportCubit` / import extrato flow
- `RecurringCubit` save form

**Local list visibility**: because Firestore `.add()` fires without await when offline, the new document enters Firestore's pending-write buffer and **will** appear in subsequent `.snapshots()` and `.get()` calls from local cache — no manual optimistic update needed. Verify this holds for categories (confirm `getCategories()` uses cache).

**Unit tests**: for each affected cubit, add a test that verifies `emit(success)` is reached when the Firestore instance is an offline-mode `FakeFirebaseFirestore`.

---

### US-95 · Health score & FI score reactive to new data ✅
**As a** user, **I want** "Saúde financeira" and "Independência Financeira" cards to reflect my latest transactions and goals automatically,
**so that** I don't need to restart the app to see updated scores.

**Root cause**: `HealthScoreCubit.loadScore` and `FiScoreCubit.load` use one-shot `.get()` calls. They are only triggered once (on initial dashboard load) and never re-run when new transactions, goals, or investments are added.

**Fix**:
- Replace all `.get()` calls in both cubits with `.snapshots()` streams using `emit.forEach` (same pattern as `HomeBloc`).
- `HealthScoreCubit` depends on: `transaction`, `limit`, `goal` collections → subscribe to all three and recompute on any change.
- `FiScoreCubit` depends on: `transaction`, `investment`, `goal` (passive income) collections → same approach.
- If merging three streams is complex, an acceptable alternative is to expose a `reload(userId)` method on each cubit, then call it from `ScaffoldShell` whenever `TransactionCubit`, `GoalCubit`, or `InvestmentCubit` emit a `success` state (via `BlocListener` in `ScaffoldShell`).
- Either approach must result in scores updating within 1–2 seconds of a new transaction/goal/investment being saved.

**Unit tests**: cubit emits an updated score after a second Firestore write (or `reload()` call) in `FakeFirebaseFirestore`.

---

### US-96 · Contas a pagar — paid status & transaction title auto-match ✅
**As a** user, **I want** to mark a bill as paid and optionally tie it to a transaction title keyword so the app auto-detects payment,
**so that** I can track which bills are settled each month without manual data entry.

**Data model changes** (`BillEntity` — requires Freezed regeneration):
```dart
@Default(false) bool isPaid,           // manual paid toggle for current month
@Default('') String transactionTitle,  // keyword to match against transaction titles (e.g. "conta de luz")
```
Both fields are optional with safe defaults so existing Firestore documents parse without migration.

**BillCubit changes**:
- `togglePaid(String billUuid, bool paid)` — updates `isPaid` field in Firestore; enqueues in SyncQueue if offline.
- Auto-match hook: `TransactionCubit.saveTransaction` and `updateTransaction` (after emitting success) should call a `BillAutoMatcher.checkAndMark(userId, transactionTitle)` use-case that:
  1. Loads all bills for `userId` from Firestore (cache-ok).
  2. For each bill where `transactionTitle.isNotEmpty` and `txTitle.toLowerCase().contains(bill.transactionTitle.toLowerCase())`, calls `togglePaid(billUuid, true)`.
  3. Does nothing silently if no matches.
  `BillAutoMatcher` is a pure domain use-case in `lib/domain/usecase/`.

**UI changes** (`lista_contas.dart`):
- Each bill card shows a checkmark icon button (checked = green, unchecked = grey) that calls `togglePaid`.
- If `transactionTitle` is non-empty, show a small "auto" chip/icon on the card to indicate auto-detection is configured.
- `CadastrarConta` form gains an optional text field "Título da transação correspondente" (hint: "ex: conta de luz") — maps to `transactionTitle`.

**Unit tests**: `BillAutoMatcher` — matches case-insensitively, matches partial substring, does not match unrelated title, handles empty `transactionTitle` gracefully.

---

### US-97 · Privacy mode persists across restarts ✅
**As a** user, **I want** the eye icon (hide/show values) state to be remembered even when I close and reopen the app,
**so that** I don't have to re-tap it on every launch.

**Implementation** (`PrivacyCubit`):
- Inject `SharedPreferences` (accept as optional constructor parameter for testability).
- On `PrivacyCubit()` construction, read `SharedPreferences.getBool('privacy_mode') ?? false` as the initial state.
- Override `toggle()` to also call `prefs.setBool('privacy_mode', newValue)`.
- `ScaffoldShell` (which creates `PrivacyCubit`) must use `Future<PrivacyCubit>` or the lazy-getter pattern to avoid reading SharedPreferences synchronously in the widget tree — use `Future<void>.microtask` + `setState` or load in `initState`.

**Simpler alternative** (preferred if the async init adds complexity): make `PrivacyCubit` synchronous by having its `register()` static method accept a pre-loaded `bool` initial value, and load that value in `main_dev.dart` / `main_prod.dart` before `runApp`.

**Unit tests**: after `toggle()`, the stored SharedPreferences key is updated; a new `PrivacyCubit` instance reads the persisted value as its initial state.

---

### US-98 · Firestore composite index fix for Patrimônio Líquido ✅
**As a** user, **I want** the Patrimônio Líquido card to load without errors,
**so that** my net worth is always visible on the dashboard.

**Root cause**: the query that backs the net worth calculation performs a compound `where` + `orderBy` that Firestore requires a composite index for. Until the index is deployed, the query throws `cloud_firestore/failed-precondition`.

**Fix options** (choose the simpler one):
- **Option A — Restructure query**: remove the server-side `orderBy` or the compound `where` clause that triggers the index requirement; sort or filter in memory after fetching.
- **Option B — Add index**: create the required composite index via `firestore.indexes.json` (checked into the repo) so it is deployed automatically with `firebase deploy --only firestore:indexes`.

Identify the exact query in `_NetWorthCardState` (or wherever the query lives), reproduce the `failed-precondition` error, and apply Option A (preferred — no infra change needed) or Option B.

**Acceptance**: the net worth card loads on first open in both dev and prod with no console errors.

---

### US-99 · Layout & UX micro-fixes ✅
**As a** user, **I want** text that fits its container, a clear path to add investments from the empty portfolio state, reliable pull-to-refresh, correct decimal formatting, a pre-selected current month in limit creation, and the offline banner fully visible on notched devices,
**so that** the app looks and behaves correctly on all devices.

Fix each item independently — they can be committed together in one PR:

**a) Text overflow — "Independência financeira" and other headers**
- Use `Flexible` or `Expanded` around any `Text` widgets in `Row` children that can overflow.
- Apply `overflow: TextOverflow.ellipsis` (or `FittedBox(fit: BoxFit.scaleDown)`) to labels that are long and adjacent to other content.
- Audit `home_page.dart` card headers and `scaffold_shell.dart` navigation labels for the same pattern.

**b) Portfolio empty state — no add button**
- In `lista_investimentos.dart`, when the empty-state widget is shown ("Nenhum investimento cadastrado"), also render an `AppButton` (or `FloatingActionButton` if the screen has one) labelled "Adicionar investimento" that navigates to the add-investment form.
- This matches the UX of every other empty-state screen in the app.

**c) Pull-to-refresh animation completes instantly**
- The `RefreshIndicator.onRefresh` callback must return a `Future` that **does not complete** until the stream emits new data. Currently it fires `unawaited(cubit.loadTransactions(...))` and returns immediately.
- Fix: use a `Completer<void>` — resolve it inside the `BlocListener` when `listed` state is received, or replace with a `Future.delayed` minimum duration (500 ms) combined with the actual load call.
- Apply to all screens that have `RefreshIndicator`: `lista_transacoes.dart`, and any others.

**d) Decimal format in Planejador de Metas chart**
- In the "evolução do patrimônio" line chart (investment goal planner screen), all monetary Y-axis labels and tooltip values must use exactly 2 decimal places — either `NumberFormat.currency(decimalDigits: 2)` or `toStringAsFixed(2)`. Remove any raw `double.toString()` calls on monetary values.

**e) Pre-selected current month in CadastrarLimites**
- When `initialLimit` is `null` (creating new), `_monthValue` must be initialised to the current month's `CalendarEntity` name:
  ```dart
  _monthValue = CalendarEntity.values[DateTime.now().month - 1].name;
  ```
- When editing an existing limit, keep the existing behaviour (use `limit.month`).

**f) Offline banner cut by device camera notch**
- In `offline_banner.dart`, the `_BannerContent` sits at the very top of the `Column`. Wrap the `_BannerContent` in a `SafeArea(bottom: false)` so the banner content begins below the status-bar/notch area.

---

### US-100 · Skeleton sizing matches real content ✅
**As a** user, **I want** loading skeletons in Transações, Renda Passiva, and Limites to match the actual size and shape of the list items they represent,
**so that** the layout does not jump when data loads.

**Reference**: the Metas page skeleton already does this correctly — each skeleton card has the same height/padding as a real goal card.

**Fix pattern for each affected screen**:
- Measure (or read from code) the exact height of one real list item (including padding).
- In the corresponding `SkeletonList` (or inline skeleton widget), set the same height and internal padding on each shimmer placeholder.
- Number of skeleton rows should match a realistic list size (3–5 rows is typical).

**Screens to update**:
- `lista_transacoes.dart` — skeleton row height must match `_TransacaoItem` card height (approx 68 dp).
- `passive_income_screen.dart` — skeleton must match the passive income card height.
- `lista_limites.dart` — skeleton must match the limit progress card height.

If a shared `SkeletonList` widget is used, add a `itemHeight` parameter so each screen passes its own value.

---

### US-101 · Unified card design — Renda Passiva style ✅
**As a** user, **I want** all list cards (transactions, limits, goals, investments, bills, templates, recurring) to follow a consistent design with a hidden delete action,
**so that** the app feels polished and the delete option is not visually noisy.

**Reference design** (Renda Passiva card): icon on the left, title + subtitle in the middle, amount on the right, action icons (edit / delete) revealed only on long-press or via a trailing `...` menu — **not** permanently visible.

**Changes**:
- Audit every card widget across all list screens.
- Cards that currently show an always-visible delete `IconButton` (e.g. `_TransacaoItem`, bill cards, template cards) must hide it.
- Replace with one of:
  - **Long-press reveal**: `GestureDetector(onLongPress: ...)` that slides in action buttons (edit, delete) via `AnimatedSize` or an inline `Row` toggle.
  - **Trailing `...` menu** (simpler): an `AppIconButton(Icons.more_vert)` that opens a small `PopupMenuButton` with "Editar" and "Excluir" options.
- The trailing `...` (more_vert) approach is preferred for simplicity and consistency.
- Apply the same icon-left / content-center / actions-right layout across all cards.
- Keep the existing tap-to-edit behaviour where applicable.

**Do not change** the Metas card (goal card) if it already follows the reference design.

---

## Sprint 21 — Financial Trajectory (US-102–104)

> **Goal**: Transform the FIRE Calculator, Compound Interest Simulator, and Investment Goal Planner from static what-if tools into living projections that overlay each user's **actual** financial trajectory. Users see where they are today on the path to their long-term goals — making the app indispensable for multi-year financial planning.

### US-102 · FIRE Calculator — real data trajectory ✅
**As a** user, **I want** the FIRE Calculator to show my actual savings rate and net worth as a starting point, and plot a projected path to financial independence over up to 10 years,
**so that** I can see whether my current spending and saving habits will get me to FIRE on time.

**Data sources** (read from Firestore; use cache when offline):
- Last 3-month average monthly income → from `transaction` collection (type = income).
- Last 3-month average monthly expenses → from `transaction` collection (type = expense).
- Current investable net worth → sum of `investment` collection (`quantity × currentPrice`).

**UI additions** to `fire_calculator_screen.dart` (or equivalent):
- A "Sua posição atual" section at the top showing: current avg monthly income, avg monthly expenses, derived savings rate (%), current portfolio value — all editable by the user if they want to override the computed values.
- A 10-year line chart with two series:
  - **Projeção** (dashed line): the theoretical compounding growth using the user-entered FIRE parameters (existing simulator logic).
  - **Trajetória real** (solid coloured line): a series built from actual monthly net worth snapshots (pulled from the `net_worth_snapshot` collection introduced in Sprint 12 / US-64, or computed on-the-fly from Firestore transaction history).
- A vertical marker on the X-axis (today) separating historical data (left, solid) from future projection (right, dashed).
- If fewer than 2 real data points exist, hide the "Trajetória real" series and show a hint "Adicione transações e investimentos para ver sua trajetória real".

**Technical note**: chart library is `fl_chart` (`LineChart` with two `LineChartBarData` series — existing pattern in `net_worth_evolution_screen.dart`).

---

### US-103 · Compound Interest Simulator — actual savings trajectory ✅
**As a** user, **I want** the Compound Interest Simulator to show how my real monthly savings compare to the simulated contribution,
**so that** I can immediately see whether I am on track with the plan I modelled.

**Data source**: last 3-month average monthly net savings (income − expenses) from the `transaction` collection.

**UI additions** to `compound_interest_screen.dart` (or equivalent):
- A read-only "Poupança real atual" badge above the chart showing the computed average monthly net savings, with a sub-label "Baseado nos últimos 3 meses".
- On the existing bar/line chart, overlay a horizontal reference line at Y = `current net savings value` labelled "Você hoje". This lets the user visually compare their real saving capacity against the simulated monthly contribution.
- A short text callout below the chart: "Com a sua poupança atual de R$ X, você atingiria R$ Y em Z anos" (using the simulator's own formula with `X` substituted as the contribution). This replaces one of the static placeholder texts if present.
- If no transaction data exists, hide the overlay and show a hint.

---

### US-104 · Investment Goal Planner — actual vs projected progress ✅
**As a** user, **I want** the Investment Goal Planner to display both my projected wealth growth and my actual net worth history on the same chart,
**so that** I can see at a glance whether my investment contributions are keeping pace with my long-term plan.

**Data source**: monthly net worth snapshots from the `net_worth_snapshot` Firestore collection (written by the net-worth evolution screen — US-64). Each snapshot: `{ userId, year, month, totalAmount }`.

**UI additions** to `investment_goal_screen.dart` (or equivalent):
- On the existing "evolução do patrimônio" `LineChart`, add a second `LineChartBarData` series for actual net worth history:
  - X = months elapsed since plan start date (or since first snapshot, whichever is earlier).
  - Y = `totalAmount` from each snapshot.
  - Style: solid line, distinct colour from the projection line (e.g. `AppColors.income` green).
- A legend below the chart distinguishing "Projeção" and "Patrimônio real".
- A vertical "hoje" marker (same pattern as US-102).
- Decimal formatting fix (from US-99d) must also be applied here: all chart values use `NumberFormat.currency(decimalDigits: 2)`.
- If fewer than 1 snapshot exists, show the chart with projection only and a hint to add investments.

---

## Sprint 22 — Social Sharing & Organic Growth (US-105–108)

> **Goal**: Turn AFC into a word-of-mouth machine. Every user who hits a financial milestone — closes a month with a positive savings rate, reaches a goal, crosses a FI milestone, or sees their portfolio grow — gets a one-tap way to share a beautiful, branded card on WhatsApp, Instagram Stories, or any social platform. The cards carry AFC's visual identity so each share is organic marketing: real data, real design, zero ad spend.

**Technical foundation** (shared across all US stories):
- Flutter's `RepaintBoundary` + `RenderRepaintBoundary.toImage(pixelRatio: 3.0)` to rasterise any widget into a `ui.Image`.
- `image` package (`dart:ui` → PNG bytes) + `path_provider` to write a temporary file.
- `share_plus` (already in `pubspec.yaml`) → `Share.shareXFiles([XFile(path)])` opens the native share sheet.
- All cards render at **1080 × 1080 px** (square, optimal for Instagram / WhatsApp) or **1080 × 1920 px** (stories format where noted).
- A `ShareCardWrapper` widget handles the fixed dimensions, background gradient, AFC logo watermark, and "Gerado com AFC · afc.app" attribution line at the bottom — ensuring every card carries the brand without each US having to repeat it.
- Cards are rendered off-screen inside an `Offstage` widget, captured, then shared — the user never sees the render step.

---

### US-105 · Monthly Financial Snapshot Card ⏳
**As a** user, **I want** to share a beautiful branded card with my monthly financial summary,
**so that** I can celebrate a good month with friends or hold myself publicly accountable.

**Trigger**: "Compartilhar resumo" button added to the `RelatorioScreen` (report screen), visible after the report data loads. Also accessible from the dashboard's "Resumo do mês" card via a share icon in the top-right corner.

**Card content** (1080 × 1080):
- **Header**: month name + year (e.g. "Março 2026"), AFC logo top-right.
- **Hero row**: three stat bubbles — Receitas (green), Despesas (red), Saldo (primary or red depending on sign).
- **Taxa de poupança**: large percentage with colour-coded label ("Excelente ≥ 30%", "Boa 15–30%", "Atenção < 15%").
- **Top 3 categorias**: horizontal bar chart (mini) showing the three highest-spend categories with amounts.
- **Saúde financeira**: health score gauge (semi-circle arc) with the numeric score.
- **Footer**: "Gerado com AFC · afc.app" in small muted text.
- Background: dark card surface (`AppColors.surface`) with subtle emerald gradient in the top-left corner.

**Implementation**:
- `MonthlySnapshotCard` widget in `lib/presentation/widgets/share_cards/monthly_snapshot_card.dart`.
- `ShareCardService.captureAndShare(GlobalKey key, String filename)` utility in `lib/utils/share_card_service.dart` — wraps the `RepaintBoundary` capture + `share_plus` call; reused by all four US stories.
- `RelatorioScreen` wraps the card in `Offstage(child: RepaintBoundary(key: _shareKey, child: MonthlySnapshotCard(...)))`.
- Privacy mode: if `PrivacyCubit` is `true` (hidden), show "••••" placeholders for all monetary values on the card.

**Unit tests**: `MonthlySnapshotCard` renders without overflow at 1080×1080; `ShareCardService` returns a non-empty byte list from a `RepaintBoundary` in a widget test.

---

### US-106 · Goal Achievement Celebration Card ⏳
**As a** user, **I want** to share a celebratory card when I complete a savings goal,
**so that** I can celebrate the milestone and inspire others to use AFC.

**Trigger**: when `currentAmount >= targetAmount` on a `GoalEntity`, the goal card in `lista_metas.dart` shows a "🎉 Meta alcançada!" banner with a "Compartilhar conquista" button. Also appears as a one-time full-screen modal the first time the user opens the goals list after a goal reaches 100% (tracked via SharedPreferences key `goal_celebrated_{uuid}`).

**Card content** (1080 × 1080):
- **Background**: rich emerald gradient (top-left `#10B981` → bottom-right `#065F46`).
- **Central icon**: the goal's `icon` rendered large (64 px) inside a white circle.
- **Goal name**: large bold white text.
- **Amount**: "R$ X,XX alcançados" in white.
- **Duration**: "em X meses" — computed from `GoalEntity.createdAt` → `deadline` (or today if reached early).
- **Confetti-style decoration**: static geometric shapes (diamonds, circles) scattered in the background using `CustomPaint` — no animation needed since this is a static image capture.
- **Footer**: AFC logo + "Realize seus objetivos financeiros · afc.app".

**Implementation**:
- `GoalAchievementCard` widget in `lib/presentation/widgets/share_cards/goal_achievement_card.dart`.
- `GoalEntity` requires a `createdAt: String` field (ISO-8601) — add with `@Default('')` (Freezed regeneration required).
- `lista_metas.dart`: detect `goal.currentAmount >= goal.targetAmount` in the `listed` state; show banner and share button per qualifying card.

**Unit tests**: `GoalAchievementCard` renders correctly for a completed goal; duration label shows "em 6 meses" for a goal created 6 months ago.

---

### US-107 · FI Milestone Share Card ⏳
**As a** user, **I want** a shareable card when I cross a Financial Independence milestone (10 / 25 / 50 / 75 / 100%),
**so that** I can mark the progress on my journey to financial independence and motivate others.

**Trigger**: `FiScoreCubit` detects a milestone crossing (new score ≥ threshold AND previous score < threshold). Emits a `FiScoreState.milestoneReached(int milestone)` variant. `ScaffoldShell` (or `home_page.dart`) listens and shows a bottom sheet with the card preview + share button. Milestone shown only once per threshold (tracked in SharedPreferences `fi_milestone_shared_{milestone}`).

**Card content** (1080 × 1920 — Stories format):
- **Top third**: large milestone percentage (e.g. "50%") in bold, sub-label "Independência Financeira".
- **Middle**: horizontal progress bar filled to the milestone %, with milestone labels (10 / 25 / 50 / 75 / 100) below.
- **Stats row**: "Renda passiva: R$ X / mês" and "Despesas: R$ Y / mês".
- **Milestone label**: contextual message per level:
  - 10% → "Primeiros passos 🌱"
  - 25% → "No caminho certo 🚀"
  - 50% → "Metade do caminho 🏆"
  - 75% → "Quase lá! 💎"
  - 100% → "Financeiramente independente! 🎉"
- **Background**: dark surface with a radial glow in `AppColors.primary` centred on the percentage.
- **Footer**: AFC logo + "Calcule sua independência financeira · afc.app".

**Implementation**:
- Add `milestoneReached` variant to `FiScoreState` (Freezed regeneration required).
- `FiScoreCubit._tryRecompute()`: after computing the new score, compare against the 5 milestone thresholds and emit `milestoneReached` if a new one is crossed.
- `FiMilestoneCard` widget in `lib/presentation/widgets/share_cards/fi_milestone_card.dart`.

**Unit tests**: `FiScoreCubit` emits `milestoneReached(50)` when score crosses from 48 → 52; does not re-emit if score stays above 50.

---

### US-108 · Portfolio Performance Share Card ⏳
**As a** user, **I want** to share a snapshot of my investment portfolio's performance,
**so that** I can show my gains (or losses) and discuss investing with friends.

**Trigger**: "Compartilhar" icon button in the top-right of `PortfolioDashboardScreen`, visible whenever the portfolio has at least 1 investment.

**Card content** (1080 × 1080):
- **Header**: "Portfólio — [Month Year]", AFC logo top-right.
- **Hero**: total current value (large), total gain/loss in R$ and % (green if positive, red if negative).
- **Allocation donut**: compact `fl_chart` `PieChart` (120 × 120 px) with colour-coded slices by asset type (Ações / Renda Fixa / Cripto / Outros) — same colours as `PortfolioDashboardScreen`.
- **Top 3 positions**: ranked list showing ticker/name, current value, ROI % — with green/red colouring.
- **Best performer chip**: ticker + ROI% highlighted in a green pill.
- **Footer**: "Acompanhe seus investimentos · afc.app" + AFC logo.
- Background: dark surface with a subtle blue-teal gradient (differentiating investment context from the green-dominant monthly card).

**Implementation**:
- `PortfolioShareCard` widget in `lib/presentation/widgets/share_cards/portfolio_share_card.dart`.
- `PortfolioDashboardScreen` holds a `GlobalKey _shareKey`; wraps the off-screen card in `Offstage` + `RepaintBoundary`; share button calls `ShareCardService.captureAndShare(_shareKey, 'portfolio_${DateTime.now().millisecondsSinceEpoch}.png')`.
- Reuses `PortfolioSummary` and `List<PortfolioPosition>` already computed by `PortfolioCalculator`.

**Unit tests**: `PortfolioShareCard` renders without overflow for a portfolio with 5 positions; gain is formatted in green when positive.

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
| Sprint 17 (US-84–85) | `feat/sprint17-benefits-accounts` | ✅ Done |
| Sprint 18 (US-86–89) | `feat/sprint18-quality-reporting` | ✅ Done |
| Sprint 19 (US-90–93) | `feat/sprint19-search-export-insights` | ✅ Done |
| Sprint 20 (US-94–101) | `fix/sprint20-resilience-polish` | ✅ Merged |
| Sprint 21 (US-102–104) | `feat/sprint21-trajectory` | ✅ Done |
| Sprint 22 (US-105–108) | `feat/sprint22-social-sharing` | ⏳ Planned |
