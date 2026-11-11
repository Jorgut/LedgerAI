# 衡账 LedgerAI · 开发架构与协作约定

更新：2026-11-12。本文件是所有并行开发者的唯一接口约定。**先读本文件，再写代码**。

## 1. 产品与发布决策（已由用户确认）

- 产品：**衡账**，本地优先的 AI 记账 App（拍照识别小票 / 语音一句话记账 / 智能分类与建议）。
- v1 只上 **iOS App Store**（iPhone、竖屏、iOS 16+）。Android 后续版本再做。
- **全离线**：不登录、不联网、不做云同步、不上传任何用户数据。所有识别与建议都在本机完成。
- **免费**上架，v1 不做内购。
- Bundle ID：`com.jorgut.ledgerai`；开发团队：`GB38532D8G`；版本 `1.0.0+1`。
- 隐私口径：App Store 隐私标签为「Data Not Collected」。不得引入会把数据发到服务器的依赖或代码。

## 2. 技术栈与工程约定

- Flutter 3.47.9 / Dart 3.13.7，Material 3。
- 依赖只用 `pubspec.yaml` 中已有的：hive、hive_flutter、uuid、intl、image_picker、path_provider、share_plus、flutter_localizations。**不要擅自加依赖**；需要时找 Lead 确认。
- 不使用 Hive codegen（`lib/models/transaction.g.dart`、`hive_generator`、`build_runner` 都已废弃）。交易以 JSON 字符串存入 Hive。
- 状态管理只用 Flutter 自带 `ChangeNotifier` + `InheritedNotifier`（见 `lib/core/app_state.dart` 的 `AppState` / `AppScope`）。
- UI 文案全部简体中文；数字金额统一用 `lib/core/format.dart` 的 `formatMoney`。
- 无障碍底线（见 `ACCESSIBILITY.md`）：主要按钮 ≥ 48dp；所有图标按钮带 `tooltip`/`semanticLabel`；正文 ≥ 16sp；大字号下不溢出（必要时用 `Wrap`/`FittedBox`/滚动）；`Semantics` 标注金额与收支方向。
- 深浅色两套主题都要能看；高对比度模式在 `AppSettings.highContrast`。
- **工作方式**：只改自己 scope 内的文件；不执行 `flutter`/`xcodebuild`/`pod` 等构建命令（沙盒会拒绝，且由 Lead 统一构建）；可用
  `/Users/aj/Development/flutter/flutter/bin/cache/dart-sdk/bin/dart analyze <自己的目录>` 做静态检查（在项目根目录执行）。
  不执行 `git commit`/`git push`（Lead 统一提交）。
- 完成后用 `send_message` 向 lead 汇报：改动文件清单、已实现能力、已知问题、需要 Lead 做什么。

## 3. 目录与写权限（严格）

| 目录/文件 | 所有者 | 说明 |
|---|---|---|
| `lib/core/**`（models、storage、stats、insights、export、app_state、format、demo_data、app_settings） | Lead | 数据层已实现，只读使用 |
| `lib/ai/parsing.dart`、`lib/ai/ocr_service.dart`、`lib/ai/speech_service.dart` | ai-input | 解析规则、OCR/语音通道的 Dart 侧 |
| `lib/ui/theme.dart`、`lib/ui/widgets/common/**`、`lib/ui/screens/{root_shell,onboarding,home,transactions,add_transaction}.dart` | ui-core | 主题、通用组件、主流程界面 |
| `lib/ui/widgets/charts/**`、`lib/ui/screens/{reports,budget,settings,legal}.dart` | ui-insights | 报表/预算/设置/法务页与图表 |
| `ios/Runner/AppDelegate.swift`（原生通道全部写在这一个文件，避免改 pbxproj） | ai-input | 原生通道 |
| `ios/Runner/Assets.xcassets/**`、`assets/**`、`store/**`、`scripts/**`、`PRIVACY.md`、`SUPPORT.md`、`README.md` | release | 图标、启动图、商店物料、隐私政策 |
| `ios/Runner/Info.plist`、`ios/Runner.xcodeproj/**`、`pubspec.yaml`、`lib/main.dart`、`lib/app.dart` | Lead | 工程配置 |
| `test/core/**`、`test/widget/**`、`integration_test/**`、`docs/QA*.md` | qa | 测试与审核检查 |
| `test/ai/**` | ai-input | 解析规则单测 |
| `docs/ARCHITECTURE.md`、`docs/PROJECT_STATE.md` | Lead | 状态文档 |

