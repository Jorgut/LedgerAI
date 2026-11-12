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

## 图标与动效（2026-11-12 后续修改，进入 1.1）

- 用户选择：1.0 保持现状（不重传），新图标与动效随 **1.1** 发布。
- 图标 v2：深绿科技渐变 + 青绿光晕 + 同心 HUD 圆环 + 局部青色弧线 + 内描边；白色钱包字形按**墨迹质心**视觉居中
  （解决"看起来偏右"），生成 1024 主图/19 尺寸/3 启动图全部通过尺寸与无 alpha 校验。
- 应用内科技感与交互动效（`lib/ui/motion/motion.dart`）：
  - 首页余额卡：TechBackdrop（光晕/HUD 圆环/弧线）+ 一次性扫光 + 金额滚动；
  - 首页卡片/最近记录：错峰淡入上移入场；快速记账卡片按压缩放 + 触感；
  - 报表：趋势柱状图生长、环形图展开、预算进度条动画；
  - 记账页：语音聆听呼吸圆环、OCR 扫描线；引导页图标光晕与页面入场；
  - 全部动效尊重系统「减少动态效果」，不使用无限循环（进行中状态除外），不影响 widget 测试 pumpAndSettle。
- 多语言：用户决定**英文放进 1.1**（与 IAP/图标同版）；沿用 `gen-l10n` + ARB 方案。
- 验证：`dart analyze lib` 无问题；模拟器截图确认新图标/启动图/首页科技卡片（`store/screenshots_raw/00_launch_tech.png`、`01_home_tech.png`）。
- 已知遗留：200% 系统字号下首页仍有横向溢出（既有问题，组件测试 6/7 通过、1 例失败）；已列入 1.1 无障碍修复，
  不要因为动效改动被误判为新回归（改动前即失败）。

## 旧版图标统一记录

- 用户反馈 App 图标（几何 ¥ + 小票框）与应用内左上角 Logo（Material 钱包图标）不统一，且更喜欢应用内样式。
- 已重写 `scripts/generate_icon.py` 与 `scripts/make_launch_images.py`：App 图标、LaunchImage、应用内 Header 现在使用**同一字形**
  `Icons.account_balance_wallet_rounded`（MaterialIcons 字体码位 0xF520）与同一渐变（#047857→#065F46），
  重新生成 1024 主图标、19 个 AppIcon 尺寸与 3 个 LaunchImage；校验尺寸/无 alpha 通过。
- 注意：1.0 已提交审核的二进制仍是旧图标；新图标随 1.1（或 1.0 被拒重提）生效。

## 多语言计划

- 1.1 优先做 IAP 与图标统一；英文 UI + App Store 英文本地化建议放 1.2（避免一次版本范围过大）。
- 实现方式：Flutter `gen-l10n` + ARB（先把现状硬编码中文抽成 `app_zh.arb`，再补 `app_en.arb`），
  权限文案用 `InfoPlist.strings`，商店文案/截图按语言单独配置；俄语视数据再定。

## OCR 真实小票问题（2026-11-12 真机反馈，已修复待发版）

- 用户用 TestFlight build 1 扫描真实小票（XX小酒香菜馆，小计 652 元），金额被错误填成 **¥2026.07**（来自小票日期 `2026.07.30`），商户/分类正确。
- 用 iOS Vision 在模拟器上复现并导出真实 OCR 文本，定位到解析器问题：
  1. 表头「金额」被当成合计关键词，导致向后找数字时取到单项 `1`；
  2. 日期/时间/电话数字未在金额扫描前剔除，兜底会选中 `2026.07`。
- 修复（`lib/ai/parsing.dart`）：
  - 金额扫描前抹掉日期（`2026.07.30` 等）、时间 `21:33`、电话；
  - 移除泛化的「金额 / amount / sum / 单价 / 数量」合计关键词，避免表头误触发；
  - 小计/合计类关键词后面若同行无金额，向后最多 10 行找独立数字并取最大值（兼容 OCR 列被拆散）；
  - 兜底小数再排除 1990–2100 的年份区间。
