# Sprint 10 — Remove Shadcn & Establish AFC Design System

## Problem Statement

The app currently has a split visual identity:
- **Splash + Onboarding**: clean, branded, teal-primary, feels premium
- **Everything else**: shadcn's zinc/violet aesthetic — different typography weight, different card surface, different button shapes

Shadcn is also causing **active engineering friction**:
- 19 files hide `Column` and `Row` to avoid conflicts
- 30 files carry the shadcn import
- Component props (`variance:`, `ButtonStyle.outline()`, `ButtonShape.circle`) are shadcn-specific and not idiomatic Flutter
- Shadcn's own `ThemeData` wrapper (`LegacyColorSchemes`) disconnects us from Material's full theming API

**Goal**: Remove `shadcn_flutter` entirely and replace every component with a thin custom design-system layer on top of Material 3, styled to match the splash/onboarding aesthetic.

---

## Scope Audit (from static analysis)

| Component | Instances | Files | Replacement |
|-----------|-----------|-------|-------------|
| `Gap` | 218 | 25 | Keep widget name, own implementation |
| `IconButton` (shadcn) | 42 | 15 | Custom `AppIconButton` |
| `Card` (shadcn) | 24 | 12 | Custom `AppCard` |
| `PrimaryButton` | 21 | 16 | `AppButton.primary()` |
| `TextField` (shadcn) | 20 | 10 | `AppTextField` |
| `OutlineButton` | 12 | 7 | `AppButton.outline()` |
| `AlertDialog` (shadcn) | 6 | 5 | `AppDialog.confirm()` helper |
| `DestructiveButton` | 5 | 5 | `AppButton.destructive()` |
| `SecondaryButton` | 4 | 3 | `AppButton.secondary()` |
| `Switch` (shadcn) | 2 | 2 | Material `Switch` (themed) |
| `LinearProgressIndicator` | 2 | 2 | Material (already hidden in some files) |
| `ShadcnApp.router` | 1 | 1 | `MaterialApp.router` |
| `LegacyColorSchemes` | 2 | 1 | Rewrite `AppTheme` with real `ColorScheme` |

**30 files to update. Zero new business logic.**

---

## New Design System

### Visual Identity (match splash + onboarding)

| Token | Value | Usage |
|-------|-------|-------|
| Primary | `Color(0xFF0D9488)` | FAB, buttons, active states, progress bars |
| Surface (dark) | `Color(0xFF1C1C1E)` | Card background in dark mode |
| Surface (light) | `Color(0xFFF8F8F8)` | Card background in light mode |
| Border radius — card | 16 dp | All cards |
| Border radius — button | 10 dp | All buttons |
| Border radius — input | 10 dp | All text fields |
| Elevation — card | 0 (border instead) | Flat cards with 1dp border |
| Button height | 48 dp | All full-width buttons |
| Icon button size | 40 dp tap target | All icon buttons |

### Color Scheme (Material 3 `ColorScheme`)

Replace `LegacyColorSchemes` with a hand-crafted `ColorScheme.fromSeed` based on our primary teal:

```dart
// lib/config/theme/app_theme.dart  (rewrite)
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    // Override key tokens to match brand:
    cardTheme: ...,
    elevatedButtonTheme: ...,
    outlinedButtonTheme: ...,
    filledButtonTheme: ...,
    inputDecorationTheme: ...,
    switchTheme: ...,
    progressIndicatorTheme: ...,
    appBarTheme: ...,
    navigationBarTheme: ...,
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    // Same overrides, dark variant
    ...
  );
}
```

---

## Delivery Plan

### Phase 1 — Foundation (no screen changes yet)

**1.1 `lib/presentation/widgets/gap.dart`**
```dart
/// Drop-in replacement for shadcn's Gap.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
```
All 218 call sites keep working unchanged — just change the import.