## 4. 数据层 API（已实现，直接调用）

```dart
// lib/core/models.dart
enum EntrySource { manual, ocr, voice }        // label 为中文字符串
class Txn { id, amount(>0), categoryId, date, note, isIncome, source, merchant?, createdAt;
  Txn copyWith({...}); Txn.fromJson/toJson; Category get category; }
class Category { id, name, icon, color, isIncome; static all/expenses/incomes/byId/forType }
class AppSettings { onboardingDone, themeMode, highContrast, monthlyBudget?, categoryBudgets, hapticsEnabled, biometricLock; copyWith/fromJson/toJson }

// lib/core/app_state.dart
class AppState extends ChangeNotifier {
  TransactionRepository get repo;
  SettingsStore get settings;
  StatsService get stats;
  InsightsService get insights;
  ExportService get export;
  AppSettings get prefs;
  List<Txn> get transactions;
  List<Txn> transactionsOf(DateTime month);
  Future<void> addTransaction(Txn);
  Future<void> saveTransaction(Txn);   // 新增与编辑共用
  Future<void> deleteTransaction(String id);
  Future<void> updateSettingsWith(AppSettings Function(AppSettings) transform);
  Future<int> importBackup(String raw);
  Future<void> clearTransactions();
  static AppState forStore(LocalStore), static Future<AppState> create()
}
class AppScope extends InheritedNotifier<AppState> {
  static AppState of(BuildContext);    // 订阅变化
  static AppState read(BuildContext);  // 不订阅
}

// lib/core/stats.dart
class MonthSummary { income, expense, count; balance; isEmpty }
class CategorySlice { category, amount, ratio(0..1) }
class MonthPoint { year, month, income, expense }
class StatsService {
  MonthSummary summary(int year, int month);
  List<CategorySlice> breakdown(int year, int month, {bool isIncome = false});
  List<MonthPoint> trend({int months = 6, DateTime? end});
  double todayExpense({DateTime? now});
  double? budgetRatio(double? monthlyBudget, int year, int month);
}

// lib/core/insights.dart
enum InsightTone { positive, warning, neutral }
class Insight { title, body, tone, metric? }
class InsightsService { List<Insight> forMonth(DateTime month, {AppSettings? settings}); }

// lib/core/export.dart
class ExportService { String buildCsv(List<Txn>); String buildBackup(List<Txn>, AppSettings);
  static List<Txn>? parseBackupTransactions(String raw); }

// lib/core/format.dart
formatMoney, formatCompactMoney, formatDateLabel, formatMonthLabel, formatMonthShort,
formatWeekday, isSameMonth, firstDayOfMonth, lastDayOfMonth, addMonths, parseAmount,
kBrandColor(#10B981), kBrandDark(#059669)
```

## 5. AI 输入层（ai-input 负责实现/完善）

Dart 侧（Lead 已写好骨架，ai-input 完善）：

```dart
// lib/ai/parsing.dart — 纯 Dart，可单测
class ParsedReceipt { amount?, date?, merchant?, categoryId?, note, rawText; bool hasUsefulData }
class ReceiptParser { ParsedReceipt parse(String rawText); }
class TextCategorizer { String? categorize(String text, {required bool isIncome}); }
class VoiceEntryParser { ParsedReceipt parse(String spoken); }

// lib/ai/ocr_service.dart
class OcrResult { String text; List<String> lines; }
class ReceiptOcr { Future<OcrResult?> recognizeFile(String path); }

// lib/ai/speech_service.dart
class SpeechResult { String text; bool isFinal; String? error; }
class SpeechRecognizer {
  Stream<SpeechResult> get results;   // EventChannel 广播流
  Future<bool> isAvailable();
  Future<void> start({String localeId = 'zh-CN'});
  Future<void> stop();
  Future<void> cancel();
}
```

原生通道协议（Swift 必须严格匹配）：
- `MethodChannel('com.jorgut.ledgerai/ocr')`，方法 `recognizeText`，参数 `{'path': String}`，
  返回 `{'text': String, 'lines': List<String>}`；失败返回 `FlutterError`。
