# AFC Accessibility Checklist

Sprint 9 — US-44 · Accessibility & Inclusive Design

---

## Semantic Labels

| Widget | Status | Notes |
|--------|--------|-------|
| FAB (Adicionar transação) | ✅ | `Semantics(label: ...)` + `tooltip` added |
| NavigationBar destinations | ✅ | `tooltip` added to each `NavigationDestination` |
| Settings icon button (home_page) | ✅ | `Semantics(label: 'Configurações')` |
| Chart widgets (fl_chart) | ⬜ | Wrap with `Semantics(label: 'Gráfico de ...')` in Sprint 10 |
| Progress bars — limits | ⬜ | Add `Semantics(value: '${pct}%')` in Sprint 10 |
| Progress bars — goals | ⬜ | Add `Semantics(value: '${pct}%')` in Sprint 10 |

---

## Reduced Motion

| Item | Status | Notes |
|------|--------|-------|
| `SkeletonList` shimmer | ✅ | Checks `MediaQuery.disableAnimations`; falls back to static box |
| FAB scale animation | ✅ | Checks `MediaQuery.disableAnimations`; uses `AlwaysStoppedAnimation` |
| Splash screen animations | ⬜ | Add check in Sprint 10 |
| Onboarding PageView transitions | ⬜ | Add check in Sprint 10 |

---

## Touch Targets

| Item | Status | Notes |
|------|--------|-------|
| FAB | ✅ | 56 × 56 dp (Material default) |
| NavigationBar items | ✅ | 48 dp+ (NavigationBar default) |
| IconButton in list rows | ⚠️ | 40 dp — may need padding at `textScaleFactor` 2.0 |
| Onboarding "Próximo" button | ✅ | Full-width, 16 dp vertical padding |

---

## Text Scaling

- Test at `textScaleFactor` 1.0, 1.5, and 2.0.
- Use `MediaQuery.textScalerOf(context)` to detect large-text mode.
- Known risk area: `HomeCard` amounts with very large numbers at scale 2.0.

---

## Color Contrast (WCAG AA)

| Token pair | Ratio | Status |
|-----------|-------|--------|
| `AppColors.primary` / `AppColors.onPrimary` | ≥ 4.5:1 | ✅ Teal on white |
| `AppColors.muted` on light background | ≥ 3:1 | ✅ |
| `AppColors.expense` on surface | ≥ 4.5:1 | ✅ |
| `AppColors.income` on surface | ≥ 4.5:1 | ✅ |

---

## Manual Test Plan

Before each release:

1. **Android TalkBack**
   - [ ] Enable TalkBack in Accessibility settings
   - [ ] Navigate all bottom tabs using swipe gestures
   - [ ] Confirm FAB announces "Adicionar transação"
   - [ ] Confirm each tab destination is announced in Portuguese
   - [ ] Open Settings → confirm all sections are readable

2. **iOS VoiceOver**
   - [ ] Enable VoiceOver in Accessibility settings
   - [ ] Repeat the TalkBack test sequence above

3. **Large Text**
   - [ ] Set font size to maximum in system settings
   - [ ] Confirm no text clipping or overflow on any screen

4. **High Contrast**
   - [ ] Enable High Contrast mode (Android) or Increase Contrast (iOS)
   - [ ] Verify all UI components remain legible

---

## Future Work (Sprint 10+)

- Add `Semantics(label: 'Gráfico de gastos: ...')` to all fl_chart widgets
- Add `Semantics(value: '${pct}%')` to limit and goal progress bars
- Test `HomeCard` balance display at `textScaleFactor` 2.0
- Add reduced-motion guard to splash screen `AnimationController`
- Evaluate `flutter_a11y_audit` package for automated contrast checking
