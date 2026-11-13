# HENG Theme Strategy / v1.1

## Recommendation for launch

**Three themes total: 1 free + 2 Pro.**

| Theme | Tier | Role |
|---|---|---|
| A Fresh | Free default | Bright, cool, youthful; best first impression for Xiaohongshu |
| B Forest | Pro | Warm paper + deep forest; calm, premium |
| C Fresh Forest | Pro | Cool green-white + mint highlight; fresh but grown-up |

Why not more:

- 3 is enough to signal personalization without making the settings page a theme store.
- More themes multiply QA (contrast, charts, dark mode, screenshots) and dilute the Pro value.
- A is the acquisition theme; B/C are the "I want my app to feel like mine" upgrade.

Future: add one seasonal/lifetime theme per year, not per month.

## Micro-adjustments per theme (recommended, not just color swap)

Keep **layout, spacing, typography scale unchanged**; vary only tokens + one decorative layer.

### A Fresh (free)
- Flat white cards, cool `#F6F7F9` canvas.
- Emerald balance gradient; vivid category colors.
- No texture, no hairline; icons on solid pastel chips.
- Voice: optimistic, light.

### B Forest (Pro)
- Warm paper `#F4F3EE`, white cards, **copper hairline** on the balance card / dividers.
- Deep forest gradient, no mint glow; category colors muted.
- Optional 2–3% paper grain on the balance card only.
- Voice: quiet, editorial, premium.

### C Fresh Forest (Pro)
- Cool green-white `#F7FAF7`, white cards, **thin mint border** (`#CDEEE1` 40%).
- Balance card: deep forest base + **soft aurora/radial mint glow** (static, not animated).
- Mint accent for progress and selected states; teal category palette.
- Voice: fresh, glassy, modern.

## Where the theme should show up

1. Home balance card (gradient + one decorative layer)
2. Primary buttons / progress / selected chips
3. Category colors & charts
4. Settings swatches and tiny preview
5. App icon? **No** — icon stays Aurora Halo for brand consistency.

Do **not** change layout or navigation per theme.

## Pro gating

- `AppColorTheme.fresh` = free.
- `AppColorTheme.forest` / `freshForest` = Pro.
- Theme selector shows a small `PRO` lock; tapping opens paywall.
- Pro is a one-time non-consumable IAP; restore purchases required.
- StoreKit gating is **not implemented yet**; current build shows all three selectable.

## QA matrix (required before launch)

- A/B/C × light/dark × four languages
- WCAG AA contrast; long amounts; 200% text; VoiceOver
- Charts + category colors + insights
- Screenshot set regenerated per theme, not recolored in design tools

## Open decisions

- Price of Pro (suggest one-time, not subscription).
- Whether C is included in Pro or sold as a separate "Fresh Pack" later.
- Whether B/C get theme-specific empty-state illustrations (recommended: one small motif each, not full redesign).
