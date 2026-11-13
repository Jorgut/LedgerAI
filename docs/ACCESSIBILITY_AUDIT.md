# HENG 1.1 Accessibility Audit

Date: 2026-11-14 · Build: 1.1.0 (13)

## Scope

- WCAG 2.2 AA contrast for A Fresh / B Forest / C Fresh Forest, light + dark
- iOS Dynamic Type up to 200%
- VoiceOver semantics for amounts, transactions, charts, tabs
- Minimum tap target 48 dp
- Reduced Motion for brand intro and chart animations

## Automated tests

| Test | Result |
|---|---|
| `flutter test test/widget/accessibility_test.dart` | 4/4 passed |
| Core test suite | 114 passed |
| Home screen widget suite | 8/8 passed |
| `dart analyze lib` | no issues |

## Contrast audit (text, WCAG AA ≥ 4.5:1)

| Theme | Text/bg | Muted/bg | Primary/bg | Button label | Income/bg | Expense/bg | Warning/bg |
|---|---|---|---|---|---|---|---|
| A Fresh light | 16.55 | 4.51 | 5.12 | 5.48 | 5.12 | 4.51 | 4.68 |
| A Fresh dark | 14.95 | 7.29 | 9.63 | 7.88 | 9.63 | 6.69 | 11.09 |
| B Forest light | 15.43 | 4.83 | 7.27 | 8.07 | 4.67 | 5.92 | **3.81 → 5.70** |
| B Forest dark | 16.12 | 8.79 | 12.19 | 10.03 | 12.19 | 6.72 | 11.13 |
| C Fresh Forest light | 16.30 | 5.10 | 7.68 | 8.07 | 4.93 | 6.25 | **4.03 → 6.02** |
| C Fresh Forest dark | 16.26 | 8.86 | 12.29 | 10.03 | 12.29 | 6.77 | 11.22 |

**Fix applied:** B/C light `warning` text was `#B26A00` (3.81 / 4.03). Changed to `#8A5300` (5.70 / 6.02) in `lib/ui/color_themes.dart`.

## Other checks

- **Tap targets:** settings rows, tabs, FAB, quick actions all ≥ 48 dp (automated).
- **Dynamic Type 200%:** home + settings + tabs have no overflow after constraining long transaction amounts with `FittedBox`; widget tests pass.
- **VoiceOver:** transaction row announces note, category, income/expense, amount, date; chart has equivalent semantic label; deletion has 44/48 dp actions.
- **Reduced Motion:** brand intro falls back to a single 400 ms fade; chart animation duration becomes zero when reduce-motion is enabled.
- **Currency/date:** date labels are locale-aware; amount separators follow Russian conventions.

## Known limitations / next

- Category colors are decorative; each color is always paired with a text label and icon, so they do not carry meaning alone.
- Real-device VoiceOver pass (Russian/Traditional long strings) still recommended before App Store submission.
- Pro theme gating (A free / B,C Pro) is a product/StoreKit task, not part of this audit.
