# CLAUDE.md — AFC (Personal Finance App)

## Project Overview

**AFC** is a complete personal finance management mobile application built with Flutter. It allows users to:
- Authenticate securely via Clerk OAuth
- Track income and expenses with custom categories
- Set and monitor monthly spending limits per category with overspend alerts
- View real-time financial stats and trends via charts
- Import bank statements (OFX/CSV) with bank-specific parsers (Nubank)
- Connect bank accounts via Open Finance (Pluggy) for automatic transaction sync
- Review and confirm imported transactions with auto-categorisation
- Log recurring transactions (daily/weekly/monthly) automatically
- Use quick-fill templates and receipt OCR (Gemini 2.0 Flash) for fast entry
- Generate monthly spending reports with PDF export
- Track savings goals with progress bars and deadlines
- Monitor an investment portfolio (stocks, fixed income, crypto)
- Receive bill reminders via FCM push notifications
- View a financial health score (0–100) with sub-factor breakdown and trend sparkline
- Sync data in real-time with Firebase Firestore (offline-capable)

**Platforms**: Android, iOS, macOS, Web
**Version**: v1.0.0+1
**Dart SDK**: >=3.9.0, **Flutter**: 3.41.5 (CI)

---

## Architecture

**Pattern**: Clean Architecture + BLoC/Cubit pattern

```
lib/
├── config/routes/         # GoRouter navigation (31 routes)
├── domain/
│   ├── entity/            # Immutable data models (Freezed, 16 entities)
│   └── usecase/           # Pure business logic (parsers, health score)
├── presentation/
│   ├── blocs/             # 1 BLoC (Auth) + 1 BLoC (Home) + 14 Cubits
│   └── screens/           # 25 UI screens
└── utils/
    ├── exception/         # Custom exceptions
    ├── flavors.dart       # Flavor detection (dev/prod)
    ├── fcm_service.dart   # FCM stub / architecture
    ├── logger.dart        # Flavored logger
    └── my_app.dart        # Root widget
```

**Layers**:
1. **Presentation** — Screens + BLoCs/Cubits (Shadcn Flutter UI)
2. **Domain** — Entities + use cases (pure Dart, no Flutter dependencies)
3. **Config** — GoRouter routing, flavor configuration
4. **Utils** — Logging, exception definitions, flavor detection, FCM service

**Key architectural decisions**:
- Cubits/BLoCs access Firestore directly (no repository layer)
- All list screens use Firestore `.snapshots()` streams (real-time updates)
- Provider injection happens at the route level via `BlocProvider` in `router.dart`
- `GetIt` is the DI service locator (for shared singletons)
- Offline persistence enabled: `persistenceEnabled: true` + `CACHE_SIZE_UNLIMITED`

---

## Build Variants (Flavors)

Two environments with separate entry points and Firebase projects:

| Variant | Entry Point | Firebase Project |
|---------|------------|-----------------|
| Development | `main_dev.dart` | `afc-mobile-9f0dc` |
| Production | `main_prod.dart` | `afc-mobile-prod` |

**Running**:
```bash
flutter run --target lib/main_dev.dart    # Dev
flutter run --target lib/main_prod.dart   # Prod
```

Firebase configs: `firebase_options_dev.dart`, `firebase_options_prod.dart`
App icons: `flutter_launcher_icons-dev.yaml`, `flutter_launcher_icons-prod.yaml`

---

## State Management

**BLoC** (event-based, for complex auth/home logic):
- `AuthBloc` — authentication state (Clerk OAuth)
- `HomeBloc` — dashboard stats + last transactions

**Cubit** (14 cubits for simpler state):
- `TransactionCubit` — CRUD for transactions
- `CategoryCubit` — CRUD for categories
- `LimitCubit` — spending limits + progress tracking + overspend detection
- `GoalCubit` — savings goals (create, contribute, delete, update)
- `InvestmentCubit` — portfolio tracker (CRUD + price updates)
- `BillCubit` — bill reminders (CRUD)
- `RecurringCubit` — recurring rules (create, pause, resume, delete, materialise)
- `TemplateCubit` — quick-fill transaction templates
- `ImportCubit` — OFX/CSV file import + review flow
- `ReviewQueueCubit` — confirm/ignore raw imported transactions
- `OpenFinanceCubit` — Pluggy connected accounts
- `HealthScoreCubit` — financial health score (0–100) + 6-month sparkline
- `ReportCubit` — monthly spending report (income/expenses/savings rate/category breakdown)
- `ReceiptOcrCubit` — Gemini 2.0 Flash receipt photo extraction

