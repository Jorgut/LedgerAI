# 衡账 LedgerAI · 项目状态

更新：2026-11-12（Asia/Almaty）。阶段：v1.0 iOS 上架冲刺中。

## 目标

把 Flutter 骨架做成可上架 App Store 的 **衡账**：本地优先的 AI 记账 App（拍照识别小票 / 语音一句话记账 / 智能分类与预算报表），100% 离线、不登录、不收集数据、免费。

## 用户已确认的决策（2026-11-12）

- 平台：**iOS 先上架**（本机无 Android SDK，磁盘剩余约 4GB，双端会显著拖慢）。
- AI：**全离线**——iOS Vision OCR + 设备端语音识别 + 本地规则分类/建议；不接云端大模型。
- 商业化：**免费上架**，v1 无内购。
- 开发者团队沿用 `GB38532D8G`；Bundle ID 按用户要求使用 archintera 前缀，定为 `com.archintera.ledgerai`。
- 无障碍/适老化要求沿用 `ACCESSIBILITY.md`。

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
- 2026-11-12：`dart analyze lib/core lib/ai` 无问题；`dart analyze lib/ui` 待 UI 落地后验证。

## 阻塞与外部依赖（需要用户处理时再确认）

1. **App Store Connect 应用记录**：尚未创建。需要 ASC Issuer ID 才能用现有 API Key 自动建记录，或在 ASC 网页手动创建「衡账」App（Bundle ID `com.archintera.ledgerai`）。
2. 审核提交需要用户对具体 App 记录/版本做最终确认（付费账号下的对外发布动作）。
3. 磁盘仅剩约 4GB，iOS Release archive 前需清理旧构建缓存（DerivedData/旧模拟器），避免空间不足。

## 下一步

1. 合并 UI/AI/物料，`flutter analyze` + `flutter test` + 模拟器全流程验收。
2. DEMO 模式截图（6.9"/6.7"）→ 元数据 → archive → TestFlight → 提审。
3. 上架后记录版本号、审核状态与后续 Android 计划。
