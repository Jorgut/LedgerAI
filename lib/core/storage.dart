import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_settings.dart';
import 'models.dart';

/// 本地存储入口：两个 Hive box。
/// - `txns_v2`：Txn 的 JSON 字符串，key 为交易 id。
/// - `settings_v1`：用户偏好（一个 JSON 字符串）。
///
/// 刻意不依赖 Hive codegen：手写 JSON 序列化，字段向后兼容，便于测试。
class LocalStore {
  LocalStore._(this._txnBox, this._settingsBox);

  final Box<String> _txnBox;
  final Box<String> _settingsBox;

  late final TransactionRepository transactions = TransactionRepository(_txnBox);
  late final SettingsStore settings = SettingsStore(_settingsBox);

  static Future<LocalStore> open({String? subDirectory}) async {
    await Hive.initFlutter(subDirectory);
    final txnBox = await Hive.openBox<String>('txns_v2');
    final settingsBox = await Hive.openBox<String>('settings_v1');
    return LocalStore._(txnBox, settingsBox);
  }

  /// 仅测试使用：用已初始化的 Hive 打开独立箱。
  static Future<LocalStore> openForTest(String path) async {
    Hive.init(path);
    final txnBox = await Hive.openBox<String>('txns_v2');
    final settingsBox = await Hive.openBox<String>('settings_v1');
    return LocalStore._(txnBox, settingsBox);
  }

  Future<void> close() async {
    await _txnBox.close();
    await _settingsBox.close();
  }
}

/// 交易仓库。全部读取走内存缓存，写入后失效并通知监听者。
class TransactionRepository extends ChangeNotifier {
  TransactionRepository(this._box);

  final Box<String> _box;
  List<Txn>? _cache;

  List<Txn> get all {
    final cached = _cache;
    if (cached != null) return cached;
    final items = <Txn>[];
    for (final raw in _box.values) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) items.add(Txn.fromJson(map));
      } catch (_) {
        // 单条损坏不应阻断整个账本；保留其余记录。
      }
    }
    items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.createdAt.compareTo(a.createdAt);
    });
    return _cache = items;
  }

  List<Txn> byMonth(int year, int month) => all
      .where((t) => t.date.year == year && t.date.month == month)
      .toList(growable: false);

  List<Txn> inRange(DateTime start, DateTime end) => all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
      .toList(growable: false);

  List<Txn> search(String query, {DateTime? month}) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return month == null ? all : byMonth(month.year, month.month);
    }
    return all.where((t) {
      if (month != null && (t.date.year != month.year || t.date.month != month.month)) {
        return false;
      }
      final category = t.category.name;
      final haystack = '${t.note} ${t.merchant ?? ''} $category ${t.amount.toStringAsFixed(2)}'
          .toLowerCase();
      return haystack.contains(keyword);
    }).toList(growable: false);
  }

  Txn? byId(String id) {
    for (final txn in all) {
      if (txn.id == id) return txn;
    }
    return null;
  }

  Future<void> save(Txn txn) async {
    await _box.put(txn.id, jsonEncode(txn.toJson()));
    _invalidate();
    notifyListeners();
  }

  Future<void> saveAll(Iterable<Txn> txns) async {
    final entries = <String, String>{
      for (final txn in txns) txn.id: jsonEncode(txn.toJson()),
    };
    await _box.putAll(entries);
    _invalidate();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _invalidate();
    notifyListeners();
  }

  Future<void> clear() async {
    await _box.clear();
    _invalidate();
    notifyListeners();
  }

  int get count => _box.length;

  void _invalidate() => _cache = null;
}

/// 设置仓库。整个设置对象作为一个 JSON 字符串保存。
class SettingsStore extends ChangeNotifier {
  SettingsStore(this._box) {
    _settings = _read();
  }

  static const String _key = 'app_settings';

  final Box<String> _box;
  late AppSettings _settings;

  AppSettings get value => _settings;

  AppSettings _read() {
    final raw = _box.get(_key);
    if (raw == null) return AppSettings.defaults;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) return AppSettings.fromJson(map);
    } catch (_) {
      // 损坏的设置回退默认值，而不是让应用起不来。
    }
    return AppSettings.defaults;
  }

  Future<void> update(AppSettings values) async {
    _settings = values;
    await _box.put(_key, jsonEncode(values.toJson()));
    notifyListeners();
  }

  Future<void> updateWith(AppSettings Function(AppSettings current) transform) =>
      update(transform(_settings));

  Future<void> reset() async {
    _settings = AppSettings.defaults;
    await _box.delete(_key);
    notifyListeners();
  }
}