**State pattern** (Freezed union types):
```dart
@freezed
sealed class TransactionState with _$TransactionState {
  const factory TransactionState.initial(List<CategoryEntity> categories) = _Initial;
  const factory TransactionState.loading() = _Loading;
  const factory TransactionState.success(TransactionEntity entity) = _Success;
  const factory TransactionState.error(String message) = _Error;
  const factory TransactionState.listed(List<TransactionEntity> transactions) = _Listed;
}
```

**Consuming state**:
```dart
state.when(
  initial: (categories) => ...,
  loading: () => CircularProgressIndicator(),
  error: (msg) => ErrorWidget(msg),
  success: (entity) => SuccessWidget(entity),
  listed: (transactions) => TransactionList(transactions),
)
```

---

## Data Models (Entities)

All entities are **immutable Freezed classes** with JSON serialization (`.fromJson()`, `.toJson()`):

**Core financial entities:**
- `CategoryEntity` — `uuid`, `name`, `iconType: int`
- `TransactionEntity` — `uuid`, `amount: double`, `categoryUUid`, `typeUuid`, `data: DateTime`, `title`, `userId`
- `LimitEntity` — `uuid`, `categoryUUid`, `month: String`, `limitAmount: double`, `userId`
- `GoalEntity` — `uuid`, `userId`, `name`, `targetAmount: double`, `currentAmount: double`, `deadline: DateTime`, `icon: int`
- `InvestmentEntity` — `uuid`, `userId`, `name`, `type: String`, `quantity: double`, `avgCost: double`, `currentPrice: double`, `ticker?: String`
- `BillEntity` — `uuid`, `userId`, `name`, `amount: double`, `dueDay: int`, `categoryUuid`
- `RecurringEntity` — `uuid`, `userId`, `templateTransaction: TransactionEntity`, `frequency: String`, `nextDue: DateTime`, `active: bool`
- `TemplateEntity` — `uuid`, `userId`, `title`, `amount: double`, `categoryUUid`, `typeUuid`

**Import/integration entities:**
- `ImportCandidateEntity` — parsed CSV/OFX row awaiting review
- `RawTransactionEntity` — webhook-imported Pluggy transaction (pending review)
- `ConnectedAccountEntity` — Pluggy bank connection (`pluggyItemId`, `status`, `lastSyncedAt`)

**Classifier enums:**
- `TypeEntity` — `income`, `expense`
- `CalendarEntity` — 12-month enum (january…december)
- `FrequencyEntity` — `daily`, `weekly`, `monthly`

**Computed data classes (non-Freezed):**
- `StatsEntity` — aggregated income/expense per month (for charts)
- `LimitProgressItem` — `categoryName`, `iconType`, `spent`, `limitAmount` (for progress bars)
- `LimitListItem` — `limit: LimitEntity`, `categoryName` (for limit management list)
- `HealthScoreData` — 4 sub-scores + total + 6-month history
- `ReportData` — income, expenses, savings rate, category breakdown per month

**After any model change**, regenerate with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Database (Firebase Firestore)

**Collections:**
| Collection | Key Filter | Purpose |
|-----------|-----------|---------|
| `category` | `uuid` | User categories |
| `transaction` | `userId` | Income/expense records |
| `limit` | `userId` | Monthly spending limits |
| `recurring` | `userId` | Recurring transaction rules |
| `template` | `userId` | Quick-fill templates |
| `goal` | `userId` | Savings goals |
| `investment` | `userId` | Portfolio positions |
| `bill` | `userId` | Bill reminders |
| `connected_account` | `userId` | Pluggy bank connections |
| `raw_transaction` | `userId` | Webhook-imported pending transactions |
| `categorisation_rule` | `userId` | Learned auto-categorisation rules |

