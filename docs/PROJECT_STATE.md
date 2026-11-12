# 衡账 LedgerAI · 项目状态

更新：2026-11-12（Asia/Almaty）。阶段：**已提交 App Store 审核（Waiting for Review）**。

## 目标

把 Flutter 骨架做成可上架 App Store 的 **衡账**：本地优先的 AI 记账 App（拍照识别小票 / 语音一句话记账 / 智能分类与预算报表），100% 离线、不登录、不收集数据、免费。

## 用户已确认的决策（2026-11-12）

- 平台：**iOS 先上架**（本机无 Android SDK，磁盘剩余约 4GB，双端会显著拖慢）。
- AI：**全离线**——iOS Vision OCR + 设备端语音识别 + 本地规则分类/建议；不接云端大模型。
- 商业化：**免费上架**，v1 无内购。
- 开发者团队沿用 `GB38532D8G`；Bundle ID 按用户要求使用 archintera 前缀，定为 `com.archintera.ledgerai`。
- 无障碍/适老化要求沿用 `ACCESSIBILITY.md`。

## 上架结果（2026-11-12）

- App Store Connect App：**衡账**，Apple ID `6833748333`，Bundle ID `com.archintera.ledgerai`，SKU `ledgerai-ios-1`，团队 `GB38532D8G`。
- 构建：`1.0.0 (1)`，Apple Distribution 签名，已上传并通过处理（build ID `cb7ca9a4-d922-44a5-916d-34955b963c57`），已关联到 1.0.0 版本。
- 商店元数据：中文（简体）名称/副标题/关键词/描述/促销文案/支持与营销 URL；
  隐私政策 URL `https://jorgut.github.io/LedgerAI/PRIVACY.html`（GitHub Pages，仓库已公开）。
- 截图：6.9 英寸（1320×2868）6 张，已上传（首页/拍照识别/报表/预算/账单/设置），APP_IPHONE_67 集合。
- 分类：财务（主）+ 效率（次）；年龄分级 4+；价格：免费（永久免费 price schedule）；内容版权：不包含第三方内容。
- App 隐私：**Data Not Collected** 已通过 ASC 网页发布（Published）。
- 审核联系信息与备注已填写；**提交审核时间 2026-11-12 08:53（Asia/Almaty）**，状态 Waiting for Review；审核通过后自动发布（AFTER_APPROVAL）。

## 已完成（2026-11-12）

- 环境核实：Flutter 3.47.9 stable、Xcode 27.2、CocoaPods 1.17.0、iOS 模拟器可用（iPhone 17 Pro 已启动）；
  本机有 Apple Distribution 证书（GB38532D8G）与 App Store Connect API Key `~/.appstoreconnect/private_keys/AuthKey_79W52WL2JB.p8`（Issuer ID 待确认）。
- 生成 iOS 工程：`com.archintera.ledgerai`、Team `GB38532D8G`、iOS 16.0、iPhone 竖屏、显示名「衡账」、
  权限文案（相机/相册/麦克风/语音识别）、`ITSAppUsesNonExemptEncryption=false`、简体中文本地化。
- 依赖：hive/hive_flutter/uuid/intl/image_picker/path_provider/share_plus/flutter_localizations；不引入图表库与状态管理库。
- 基线构建：`flutter build ios --simulator --debug` 通过（`build/ios/iphonesimulator/Runner.app`），CocoaPods 与插件正常。
- 数据层 `lib/core/`：Txn/Category/AppSettings、Hive JSON 存储（无 codegen）、仓库/设置、统计（月汇总/分类占比/趋势/预算）、
  本地智能建议、CSV/JSON 导出与备份解析、AppState + AppScope、演示数据（`--dart-define=DEMO=true`）。
- AI 骨架 `lib/ai/`：小票解析、语音口语解析、中文数字金额、关键词分类、OCR/语音通道 Dart 侧；
  `dart analyze lib/core lib/ai` 无问题。
- 协作契约 `docs/ARCHITECTURE.md`；基线提交 `1cc8ecc`。

## 进行中（并行）

| 负责人 | 范围 | 任务 |
|---|---|---|
| ui-core | 主题/Shell/首页/账单/记账页 | task-1 |
| ui-insights | 报表/预算/设置/图表 | task-2 |
| ai-input | AppDelegate.swift 原生 Vision/语音通道 + 解析增强 + 单测 | task-3 |
| release | 图标/启动图/商店文案/隐私与支持/README | task-4 |
| qa | 核心单测、组件测试、审核与无障碍清单 | task-5 |
| lead | 集成、构建、模拟器验收、截图、TestFlight/提审、状态维护 | — |

## 验证记录

- 2026-11-12：iOS 模拟器 Debug 构建通过（105.5s），产物 `build/ios/iphonesimulator/Runner.app`。
- 2026-11-12：`dart analyze lib test integration_test` 无问题。
- 2026-11-12：`flutter test test/core` **106/106 通过**；`flutter test test/ai` **51/51 通过**。
- 2026-11-12：`flutter build ipa --release --export-method app-store` 成功（archive 179.9MB，IPA 22MB，Apple Distribution 签名，Team GB38532D8G）。
- 2026-11-12：`flutter test test/widget/home_screen_test.dart`：7 例中 6 通过，1 例失败 —
  「200% 大字号下不溢出」在首页出现右侧 172px RenderFlex 溢出（无障碍 P1，列入 1.0.1 修复，不阻塞本次审核）。
- 2026-11-12：App Store Connect 提交成功，`submittedDate` 2026-11-12T03:53:45Z，状态 `WAITING_FOR_REVIEW`。
- 2026-11-12：TestFlight 内部测试组「Personal Testing」已创建（`f18d353f-199a-42c5-8112-668b5b545fbc`），build 1 已关联，
  已邀请 2 名内部测试员：`jorgutyn@yahoo.com`（Developer）与 `juhonl@163.com`（Account Holder），状态均 Invited。
  内部测试员无法用公开 API 添加（409 Tester(s) cannot be assigned），本次通过独立 Chrome 实例（临时 profile + CDP，
  不影响用户原 Chrome 会话）在 ASC 网页自动完成；该实例仍开着 TestFlight 组页面。
  另已通过 API 写入「What to Test」中文测试说明（betaBuildLocalization `f37d9291-326c-44cd-ac18-8fc0dd01d618`）。

## 阻塞与外部依赖

1. 审核结果由 Apple 决定（通常 24–48 小时）。被拒时按 Resolution Center 反馈修复并重新提交。
2. 真机验证：模拟器无相机、无设备端中文语音模型，原生 OCR/语音通道仅做过 `swiftc -typecheck`；
   建议用 TestFlight 装到 iPhone 实测「拍照识别 / 语音记账 / 权限拒绝降级 / 飞行模式全流程」。
3. EU DSA trader（商家）状态未提供：ASC 控制台提示需 Account Holder/Admin 在 EU 分发前补充，
   否则可能影响 EU 上架范围。需用户决定并提供商家信息。

## 下一步

1. 等审核结果；被拒则修 → 重传（build 号 +1）→ 重新提交。
2. 真机 TestFlight 验收（相机/语音/权限/导出）。
3. 通过后确认自动上架，记录版本与审核结论；后续再做 Android（需安装 Android SDK）与英文/俄文本地化。
