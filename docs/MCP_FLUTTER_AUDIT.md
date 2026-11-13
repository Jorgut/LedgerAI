# mcp_flutter Audit (read-only)

Date: 2026-11-14
Repo: https://github.com/Arenukvern/mcp_flutter
Commit audited: 04506a1 (v7.1.1), MIT, ~397 stars, updated 2026-11-14

## What it is

A Dart MCP server + Flutter package for agent-driven debug automation:

- discover running debug apps / attach to VM service;
- semantic snapshots, tap/type, hot reload, logs, screenshots;
- app-registered custom MCP tools;
- optional external AI error summarization (OpenAI), off by default.

## Static security review

Skill Atlas scanner over the repo:

- targets: 35
- unsafe: 5 (all `curl ... | bash` install snippets in documentation)
- review-needed: 8 (examples containing secret placeholders, agent config, network links)
- safe: 22

Notable:

- `install.sh` downloads GitHub release binaries and **verifies SHA-256** before install.
- It installs to `~/.local/bin` and appends that path to the user's shell rc file.
- The server talks to local VM service/WebSocket endpoints and localhost HTTP; no telemetry found.
- Optional OpenAI summary posts diagnostics only when `summaryProvider=openai` + `allowExternalSummary=true`; defaults are `none` + false.
- No obfuscated payloads or destructive commands found in runtime source; the `unsafe` findings are installation docs, not hidden behavior.

## Integration cost

`flutter-mcp-toolkit codegen-init`:

- adds `mcp_toolkit` to the Flutter app;
- emits a `main.dart` snippet;
- writes agent/MCP config.

This must be treated as an **isolated dev-only branch**, not a production dependency.

## Verdict

**Conditionally safe to trial in an isolated worktree; do not install into this repo yet.**

Reasons to trial:

- strong fit for live flow QA, especially localization/typography/large-text and the upcoming split flow;
- complements `flow-walkthrough` (XCUITest) with live widget-tree inspection and hot reload.

Reasons not to adopt now:

- adds app dependency and modifies `main.dart`;
- new/low-risk but still third-party debug tooling;
- 1.1 is in release/QA; don't destabilize it;
- installer writes shell config; avoid `curl | bash` and build/run from source instead.

## If approved: trial protocol

1. `git worktree add /tmp/heng-mcp-trial` (never the main worktree).
2. Build/run the server from source; do not run `curl | bash`.
3. Do not set `OPENAI_API_KEY`; keep `summaryProvider=none`, `allowExternalSummary=false`.
4. Add `mcp_toolkit` only in the trial worktree; verify `flutter build ipa` has no release impact.
5. Use it to inspect/tap/screenshot: language switching, long amounts, split flow, dark themes.
6. Network check: localhost VM service only; no unexpected outbound traffic.
7. Keep the trial branch out of releases; remove dependency before merge.
8. Re-run the full analyzer/tests in the trial branch.

## What it does NOT solve

- no CloudKit sharing helper;
- no StoreKit/IAP helper;
- no split data model;
- no App Store review automation.

For those, continue native/Flutter implementation plus local Apple release/privacy skills.
