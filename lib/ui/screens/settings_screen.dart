import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_settings.dart';
import '../../core/app_state.dart';
import '../../core/bill_import.dart';
import '../../core/models.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/cloud_sync.dart';
import '../color_themes.dart';
import '../../core/format.dart';
import '../theme.dart';
import '../widgets/common/app_snack.dart';
import '../widgets/common/section_header.dart';
import 'budget_screen.dart';
import 'language_screen.dart';
import 'legal_screens.dart';

/// 应用版本号（与 pubspec.yaml 的 `version: 1.0.0+1` 保持一致）。
const String _kAppVersion = '1.1.0';
const String _kBuildNumber = '19';

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
      (settings) => settings.copyWith(elderMode: value),
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
    final l10n = AppLocalizations.of(context);
    setState(() => _syncing = true);
    try {
      final report =
          await const CloudSyncService().sync(AppScope.read(context));
      if (!mounted) return;
      _showSnack(
        report.deleted > 0
            ? l10n.syncCompleteWithDeleted(
                report.downloaded, report.uploaded, report.deleted)
            : l10n.syncComplete(report.downloaded, report.uploaded),
      );
    } on CloudSyncException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnack(l10n.syncFailed('$e'));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _themeLabel(AppLocalizations l10n, AppColorTheme theme) =>
      switch (theme) {
        AppColorTheme.fresh => l10n.themeFresh,
        AppColorTheme.forest => l10n.themeForest,
        AppColorTheme.freshForest => l10n.themeFreshForest,
        AppColorTheme.blush => l10n.themeBlush,
        AppColorTheme.peach => l10n.themePeach,
        AppColorTheme.lavender => l10n.themeLavender,
      };

  Future<void> _setColorTheme(AppColorTheme value) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(colorTheme: value),
    );
    if (!mounted) return;
    _hapticTick();
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
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    if (app.transactions.isEmpty) {
      _showSnack(l10n.exportNoData);
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
          subject:
              csv ? l10n.exportCsvShareSubject : l10n.exportJsonShareSubject,
          title: csv ? l10n.exportCsvTitle : l10n.exportJsonTitle,
        ),
      );
    } catch (_) {
      if (mounted) _showSnack(l10n.exportFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _importBillCsv() async {
    if (_importing || _exporting) return;
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    try {
      final typeGroup = XTypeGroup(
        label: l10n.billCsvFileType,
        extensions: ['csv'],
        mimeTypes: ['text/csv', 'text/comma-separated-values'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      if (!mounted) return;
      if (content.contains('\uFFFD')) {
        _showSnack(l10n.importEncodingWarning);
      }
      final result =
          const BillCsvImporter().parse(content, fileName: file.name);
      if (result.isEmpty) {
        _showSnack(result.warnings.isEmpty
            ? l10n.importNoBill
            : result.warnings.first);
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
        _showSnack(l10n.importAllDuplicates(result.transactions.length));
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.importBillTitle),
          content: Text(
            l10n.importBillSummary(
              result.transactions.length,
              duplicates > 0 ? 'some' : 'none',
              duplicates,
              fresh.length,
              result.skipped > 0 ? 'some' : 'none',
              result.skipped,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.importButtonCount(fresh.length)),
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
      _showSnack(l10n.importedCount(fresh.length));
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      _showSnack(l10n.importFailed('$e'));
    }
  }

  static String _billFingerprint(Txn txn) {
    final merchant = (txn.merchant ?? '').trim().toLowerCase();
    return '${txn.date.toIso8601String()}|${txn.amount.toStringAsFixed(2)}|'
        '${txn.isIncome}|$merchant|${txn.note.trim().toLowerCase()}';
  }

  Future<void> _importBackup() async {
    if (_importing || _exporting) return;
    final l10n = AppLocalizations.of(context);
    try {
      final typeGroup = XTypeGroup(
          label: l10n.jsonBackupFileType,
          extensions: ['json'],
          mimeTypes: ['application/json']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      final content = await file.readAsString();
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.importJsonBackup),
          content: Text(l10n.importJsonConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.importAction),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => _importing = true);
      final app = AppScope.read(context);
      final count = await app.importBackup(content);
      if (!mounted) return;
      _showSnack(l10n.importedCount(count));
    } catch (_) {
      if (mounted) _showSnack(l10n.importBackupFailed);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // 清空数据（两次确认）
  // ---------------------------------------------------------------------------

  Future<void> _clearData() async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final count = app.transactions.length;
    if (count == 0) {
      _showSnack(l10n.noDataToClear);
      return;
    }

    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearAllTransactionsConfirmTitle),
        content: Text(l10n.clearDataConfirmContent(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.continueAction),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.finalConfirmTitle),
        content: Text(l10n.finalConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.backAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.confirmClear),
          ),
        ],
      ),
    );
    if (second != true || !mounted) return;

    await app.clearTransactions();
    if (!mounted) return;
    _hapticTick();
    _showSnack(l10n.clearedAllTransactions);
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
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final prefs = app.prefs;
    final fontScaleOptions = [
      _FontScaleOption(l10n.fontScaleStandard, 1.0),
      _FontScaleOption(l10n.fontScaleLarge, 1.15),
      _FontScaleOption(l10n.fontScaleXLarge, 1.30),
      _FontScaleOption(l10n.fontScaleXXLarge, 1.50),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppTheme.pageInsets,
          children: [
            SectionHeader(
                title: l10n.settingsAppearance,
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8)),
            Card(
              child: Column(
                children: [
                  _ThemeModeTile(
                    icon: Icons.brightness_auto_rounded,
                    label: l10n.followSystem,
                    selected: prefs.themeMode == ThemeMode.system,
                    onTap: () => _setThemeMode(ThemeMode.system),
                  ),
                  const Divider(),
                  _ThemeModeTile(
                    icon: Icons.light_mode_rounded,
                    label: l10n.lightMode,
                    selected: prefs.themeMode == ThemeMode.light,
                    onTap: () => _setThemeMode(ThemeMode.light),
                  ),
                  const Divider(),
                  _ThemeModeTile(
                    icon: Icons.dark_mode_rounded,
                    label: l10n.darkMode,
                    selected: prefs.themeMode == ThemeMode.dark,
                    onTap: () => _setThemeMode(ThemeMode.dark),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.contrast_rounded),
                    title: Text(l10n.highContrast),
                    subtitle: Text(l10n.highContrastSubtitle),
                    value: prefs.highContrast,
                    onChanged: _setHighContrast,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: l10n.settingsLanguageSection,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: ListTile(
                onTap: () => _openPage(const LanguageScreen()),
                leading: Icon(
                  Icons.translate_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.appLanguage),
                subtitle: Text(
                  prefs.language == AppLanguage.system
                      ? l10n.followSystem
                      : prefs.language.nativeLabel,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: l10n.theme,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(l10n.chooseThemeColor,
                            style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in AppColorTheme.values)
                          ChoiceChip(
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor: HengPalette.forTheme(
                                option,
                                Theme.of(context).brightness,
                              ).primary,
                            ),
                            label: Text(_themeLabel(l10n, option)),
                            selected: prefs.colorTheme == option,
                            onSelected: (_) => _setColorTheme(option),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      l10n.themeColorNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: l10n.settingsElderSection,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.elderly_rounded),
                    title: Text(l10n.elderMode),
                    subtitle: Text(l10n.elderModeSubtitle),
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
                            l10n.appFontSize,
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
                        for (final option in fontScaleOptions)
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: prefs.fontScale.clamp(0.85, 1.5),
                            min: 0.85,
                            max: 1.5,
                            divisions: 13,
                            label: '${(prefs.fontScale * 100).round()}%',
                            onChanged: _setFontScale,
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(prefs.fontScale * 100).round()}%',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      l10n.fontScaleNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
                title: l10n.settingsGeneralSection,
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8)),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded),
                    title: Text(l10n.haptics),
                    subtitle: Text(l10n.hapticsSubtitle),
                    value: prefs.hapticsEnabled,
                    onChanged: _setHaptics,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.savings_outlined),
                    title: Text(l10n.budgetManagement),
                    subtitle: Text(
                      prefs.monthlyBudget != null
                          ? l10n.monthlyBudgetTotal(
                              formatMoney(prefs.monthlyBudget!))
                          : l10n.noMonthlyBudget,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const BudgetScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: l10n.icloudSync,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud_outlined),
                    title: Text(l10n.icloudSync),
                    subtitle: Text(
                      prefs.icloudSyncEnabled
                          ? (prefs.lastSyncAt == null
                              ? l10n.icloudWaitingFirstSync
                              : l10n.lastSyncAt(
                                  _formatSyncTime(prefs.lastSyncAt!)))
                          : l10n.icloudSyncOffSubtitle,
                    ),
                    value: prefs.icloudSyncEnabled,
                    onChanged: _syncing ? null : _setSyncEnabled,
                  ),
                  if (prefs.icloudSyncEnabled) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.sync_rounded),
                      title: Text(l10n.syncNow),
                      subtitle: Text(
                          _syncing ? l10n.syncingNow : l10n.syncNowSubtitle),
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
                      l10n.icloudSyncNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: l10n.dataSectionLocalOnly,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
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
                    title: Text(l10n.exportCsv),
                    subtitle: Text(
                      l10n.exportCsvSubtitle(app.transactions.length),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing
                        ? null
                        : () => _export(csv: true),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text(l10n.exportJsonBackup),
                    subtitle: Text(l10n.exportJsonBackupSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _exporting || _importing
                        ? null
                        : () => _export(csv: false),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.file_upload_outlined),
                    title: Text(l10n.importWechatAlipay),
                    subtitle: Text(l10n.importWechatAlipaySubtitle),
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
                    title: Text(l10n.importJsonBackup),
                    subtitle: Text(l10n.importJsonBackupSubtitle),
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
                      l10n.clearAllTransactions,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: Text(l10n.clearDataSubtitle),
                    onTap: _clearData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
                title: l10n.about,
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8)),
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
                            gradient: AppTheme.brandGradientOf(context),
                            borderRadius: BorderRadius.circular(
                              AppTheme.controlRadius,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Image.asset(
                              'assets/brand/heng_glyph.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HENG',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.versionBuild(_kAppVersion, _kBuildNumber),
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
                          children: [
                            _PrivacyBadge(l10n.badgeNoLogin),
                            _PrivacyBadge(l10n.badgeNoNetwork),
                            _PrivacyBadge(l10n.badgeNoUpload),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.aboutLocalFirstNote,
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
                    title: Text(l10n.privacyPolicy),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const PrivacyPolicyScreen()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.userAgreement),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openPage(const UserAgreementScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'HENG PRIVATE LEDGER\nDESIGNED BY ARCHINTERA · © 2026',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                  letterSpacing: 0.8,
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
                  : AppTheme.brandTextOf(context),
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
    final color = isDark ? AppTheme.incomeDark : AppTheme.brandTextOf(context);
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