- 新增 `test/ai/receipt_amount_regression_test.dart`：真实设备 OCR 文本 + 用户小票 + 列拆散 + 只有日期四组回归，全部通过。
- 已构建并上传 **TestFlight build 2（1.0.0 (2)）**，处理完成（VALID）并加入「Personal Testing」内部测试组；
  构建包含：OCR 金额修复 + 新科技感图标/启动图 + 应用内动效。用户可在 TestFlight 更新测试同一张小票。
- 商店提交已按用户要求撤回并改提 **build 3（1.0.0 (3)）**：
  - build 3 = 简化版图标（去掉同心圆/弧线/HUD 边框）+ OCR 金额修复 + 应用内动效；
  - 6 张带中英文案排版的商店截图已替换上传（`store/screenshots_marketing/`）；
  - 2026-11-12T11:10Z 重新提交，状态 `WAITING_FOR_REVIEW`。
- 15 秒演示视频已生成：`store/marketing/demo_15s.mp4`（1080×1920，含小票→识别→隐私→CTA 四段）。
- 英文/买断 IAP 按用户决定推迟到 1.1，并与全球发布一起做。
- 外部 TestFlight：用户已创建外测组「Testing」并添加测试员 `409700385@qq.com`；原状态不可安装（无构建、无测试信息、无 Beta App Review）。
  已补齐：build 2 加入外测组、中文 Test Information/审核联系方式填写、**Beta App Review 已提交**（2026-11-12T02:41Z，`WAITING_FOR_REVIEW`）。
  Public link：`https://testflight.apple.com/join/nvHDDQQT`（Beta 审核通过后可用）；测试员状态目前 `NOT_INVITED`，审核通过后 Apple 自动发邀请。

## 1.1 开发启动（2026-11-12）

- 名称暂定 **A：衡账 - 不登录不联网的记账本**；用户继续研究单字「衡」与英文命名。
- 已实现第一块 **适老化**：
  - `AppSettings` 新增 `elderMode`、`fontScale`（标准/大/特大/超大，1.0/1.15/1.3/1.5）；
  - `MaterialApp.builder` 按设置覆盖 `TextScaler`，与系统字号取较大值；
  - 设置页新增「适老化」区块：父母模式开关 + 字体大小 ChoiceChip + 说明；
  - 父母模式自动开启高对比度（`AppTheme.light/dark(highContrast: true)`）。
- 已完成 1.1 迁移入口：**微信/支付宝账单 CSV 导入**（`lib/core/bill_import.dart` + 设置页入口），
  支持识别收支/商户/分类、跳过不计收支与失败交易、稳定 id 去重；单测 `test/core/bill_import_test.dart` 4/4 通过。
- 英文名确认为 **HENG**；App Store 名称暂定「衡账 - 不登录不联网的记账本」。
- iCloud 同步（第一版已接）：
  - Xcode 已自动开启 iCloud/CloudKit capability（`iCloud.com.archintera.ledgerai`）；
  - Txn 增加 `updatedAt`；本地 `deletions_v1` 墓碑盒；
  - `AppDelegate.swift` 增加 CloudKit 通道（status/pull/push，private database）；
  - `lib/sync/cloud_sync.dart` 全量合并同步（LWW + 墓碑）；
  - 设置页新增「iCloud 同步」开关 + 立即同步 + 上次同步时间（1.1 内测免费）。
- **TestFlight 1.1.0 (4)** 已上传并处理完成，已加入内部组「Personal Testing」：
  - 含适老化、微信/支付宝 CSV 导入、iCloud 同步第一版；
  - 需在两台登录同一 iCloud 的设备上验证；TestFlight 使用 CloudKit **Production** 环境，
    首次若报错需要去 CloudKit Dashboard 部署 schema（开发环境自动建 schema 后 Deploy to Production）。
- 待办 1.1：同步真机双设备验证、小组件、多账本、英文 UI/商店、Pro 买断 IAP、名称修改、WELTRIA「更多作品」入口。
- 1.2：Android + Google Play、家庭共享（CloudKit）、投资/理财轻量功能。



## 品牌视觉定稿（2026-11-12）

