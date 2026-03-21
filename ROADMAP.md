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

### US-01 · Real financial summary on dashboard 🔲
**As a** user, **I want** to see my real total income, total expenses, and balance on the home page,
**so that** I have an accurate snapshot of my finances.

- [ ] `HomeBloc` loads transactions from Firestore for the current user
- [ ] Computes `totalIncome`, `totalExpenses`, `balance`
- [ ] `HomePage` displays real values (replacing hardcoded/empty state)
- [ ] Unit tests for `HomeBloc` summary calculation

---

### US-02 · Real last transactions on dashboard 🔲
**As a** user, **I want** to see my most recent transactions on the home page,
**so that** I can quickly review recent activity without opening the full list.

- [ ] `HomeBloc` loads the last N transactions from Firestore
- [ ] `HomePage` renders the transaction list (replacing empty state)
- [ ] Unit tests for `HomeBloc` transaction fetching

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

### US-07 · Transaction list screen 🔲
- [ ] Screen listing all transactions for the current user
- [ ] Fetches from Firestore via `TransactionCubit`
- [ ] Widget tests

### US-08 · Delete transaction 🔲
- [ ] Delete action on transaction list items
- [ ] Removes document from Firestore
- [ ] Unit tests

### US-09 · Category list screen 🔲
- [ ] Screen listing all categories for the current user
- [ ] Widget tests

### US-10 · Delete category 🔲
- [ ] Delete action on category list
- [ ] Unit tests

### US-11 · Limit list screen 🔲
- [ ] Screen listing all limits for the current user
- [ ] Widget tests

### US-12 · Delete limit 🔲
- [ ] Delete action on limit list
- [ ] Unit tests

### US-13 · Edit transaction / category / limit 🔲
- [ ] Pre-fill existing forms for editing
- [ ] Update Firestore document on save
- [ ] Unit tests

---

## Branch Strategy

| Sprint | Branch |
|--------|--------|
| Sprint 1 (US-05, US-06) | `feat/us-05-06-auth-navigation` ✅ |
| Sprint 1 (US-01, US-02) | `feat/us-01-02-dashboard-data` |
| Sprint 2 (US-03, US-04) | `feat/us-03-04-limits-charts` ✅ |
| Sprint 3 | `feat/us-07-13-crud-lists` |