**Offline support**: Both `main_dev.dart` and `main_prod.dart` configure:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Access pattern** (no repository layer):
```dart
// Real-time stream (preferred for lists)
_firestore.collection('transaction')
    .where('userId', isEqualTo: userId)
    .snapshots()
    .listen((snap) => emit(TransactionState.listed(snap.docs.map(...))));

// One-shot read
final snap = await _firestore.collection('category').get();
```

---

## Authentication

Clerk OAuth via `clerk_flutter` package. Configuration:
- `CLERK_PUBLISHABLE_KEY` in `.env` file (git-ignored), passed as `--dart-define` in CI
- Firebase Auth is also initialised (for Firestore security rules)

**Auth flow**:
1. App starts → `HomeScreen` (splash spinner)
2. `AuthBloc` evaluates Clerk session:
   - `signedIn` → `/home` (dashboard)
   - `signedOut` → `/login` (Clerk UI)
3. On sign-in, `ScaffoldShell.initState` triggers `RecurringCubit.checkAndMaterialise`

---

## Navigation

GoRouter (`go_router`) with 31 routes. Routes defined in `lib/config/routes/router.dart`.

**Bottom navigation** (`ScaffoldShell`):
- `StatefulShellRoute.indexedStack` with **4 branches** (reduced from 6 in Sprint 11)
- Tab 0: Dashboard (`/home`) — HomeBloc + LimitCubit + HealthScoreCubit
- Tab 1: Transactions (`/lista-transacoes`) — TransactionCubit
- Tab 2: Limits (`/lista-limites`) — LimitCubit
- Tab 3: Goals (`/lista-metas`) — GoalCubit
- Categories → accessible via Settings screen ("Gerenciar categorias" tile → `/lista-categorias`)
- Recurring → accessible via Transactions header icon button (`→ /lista-recorrentes`)

**Modal/form routes** (pushed over tabs):
```
/cadastro-transacao, /editar-transacao
/cadastro-categoria, /editar-categoria
/cadastro-limite,    /editar-limite
/cadastro-meta,      /editar-meta
/cadastro-recorrente
/cadastro-investimento, /editar-investimento, /lista-investimentos
/cadastro-conta,        /editar-conta,        /lista-contas
/lista-categorias,      /lista-recorrentes     (now push routes, not shell branches)
/importar-extrato, /revisar-transacoes
/relatorio
/contas-conectadas, /connect-bank
/seed   (dev only — test data seeder)
```

**Primary UX path for create/edit forms**: `showFormSheet<T>()` — draggable bottom sheet.
Router entries are kept for deep linking but the primary path uses the bottom sheet.

```dart
// Showing a form as a bottom sheet with its own cubit
await showFormSheet<void>(
  context,
  builder: (ctx) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => LimitCubit()..getCategories()),
    ],
    child: const CadastrarLimites(),
  ),
);
```

BLoC providers are also injected at the route level (for deep links):
```dart
GoRoute(
  path: '/cadastro-transacao',
  builder: (context, state) => BlocProvider<TransactionCubit>(
    create: (_) => TransactionCubit()..getCategories(),
    child: const CadastrarTransacao(),
  ),
)
```

---

## Screens (25 total)