- 最终采用 **B2 极简启动页**：甲骨文「衡」直接使用，不抽象；HENG 130px；底部两行
  `PRIVATE LEDGER` / `DESIGNED BY ARCHINTERA`（同一字体/字号/字重，颜色区分主次）。
- 动效采用 **C 景深显影**：2.6s、单次、ease-out、可跳过、reduce-motion 降级；iOS LaunchScreen 静态，动效为 App 内冷启动开场。
- 最终资产目录：`store/marketing/brand/final/`
  - `launch.png`（1320×2868）
  - `launch_motion.mp4`（540×1174 预览；正式实现 1080×1920）
  - `ui_palette.png`（Forest Paper 色板，待应用）
  - `source/heng_oracle.svg`、`source/heng_reference.jpg`
- 已清理之前所有过程稿（mark/seals/oracle/launch/motion 草稿）。


- 启动页/品牌开场已落地（1.1 开发中）：
  - iOS LaunchScreen 使用与开场一致的深绿渐变背景（全屏、静态），避免与 Flutter 动效重复；
  - 新增 `lib/ui/brand_intro.dart`：2.6s 景深显影（甲骨模糊→清晰、HENG、副标、footer 依次淡入），可点击跳过，reduce-motion 降级为 400ms 淡入；商店截图模式与 widget 测试自动跳过；
  - 最终静态图仍以 `store/marketing/brand/final/launch.png` 为准；
  - 待发布前做真机/Release 验收。


- Forest Paper 色板已落地到 `lib/ui/theme.dart`、`lib/core/format.dart`、分类色与首页快捷入口：
  - Paper #F4F3EE / Ink #0B1F1A / Forest 700 #0B5B47 / Mint #CDEEE1 / Copper #B4845A；
  - 深色模式 #0B1512 / #111F1A；
  - 无障碍测试 4/4 通过；模拟器截图：`store/marketing/brand/final/home_forest_paper.png`。
- TestFlight 1.1.0 (5) 已上传（含品牌启动动效，未含色板）。
- TestFlight 1.1.0 (6) 已处理完成并挂到内部组「Personal Testing」：含品牌启动动效 + Forest Paper 色板（build 5 未挂组）。
- TestFlight 1.1.0 (7) 已处理完成并挂内部组：三套主题色，默认 A。

- 1.1 第 3 段（英文/小组件/IAP）已开始：新增 `docs/LOCALIZATION_PLAN.md` 与 `store/metadata_en.md`（英文商店文案）；UI 文案迁移、小组件、Pro IAP 后续分批执行。


## 三套主题色（2026-11-12）

- 默认 **A 清新**；设置 → 主题色可切换 A 清新 / B 森林 / C 清新森林；
- 三套都是完整的 ThemeExtension（`lib/ui/color_themes.dart`）：背景、主色、语义色、分类色、渐变一起切换；
- 分类色/环形图/快捷入口已改为从当前主题读取，不再依赖硬编码；
- 无障碍测试与核心测试通过；截图：`store/marketing/brand/final/theme_a_home.png`、`theme_a_settings.png`。


## 字号与版权修正（2026-11-12）

- 应用内字号：标准/大/特大/超大 + 滑块微调；标准 100% 对应用内基准 0.95 设计字号，解决“标准偏大”；
- 字号与系统字号改为**倍率叠加**，仍尊重系统无障碍放大；
- 父母模式不再把用户字号改成 1.3；开启时只临时提升到特大，关闭后回到用户选择的字号；
- 设置底部改为 `HENG PRIVATE LEDGER / DESIGNED BY ARCHINTERA`；
- 语言（简中/繁中/英/俄）为 1.1 下一项独立 i18n 工作，尚未加假选择器。

## 下一步

1. **待用户决定**：1.0 是否撤回并用 build 2 重提（仅 OCR 修复 + 可带新图标），或让 1.0 先过审、修复随 1.1 发布。
2. 等审核结果；被拒则修 → 重传（build 号 +1）→ 重新提交。
2. 真机 TestFlight 验收（相机/语音/权限/导出）。
3. 通过后确认自动上架，记录版本与审核结论；后续再做 Android（需安装 Android SDK）与英文/俄文本地化。
