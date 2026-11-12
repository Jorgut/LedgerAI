# 衡账 LedgerAI · 上线前 QA 检查清单

版本对象：`1.0.0 (1)` · Bundle ID `com.archintera.ledgerai` · Team `GB38532D8G`
目标：iOS App Store 首发（iPhone、竖屏、iOS 16+、免费、无登录、全离线）。
用法：逐项打勾；未完成项写清责任人（Lead / ui / ai-input / release / qa）。**任何 P0 未通过不得提审。**

---

## 0. 自动化测试门禁（qa）

- [ ] `flutter analyze` 无 error（warning 需逐条说明）
- [ ] `flutter test test/core` 全绿（models / format / storage / stats / insights / export 共 6 个文件）
- [ ] `flutter test test/widget` 全绿（8 个文件：home / add_transaction / transactions / reports / budget / settings / root_shell / accessibility + `test_support.dart` 脚手架）
- [ ] `flutter test integration_test/smoke_test.dart -d <iOS 模拟器>` 通过（启动 → 首页 → 记一笔 → 列表出现；独立 Hive 子目录 `qa_smoke`）
- [ ] `flutter test test/ai`（ai-input 负责的解析单测）全绿
- [x] 旧骨架 `test/widget_test.dart`（引用不存在的 `MyApp`）已删除（Lead，2026-11-12）；`dart analyze test` 已无 error
- [x] `test/widget/test_support.dart` 已完成：真实 Hive + `AppState.forStore` 注入、iPhone 390×844 画布、200% 字号、48dp 点击区、溢出断言、平台通道桩（触觉/语音/OCR）
- [ ] 本地 Hive 相关测试不残留临时目录（`Directory.systemTemp` + `tearDown` 已清理）

## 1. 构建 / 签名 / 版本号（Lead）

- [ ] Flutter 3.47.9 / Dart 3.13.7；`flutter pub get` 干净，无新增依赖、无 dependency_overrides
- [ ] `flutter clean && flutter pub get && flutter build ipa --release` 成功（Archive 无 signing error）
- [ ] Bundle ID `com.archintera.ledgerai`；DEVELOPMENT_TEAM `GB38532D8G`；Automatic signing 生效
- [ ] 版本：`pubspec.yaml` 为 `1.0.0+1` → 包内 `CFBundleShortVersionString=1.0.0`、`CFBundleVersion=1`；提审被拒后每次重传 build 号必须 +1
- [ ] 部署目标 iOS 16.0；TARGETED_DEVICE_FAMILY=1（仅 iPhone）；`UISupportedInterfaceOrientations` 仅 Portrait
- [ ] `ITSAppUsesNonExemptEncryption=false` 已写入 Info.plist（本 App 无自带加密、无网络，出口合规答案选“否”）
- [ ] Release 构建含 dSYM，Archive 已上传；App Store Connect 的 “缺少符号” 警告为 0
- [ ] 无 `--dart-define=DEMO` 混入正式包；正式包不写入示例数据（DemoData 仅在显式 DEMO 时调用）
- [x] `ios/Runner/PrivacyInfo.xcprivacy` 已存在并接入 pbxproj Resources：`NSPrivacyTracking=false`、`NSPrivacyCollectedDataTypes=[]`、`NSPrivacyAccessedAPITypes=[]`（Lead，2026-11-12）
- [ ] Archive 后在 Xcode Organizer 执行 “Generate Privacy Report”，确认 Flutter 引擎与各插件 framework 的 required-reason 声明齐全（工程自身无 required-reason API；path_provider / share_plus 等由插件自带 manifest 覆盖）
- [ ] App 图标 1024×1024 无 alpha、无圆角；LaunchScreen 正常，无白屏/黑屏闪跳
- [x] 旧骨架 `lib/screens/**`、`lib/models/transaction.g.dart`、`lib/services/**`（登录页 + Hive codegen）已删除（Lead，2026-11-12）；入口只剩 `lib/main.dart → lib/app.dart → lib/ui/**`，无登录路径

## 2. 隐私标签与权限文案（release + Lead）

### 2.1 App Store 隐私标签

