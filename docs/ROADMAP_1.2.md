# HENG / 衡记 · 1.2 Roadmap & Decisions

Updated: 2026-11-14

## Locked decisions

- One app, one bundle ID (`com.archintera.ledgerai`), one binary. Region behavior is gated at runtime by App Store storefront.
- Repo stays `Jorgut/LedgerAI`; GitHub description is `衡记 HENG · 本地优先的私密记账 App`.
- Free themes: **A Fresh**, **D Rose Paper**.
- Pro themes: **B Forest**, **C Fresh Forest**, **E Peach**, **F Lavender**.
- Pro is a one-time non-consumable (`com.archintera.ledgerai.pro`) and includes premium themes + real split + sharing.
- Early testers: permanent Pro promo codes (Apple Promo Code), only for testers who submit feedback.
- Beta: all themes/features free via a beta flag; production gates them.
- Global launch includes EU; EU DSA trader information must be supplied before EU distribution.
- China: no third-party live FX. Manual rates only, so the app remains offline/Apple-services-only for the China ICP exception.
- Sequence: ship manual FX globally → obtain China ICP exception → enable live FX only outside China. If China later needs live FX, complete APP/ICP filing instead.
- FX provider for non-China: Frankfurter (free, daily ECB rates), cached 24h, manual override.
- No server proxy is required for the free provider; never embed a paid API key in the client.

## Milestones

### M0 — 1.1 release readiness
- Hide `SHOW_SPLIT_PREVIEW` in production builds.
- Update App Store name/icon/screenshots/description/keywords for 衡记.
- Full test suite green; real-device OCR/voice/permission/offline QA.
- China ICP exception application (offline/Apple-only build).
- EU DSA trader info or exclude EU.

### M1 — Local split
- `SplitGroup`, `SplitParticipant`, `SplitExpense`; integer minor units.
- Hive persistence, tombstones, settlement calculator, tests.
- Home entry, group list/detail, add expense, balances, settle up.
- No CloudKit yet.

### M2 — StoreKit + theme gating
- StoreKit 2 non-consumable Pro, restore, transaction listener.
- Free A/D; Pro B/C/E/F; paywall; early-tester promo codes.
- Beta entitlement bypass.

### M3 — Region policy + manual FX
- `RegionPolicy` from StoreKit storefront; China = manual FX only.
- Manual rate entry + last-cached rate display.

### M4 — CloudKit sharing + non-China live FX
- CKShare per group; invite/join; LWW + tombstones.
- Frankfurter live rates outside China; China remains manual.
- Privacy policy / review notes for sharing and region behavior.