| Screen | File | Bottom Tab |
|--------|------|-----------|
| Splash/Entry | `home_screen.dart` | — |
| Login | `login_screen.dart` | — |
| Dashboard | `home_page.dart` | 0 (Início) |
| Transaction List | `lista_transacoes.dart` | 1 (Transações) |
| Limit List | `lista_limites.dart` | 2 (Limites) |
| Goals List | `lista_metas.dart` | 3 (Metas) |
| Category List | `lista_categorias.dart` | push route (via Settings) |
| Recurring List | `lista_recorrentes.dart` | push route (via Transactions header) |
| Add/Edit Transaction | `cadastrar_transacao.dart` | — |
| Add/Edit Category | `cadastrar_categoria.dart` | — |
| Add/Edit Limit | `cadastrar_limites.dart` | — |
| Add/Edit Goal | `cadastrar_meta.dart` | — |
| Add/Edit Recurring | `cadastrar_recorrente.dart` | — |
| Investment List | `lista_investimentos.dart` | — |
| Add/Edit Investment | `cadastrar_investimento.dart` | — |
| Bill List | `lista_contas.dart` | — |
| Add/Edit Bill | `cadastrar_conta.dart` | — |
| Statement Import | `importar_extrato.dart` | — |
| Report | `relatorio.dart` | — |
| Connected Accounts | `connected_accounts_screen.dart` | — |
| Connect Bank | `connect_bank_screen.dart` | — |
| Review Queue | `review_queue_screen.dart` | — |
| Scaffold Shell | `scaffold_shell.dart` | Wrapper |
| Quick-Add Sheet | `quick_add_sheet.dart` | Modal |
| Dev Seed | `dev_seed_screen.dart` | — |

---

## UI Framework

- **Design system**: Custom Material 3 system — import via the barrel file:
  ```dart
  import '../widgets/design_system.dart';
  ```
  Exports: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppButton`/`PrimaryButton`/`SecondaryButton`,
  `AppCard`, `AppDialog`/`showAppDialog`/`showInputDialog`, `AppIconButton`, `AppTextField`,
  `showFormSheet`, `Gap`
- **Charts**: `fl_chart` (PieChart, BarChart, LineChart, SparkLine)
- **Icons**: `cupertino_icons` + Material `Icons`
- **PDF**: `pdf` + `printing` packages for report export

---

## Code Style & Conventions

- **Files**: `snake_case.dart` (Portuguese names for screens, e.g. `lista_transacoes.dart`)
- **Classes/Types**: `PascalCase`
- **Variables/methods**: `camelCase`
- **Private members**: `_leadingUnderscore`
- Explicit return types everywhere (strict linting — `always_declare_return_types`)
- Use `sealed class` + Freezed for all state/entity types
- Pattern matching via `.when()` / `.whenOrNull()`
- `always_put_control_body_on_new_line` — no single-line `if` bodies
- Portuguese field names in UI strings; English in code identifiers

**Linting**: `analysis_options.yaml` with 134+ rules + `bloc_lint` plugin. Generated files (`*.g.dart`, `*.freezed.dart`) are excluded.

---

## Key Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | BLoC/Cubit state management |
| `freezed_annotation` | ^3.1.0 | Immutable code generation |
| `go_router` | ^17.1.0 | Declarative navigation |
| `shadcn_flutter` | ^0.0.44 | UI component library |
| `cloud_firestore` | ^6.0.2 | NoSQL database (real-time streams) |
| `firebase_auth` | ^6.0.2 | Firebase authentication |
| `firebase_core` | ^4.1.0 | Firebase initialisation |
| `clerk_flutter` | ^0.0.12-beta | Clerk OAuth |
| `fl_chart` | ^1.1.1 | Charts/graphs |
| `google_generative_ai` | ^0.4.6 | Gemini 2.0 Flash (receipt OCR) |
| `flutter_pluggy_connect` | ^3.0.1 | Open Finance / Pluggy Connect Widget |
| `webview_flutter` | ^4.10.0 | WebView for Pluggy Connect |
| `image_picker` | ^1.1.2 | Camera / gallery picker |
| `file_picker` | ^9.0.0 | File import (OFX/CSV) |
| `pdf` | ^3.11.1 | PDF generation |
| `printing` | ^5.13.1 | PDF export / share |
| `result_dart` | ^2.1.1 | Result type for error handling |
| `intl` | ^0.20.2 | Date formatting + i18n |
| `uuid` | ^4.5.1 | UUID generation |
| `logger` | ^2.6.1 | Structured logging (flavored) |
| `get_it` | ^9.2.1 | Dependency injection |
| `device_info_plus` | ^12.3.0 | Device info on startup |
| `package_info_plus` | ^9.0.0 | App version info |
| `google_sign_in` | ^7.2.0 | Google sign-in |

**Dev dependencies:**
| Package | Purpose |
|---------|---------|
| `bloc_test` | ^10.0.0 | BLoC/Cubit unit testing helpers |
| `mocktail` | ^1.0.4 | Mocking library |
| `fake_cloud_firestore` | ^4.0.2 | In-memory Firestore for tests |
| `build_runner` | ^2.8.0 | Code generation runner |
| `freezed` | ^3.2.0 | Freezed codegen |
| `json_serializable` | ^6.11.1 | JSON serialisation codegen |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `bloc_lint` | ^0.4.0 | BLoC-specific lint rules |

---

## Logging

Centralized via `lib/utils/logger.dart`. Flavor-aware:
- Enabled with debug output in dev
- Reduced/disabled in release/prod builds

Logs device info on startup. Use the global `logger` instance throughout.

---

## Testing

**268 tests** across 23 test files (as of current sprint).

| Category | Files | Tests |
|----------|-------|-------|
| Domain entity tests | 7 | ~50 |
| Domain usecase tests | 3 | ~60 (health score: 37, parsers: 23) |
| Cubit/BLoC unit tests | 13 | ~145 |
| Screen widget tests | 3 | ~16 |

**Test infrastructure:**
- `fake_cloud_firestore` — all cubit tests use `FakeFirebaseFirestore` (no network)
- `mocktail` + `MockBloc` — all widget tests mock BLoCs
- `bloc_test` `blocTest<C, S>(...)` helper for cubit state sequence assertions
- Real `GoRouter` with stub routes for widget tests requiring navigation

**Running tests:**
```bash
flutter test --coverage           # all tests + coverage
flutter test test/path/file.dart  # single file
bash coverage.sh                  # HTML coverage report via lcov
```

**Test file locations** mirror `lib/` structure:
```
test/
├── domain/entity/            # Freezed entity serialisation tests
├── domain/usecase/           # Parser + health score pure logic tests
└── presentation/
    ├── blocs/                # Cubit state emission tests
    └── screens/              # Widget tests (home_screen, login_screen, scaffold_shell)