- [ ] 全部分区选择 **Data Not Collected**：联系信息、健康、财务、位置、敏感信息、通讯录、用户内容、浏览历史、搜索历史、标识符、使用数据、诊断、购买记录、其他
- [ ] 依据：架构约定全离线、无登录、无账号、无云同步、无第三方 SDK、无广告、无分析上报（`web/网络请求` 代码为 0）
- [ ] 相机 / 照片 / 麦克风 / 语音识别数据仅在本机处理，不离开设备 → 不构成 “收集”
- [ ] share_plus 分享导出文件由用户主动触发，仅走系统分享面板，App 不上传
- [ ] App Privacy 页与 `PRIVACY.md`、App 内隐私政策三者口径一致（“Data Not Collected”）
- [ ] 若有崩溃/性能诊断 SDK 被加入 → 隐私标签必须改为收集 Diagnostics，且本次上架禁止（无依赖）

### 2.2 权限文案（Info.plist 现有 4 条，逐条确认与实际功能一致）

- [ ] `NSCameraUsageDescription`：扫描小票或账单截图，自动识别金额与商户，照片仅在本机处理，不会上传。
- [ ] `NSPhotoLibraryUsageDescription`：从相册选择小票或账单截图进行识别，照片仅在本机处理，不会上传。
- [ ] `NSMicrophoneUsageDescription`：按住说话即可记账，录音仅在本机用于语音识别，不会上传。
- [ ] `NSSpeechRecognitionUsageDescription`：将你说的话在本机转换成记账内容，语音不会上传到服务器。
- [ ] 无保存相册功能 → 不需要 `NSPhotoLibraryAddUsageDescription`；若后续加入保存，必须补文案
- [ ] 语音识别强制 `requiresOnDeviceRecognition = true`；设备端不可用时返回不可用并给中文提示，不降级到联网识别
- [ ] 首次触发权限前有中文说明；拒绝权限后可手动记账（不得卡死、不得反复弹窗）
- [ ] 无 ATT / 无广告标识符 / 无 IDFA 相关代码与弹窗

## 3. App Store 审核高风险点（逐条自审）

- [ ] **无登录**：启动不要求注册/登录，无账号页、无假登录、无测试账号（审核备注写明“无需登录，全部功能本地可用”）
- [ ] **离线**：飞行模式下完整可用；不出现网络错误提示、加载转圈、同步文案；不请求任何后端
- [ ] **无支付**：无内购、无订阅、无“升级 Pro”、无跳转外部支付/二维码；定价为免费
- [ ] **无 UGC**：无社区、评论、公开分享、排行榜；导出/分享仅本机文件，用户自发
- [ ] **最小功能**（4.2）：拍照识别、语音记账、报表、预算、导出构成完整闭环，非空壳
- [ ] **AI 表述准确**（2.3.1 / 1.1）：使用“智能建议 / 本地识别”，不宣称大模型、不承诺“自动记账 100% 准确”；商店描述与真实能力一致
- [ ] **隐私政策 URL、支持 URL、用户协议** 可访问（release 提供 GitHub Pages），App 内可打开且非空白
- [ ] **数据删除**：“清空数据”有二次确认；清空后首页/报表回到空状态；设置保留
- [ ] **崩溃与数据安全**：强杀进程、低内存、快速连续记账不丢数据；单条 Hive 记录损坏不导致整库不可用
- [ ] **误导风险**：不展示假用户头像/昵称、假连续天数、假评分；DEMO 数据只能用于截图，不得出现在正式包
- [ ] **商标与素材**：图标、截图、描述无第三方商标；截图不含模拟器/调试标识
- [ ] **年龄分级**：4+；类别：财务（Finance）；若含理财建议措辞需加“不构成投资建议”免责声明
- [ ] **iOS 16 兼容**：在最低版本真机/模拟器上无崩溃、无新版 API 白屏
- [ ] **后台/多任务**：切后台再回来不丢失输入中的金额；语音/相机中断有恢复路径
- [ ] 审核备注写清：拍照/语音均为可选、本地处理、不联网、无账号

## 4. 无障碍与适老化（对照 `ACCESSIBILITY.md`）

