# AFC — Sprint 8 & 9: Brand Identity & User Experience

> **Context**: Sprints 1–7 delivered the full feature set (authentication, transactions, limits, goals, investments, bills, Open Finance, health score). Sprints 8 and 9 shift focus entirely to how the app **looks** and **feels** — establishing a strong visual identity and polishing every interaction so the product earns trust and daily habit.

---

## Sprint 8 — Brand Identity & Visual Language

> **Goal**: Give AFC a distinctive, professional identity that users recognise and trust. Every screen should feel intentional — not like a generic CRUD app, but like a product someone chose to open every day.

---

### US-33 · Brand color system & typography scale

**As a** user, **I want** the app to have a consistent, well-defined visual identity,
**so that** it feels polished and trustworthy, not like a generic template.

**Color palette** (token-based, defined in `lib/config/theme/app_colors.dart`):

| Token | Role | Suggested Value |
|-------|------|----------------|
| `primary` | Main actions, active tabs, FAB | Deep teal or indigo |
| `primaryVariant` | Hover / pressed states | Darker shade of primary |
| `income` | Income amounts, positive balance | Emerald green |
| `expense` | Expense amounts, limit warnings | Rose / coral |
| `warning` | Approaching limit, upcoming bills | Amber |
| `surface` | Card backgrounds | Neutral warm gray |
| `background` | Page background | Near-white (light) / near-black (dark) |
| `onPrimary` | Text/icon on primary | White |
| `textPrimary` | Body text | Charcoal |
| `textSecondary` | Labels, subtitles | Medium gray |
| `divider` | Separators | Light gray |

**Typography scale** (defined in `lib/config/theme/app_typography.dart`):

| Style | Usage | Suggested Spec |
|-------|-------|---------------|
| `displayLarge` | Balance amount on dashboard | 36 sp, weight 700 |
| `headlineMedium` | Screen titles | 22 sp, weight 600 |
| `titleMedium` | Card titles, section headers | 16 sp, weight 600 |
| `bodyLarge` | Transaction rows, form fields | 15 sp, weight 400 |
| `bodySmall` | Dates, subtitles, chip labels | 12 sp, weight 400 |
| `labelSmall` | Badge text, tab labels | 11 sp, weight 500 |

**Acceptance criteria:**
- [ ] `AppColors` class with all tokens as static `Color` constants
- [ ] `AppTypography` class with all text styles
- [ ] `ThemeData` (light + dark) built from these tokens — no hardcoded colors elsewhere
- [ ] All existing screens updated to use tokens instead of ad-hoc `Color(0x...)` values
- [ ] Linter rule `avoid_hardcoded_colors` (or custom lint) prevents regression

---

### US-34 · Custom app icon & branded splash screen

**As a** first-time user, **I want** a memorable app icon and a smooth branded opening screen,
**so that** AFC stands out on my home screen and the app opening feels intentional.

**App icon:**
- [ ] Design a custom icon for AFC (not a generic wallet or chart icon)
- [ ] Icon follows Material You adaptive icon spec (foreground + background layers)
- [ ] Separate icon assets for dev flavor (e.g. "AFC Dev" label or different badge color)
- [ ] Regenerate via `flutter_launcher_icons` for both flavors (`flutter_launcher_icons-dev.yaml`, `flutter_launcher_icons-prod.yaml`)

**Animated splash screen** (`lib/presentation/screens/splash_screen.dart`):
- [ ] Replaces the bare `CircularProgressIndicator` in `HomeScreen` while auth state resolves
- [ ] Shows the AFC logo with a subtle fade-in or scale animation (200–400 ms)
- [ ] Background matches `AppColors.primary` — no white flash
- [ ] Respects `prefers_reduced_motion` / accessibility settings
- [ ] Transitions out smoothly to `/home` or `/login` (slide or fade)
- [ ] Widget tests: splash renders during initial state; transitions correctly on signedIn/signedOut

---

### US-35 · Consistent iconography system

**As a** user, **I want** icons throughout the app to feel like they belong to the same family,
**so that** the UI reads as intentional and coherent, not assembled from different icon packs.

- [ ] Choose one icon set as the primary source: **Material Symbols** (rounded variant) or a custom SVG icon set — document the decision in `CLAUDE.md`
- [ ] Create `lib/config/icons/app_icons.dart` mapping semantic names to icon data:
  ```dart
  class AppIcons {
    static const IconData transaction = Symbols.receipt_long;
    static const IconData income = Symbols.arrow_downward;
    static const IconData expense = Symbols.arrow_upward;
    static const IconData category = Symbols.category;
    static const IconData limit = Symbols.tune;
    static const IconData goal = Symbols.savings;
    static const IconData investment = Symbols.candlestick_chart;
    static const IconData bill = Symbols.calendar_today;
    static const IconData health = Symbols.favorite;
    static const IconData add = Symbols.add;
    static const IconData settings = Symbols.settings;
    static const IconData profile = Symbols.person;
  }
  ```
