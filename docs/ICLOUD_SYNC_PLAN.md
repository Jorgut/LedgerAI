# iCloud 同步方案（1.1）

更新：2026-11-12。目标：多设备同步账单与预算，不建服务器、不改变「数据只在你 iCloud」的隐私口径。

## 1. 技术选型

- **CloudKit private database**：数据只存在用户自己的 iCloud，开发者不可见；
- Flutter 侧通过 MethodChannel `com.archintera.ledgerai/cloudkit` 调用原生 Swift；
- 记录模型：`Txn`（id/amount/categoryId/date/note/isIncome/source/merchant/updatedAt/deletedAt）；
- 同步单位：交易记录 + 设置（预算、偏好）；分类先使用内置分类，自定义分类 1.1 暂不同步。

## 2. 数据层改动

1. `Txn` 增加 `updatedAt`（修改时间）与 `deletedAt`（软删除墓碑）；
2. Hive JSON 向后兼容：旧数据 `updatedAt` 缺省 = `createdAt`，`deletedAt` 为空；
3. 同步状态本地保存：`lastSyncToken`（CloudKit change token）、`deviceId`；
4. 合并策略：
   - 同一 id 取 `updatedAt` 较新者（LWW）；
   - 删除用墓碑记录同步，避免「删了又被另一台设备拉回来」；
   - 批量分页拉取（CloudKit `CKFetchRecordZoneChangesOperation`）。

## 3. 原生改动（iOS）

- 开启 iCloud capability：`iCloud.com.archintera.ledgerai` CloudKit container；
- 新建自定义 zone `LedgerZone`；
- `AppDelegate.swift` 增加 CloudKit 通道：
  - `availability`：iCloud 账号/网络状态；
  - `pullChanges(sinceToken)`；
  - `pushChanges(records)`；
  - `delete(recordIds)`；
- 错误码：未登录 iCloud、网络不可用、配额不足、冲突，Dart 侧转成可读提示。

## 4. UI 与商业

- 设置 →「iCloud 同步」开关（Pro 功能；免费版可试用只读？先只给 Pro）；
- 状态展示：最后同步时间、立即同步、错误重试；
- 隐私说明：只同步到用户自己的 iCloud，开发者不接触；App Store 隐私标签更新为「数据由用户 iCloud 存储，不收集到开发者服务器」；
- 付费墙文案：`iCloud 多设备同步` 作为 Pro 权益之一。

## 5. 实施顺序与依赖

1. 数据层：`updatedAt/deletedAt` + 合并引擎 + 单元测试（不依赖 Apple 账号）；
2. 原生 CloudKit 通道 + entitlements（需要 Xcode 登录开发者账号开启 iCloud 能力）；
3. Dart 同步服务 + 设置 UI；
4. 真机/模拟器（登录 iCloud）验证双设备同步、删除、冲突；
5. App Store 审核：iCloud 能力 + 隐私标签更新。

> 当前阻塞：iCloud capability 需要开发者账号在 Xcode/ASC 中开启并重新签名，无法在无账号登录的自动构建里静默完成。
