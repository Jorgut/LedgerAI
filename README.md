# 衡账 LedgerAI

**本地优先的个人记账 App**：拍一张小票、说一句话，就能记好一笔账。
全程离线，不登录、不联网、不上传数据，账本只留在你的 iPhone 上。

![App 图标](assets/app_icon_1024.png)

- 平台：iPhone（竖屏）· iOS 16+
- 价格：免费，无内购、无广告
- Bundle ID：`com.archintera.ledgerai`
- 当前版本：`1.0.0+1`
- App Store 隐私标签：**Data Not Collected**

---

## 功能

| 能力 | 说明 |
|---|---|
| 拍照记账 | 拍摄小票后用 iOS Vision 在**本机**识别文字，自动填出金额、日期、商户与分类，确认或修改后保存；照片不上传、不保存原图 |
| 语音记账 | 按住说一句「午饭三十二块」，由 iOS 语音识别（强制**设备端**识别）转文字并解析金额与分类；设备不支持时提示改用拍照/手动，不录音上传 |
| 智能分类 | 按备注与商户文字在**本机**匹配分类（餐饮、交通、购物、居家、医疗、教育、人情、娱乐、工资、奖金等），可随时修改 |
| 预算 | 月度总预算 + 分类预算，进度条与超支提醒 |
| 报表 | 月度收支/结余、分类占比环形图、近 6 个月趋势 |
| 本地建议 | 基于本机账本给出消费结构提示（如「餐饮占比偏高」），只做记录提醒，不构成投资建议 |
| 账单管理 | 按月筛选、分类筛选、搜索、分组列表、编辑与删除 |
| 数据自主 | CSV / JSON 导出（系统分享面板）、JSON 备份导入、清空数据（二次确认） |
| 适老化与无障碍 | 大字号、主要按钮 ≥48pt、图标按钮语义标签、深色模式、高对比度（详见 [ACCESSIBILITY.md](ACCESSIBILITY.md)） |

> 关于「智能」：全部指**设备本机**的 OCR、语音转写与规则分类，不依赖云端大模型，断网可用。

---

## 隐私

- 不收集、不上传任何数据；无账号、无服务器、无云同步、无广告、无统计分析 SDK、无追踪。
- 相机、照片、麦克风、语音识别只在你主动使用对应功能时调用，可随时在系统设置中关闭。
- 账本仅保存在本机 App 沙盒（Hive 本地数据库）；卸载或清空即删除。
- 完整说明：[PRIVACY.md](PRIVACY.md) · App Store 隐私标签逐项依据：[store/privacy_labels.md](store/privacy_labels.md)

---

## 技术栈

- Flutter 3.47 / Dart 3.13，Material 3
- 状态管理：Flutter 自带 `ChangeNotifier` + `InheritedNotifier`（`lib/core/app_state.dart`）
- 本地存储：Hive（交易与设置以 JSON 字符串存储，不使用 codegen）
- 原生通道：iOS Vision（`VNRecognizeTextRequest`）+ iOS Speech（`SFSpeechRecognizer`，设备端）
- 依赖：hive、hive_flutter、uuid、intl、image_picker、path_provider、share_plus、flutter_localizations（**不新增其他依赖**）

---

## 目录结构

```text
.
├── assets/                  # 品牌素材（app_icon_1024.png 主图标）
├── docs/                    # ARCHITECTURE.md 等开发约定
├── ios/Runner/              # iOS 工程与 Assets.xcassets（图标 / 启动图）
├── lib/
│   ├── main.dart            # 入口，支持 --dart-define=DEMO=true
│   ├── app.dart             # MaterialApp、主题、引导流程
│   ├── core/                # 数据层：模型、Hive 存储、统计、建议、导出、设置
│   ├── ai/                  # 拍照/语音的 Dart 侧通道与解析规则
│   └── ui/                  # 主题、通用组件、各页面（并行开发中）
├── scripts/                 # 图标/启动图生成、模拟器截图脚本
├── store/                   # App Store 中文物料与截图方案
├── test/                    # 单元与 Widget 测试
├── PRIVACY.md               # 隐私政策（中文）
├── SUPPORT.md               # 支持与 FAQ（中文）
└── ACCESSIBILITY.md         # 无障碍与适老化规范
```

详细分层、API 与写权限约定见 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)。

---

## 环境要求

- macOS + Xcode（iOS 构建/模拟器）
- Flutter SDK（`flutter doctor` 通过）
- Python 3 + Pillow（仅用于重新生成图标/启动图，普通开发不需要）

## 运行

```bash
flutter pub get
flutter run                       # 普通模式：空白账本，首次启动进入引导页
```

### 商店截图 / 演示数据模式

```bash
flutter run --dart-define=DEMO=true
```

该模式下，若账本为空会写入示例交易、月度预算（6000 元）与分类预算，并跳过引导页——仅用于截图演示，**不影响正常构建**（逻辑见 `lib/main.dart`、`lib/core/demo_data.dart`）。

## 构建

```bash
flutter build ios --release                 # 真机构建（需配置签名）
flutter build ipa --release                 # 导出 ipa 上传 App Store Connect
```

## 静态检查与测试

```bash
flutter analyze
flutter test
```

## 图标、启动图与商店物料

```bash
python3 scripts/generate_icon.py          # 生成 assets/app_icon_1024.png（无 alpha）与 AppIcon 全尺寸
python3 scripts/make_launch_images.py     # 生成 LaunchImage 1x/2x/3x
./scripts/capture_screenshots.sh          # 在模拟器用 DEMO 数据抓 App Store 截图（需 Flutter + Xcode）
```

- 图标：品牌绿渐变 `#10B981 → #059669` + 白色几何 ¥ + 小票卡片意象，`Contents.json` 中列的尺寸全部覆盖并校验「尺寸正确 + 无 alpha」。
- 启动图：168×185pt 品牌徽标 + 「衡账」字标（对应 `LaunchScreen.storyboard` 的居中视图尺寸）。
- 商店物料：[store/metadata_zh.md](store/metadata_zh.md)（名称/副标题/关键词/描述/审核备注）、[store/screenshots_plan.md](store/screenshots_plan.md)（6.9" 截图清单与文案）。

---

## 已知限制

- 拍照识别精度受图片质量影响（手写、反光、折痕），识别结果需人工确认；
- 语音记账依赖设备端中文识别能力，部分设备不可用时会明确提示，不做服务器回退；
- v1 仅 iPhone 竖屏，不含 iPad 布局、多币种、账号与云同步；
- 数据仅存本机，换机请用 JSON 导出/导入。

---

## 文档

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — 产品决策、分层、API 与协作约定
- [ACCESSIBILITY.md](ACCESSIBILITY.md) — 适老化与无障碍设计规范
- [PRIVACY.md](PRIVACY.md) — 隐私政策
- [SUPPORT.md](SUPPORT.md) — 支持与常见问题
- [store/](store/) — App Store 中文物料

## 许可与支持

- 应用免费下载、无内购、无广告。
- 本仓库代码版权归作者所有（All rights reserved），未提供开源许可；第三方依赖遵循各自许可证。
- 问题反馈：<https://github.com/Jorgut/LedgerAI/issues>
- 项目主页：<https://github.com/Jorgut/LedgerAI>