- [ ] Replace all ad-hoc `Icons.xxx` references in screens with `AppIcons.xxx`
- [ ] Category icon picker (`cadastrar_categoria.dart`) updated to display icons from the chosen set
- [ ] Bottom navigation bar icons updated to use `AppIcons`

---

### US-36 · Dark mode & theme toggle

**As a** user, **I want** to switch between light and dark themes,
**so that** I can use AFC comfortably at night without straining my eyes.

- [ ] `ThemeCubit` — emits `ThemeMode` (system / light / dark), persisted to `SharedPreferences`
- [ ] `ThemeCubit` provided at app root level (above `MaterialApp`)
- [ ] `MyApp` consumes `ThemeCubit` and passes `themeMode` to `MaterialApp.router`
- [ ] Both `ThemeData` (light) and `ThemeData.dark()` fully defined using `AppColors` tokens — no unthemed screens
- [ ] Settings screen (US-41) exposes the toggle (system / light / dark radio buttons)
- [ ] All Shadcn components adapt correctly in dark mode (check `shadcn_flutter` theming docs)
- [ ] Unit test: `ThemeCubit` persists and restores selected mode across sessions

---

### US-37 · Branded empty states

**As a** user, **I want** empty list screens to show a helpful illustration and message,
**so that** I understand what to do next instead of staring at a blank white area.

**Empty state widget** (`lib/presentation/widgets/empty_state.dart`):
```dart
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.illustration, // SVG asset path or LottieBuilder
    required this.title,
    required this.subtitle,
    this.action,      // optional CTA button
    super.key,
  });
}
```

**Screens that need empty states:**

| Screen | Illustration concept | Subtitle | CTA |
|--------|---------------------|----------|-----|
| Transaction list | Wallet with a question mark | "Nenhuma transação ainda." | "Adicionar" |
| Category list | Tag icon | "Crie categorias para organizar seus gastos." | "Nova categoria" |
| Limit list | Empty gauge | "Defina limites mensais por categoria." | "Novo limite" |
| Goals list | Piggy bank | "Crie uma meta para começar a poupar." | "Nova meta" |
| Investment list | Seedling / sprout | "Registre seus investimentos aqui." | "Novo investimento" |
| Bill list | Calendar clear | "Sem contas cadastradas." | "Nova conta" |
| Recurring list | Clock with no hands | "Nenhuma recorrência configurada." | "Nova recorrência" |
| Report (no data) | Chart with no bars | "Sem transações no período selecionado." | — |
| Review queue | Inbox zero | "Tudo em dia! Nenhuma transação para revisar." | — |

- [ ] `EmptyState` widget built with `illustration`, `title`, `subtitle`, and optional `action`
- [ ] All list screens use `EmptyState` when the `listed([])` state is empty
- [ ] Illustrations are SVG assets in `assets/illustrations/` (use `flutter_svg` or Lottie animations)
- [ ] Widget tests for `EmptyState` render

---

## Sprint 9 — User Experience & Interaction Design

> **Goal**: Make AFC feel alive. Every tap, transition, and error state should respond with intention — building the muscle memory and emotional connection that turns a "useful app" into a "daily habit."

---

### US-38 · Onboarding flow (first-time user)

**As a** first-time user, **I want** a brief walkthrough that explains the app's value,
**so that** I understand what AFC does and feel confident setting it up.

**Trigger**: shown once, after first sign-in, before routing to `/home`. Completed flag stored in `SharedPreferences`.

**Screens** (`lib/presentation/screens/onboarding/`):

| Step | Title | Illustration | Copy |
|------|-------|-------------|------|
| 1/4 | Controle total | Dashboard preview | "Veja seu saldo, gastos e metas em um só lugar." |
| 2/4 | Registre com um toque | Quick-add FAB demo | "Adicione qualquer gasto em segundos — direto da tela principal." |
| 3/4 | Defina limites | Limit progress bar | "Crie limites mensais por categoria e receba alertas antes de estourar." |
| 4/4 | Conecte seu banco | Open Finance diagram | "Importe extratos ou conecte sua conta para sincronismo automático." |

