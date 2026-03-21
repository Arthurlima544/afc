# CLAUDE.md — AFC (Personal Finance App)

## Project Overview

**AFC** is a personal finance management mobile application built with Flutter. It allows users to:
- Track financial transactions (income and expenses)
- Manage spending categories with custom icons
- Set and monitor monthly spending limits per category
- View financial statistics and trends via charts
- Authenticate via Clerk OAuth
- Sync data with Firebase Firestore

**Platforms**: Android, iOS, macOS, Web
**Version**: v1.0.0+1
**Dart SDK**: >=3.9.0

---

## Architecture

**Pattern**: Clean Architecture + BLoC/Cubit pattern

```
lib/
├── config/routes/         # GoRouter navigation
├── domain/entity/         # Immutable data models (Freezed)
├── presentation/
│   ├── blocs/             # BLoC (events) and Cubit (simple state)
│   └── screens/           # UI screens
└── utils/                 # Logger, flavors, exceptions, root widget
```

**Layers**:
1. **Presentation** — Screens + BLoCs/Cubits (Shadcn Flutter UI components)
2. **Domain** — Entities only (immutable, Freezed-generated)
3. **Config** — GoRouter routing, flavor configuration
4. **Utils** — Logging, exception definitions, flavor detection

**Key architectural decisions**:
- Cubits/BLoCs access Firestore directly (no repository layer)
- No service/repository abstraction — keep it simple
- Provider injection happens at the route level via `BlocProvider` in `router.dart`
- `GetIt` is the DI service locator

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

**BLoC** (event-based, for complex logic):
- `AuthBloc` — authentication state
- `HomeBloc` — dashboard/stats

**Cubit** (simpler state emission):
- `TransactionCubit` — CRUD for transactions
- `CategoryCubit` — CRUD for categories
- `LimitCubit` — spending limits management

**State pattern** (Freezed union types):
```dart
@freezed
sealed class TransactionState with _$TransactionState {
  const factory TransactionState.initial(List<CategoryEntity> categories) = _Initial;
  const factory TransactionState.loading() = _Loading;
  const factory TransactionState.success(TransactionEntity entity) = _Success;
  const factory TransactionState.error(String message) = _Error;
}
```

**Consuming state**:
```dart
state.when(
  initial: (categories) => ...,
  loading: () => CircularProgressIndicator(),
  error: (msg) => ErrorWidget(msg),
  success: (entity) => SuccessWidget(entity),
)
```

---

## Data Models (Entities)

All entities are **immutable Freezed classes** with JSON serialization:

- `CategoryEntity` — `uuid`, `name`, `iconType` (int)
- `TransactionEntity` — `uuid`, `amount`, `categoryUuid`, `typeUuid`, `data` (DateTime), `title`, `userId`
- `LimitEntity` — `uuid`, `categoryUuid`, `month`, `limitAmount`, `userId`
- `StatsEntity` — computed statistics for the dashboard
- `TypeEntity` — income/expense type
- `CalendarEntity` — month enum for date filtering

**After any model change**, regenerate with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Database (Firebase Firestore)

**Collections**:
- `category` — filtered by `uuid` (user identifier)
- `transaction` — filtered by `userId`
- `limit` — filtered by `userId`

**Direct access pattern** (no repository layer):
```dart
// Read
FirebaseFirestore.instance.collection('category')
    .where('uuid', isEqualTo: userUuid).get()

// Write
FirebaseFirestore.instance.collection('transaction').add(entity.toJson())
```

Firestore is schemaless — no migrations needed, but keep entity JSON shape consistent.

---

## Authentication

Clerk OAuth via `clerk_flutter` package. Configuration:
- `CLERK_PUBLISHABLE_KEY` in `.env` file (git-ignored)
- Firebase Auth is also initialized (for Firestore security rules)

**Auth flow**:
1. App starts → `HomeScreen` (splash)
2. Redirects to `LoginScreen` (Clerk UI)
3. `AuthBloc` captures authenticated state
4. Navigates to `HomePage` on success

---

## Navigation

GoRouter (`go_router: ^16.2.1`). Routes defined in `lib/config/routes/router.dart`.

BLoC providers are injected at the route level:
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

## Screens

