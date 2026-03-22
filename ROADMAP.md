# AFC — Product Roadmap

## Objective

Build a complete personal finance management app where users can:
- Authenticate securely via Clerk
- Track income and expenses with categories
- Set and monitor monthly spending limits
- View financial trends through charts and summaries

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

- [x] `ScaffoldShell` with `StatefulShellRoute` (GoRouter) wrapping the four main screens
- [x] Active tab highlighted; GoRouter state preserved per tab
- [x] Replace scattered "Ver Todas" buttons with navigation-bar equivalent routes
- [ ] Widget tests for tab switching

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
- [ ] Unit tests for overspend detection logic

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

### US-22 · Receipt photo & auto-fill 🔲
**As a** user, **I want** to photograph a receipt and have the amount and merchant pre-filled,
**so that** logging a transaction takes seconds.

- [ ] Camera / gallery picker in the quick-add modal
- [ ] Image sent to a Cloud Vision (or Gemini) API to extract total amount and merchant name
- [ ] Extracted values pre-fill the form; user reviews and confirms
- [ ] Falls back gracefully if extraction fails

---

## Sprint 7 — Financial Intelligence & Investments

> **Goal**: Give users actionable insights and basic investment tracking, turning AFC into a true financial companion.

### US-23 · Monthly spending report 🔲
**As a** user, **I want** a monthly report showing my spending by category with trends,
**so that** I can understand where my money went and compare months.

- [ ] `ReportScreen` with a selectable month/year picker
- [ ] Pie chart of expenses by category for the selected month
- [ ] Month-over-month comparison bar chart (current vs previous month per category)
- [ ] Summary row: total income, total expenses, savings rate %
- [ ] Export to PDF via `pdf` package

---

### US-24 · Savings goals 🔲
**As a** user, **I want** to create savings goals with a target amount and deadline,
**so that** I can track progress towards things I'm saving for (e.g. travel, emergency fund).

- [ ] `GoalEntity` — `uuid`, `userId`, `name`, `targetAmount`, `currentAmount`, `deadline`, `icon`
- [ ] `GoalCubit` — create, update progress, delete
- [ ] Goals screen with progress bars and days-remaining countdown
- [ ] Manual "add contribution" action that increments `currentAmount`
- [ ] Unit tests for contribution and progress calculation

---

### US-25 · Investment portfolio tracker 🔲
**As a** user, **I want** to register my investments (stocks, fixed income, crypto) and see my total portfolio value,
**so that** I can monitor my net worth alongside my spending.

- [ ] `InvestmentEntity` — `uuid`, `userId`, `name`, `ticker` (optional), `type` (stock/fixed/crypto/other), `quantity`, `avgCost`, `currentPrice`
- [ ] `InvestmentCubit` — CRUD for investments
- [ ] Manual price update or optional integration with a public quotes API (e.g. `brapi.dev` for Brazilian stocks)
- [ ] Portfolio screen: total invested, current value, overall gain/loss %
- [ ] Net-worth card on dashboard (assets − liabilities)
- [ ] Unit tests for gain/loss calculation

---

### US-26 · Bill reminders & push notifications 🔲
**As a** user, **I want** to set reminders for upcoming bills,
**so that** I never miss a due date or incur a late fee.

- [ ] `BillEntity` — `uuid`, `userId`, `name`, `amount`, `dueDay` (day of month), `categoryUuid`
- [ ] `BillCubit` — CRUD for bills
- [ ] Bills list screen with upcoming-this-month highlight
- [ ] Firebase Cloud Messaging integration for push notifications 3 days before due date
- [ ] Cloud Function scheduled trigger for notification dispatch

---

### US-27 · Financial health score 🔲
**As a** user, **I want** a simple score that summarises my financial health,
**so that** I have a single number to track and improve over time.

- [ ] Score (0–100) computed from: savings rate, limit adherence, goal progress, expense variance month-over-month
- [ ] Score card on dashboard with colour coding (red / yellow / green)
- [ ] Breakdown tooltip explaining each contributing factor
- [ ] Historical score trend (last 6 months) as a small sparkline chart
- [ ] Unit tests for scoring formula

---

## Technical Debt & Cross-cutting

These items are not user stories but are necessary for long-term quality.

| Item | Priority | Notes |
|------|----------|-------|
| Firestore streams (replace `.get()`) | High | Prerequisite for US-14 |
| Widget test coverage for all screens | High | Currently zero widget tests post-Sprint 1 |
| Cloud Functions project setup | High | Prerequisite for Sprint 5 (Open Finance proxy + webhooks) |
| Pluggy sandbox account & API keys | High | Prerequisite for US-28–32; register at pluggy.ai |
| Integration tests (golden tests) | Medium | Catch regressions on UI redesign |
| Repository layer abstraction | Medium | Currently BLoCs call Firestore directly — harder to test and swap |
| Offline support (`FirebaseFirestore.instance.settings`) | Medium | Enable persistence so app works without network |
| Accessibility audit (semantics, contrast) | Medium | Required for app store compliance |
| CI: separate lint / test / build jobs | Low | Current workflow runs everything in one step |
| Error boundary widget | Low | Catch unhandled exceptions and show user-friendly screen |

---

## Branch Strategy

| Sprint | Branch |
|--------|--------|
| Sprint 1 (US-05, US-06) | `feat/us-05-06-auth-navigation` ✅ |
| Sprint 1 (US-01, US-02) | `feat/us-01-02-dashboard-data` ✅ |
| Sprint 2 (US-03, US-04) | `feat/us-03-04-limits-charts` ✅ |
| Sprint 3 (US-07–13) | `feat/us-07-13-crud-lists` ✅ |
| Sprint 4 (US-14–18) | `feat/us-14-18-ux-reactivity` ✅ |
| Sprint 5 (US-28–32) | `feat/us-28-32-open-finance` ✅ |
| Sprint 6 (US-19–22) | `feat/us-19-22-smart-transactions` |
| Sprint 7 (US-23–27) | `feat/us-23-27-financial-intelligence` |