- [ ] `OnboardingScreen` with `PageView` and animated dot indicators
- [ ] Skip button (top-right) skips all remaining pages
- [ ] "Próximo" / "Começar" button advances / finishes
- [ ] Completion writes `onboarding_done: true` to `SharedPreferences`; router redirects to `/home` afterward
- [ ] Smooth page transitions (slide + crossfade)
- [ ] Widget tests: renders 4 pages; skip navigates to home; last page "Começar" navigates to home

---

### US-39 · Skeleton loading screens

**As a** user, **I want** loading states to show placeholder shapes instead of a spinner,
**so that** the app feels faster and the layout doesn't "jump" when data arrives.

**Skeleton widget** (`lib/presentation/widgets/skeleton.dart`):
- [ ] `Skeleton` — single shimmer rectangle with configurable `width`, `height`, `borderRadius`
- [ ] `SkeletonList` — N repeated `Skeleton` rows matching the real list item's layout
- [ ] Shimmer animation uses the brand's surface/divider colors (adapts to dark mode)
- [ ] No external shimmer package — implement with `AnimationController` + `LinearGradient`

**Screens to update:**

| Screen | Skeleton shape |
|--------|---------------|
| Dashboard (`home_page.dart`) | Balance card rectangle + 3 transaction rows |
| Transaction list | 6 rows: leading circle + two rectangles (title / amount) |
| Category list | 4 rows: square icon + rectangle |
| Limit list | 3 rows: rectangle + progress bar |
| Goals list | 3 cards: rectangle + thin bar |
| Report | Pie placeholder circle + 3 legend rows |

- [ ] All `loading` states on the above screens render `SkeletonList` instead of `CircularProgressIndicator`
- [ ] Widget tests: loading state renders `Skeleton` widgets; data state renders real content

---

### US-40 · Micro-animations & page transitions

**As a** user, **I want** smooth, purposeful animations as I navigate and interact,
**so that** the app feels responsive and premium rather than abrupt.

**Navigation transitions** (`lib/config/routes/transitions.dart`):
- [ ] Define a reusable `slideUpTransition` for modal/bottom-sheet-style routes (form screens slide up from bottom)
- [ ] Define a `fadeScaleTransition` for dashboard-level routes (dashboard, report)
- [ ] All `GoRoute` builders use these via `pageBuilder` instead of `builder` where applicable
- [ ] Back navigation uses the reverse of the entry animation

**Interaction animations:**
- [ ] FAB: `ScaleTransition` on first render (pops into view when shell loads)
- [ ] NavigationBar destination tap: `AnimatedSwitcher` crossfade on the body content
- [ ] Progress bars (limits, goals): animate from 0 → current value on first render (`TweenAnimationBuilder`, 600 ms, `Curves.easeOut`)
- [ ] Health score card: score counter animates from 0 → value on first load
- [ ] Transaction saved: the quick-add sheet slides down with a satisfying spring curve before closing
- [ ] List items: `AnimatedList` for real-time additions (slide-in from bottom)

**Haptic feedback** (already partially in place — extend consistently):
- [ ] `HapticFeedback.lightImpact()` — every navigation tap, toggle
- [ ] `HapticFeedback.mediumImpact()` — save / confirm actions
- [ ] `HapticFeedback.heavyImpact()` — delete / destructive confirmation
- [ ] `HapticFeedback.selectionClick()` — category chip selection, type toggle

---

### US-41 · User profile & settings screen

**As a** user, **I want** a settings screen where I can manage my account and preferences,
**so that** I feel in control of how the app behaves and how my data is used.

**Route**: `/settings` — accessible via profile avatar tap on dashboard header.

**Sections:**

**Profile**
- [ ] Display name and avatar from Clerk (read-only initially; edit in a future sprint)
- [ ] Email address (Clerk)
- [ ] "Sair" (sign out) button → calls `AuthBloc.signOut()` → redirects to `/login`

**Appearance**
- [ ] Theme toggle: Sistema / Claro / Escuro (drives `ThemeCubit`)
- [ ] Currency display format (R$ prefix, decimal separator — stored in `SharedPreferences`)

**Notifications**
- [ ] Toggle: bill reminders (enables/disables FCM via `FcmService`)
- [ ] Toggle: overspend alerts
- [ ] Toggle: health score weekly digest

**Data**
- [ ] "Exportar transações (CSV)" — generates and shares a CSV of all transactions via `share_plus`
- [ ] "Exportar backup (JSON)" — full data export (all collections) as a JSON file
- [ ] "Contas conectadas" — navigates to `/contas-conectadas` (US-31)

