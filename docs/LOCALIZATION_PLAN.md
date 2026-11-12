# 1.1 英文本地化计划（HENG）

更新：2026-11-12。目标：中英双语 UI + en-US App Store 页面，配合全球发布。

## 范围

- UI 文案：`lib/ui/**` 硬编码中文（约 400 条），不含 `lib/ai/parsing.dart` 的识别关键词与 demo 数据；
- 启动/品牌：HENG、PRIVATE LEDGER、DESIGNED BY ARCHINTERA 已为英文，仅中文 tagline 需按语言切换；
- App Store：en-US 名称/副标题/描述/关键词/截图；
- 法务：PRIVACY/SUPPORT 已有英文？需补英文版本；
- 不翻译：OCR/语音规则关键词、内置分类 id。

## 技术方案

1. `l10n.yaml` + ARB：`lib/l10n/app_zh.arb`（模板）、`app_en.arb`；
2. 使用 `flutter gen-l10n` 生成 `AppLocalizations`；
3. `MaterialApp` 的 `supportedLocales` 加 `en`，`locale` 跟随系统/设置；
4. 逐屏替换硬编码中文为 `AppLocalizations.of(context).xxx`；
5. 金额/日期格式按 locale（`intl` NumberFormat/DateFormat）；
6. 测试：widget 测试跑 zh/en 两套；RTL 暂不需要。

## 优先级

1. 设置 → 首页 → 记账 → 报表 → 预算 → 账单 → 引导 → 法务；
2. App Store en-US 元数据与截图；
3. 英文版启动页 tagline（`Bookkeeping that stays on your phone.`）与英文商店文案。

## 风险

- 一次性替换 400 条文案容易漏；按屏分批、每批 `flutter analyze` + 截图回归；
- 中文文案里带占位符/金额，需要 ICU plural/format；
- 分类名既是 UI 又是导出字段：导出保持 id，UI 用 localization。

## 下一步

- 先搭 l10n 基础 + 设置页 pilot，再逐屏迁移；预计 2–3 个开发批次。