- [ ] 系统字体 AX1（≈135%）、AX3（≈200%）、AX5（≈310%）三档下：首页/账单/报表/记账/设置无溢出、无截断，可滚动
- [ ] 大字号下金额不折行错位；超长数字用 `FittedBox`/换行而非 `RenderFlex overflow`
- [ ] VoiceOver 朗读金额含方向（“支出 42 元”/“收入 8000 元”），不是孤立的“¥42.00”
- [ ] 所有纯图标按钮有 `tooltip` / `semanticLabel`；图表有等价文字摘要
- [ ] 主要按钮点击区 ≥ 48×48dp：FAB、保存、删除、Tab、设置开关、分类项逐项量测
- [ ] 对比度：正文 ≥ 4.5:1；品牌绿 `kBrandColor #10B981` 在浅色背景约 2.5:1，**只用于图标/填充/强调**；浅色正文用 `kBrandText #047857`（新增），高对比度模式用 `kBrandDark #059669` 或更深；绿底白字按钮需实测
- [ ] 深色 / 浅色 / 高对比度三套主题都检查；高对比度开关立即生效并持久化
- [ ] 收入/支出不只靠颜色区分（符号 + 文字 + 图标至少两种编码）
- [ ] “减弱动态效果 / 降低透明度 / 加粗文本”系统开关下无异常；图表动画可关闭
- [ ] VoiceOver 焦点顺序合理（标题 → 主数字 → 列表 → 操作），弹窗/确认框可聚焦
- [ ] 触觉反馈开关关闭后不再震动；开启时保存/删除有反馈但不过度
- [ ] Xcode Accessibility Inspector 自动审计 + 真机 VoiceOver 走查各页并记录问题
- [ ] 横屏锁定符合设计（仅竖屏）；分屏/画中画不涉及

## 5. 功能冒烟路径（qa 手测 + 自动化）

**主路径**
1. 清空安装 → 首次启动 → 引导页 → 完成 → 首页空状态（0.00、无记录、无崩溃）
2. 手动记一笔支出 42.50（餐饮/午餐/麦当劳）→ 保存 → 首页本月支出 42.50、最近交易出现
3. 记一笔收入 8000（工资）→ 首页结余/收入正确、趋势与占比包含该笔
4. 账单页：按月份切换、分类筛选、关键词搜索、左滑删除、点击编辑后保存
5. 报表页：空月份显示空状态；有数据时趋势正序、分类占比合计 100%、智能建议 ≤3 条
6. 预算页：设置月度预算 → 首页进度条与超支提示；设置分类预算；预算为 0/未设置不出现除零
7. 设置页：主题切换、高对比度、触觉、导出 CSV（打开分享面板）、导出 JSON 备份、清空数据（二次确认）
8. 拍照识别：拍照/相册 → 预览 → 识别结果回填金额/商户 → 用户确认后保存；取消/无文字时给出中文提示
9. 语音记账：按住说话 → 实时文字 → 松开结束 → 回填；设备端不可用/拒绝麦克风时给出提示且可转手动
10. 杀进程重启 → 数据、设置、主题、当前月份全部保留
11. 飞行模式重复 2–10，全部可用且无任何网络报错

**边界与异常**
- [ ] 金额：0、0.01、9999999.99、只输小数点、多位小数、输入中文/符号被过滤
- [ ] 日期：今天/昨天/当月 1 号/跨年 12-31 → 1-1；月份切换跨年正确
- [ ] 预算：未设置、0、负数（输入层应拦截）；超支 100%+ 文案正确
- [ ] 空数据：账单/报表/预算/建议均显示合理空状态与引导
- [ ] 1000+ 条交易时列表/报表滚动与打开速度可接受（不卡死）
- [ ] 快速连续点保存只产生 1 条记录；保存中退出再进不重复
- [ ] 编辑已有交易改为收入/换分类/改日期后各页统计同步
- [ ] 时区/系统时间变更后“今天/本月”边界正确

## 6. App Store 截图清单（release）

尺寸：iPhone 6.9"（1320×2868）主套必传；如 AC 要求补 6.5"（1242×2688）。6–8 张，中文文案。

1. 首页：本月结余 + 收入/支出 + 预算进度（强调“一屏看清”）
2. 拍照识别：小票 → 自动填金额/商户（强调“拍一下就好”）
3. 语音记账：一句话生成一笔（强调“说一句就记好”）
4. 账单列表：分组 + 搜索 + 分类筛选
5. 报表：趋势图 + 分类占比
6. 智能建议：本地生成的 2–3 条建议卡片
7. 预算：月度/分类预算与超支提醒
8. 隐私/适老化：全离线、数据不出手机、大字模式（不提“医疗/理财建议”等越界表述）