**1.2 `lib/presentation/widgets/app_card.dart`**
```dart
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding, super.key});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  // Flat card: 16dp radius, 1dp border (theme color), 0 elevation
}
```
Note: We name it `AppCard` in the widget file but re-export it as `Card` from a barrel, so screen files only change the import, not the widget name.

**1.3 `lib/presentation/widgets/app_button.dart`**
```dart
/// PrimaryButton — teal filled
class PrimaryButton extends StatelessWidget { ... }

/// OutlineButton — transparent with border
class OutlineButton extends StatelessWidget { ... }

/// SecondaryButton — surface color, no border
class SecondaryButton extends StatelessWidget { ... }

/// DestructiveButton — red fill
class DestructiveButton extends StatelessWidget { ... }
```
Each takes `onPressed` + `child` (same API as shadcn versions). No `variance:` props.

**1.4 `lib/presentation/widgets/app_icon_button.dart`**
```dart
/// Replaces shadcn's IconButton(variance: ButtonStyle.outline(), ...)
/// and IconButton(variance: ButtonStyle.primary(), shape: ButtonShape.circle, ...)
class AppIconButton extends StatelessWidget {
  const AppIconButton({required this.icon, this.onPressed, this.filled = false, this.circle = false, ...});
}
```

**1.5 `lib/presentation/widgets/app_text_field.dart`**
```dart
/// Consistent branded text input.
class AppTextField extends StatelessWidget {
  const AppTextField({this.controller, this.placeholder, this.keyboardType, ...});
  // Themed border radius, focus color = AppColors.primary
}
```

**1.6 `lib/presentation/widgets/app_dialog.dart`**
```dart
Future<T?> showAppDialog<T>({required BuildContext context, required Widget dialog}) { ... }

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({required this.title, required this.content, required this.actions, ...});
}
```

**1.7 Rewrite `lib/config/theme/app_theme.dart`**
Full Material 3 `ThemeData` with `useMaterial3: true`, `ColorScheme.fromSeed`, and per-component theme overrides.

**1.8 `lib/presentation/widgets/design_system.dart` (barrel export)**
```dart
export 'gap.dart';
export 'app_card.dart' show AppCard;       // also aliased as Card
export 'app_button.dart';
export 'app_icon_button.dart';
export 'app_text_field.dart';
export 'app_dialog.dart';
```
Screen files replace the shadcn import with this single barrel import.

---

### Phase 2 — Root & Theme

**2.1 `my_app.dart`** — replace `ShadcnApp.router` → `MaterialApp.router`
**2.2 Remove `shadcn_flutter` from `pubspec.yaml`**

Running `flutter analyze` at this point will list every remaining shadcn reference as an error — the full migration checklist.

---

### Phase 3 — Screen-by-screen migration

Work through all 30 files. For each:
1. Replace `import 'package:shadcn_flutter/shadcn_flutter.dart' hide ...` → `import '../widgets/design_system.dart'`
2. Remove all `hide` clauses from `flutter/material.dart` imports (no more conflicts)
3. Rename: `Card` → `AppCard`, `IconButton(variance: ...)` → `AppIconButton(...)`, etc.
4. Replace `TextField` (shadcn) → `AppTextField`
5. Replace `showDialog` (shadcn) → `showAppDialog`

**Recommended migration order** (simplest → most complex):