```

---

## CI/CD (GitHub Actions)

Workflow: `.github/workflows/main.yml`

**Triggers**: Push/PR to `main`; release tags (`v*.*.*`) trigger APK release

**3 separate jobs (in dependency order):**

**1. lint** (~2 min, ubuntu-latest)
- Cache pub + setup Flutter
- `flutter analyze` (134+ lint rules)

**2. test** (~5 min, depends on lint)
- Cache pub + setup Flutter
- `flutter test --coverage`
- Uploads `coverage/lcov.info` as artifact

**3. build** (~15 min, depends on test)
- Cache pub + setup Flutter + Java 17 + Android CMake 3.22.1
- `flutter build apk --release --split-per-abi --flavor dev --target lib/main_dev.dart`
- `CLERK_PUBLISHABLE_KEY` passed via `--dart-define=${{ secrets.CLERK_PUBLISHABLE_KEY }}`
- Uploads APK artifact
- On version tags: creates GitHub Release with APKs attached

---

## Cloud Functions (Firebase)

Located in `functions/src/` (TypeScript/Node.js):

| Function | Trigger | Purpose |
|----------|---------|---------|
| `createPluggyItem` | HTTP call | Create Pluggy connection + return connectToken |
| `onPluggyWebhook` | HTTP webhook | Handle TRANSACTION_CREATED/UPDATED → write `raw_transaction` |
| `syncAllItems` | Scheduled (nightly) | Catch any missed Pluggy webhooks |
| `deletePluggyItem` | HTTP call | Disconnect account + cleanup Firestore |
| `billReminders` | Scheduled (09:00 UTC daily) | Send FCM 3 days before bill due date |
| `categorisationRuleEngine` | Internal | Keyword → category mapping for auto-categorisation |

---

## Starting a New Implementation

**Always** follow these steps before writing any code for a new sprint or feature:

```bash
git checkout main
git pull
git checkout -b <branch-name>
```

Branch names follow the pattern from the Branch Strategy table in `ROADMAP.md`:
- Sprint branches: `feat/us-XX-YY-short-description`
- Bug fixes: `fix/short-description`
- Chores: `chore/short-description`

---

## Commit Convention

Single-line commit messages using Conventional Commits. No co-author lines.

```
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`

Examples:
```
feat(auth): implement auto-redirect on sign-in
fix(home): correct splash spinner not showing on initial state
test(transaction): add unit tests for TransactionCubit
chore(debt): add overspend/tab tests, offline support, split CI jobs
```

---

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run in dev
flutter run --target lib/main_dev.dart

# Run in prod
flutter run --target lib/main_prod.dart

# Regenerate code (Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Test with coverage
flutter test --coverage
bash coverage.sh   # generates HTML report

# Regenerate app icons
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
dart run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```

