import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_state.dart';
import '../../core/bill_import.dart';
import '../../core/models.dart';
import '../../sync/cloud_sync.dart';
import '../../core/format.dart';
import '../theme.dart';
import '../widgets/common/app_snack.dart';
import '../widgets/common/section_header.dart';
import 'budget_screen.dart';
import 'legal_screens.dart';

/// 应用版本号（与 pubspec.yaml 的 `version: 1.0.0+1` 保持一致）。
const String _kAppVersion = '1.1.0';
const String _kBuildNumber = '4';

/// 设置页：外观、触觉反馈、预算入口、数据导出与清空、法务与关于。
///
/// 所有偏好通过 [AppState.updateSettingsWith] 写入本机，不联网、不上传。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.initialScrollOffset = 0});

  /// 仅截图/演示模式使用。
  final double initialScrollOffset;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ScrollController _scrollController =
      ScrollController(initialScrollOffset: widget.initialScrollOffset);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _exporting = false;
  bool _importing = false;
  bool _syncing = false;

  static const List<_FontScaleOption> _fontScaleOptions = [
    _FontScaleOption('标准', 1.0),
    _FontScaleOption('大', 1.15),
    _FontScaleOption('特大', 1.3),
    _FontScaleOption('超大', 1.5),
  ];

  // ---------------------------------------------------------------------------
  // 偏好设置
  // ---------------------------------------------------------------------------

  void _hapticTick() {
    if (AppScope.read(context).prefs.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(themeMode: mode),
    );
    if (!mounted) return;
    _hapticTick();
  }

  Future<void> _setHighContrast(bool value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(highContrast: value),
    );
    if (!mounted) return;
    if (value) _hapticTick();
  }

  Future<void> _setElderMode(bool value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(
        elderMode: value,
        fontScale: value && settings.fontScale < 1.3 ? 1.3 : settings.fontScale,
      ),
    );
    if (!mounted) return;
    _hapticTick();
  }

  static String _formatSyncTime(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }

  Future<void> _setSyncEnabled(bool value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(icloudSyncEnabled: value),
    );
    if (!mounted) return;
    _hapticTick();
    if (value) await _syncNow();
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final report =
          await const CloudSyncService().sync(AppScope.read(context));
      if (!mounted) return;
      _showSnack(
        '同步完成：下载 ${report.downloaded} 笔，上传 ${report.uploaded} 笔'
        '${report.deleted > 0 ? '，删除 ${report.deleted} 笔' : ''}',
      );
    } on CloudSyncException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnack('同步失败：$e');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _setFontScale(double value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(fontScale: value),
    );
    if (!mounted) return;
    _hapticTick();
  }

  Future<void> _setHaptics(bool value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(hapticsEnabled: value),
    );
    if (!mounted) return;
    if (value) HapticFeedback.selectionClick();
  }

  // ---------------------------------------------------------------------------
  // 导出
  // ---------------------------------------------------------------------------

  static String _pad(int value) => value.toString().padLeft(2, '0');

  void _showSnack(String message) {
    if (!mounted) return;
    AppSnack.show(context, message);
  }

  Future<void> _export({required bool csv}) async {
    if (_exporting) return;
    final app = AppScope.read(context);
    if (app.transactions.isEmpty) {
      _showSnack('还没有账单数据，先记一笔再导出');
      return;
    }

    setState(() => _exporting = true);
    try {
      final now = DateTime.now();
      final stamp = '${now.year}${_pad(now.month)}${_pad(now.day)}'
          '-${_pad(now.hour)}${_pad(now.minute)}';
      final extension = csv ? 'csv' : 'json';
      final fileName = 'ledgerai-${csv ? 'transactions' : 'backup'}'
          '-$stamp.$extension';
      final content = csv
          ? app.export.buildCsv(app.transactions)
          : app.export.buildBackup(app.transactions, app.prefs);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      // CSV 加 UTF-8 BOM，Excel 打开中文不乱码。
      await file.writeAsString(csv ? '\uFEFF$content' : content, flush: true);
      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              mimeType: csv ? 'text/csv' : 'application/json',
            ),
          ],
          subject: csv ? '衡账 · 账单表格' : '衡账 · 数据备份',
          title: csv ? '导出账单 CSV' : '导出 JSON 备份',
        ),
      );
    } catch (_) {
      if (mounted) _showSnack('导出失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _importBillCsv() async {
    if (_importing || _exporting) return;
    final app = AppScope.read(context);
    try {
      const typeGroup = XTypeGroup(
        label: '账单 CSV',
        extensions: ['csv'],
        mimeTypes: ['text/csv', 'text/comma-separated-values'],
      );
      final file = await openFile(acceptedTypeGroups: const [typeGroup]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      if (!mounted) return;
      if (content.contains('\uFFFD')) {
        _showSnack('文件编码可能不是 UTF-8，部分文字可能乱码；建议在微信/支付宝里重新导出');
      }
      final result =
          const BillCsvImporter().parse(content, fileName: file.name);
      if (result.isEmpty) {
        _showSnack(
            result.warnings.isEmpty ? '没有可导入的账单' : result.warnings.first);
        return;
      }
      final existing = <String>{
        for (final txn in app.transactions) _billFingerprint(txn),
      };
      final fresh = <Txn>[];
      var duplicates = 0;
      for (final txn in result.transactions) {
        if (existing.add(_billFingerprint(txn))) {
          fresh.add(txn);
        } else {
          duplicates++;
        }
      }
      if (!mounted) return;
      if (fresh.isEmpty) {
        _showSnack('这 ${result.transactions.length} 笔记录都已经在账本里了');
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('导入账单'),
          content: Text(
            '识别到 ${result.transactions.length} 笔收支，'
            '${duplicates > 0 ? '其中 $duplicates 笔已存在，' : ''}'
            '将新增 ${fresh.length} 笔。\n'
            '${result.skipped > 0 ? '已跳过 ${result.skipped} 行（不计收支/失败/重复等）。\n' : ''}'
            '导入后可在账单页修改分类和备注。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('导入 ${fresh.length} 笔'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      setState(() => _importing = true);
      for (final txn in fresh) {
        await app.saveTransaction(txn);
      }
      if (!mounted) return;
      setState(() => _importing = false);
      _showSnack('已导入 ${fresh.length} 笔账单');
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      _showSnack('导入失败：$e');
    }
  }

  static String _billFingerprint(Txn txn) {
    final merchant = (txn.merchant ?? '').trim().toLowerCase();
    return '${txn.date.toIso8601String()}|${txn.amount.toStringAsFixed(2)}|'
        '${txn.isIncome}|$merchant|${txn.note.trim().toLowerCase()}';
  }

  Future<void> _importBackup() async {
    if (_importing || _exporting) return;
    try {
      const typeGroup = XTypeGroup(
          label: 'JSON 备份',
          extensions: ['json'],
          mimeTypes: ['application/json']);
      final file = await openFile(acceptedTypeGroups: const [typeGroup]);
      if (file == null) return;
      final content = await file.readAsString();
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('导入 JSON 备份'),
          content:
              const Text('将把备份中的账单合并到当前账本（同 ID 记录会覆盖），并恢复备份里的预算与偏好设置。是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('导入'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => _importing = true);
      final app = AppScope.read(context);
      final count = await app.importBackup(content);
      if (!mounted) return;
      _showSnack('已导入 $count 笔账单');
    } catch (_) {
      if (mounted) _showSnack('导入失败，请确认文件是衡账导出的 JSON 备份');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // 清空数据（两次确认）
  // ---------------------------------------------------------------------------

  Future<void> _clearData() async {
    final app = AppScope.read(context);
    final count = app.transactions.length;
    if (count == 0) {
      _showSnack('当前没有账单数据');
      return;
    }

    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空全部账单？'),
        content: Text(
          '将删除本机保存的 $count 笔账单记录，预算与设置会保留。此操作无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('最后确认'),
        content: const Text(
          '删除后无法恢复。如果还想保留账单，请先返回并导出 JSON 备份。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('返回'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
    if (second != true || !mounted) return;

    await app.clearTransactions();
    if (!mounted) return;
    _hapticTick();
    _showSnack('已清空全部账单');
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  // ---------------------------------------------------------------------------
  // 界面
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final prefs = app.prefs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppTheme.pageInsets,
          children: [
            const SectionHeader(
                title: '外观', padding: EdgeInsets.fromLTRB(4, 0, 4, 8)),
            Card(
              child: Column(
                children: [
                  _ThemeModeTile(
                    icon: Icons.brightness_auto_rounded,
                    label: '跟随系统',
                    selected: prefs.themeMode == ThemeMode.system,
                    onTap: () => _setThemeMode(ThemeMode.system),
                  ),
                  const Divider(),
                  _ThemeModeTile(
                    icon: Icons.light_mode_rounded,
                    label: '浅色',
                    selected: prefs.themeMode == ThemeMode.light,
                    onTap: () => _setThemeMode(ThemeMode.light),
                  ),
                  const Divider(),
                  _ThemeModeTile(
                    icon: Icons.dark_mode_rounded,
                    label: '深色',
                    selected: prefs.themeMode == ThemeMode.dark,
                    onTap: () => _setThemeMode(ThemeMode.dark),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.contrast_rounded),
                    title: const Text('高对比度'),
                    subtitle: const Text('适合弱视或强光环境，文字更清晰'),
                    value: prefs.highContrast,
                    onChanged: _setHighContrast,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              title: '适老化',
              padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.elderly_rounded),
                    title: const Text('父母模式'),
                    subtitle: const Text('更大字体、更高对比、简化展示，适合长辈使用'),
                    value: prefs.elderMode,
                    onChanged: _setElderMode,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        const Icon(Icons.format_size_rounded),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '应用内字体大小',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in _fontScaleOptions)
                          ChoiceChip(
                            label: Text(option.label),
                            selected:
                                (prefs.fontScale - option.scale).abs() < 0.01,
                            onSelected: (_) => _setFontScale(option.scale),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      '只影响衡账 App，不改变系统字号；系统已放大的字号会保留更大值。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
                title: '通用', padding: EdgeInsets.fromLTRB(4, 0, 4, 8)),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded),
                    title: const Text('触觉反馈'),
                    subtitle: const Text('记账、保存等操作时轻震一下'),
                    value: prefs.hapticsEnabled,
                    onChanged: _setHaptics,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.savings_outlined),
                    title: const Text('预算管理'),
                    subtitle: Text(
                      prefs.monthlyBudget != null
                          ? '本月总预算 ${formatMoney(prefs.monthlyBudget!)}'
                          : '还没有设置月度预算',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const BudgetScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              title: 'iCloud 同步',
              padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud_outlined),
                    title: const Text('iCloud 同步'),
                    subtitle: Text(
                      prefs.icloudSyncEnabled
                          ? (prefs.lastSyncAt == null
                              ? '已开启，等待首次同步'
                              : '上次同步：${_formatSyncTime(prefs.lastSyncAt!)}')
                          : '多设备同步到自己的 iCloud，开发者看不到数据',
                    ),
                    value: prefs.icloudSyncEnabled,
                    onChanged: _syncing ? null : _setSyncEnabled,
                  ),
                  if (prefs.icloudSyncEnabled) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.sync_rounded),
                      title: const Text('立即同步'),
                      subtitle: Text(_syncing ? '正在同步…' : '把本机账单与 iCloud 合并'),
                      trailing: _syncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: _syncing ? null : _syncNow,
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      '数据只写入你自己的 iCloud private database，衡账没有服务器；'
                      '1.1 内测期间免费。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              title: '数据（只保存在本机）',
              padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                children: [
                  if (_exporting || _importing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ListTile(
                    leading: const Icon(Icons.table_chart_outlined),
                    title: const Text('导出 CSV 表格'),
                    subtitle: Text(
                      '共 ${app.transactions.length} 笔账单，可在 Excel / Numbers 中查看',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing
                        ? null
                        : () => _export(csv: true),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('导出 JSON 备份'),
                    subtitle: const Text('包含全部账单与设置，可用于迁移或找回数据'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing
                        ? null
                        : () => _export(csv: false),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: const Text('导入微信/支付宝账单'),
                    subtitle: const Text('CSV 文件，自动识别收支、商户并分类；重复记录会跳过'),
                    trailing: _importing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing ? null : _importBillCsv,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore_page_outlined),
                    title: const Text('导入 JSON 备份'),
                    subtitle: const Text('从衡账导出的备份文件合并账单与设置'),
                    trailing: _importing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing ? null : _importBackup,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      '清空全部账单',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: const Text('仅删除本机账单，预算与设置保留；需两次确认'),
                    onTap: _clearData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(
                title: '关于', padding: EdgeInsets.fromLTRB(4, 0, 4, 8)),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.controlRadius,
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '衡账 LedgerAI',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '版本 $_kAppVersion（构建 $_kBuildNumber）',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _PrivacyBadge('不登录'),
                            _PrivacyBadge('不联网'),
                            _PrivacyBadge('不上传'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '衡账是本地优先的记账 App：账单、预算和设置只保存在这台 iPhone 上，'
                          '拍照与语音识别都在本机完成。卸载 App 会一并删除数据，建议定期导出备份。',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('隐私政策'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const PrivacyPolicyScreen()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('用户协议'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const UserAgreementScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '© 2026 衡账 · 本地优先记账',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      trailing: selected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppTheme.isDark(context)
                  ? theme.colorScheme.primary
                  : AppTheme.brandText,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
    final color = isDark ? AppTheme.incomeDark : AppTheme.brandText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FontScaleOption {
  const _FontScaleOption(this.label, this.scale);

  final String label;
  final double scale;
}
