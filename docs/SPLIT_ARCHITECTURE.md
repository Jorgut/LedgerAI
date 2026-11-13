# Split / 分账 Architecture (1.2)

Status: design agreed; not implemented yet.

## Product correction

- Split is **generic**, not travel-only: dinner, rent, trip, gifts.
- No bottom-nav tab. Entry is a **Home ledger card** ("Split").
- Detail page is pushed full-screen; back returns to the ledger.
- Travel is one `kind` of split group, not a separate product.

## Local data model

```text
SplitGroup
  id, title, kind (meal|trip|rent|other), baseCurrency,
  createdAt, updatedAt, archived, ownerId, cloudShareId

SplitParticipant
  id, groupId, displayName, iCloudUserRecordId?, role, joinedAt

SplitExpense
  id, groupId, payerId, amountMinor, currency, fxRate,
  baseAmountMinor, shares: Map<participantId, shareMinor|weight>,
  categoryId, date, note, createdBy, updatedAt

SplitSettlement (computed, not stored)
  balances: Map<participantId, int minor>
  transfers: [{fromId, toId, amountMinor}]
```

Rules:

- Money is integer minor units; never floats in storage.
- Group base currency is set once; each expense keeps original currency + rate.
- Equal split = weight 1 each; custom split = explicit shares; sum must equal amount.
- Settlement algorithm minimizes transfers (greedy debtors/creditors).
- Tombstones + `updatedAt` for LWW, same pattern as transactions.

Storage: Hive `split_groups_v1`, `split_expenses_v1`, `split_participants_v1`, tombstones box. Migration from no schema is additive.

## CloudKit sharing

- One `CKRecord` per `SplitGroup` in the user's private DB.
- `CKShare` attached to the group; participants join via iCloud share URL.
- Shared zone with read/write; organizer owns group metadata; participants can add expenses.
- Merge strategy: LWW by `updatedAt`; deletions via tombstones; ignore unknown participants until joined.
- Developer has no server; data remains in participants' iCloud.
- iOS-only at first. Android cross-platform sharing will need a separate backend and is **out of 1.2 scope**.

Security/privacy:

- No public links; share URL is capability.
- Do not upload to a developer server.
- Privacy policy must state split data is shared with invited participants via iCloud.
- No public user-generated content; App Store 1.2 review note prepared.

## Real-time FX

- `FxRateService` fetches rates for currency pairs (base/quote), caches daily.
- API sends only currency codes; never amounts, merchants, participants, or user IDs.
- Offline: use last cached rate and show "rate as of <date>".
- Manual override per expense; settlement uses group base currency.
- Available only for Pro/split (online feature); core ledger remains offline.
- Provider: select one with clear terms/SLA (e.g. Frankfurter/ECB, open-er-api) and add retry/fallback. No API key in client if possible.

## StoreKit / theme gating

- Product: one non-consumable Pro (`com.archintera.ledgerai.pro`) including:
  - B/C (and D/E/F) Pro themes,
  - split groups + iCloud share,
  - live FX,
  - future theme pack updates.
- StoreKit 2 via native channel; verify transactions; restore purchases.
- Theme selector: free = Rose Paper; Pro themes locked with `PRO` badge; tapping opens paywall.
- Invited participants can join and view a split **without Pro**; only the organizer needs Pro (growth loop).
- App Store: digital unlock must use IAP; no external payment links.

## Delivery order

1. Local split model + repository + calculator + tests.
2. Home entry + group list/detail + create/edit expense (local only).
3. CloudKit share (create/join, merge, conflict tests).
4. FX service + cache + UI.
5. StoreKit + theme gating + restore.
6. Privacy/store metadata, TestFlight, review.

No fake "Preview" entry in production; the card is behind a feature flag until step 2 is complete.

## Non-goals for 1.2

- Android cross-platform split sync.
- Chat / comments in split.
- Automatic bank import into split.
- Subscription; Pro remains one-time.
