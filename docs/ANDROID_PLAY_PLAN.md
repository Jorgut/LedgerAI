# Android / Google Play 计划与条件

更新：2026-11-12。结论：**可以做，且优先级高于 watchOS**，但比 iOS 上架多了 Android 原生适配与 Google Play 新账号测试门槛。

## 一、技术工作量（Flutter 复用 + 原生补齐）

| 模块 | 复用情况 |
|---|---|
| UI/报表/预算/数据层/Hive | 约 90% 复用（Flutter 跨平台） |
| 拍照/相册 | image_picker 已跨平台 |
| 小票 OCR | **需要 Kotlin 原生实现**（ML Kit 文字识别，设备端中文） |
| 语音识别 | **需要 Kotlin 原生实现**（Android SpeechRecognizer；设备端能力因机型/语言而异，需实测） |
| 权限流程 | AndroidManifest + 运行时权限（相机/麦克风/相册） |
| iCloud 同步 | Android 不支持；Pro 功能需替换为本地导出/网盘或取消该卖点 |
| 图标/启动图 | Android adaptive icon + splash |
| 签名/打包 | keystore + `flutter build appbundle` |

预计：环境与 SDK 0.5–1 天；原生 OCR/语音 1–2 周；UI 适配/测试 3–5 天；上架流程 1–3 天；新个人账号还有 14 天封闭测试。

## 二、Google Play 上架条件（2026 当前）

1. **开发者账号**：$25 一次性注册；身份验证（证件/地址/电话）；开发者名称与地址会公开展示；
2. **付款资料**：如收费/内购，需要付款资料与税务信息；
3. **新个人账号封闭测试**：2023-11 之后创建的个人账号，正式发布前需 **至少 12 名测试者连续 14 天参与封闭测试**，再申请 production access；
4. **应用包**：AAB、Play App Signing；target API 满足当年要求；16KB page size（含原生库）需兼容；
5. **合规材料**：隐私政策 URL、Data safety 表单、内容分级（IARC）、广告声明、金融功能声明（个人记账通常不涉及放贷/支付牌照，但要如实填写）；
6. **商店资料**：截图/描述/图标/feature graphic；应用访问说明；无账号体系则注明无需登录；
7. **审核**：新账号/新应用审核更慢，政策违规（隐私、金融、误导）会被拒。

> Google Play 不覆盖中国大陆；中国 Android 渠道需另做：软件著作权、APP 备案（工信部）、各商店（华为/小米/OPPO/vivo/应用宝）资质与审核，工作量明显更大。

## 三、时间线与建议

- **乐观（已有可生产 Play 账号）**：2–3 周；
- **新个人账号**：3–5 周（含 14 天封闭测试）；
- **建议顺序**：1.1（英文/IAP/iCloud，iOS）→ **1.2 Android + Google Play 全球** → 中国 Android 商店（视资源）→ watchOS（最后）。

## 四、风险

- Android 语音识别可能依赖 Google 服务/网络，需实测并调整“全离线”口径；
- 两套原生通道维护成本；
- Google Play 新账号 12 人测试需要真实测试者；
- 中国 Android 合规成本高，不建议首发就做。