**About**
- [ ] App version (from `package_info_plus`)
- [ ] "Política de privacidade" (opens URL)
- [ ] "Termos de uso" (opens URL)

- [ ] `SettingsCubit` manages notification toggles and currency format preference
- [ ] All preferences persisted to `SharedPreferences`
- [ ] Widget test: renders all sections; sign-out triggers `AuthBloc.add(AuthEvent.signOut())`

---

### US-42 · Contextual error states with retry

**As a** user, **I want** clear, actionable error messages when something goes wrong,
**so that** I know what happened and can try again without restarting the app.

**Error state widget** (`lib/presentation/widgets/error_state.dart`):
```dart
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });
}
```

- [ ] Shows a relevant icon (network error → wifi_off, generic → error_outline), the `message`, and a "Tentar novamente" button that calls `onRetry`
- [ ] All screens that have an `error` BLoC state render `ErrorState` instead of a raw `Text`
- [ ] `onRetry` re-dispatches the load action (e.g. `cubit.loadTransactions(userId)`)
- [ ] Network errors mapped to a user-friendly Portuguese message (not a Dart stack trace)
- [ ] `ErrorBoundary` widget wraps the root `MaterialApp` to catch unhandled Flutter errors:
  ```dart
  class ErrorBoundary extends StatefulWidget { ... }
  // Overrides ErrorWidget.builder globally; shows ErrorState with "Reiniciar" action
  ```
- [ ] Widget tests for `ErrorState` render and retry callback

---

### US-43 · Pull-to-refresh on all list screens

**As a** user, **I want** to pull down any list to manually refresh its data,
**so that** I can force a sync without closing and reopening the app.

- [ ] Wrap list `ListView` / `CustomScrollView` with `RefreshIndicator` using `AppColors.primary` as `color`
- [ ] `onRefresh` callback re-fires the load cubit method (e.g. `cubit.loadTransactions(userId)`)
- [ ] Dashboard (`home_page.dart`): pull-to-refresh triggers `HomeBloc.add(LoadHome(userId))` + optional Cloud Function `syncAllItems` call if any Open Finance account is connected
- [ ] Refresh indicator inherits from the brand theme (no default blue)
- [ ] Screens: transaction list, category list, limit list, goals, investments, bills, recurring, report, review queue, connected accounts

---

### US-44 · Accessibility & inclusive design

**As a** user with accessibility needs, **I want** the app to work with screen readers, large text, and high contrast,
**so that** AFC is usable regardless of visual ability or device settings.

**Semantic labels:**
- [ ] All `IconButton`, `FloatingActionButton`, `NavigationDestination` have `Tooltip` / `Semantics(label: ...)` in Portuguese
- [ ] Chart widgets (`fl_chart`) wrapped with `Semantics(label: 'Gráfico de gastos: ...')` providing a text summary of the data
- [ ] Progress bars (limits, goals) use `Semantics(value: '${pct}%', label: '...')` so screen readers announce progress

**Text scaling:**
- [ ] All layouts tested at `textScaleFactor` 1.0, 1.5, and 2.0 — no text overflow or clipped buttons
- [ ] Interactive targets meet 48×48 dp minimum touch target size

**Contrast:**
- [ ] All color token combinations meet WCAG AA (4.5:1 for body text, 3:1 for large text/UI components)
- [ ] Test both light and dark themes

**Reduced motion:**
- [ ] All animations respect `MediaQuery.of(context).disableAnimations`; skip or reduce when true

- [ ] Accessibility checklist document: `docs/accessibility_checklist.md`
- [ ] Manual test pass on Android TalkBack and iOS VoiceOver before release

---

## Technical Debt Created by Sprints 8–9

| Item | Notes |
|------|-------|
| `share_plus` package | Needed for US-41 CSV/JSON export — add to `pubspec.yaml` |
| `flutter_svg` or `lottie` | Needed for US-37 illustrations — evaluate which fits the asset format |
| `shared_preferences` | Needed for US-36 (theme), US-38 (onboarding flag), US-41 (notification prefs) |
| Golden / screenshot tests | Once UI is stable post-Sprint 8, add golden tests for key screens to prevent visual regression |
| Design token sync | If a design tool (Figma) is introduced, set up a token export pipeline to keep `AppColors` / `AppTypography` in sync |

---

## Branch Strategy

| Sprint | Branch |
|--------|--------|
| Sprint 8 (US-33–37) | `feat/us-33-37-brand-identity` |
| Sprint 9 (US-38–44) | `feat/us-38-44-ux-polish` |