- [ ] 截图内数据来自 `DEMO=true` 演示账本，金额/日期自然、中文无错字
- [ ] 状态栏干净（9:41、满信号），无调试横幅、无模拟器边框、无测试标识
- [ ] 每张文案 ≤ 一行主标题 + 一行副标题，不夸大、不出现“第一/最好/免费内购”等违规词
- [ ] 不含其他平台（Android）设备画面、不含竞品商标
- [ ] 如需 App 预览视频：15–30 秒，仅竖屏实机录屏，展示记账主流程

## 7. TestFlight 与提审步骤（Lead + release）

1. App Store Connect 建 App：Bundle ID `com.archintera.ledgerai`、主语言简体中文、SKU（如 `ledgerai-ios-1`）、类别财务
2. `flutter build ipa --release`（或 Xcode Archive）→ Organizer/Transporter 上传 build 1
3. 等待处理完成；出口合规选“不使用非豁免加密”（Info.plist 已声明，通常不再询问）
4. 内部测试：添加 App Store Connect 用户 → TestFlight 内部组（无需审核）→ 安装验证
5. 外部测试（可选）：填 Beta 审核信息、测试说明（中文）、隐私政策 URL、联系方式 → 提交 Beta 审核（首次约 1 天）
6. TestFlight 真机验收：按第 5 节主路径 + 第 4 节无障碍各档字号；收集崩溃/截图反馈
7. 商店元数据：名称 ≤30 字、副标题 ≤30 字、关键词 ≤100 字、描述、促销文案、分类、年龄 4+、免费、截图、隐私标签、审核备注
8. 选择 build 1 → 提交 App 审核；审核期间保持构建可用
9. 若被拒：按 Resolution Center 逐条修复，build 号 +1 重传；记录拒审原因到本节
10. 通过后发布方式（自动发布/手动发布）确认；上线后首日检查下载、崩溃、反馈渠道

## 8. 已知风险与待办（qa 静态检查发现，2026-11-12）

- [x] `lib/core/format.dart` 注释与实现不一致（注释 `¥-42.00` / 实际 `-¥42.00`）已由 Lead 按实际输出修正；新增 `kBrandText #047857`。单元测试均按实现断言
- [x] `test/widget_test.dart` 旧样板已删除；`dart analyze test` 无 error（test/core 6 个文件 + test/widget 脚手架）
- [x] `ios/Runner/PrivacyInfo.xcprivacy` 已新增并接入 pbxproj（见第 1 节，待 Archive 隐私报告复核）
- [x] 旧骨架 `lib/screens/**`、`lib/models/transaction.g.dart`、`lib/services/**` 已删除，无登录页/codegen 残留
- [ ] `README.md` 仍写旧功能（登录页、上架 Google Play），需 release 改为真实功能与构建说明
- [x] `test/widget/**` 已按最终 `lib/ui/**` 编写：首页/记账/账单/报表/预算/设置页面用例、应用壳闭环、无障碍专项（200% 字号、高对比度、48dp、VoiceOver 语义）；`integration_test/smoke_test.dart` 冒烟路径已写。组件测试通过 `test/widget/test_support.dart` 注入真实 Hive + `AppState.forStore`，并给触觉/语音/OCR 通道打了桩，不依赖插件实现
- [ ] 上述测试需 Lead 在本地执行确认全绿（qa 按约定不运行 flutter test；当前 `dart analyze test integration_test` 无 error）
- [x] **P1 代码健壮性（已修复）**：`AddTransactionScreen._save` / `TransactionsScreen._deleteTransaction` 已把触觉反馈移出「保存/删除失败」判定（ui-core，2026-11-12），避免已写入却提示失败导致的重复记账
- [x] 原生通道前缀已统一为 `com.archintera.ledgerai/*`（lib/ai + AppDelegate + 测试桩，Lead，2026-11-12），与文档/Bundle ID 一致
- [ ] **P1 一致性**：`SettingsScreen` 中 `_kAppVersion = '1.0.0'`、`_kBuildNumber = '1'` 为硬编码，每次提审 bump `pubspec.yaml` build 号时需同步修改，否则「关于」页版本号与二进制不一致
- [ ] **P2 备份健壮性**：`ExportService.parseBackupTransactions` 遇到单条坏记录会整体返回 null（无法只跳过坏条目）；v1 设置页未暴露导入入口，可延后
- [ ] 本清单中依赖 UI/真机的项目前均未验证，需 Lead 构建后在模拟器逐项补勾

---

**验收签字**：构建 Lead ______ · 测试 qa ______ · 商店物料 release ______ · 日期 ______ · 结论：可提审 / 有条件通过 / 不可提审