| Screen | File | Purpose |
|--------|------|---------|
| Home (Splash) | `home_screen.dart` | Entry point / auth redirect |
| Login | `login_screen.dart` | Clerk OAuth login |
| Home Page | `home_page.dart` | Dashboard + charts |
| Add Transaction | `cadastrar_transacao.dart` | Create income/expense |
| Add Category | `cadastrar_categoria.dart` | Create category + pick icon |
| Set Limits | `cadastrar_limites.dart` | Monthly spending limits |

---

## UI Framework

- **Design system**: `shadcn_flutter` (Shadcn components)
- **Charts**: `fl_chart` (line/bar charts)
- **Icons**: `cupertino_icons` + `Icons` (Material)
- **Forms**: `shadcn_flutter` Form + `FormKey<T>` for typed field extraction

---

## Code Style & Conventions

- **Files**: `snake_case.dart`
- **Classes/Types**: `PascalCase`
- **Variables/methods**: `camelCase`
- **Private members**: `_leadingUnderscore`
- Explicit return types everywhere (strict linting)
- Use `sealed class` + Freezed for all state/entity types
- Pattern matching via `.when()` / `.whenOrNull()`
- Extension methods for layout helpers (`.gap()`, `.withPadding()`)
- Portuguese naming in screen files (project origin language)

**Linting**: `analysis_options.yaml` with 140+ rules + `bloc_lint` plugin. Generated files (`*.g.dart`, `*.freezed.dart`) are excluded.

---

## Key Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | BLoC state management |
| `freezed_annotation` | ^3.1.0 | Immutable code generation |
| `go_router` | ^16.2.1 | Declarative navigation |
| `shadcn_flutter` | ^0.0.44 | UI component library |
| `cloud_firestore` | ^6.0.2 | NoSQL database |
| `firebase_auth` | ^6.0.2 | Firebase authentication |
| `clerk_flutter` | ^0.0.12-beta | Clerk OAuth |
| `fl_chart` | ^1.1.1 | Charts/graphs |
| `result_dart` | ^2.1.1 | Result type for error handling |
| `flutter_dotenv` | ^5.1.0 | `.env` environment variables |
| `get_it` | ^8.2.0 | Dependency injection |
| `logger` | ^2.6.1 | Structured logging |
| `uuid` | ^4.5.1 | UUID generation |
| `intl` | ^0.20.2 | Internationalization / date formatting |
| `build_runner` | ^2.8.0 | Code generation runner |
| `json_serializable` | ^6.11.1 | JSON serialization codegen |
| `freezed` | ^3.2.0 | Freezed codegen |

---

## Logging

Centralized via `lib/utils/logger.dart`. Flavor-aware:
- Enabled in dev
- Disabled (or reduced) in release/prod builds

Log device info on startup. Use the global `logger` instance throughout.

---

## Testing

**Status**: Infrastructure in place, no test files written yet.

- Framework: `flutter_test`
- Coverage script: `coverage.sh` (generates HTML report via `lcov`)
- Run tests: `flutter test --coverage`

When writing tests, place them in `test/` mirroring the `lib/` structure.

---

## CI/CD (GitHub Actions)

Workflow: `.github/workflows/main.yml`

**Triggers**: Push/PR to `main`, release tags (`v*.*.*`)

**Steps**:
1. Cache Pub dependencies
2. Setup Java 17 (Temurin) + Flutter 3.35.1 stable
3. `flutter pub get`
4. `flutter analyze`
5. `flutter test --coverage`
6. Build release APK (per-ABI split)
7. Create GitHub Release (on tag)

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

1. Copy `.env.example` to `.env` (if it exists) or create `.env`:
   ```
   CLERK_PUBLISHABLE_KEY=pk_test_...
   ```
2. Ensure `firebase_options_dev.dart` and `firebase_options_prod.dart` are present (generated via `flutterfire configure`)
3. Run `flutter pub get`
4. Run `dart run build_runner build --delete-conflicting-outputs`

---

## Gotchas & Notes

- **No repository layer**: BLoCs/Cubits access Firestore directly. If you add a repository layer, be consistent across all features.
- **Freezed union states**: Always handle all variants in `.when()` — the linter will catch missing cases.
- **Clerk beta**: `clerk_flutter` is `^0.0.12-beta` — API may change on updates.
- **Generated files**: Never manually edit `*.freezed.dart` or `*.g.dart` — always regenerate.
- **Dual Firebase**: Make sure you're using the correct `FirebaseOptions` per flavor in main entry points.
- **Portuguese naming**: Screen files and some variables use Portuguese (Brazilian) — this is intentional and consistent with the project's origin.
