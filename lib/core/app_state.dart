import 'package:flutter/widgets.dart';

import 'app_settings.dart';
import 'export.dart';
import 'insights.dart';
import 'models.dart';
import 'stats.dart';
import 'storage.dart';

/// 全应用共享状态：仓库 + 设置 + 计算服务。
///
/// 仅依赖 Flutter 自带的 [ChangeNotifier] 与 [InheritedNotifier]，
/// 不引入第三方状态管理库，减少体积与版本风险。
class AppState extends ChangeNotifier {
  AppState._(this.store)
      : repo = store.transactions,
        settings = store.settings {
    stats = StatsService(repo);
    insights = InsightsService(repo, stats);
    repo.addListener(_handleChange);
    settings.addListener(_handleChange);
  }

  static Future<AppState> create({String? subDirectory}) async {
    final store = await LocalStore.open(subDirectory: subDirectory);
    return AppState._(store);
  }

  /// 测试与截图模式使用：注入已打开的仓库。
  static AppState forStore(LocalStore store) => AppState._(store);

  final LocalStore store;
  final TransactionRepository repo;
  final SettingsStore settings;
  late final StatsService stats;
  late final InsightsService insights;
  final ExportService export = const ExportService();

  AppSettings get prefs => settings.value;

  /// 是否为商店截图模式（`--dart-define=DEMO=true`）。
  static bool get isDemo => const bool.fromEnvironment('DEMO', defaultValue: false);

  List<Txn> get transactions => repo.all;

  List<Txn> transactionsOf(DateTime month) => repo.byMonth(month.year, month.month);

  Future<void> addTransaction(Txn txn) => repo.save(txn);

  Future<void> saveTransaction(Txn txn) => repo.save(txn);

  Future<void> deleteTransaction(String id) => repo.delete(id);

  Future<void> updateSettings(AppSettings values) => settings.update(values);

  Future<void> updateSettingsWith(AppSettings Function(AppSettings) transform) =>
      settings.updateWith(transform);

  /// 导入 JSON 备份；返回导入条数。格式错误时抛 [FormatException]。
  Future<int> importBackup(String raw) async {
    final parsed = ExportService.parseBackupTransactions(raw);
    if (parsed == null) {
      throw const FormatException('备份文件格式不正确');
    }
    await repo.saveAll(parsed);
    return parsed.length;
  }

  /// 清空全部账本数据（设置保留）。
  Future<void> clearTransactions() => repo.clear();

  void _handleChange() => notifyListeners();

  @override
  void dispose() {
    repo.removeListener(_handleChange);
    settings.removeListener(_handleChange);
    super.dispose();
  }

  Future<void> shutdown() async {
    dispose();
    await store.close();
  }
}

/// 让任意页面通过 `AppScope.of(context)` 拿到 [AppState]，并自动随数据变化重建。
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope 未挂在 Widget 树上');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget as AppScope?;
    assert(scope != null, 'AppScope 未挂在 Widget 树上');
    return scope!.notifier!;
  }
}