| Priority | File | Why this order |
|----------|------|----------------|
| 1 | `empty_state.dart` | Only Gap + OutlineButton |
| 2 | `error_state.dart` | Only Gap + OutlineButton |
| 3 | `skeleton_list.dart` | Only Card + Gap |
| 4 | `lista_transacoes.dart` | Card + IconButton + Gap |
| 5 | `lista_categorias.dart` | Card + IconButton + Gap |
| 6 | `lista_limites.dart` | Card + IconButton + Gap |
| 7 | `lista_recorrentes.dart` | Card + IconButton + Switch |
| 8 | `lista_metas.dart` | Card + IconButton + AlertDialog + LinearProgressIndicator |
| 9 | `lista_investimentos.dart` | Card + IconButton + AlertDialog + DestructiveButton |
| 10 | `lista_contas.dart` | Card + IconButton + AlertDialog |
| 11 | `review_queue_screen.dart` | Card + PrimaryButton + AlertDialog |
| 12 | `connected_accounts_screen.dart` | Card + PrimaryButton + DestructiveButton |
| 13 | `relatorio.dart` | Card + Gap layout |
| 14 | `importar_extrato.dart` | Card + PrimaryButton + OutlineButton |
| 15 | `home_page.dart` | Complex — many sub-widgets, LinearProgressIndicator |
| 16 | `quick_add_sheet.dart` | TextField + PrimaryButton + AlertDialog |
| 17 | `cadastrar_transacao.dart` | TextField + PrimaryButton |
| 18 | `cadastrar_categoria.dart` | TextField + PrimaryButton + IconButton.circle |
| 19 | `cadastrar_limites.dart` | TextField + PrimaryButton |
| 20 | `cadastrar_meta.dart` | TextField + PrimaryButton |
| 21 | `cadastrar_recorrente.dart` | TextField + PrimaryButton |
| 22 | `cadastrar_conta.dart` | TextField + PrimaryButton |
| 23 | `cadastrar_investimento.dart` | TextField + PrimaryButton + OutlineButton |
| 24 | `dev_seed_screen.dart` | PrimaryButton + DestructiveButton |
| 25 | `settings_screen.dart` | Already partially on material; finish |
| 26 | `my_app.dart` | Root widget swap |

---

### Phase 4 — Polish pass

After all screens compile:
- Visual QA pass: compare each screen against splash/onboarding aesthetic
- Tune `cardTheme`, button padding, text field decoration in `AppTheme` until everything is cohesive
- Run 268 tests — update any widget tests that relied on shadcn widget types
- Update `scaffold_shell.dart`, `home_screen.dart`, `onboarding_screen.dart` (these already look right but may need minor tweaks)
- Add light-mode card styling (these screens were mostly designed for dark)

---

## Files Created / Modified Summary

| Action | Files |
|--------|-------|
| New (design system) | `gap.dart`, `app_card.dart`, `app_button.dart`, `app_icon_button.dart`, `app_text_field.dart`, `app_dialog.dart`, `design_system.dart` |
| Rewrite | `app_theme.dart`, `my_app.dart` |
| Migrate (import swap + component rename) | 28 screen/widget files |
| Remove from pubspec | `shadcn_flutter: ^0.0.44` |

**Zero new business logic. Zero BLoC changes. Zero routing changes.**

---

## Risks

| Risk | Mitigation |
|------|------------|
| `AppCard` vs material `Card` naming | Use barrel export; re-export as `Card` so most usages don't change the widget name |
| `Colors` class (used via shadcn) → now material's | Already works — `Colors` in existing code comes from material |
| `Theme.of(context)` behaviour change | Material 3 ThemeData is a superset; existing `Theme.of(context).colorScheme` calls still work |
| Test failures from widget type changes | Update widget tests to find by `AppCard` / `AppButton` types |
| `IconButton` API change (`variance` → `filled`/`circle` flags) | Our `AppIconButton` provides the same variants |
| `placeholder:` named param on TextField | Shadcn uses `placeholder: Text(...)`, Material uses `labelText:` or `hintText:` — needs per-call review |

---

## Branch

`feat/sprint10-design-system`

---

## Definition of Done

- [ ] `shadcn_flutter` removed from `pubspec.yaml`
- [ ] `flutter pub get` succeeds with no shadcn references
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all existing tests pass
- [ ] Every screen uses only `design_system.dart` + `flutter/material.dart` (no hide clauses needed)
- [ ] Dark and light themes look cohesive with splash/onboarding
- [ ] Visual QA pass completed on all main screens
