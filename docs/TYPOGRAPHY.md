# HENG Typography / 1.1

## Problem

Chinese UI looked uneven and slightly blurry:

- App applied `0.95` fractional text scaling on top of system text size.
- CJK headings used `w700`, which triggers uneven synthetic bold on PingFang.
- Latin and Chinese fell back independently without an explicit CJK fallback.
- Body line-height was 1.5, tight for Chinese paragraphs.

## Changes

- Removed fractional `0.95` scaling; in-app font size now multiplies system size directly.
- New integer type scale:
  - display 46 / 38 / 32
  - headline 29 / 27 / 23
  - title 21 / 17 / 15
  - body 16 / 15 / 13
  - labels 15 / 13 / 12
- Heading weights: `w600` (was `w700`); body `w400`.
- Body line-height 1.55; bodySmall 1.5.
- Explicit CJK fallback: PingFang SC → PingFang TC → Hiragino Sans GB → Noto Sans CJK SC.
- Amounts keep tabular figures and Latin SF rendering.

## Why

- Integer font sizes avoid half-pixel CJK rasterization.
- w600 PingFang semibold is native weight; w700 is synthesized and uneven.
- More line-height improves Chinese paragraph rhythm.
- Explicit fallback prevents accidental Japanese/Korean glyph variants.

## Open question

If PingFang still feels too "system default", next options:

1. Bundle **Source Han Sans SC** regular + semibold (larger app size, consistent across iOS/Android).
2. Use **Songti SC** for large editorial headings only (premium, more feminine), keep PingFang for UI.
3. Pair **Inter** for Latin/amounts + PingFang for Chinese (best mixed-script match).

Do not ship a custom font until Chinese/English/Russian QA is complete.