- `MethodChannel('com.jorgut.ledgerai/speech')`：`isAvailable` → bool；`start` 参数 `{'localeId': String}`；`stop`；`cancel`。
- `EventChannel('com.jorgut.ledgerai/speech_events')` 发出 Map：`{'type': 'partial'|'final'|'error'|'state', 'text': String?, 'message': String?, 'state': 'listening'|'idle'?}`。
- OCR 用 iOS Vision `VNRecognizeTextRequest`（zh-Hans + en，accurate）。语音用 `SFSpeechRecognizer`，
  **必须要求设备端识别**（`requiresOnDeviceRecognition = true`），不可用时 `isAvailable` 返回 false 并给出中文提示；
  不得把音频写入磁盘或上传。注意 `NSSpeechRecognitionUsageDescription`、`NSMicrophoneUsageDescription` 已在 Info.plist 配置。

## 6. UI 层约定（ui 负责）

`lib/ui/theme.dart`：

```dart
class AppTheme {
  static ThemeData light({bool highContrast = false});
  static ThemeData dark({bool highContrast = false});
}
```

`lib/ui/screens/` 必须提供这些 Widget（构造函数签名不可改，Lead 的 `lib/app.dart` 依赖）：

- `RootShell`：4 个 Tab（首页 / 账单 / 报表 / 我的），顶部或底部导航 + 记账 FAB；点击 FAB 打开 `AddTransactionScreen`。
- `HomeScreen`：本月结余 / 收入 / 支出、预算进度、最近交易、快速入口（拍照 / 语音 / 手动）。
- `TransactionsScreen`：按月份筛选、分类筛选、搜索、分组列表、左滑删除、点击编辑；空状态。
- `AddTransactionScreen({Txn? transaction, ParsedReceipt? initialReceipt})`（可额外加可选参数，但这两个必须保留）：收支切换、大号金额输入、
  分类选择、备注、日期、保存/更新、删除（编辑时）；入口包含「拍照识别」「语音记账」「手动」。
- `ReportsScreen`：月份切换、趋势柱状/折线图、分类占比环形图与列表、智能建议卡片。
- `BudgetScreen`：月度总预算 + 分类预算设置，进度条、超支提示。
- `SettingsScreen`：主题（跟随系统/浅色/深色）、高对比度、触觉反馈、数据导出 CSV/JSON（share_plus）、
  清空数据（二次确认）、隐私政策/用户协议（应用内页面）、关于与版本号。
- `OnboardingScreen({required VoidCallback onDone})`：首次启动 2-3 屏介绍（本地隐私、拍照/语音记账），完成后写入 `onboardingDone`。
- 图表一律用 `CustomPainter` 或基础 Widget 自绘，**不要引入图表库**。第一版不做登录/注册、微信/支付宝绑定、假用户昵称与假连续天数。

设计参考：仓库根目录 `AI记账APP原型.html`（8 屏原型，浏览器打开可看）。品牌绿 `#10B981`，卡片圆角 16，
浅色背景 `#F6F7F9`，深色背景 `#0F1419`；金额用 tabular 数字（`FontFeature.tabularFigures()`）。

## 7. 发布（release 负责）

- App 图标：1024×1024 无 alpha PNG + 各尺寸 AppIcon（iOS 26 单尺寸即可，但保留 `Contents.json` 合法）。
  风格：品牌绿渐变 + 白色「衡/¥」账本或扫描小票意象，不要文字堆叠。
- 启动图：纯色/渐变 + 居中图标文字，`LaunchScreen.storyboard` 已存在，替换资源即可。
- 商店物料（中文）：`store/metadata_zh.md`（名称 ≤30 字、副标题 ≤30 字、关键词 ≤100 字、描述、促销文案、审核备注）、
  `store/privacy_labels.md`（Data Not Collected 逐项依据）、`store/screenshots_plan.md`（6.9"/6.7" 尺寸要求与每张文案）。
- `PRIVACY.md`、`SUPPORT.md`（中文，可放 GitHub Pages）；App 内隐私政策/用户协议页面内容来源。
- `README.md` 更新为真实功能与构建说明；`scripts/` 放图标生成与截图脚本（Python/PIL 可用）。
- 不碰 `ios/Runner.xcodeproj`、`Info.plist`、`lib/**`。

## 8. 里程碑

1. 数据层 + 工程骨架（Lead）——进行中。
2. UI 全屏实现（ui）；AI 原生通道与解析（ai-input）；图标/物料/文档（release）——并行。
3. Lead 集成构建、模拟器验收、修复、无障碍与 QA。
4. 截图 → App Store Connect → TestFlight → 提审。
