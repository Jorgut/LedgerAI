# HENG / 衡记 · Security Audit

Date: 2026-11-14
Scope: iOS app code, local storage, CloudKit sync, file import/export, feedback/share, release configuration.
Version audited: 1.1.0 (19)

## Verdict

No critical or blocking vulnerability found.

One high-severity data-export issue was found and fixed (CSV formula injection).
One medium data-at-rest hardening was added (iOS file protection entitlement).

Remaining items are low/informational and can ship with 1.1 if accepted.

## Findings

### H-01 CSV formula injection — FIXED

`ExportService.buildCsv` wrote merchant/note/category directly to CSV. A value
beginning with `=`, `+`, `-`, or `@` can execute as a formula when opened in
Excel/Numbers (CSV injection).

Fix: prefix a leading apostrophe to those values before escaping. Regression test
in `test/core/export_test.dart` (15/15 pass).

### M-01 Data at rest — FIXED

Financial data (Hive) previously relied on the iOS default protection class.
Added:

```xml
<key>com.apple.developer.default-data-protection</key>
<string>NSFileProtectionComplete</string>
```

Verified in the release-signed IPA entitlements. The app is foreground-only for
ledger writes; no background sync writes are performed while locked.

### L-01 App switcher snapshot — OPEN / accepted for 1.1

When the app is backgrounded, iOS may snapshot the current screen, including
balances. A privacy blur overlay would improve this. Not a remote vulnerability;
defer to a privacy-polish pass.

### L-02 Imported file size — OPEN / accepted for 1.1

CSV/JSON import reads the whole file in memory. A malicious/accidental huge file
could cause memory pressure. Local user-initiated action; add a size cap later.

### I-01 No account / no third-party auth

No HENG account, no Sign in with Apple, no passwords, no tokens. Identity for
sync is iCloud; purchases will be StoreKit. This removes credential attack surface.

### I-02 Network surface

No third-party network calls in the app. CloudKit uses the user's private
database via Apple frameworks; no developer server. No ATS exceptions.
Future live FX must be re-audited (third-party API, China ICP position, privacy
policy, API-key handling).

## Checklist

- [x] No tracked secrets/API keys; `.env.asc` ignored and absent from history
- [x] No hardcoded credentials in app/release tools
- [x] No analytics/tracking SDKs
- [x] No ATS arbitrary-load exceptions
- [x] No app file-sharing / document exposure keys
- [x] Privacy manifest present; no tracking domains; no collected data
- [x] Plugin privacy manifests present in built app (share_plus, file_selector, image_picker, url_launcher, Flutter)
- [x] Hive files protected with NSFileProtectionComplete
- [x] CloudKit uses private database only; no public/shared DB yet
- [x] No amounts/notes/merchant logged; no print/debugPrint in lib
- [x] CSV injection neutralised + tested
- [x] Release IPA signs the data-protection entitlement
- [ ] App switcher privacy blur (low, deferred)
- [ ] Large import size cap (low, deferred)
- [ ] Re-audit StoreKit, CKShare, live FX before their release

## Verification commands

```bash
git ls-files | grep -Ei '\.env|key|secret|p8|p12'
git grep -nE 'BEGIN .*PRIVATE KEY|sk-[A-Za-z0-9]{20,}'
grep -nE 'NSAppTransportSecurity|UIFileSharingEnabled' ios/Runner/Info.plist
flutter test --no-pub test/core/export_test.dart
codesign -d --entitlements :- Payload/Runner.app
```

## Privacy manifest note

`ios/Runner/PrivacyInfo.xcprivacy` declares no tracking and no collected data,
which matches the current product. The bundled plugins ship their own manifests.
No app-level Required Reason API usage was found; re-check after adding new plugins.