---

## Environment Setup

1. Create `.env` (git-ignored):
   ```
   CLERK_PUBLISHABLE_KEY=pk_test_...
   ```
2. Ensure `firebase_options_dev.dart` and `firebase_options_prod.dart` are present (via `flutterfire configure`)
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`

---

## Gotchas & Notes

- **No repository layer**: BLoCs/Cubits access Firestore directly. If you add a repository layer, be consistent across all features.
- **Freezed union states**: Always handle all variants in `.when()` — the linter will catch missing cases.
- **Clerk beta**: `clerk_flutter` is `^0.0.12-beta` — API may change on updates.
- **Generated files**: Never manually edit `*.freezed.dart` or `*.g.dart` — always regenerate.
- **Dual Firebase**: Make sure you're using the correct `FirebaseOptions` per flavor in main entry points.
- **Portuguese naming**: Screen files use Portuguese (Brazilian) — this is intentional and consistent with the project's origin. Code identifiers remain English.
- **`@JsonSerializable(explicitToJson: true)`** is required on `RecurringEntity` (nested `TransactionEntity`); add `// ignore: invalid_annotation_target` comment above it.
- **`always_put_control_body_on_new_line`**: All `if` bodies must be on a new line — no single-line `if (x) return;`.
- **`sort_pub_dependencies`**: `pubspec.yaml` dependencies must be alphabetically ordered; analyzer enforces this.
- **`unawaited_futures`**: Fire-and-forget futures (e.g. cubit refreshes inside `async` methods) must be wrapped: `unawaited(cubit.loadCategories())`. Add `import 'dart:async';`.
- **Modal navigation in `StatefulShellRoute`**: Use `onClose` callback pattern (capture `sheetContext` from `showModalBottomSheet` builder) instead of `Navigator.of(context).pop()` to avoid branch-navigator issues.
- **Wildcard parameters in Dart 3.9+**: Use `(_, _) => ...` (two `_`) instead of `(_, __) => ...` — `unnecessary_underscores` lint enforces this.
- **`use_build_context_synchronously`**: Never use `context.read<X>()` after an `await` inside `initState`. Capture the cubit reference synchronously first:
  ```dart
  @override
  void initState() {
    super.initState();
    final MyCubit cubit = context.read<MyCubit>(); // captured before async gap
    Future<void>.microtask(cubit.loadData);         // no context across gap
  }
  ```
- **`showFormSheet` — always provide cubits inline**: Each form opened via `showFormSheet` must supply its own `BlocProvider`/`MultiBlocProvider` in the `builder:` param. The form's `initState` also triggers its own category load via the microtask pattern above, making forms self-contained regardless of caller.
- **`showInputDialog` — StatefulWidget owns the controller**: `app_dialog.dart` wraps the dialog content in `_InputDialog` (a `StatefulWidget`) so the `TextEditingController` is disposed in `State.dispose()` — never create a controller outside the widget tree for a dialog.
- **`StatefulShellRoute` branch count must match `NavigationDestination` count**: The number of branches in `router.dart` must exactly equal the number of `NavigationDestination` entries in `scaffold_shell.dart`. Mismatches cause index-out-of-range crashes at runtime.
- **Category chip selector pattern**: All form screens use a `Wrap` of tappable chips (not `DropdownButtonFormField`) for category selection, matching the QuickAddSheet UX. The last chip is always "Nova" to trigger inline category creation via `_showAddCategoryDialog()`.
