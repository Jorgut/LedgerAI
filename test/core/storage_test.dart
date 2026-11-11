// 本地存储单测：TransactionRepository / SettingsStore（Hive，临时目录，每个用例独立）。
// 被测代码：lib/core/storage.dart、lib/core/models.dart、lib/core/app_settings.dart。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/models.dart';
import 'package:ledger_ai/core/storage.dart';

Txn buildTxn({
  required String id,
  double amount = 42,
  String categoryId = 'food',
  DateTime? date,
  String note = '',
  bool isIncome = false,
  EntrySource source = EntrySource.manual,
  String? merchant,
  DateTime? createdAt,
}) {
  final txnDate = date ?? DateTime(2026, 3, 15, 12);
  return Txn(
    id: id,
    amount: amount,
    categoryId: categoryId,
    date: txnDate,
    note: note,
    isIncome: isIncome,
    source: source,
    merchant: merchant,
    createdAt: createdAt ?? txnDate,
  );
}

void main() {
  late Directory tempDir;
  late LocalStore store;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledger_ai_storage_');
    store = await LocalStore.openForTest(tempDir.path);
  });

  tearDown(() async {
    await store.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('TransactionRepository 基础读写', () {
    test('初始为空', () {
      expect(store.transactions.all, isEmpty);
      expect(store.transactions.count, 0);
      expect(store.transactions.byId('nope'), isNull);
    });

    test('save 后 all 按日期倒序，同日按 createdAt 倒序', () async {
      final repo = store.transactions;
      final day = DateTime(2026, 1, 10);
      await repo.save(buildTxn(id: 'old', date: day, createdAt: DateTime(2026, 1, 10, 9)));
      await repo.save(buildTxn(
        id: 'same-day-late',
        date: day,
        createdAt: DateTime(2026, 1, 10, 21),
      ));
      await repo.save(buildTxn(
        id: 'newest',
        date: DateTime(2026, 1, 12),
        createdAt: DateTime(2026, 1, 12, 8),
      ));

      expect(repo.all.map((t) => t.id).toList(), ['newest', 'same-day-late', 'old']);
      expect(repo.count, 3);
    });

    test('save 同一 id 是覆盖更新而不是新增', () async {
      final repo = store.transactions;
      await repo.save(buildTxn(id: 'a', amount: 10, note: '旧'));
      await repo.save(buildTxn(id: 'a', amount: 20, note: '新'));

      expect(repo.count, 1);
      expect(repo.byId('a')!.amount, 20);
      expect(repo.byId('a')!.note, '新');
    });

    test('saveAll 批量写入', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'a', date: DateTime(2026, 2, 1)),
        buildTxn(id: 'b', date: DateTime(2026, 2, 2)),
      ]);
      expect(store.transactions.count, 2);
      expect(store.transactions.all, hasLength(2));
      expect(store.transactions.all.first.id, 'b');
    });

    test('delete 只删除指定 id', () async {
      final repo = store.transactions;
      await repo.saveAll([
        buildTxn(id: 'a', date: DateTime(2026, 2, 1)),
        buildTxn(id: 'b', date: DateTime(2026, 2, 2)),
      ]);
      await repo.delete('a');

      expect(repo.byId('a'), isNull);
      expect(repo.byId('b'), isNotNull);
      expect(repo.count, 1);
    });

    test('clear 清空交易但保留设置', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'a'),
        buildTxn(id: 'b', date: DateTime(2026, 2, 2)),
      ]);
      await store.settings.update(const AppSettings(monthlyBudget: 6000));

      await store.transactions.clear();

      expect(store.transactions.all, isEmpty);
      expect(store.transactions.count, 0);
      expect(store.settings.value.monthlyBudget, 6000);
    });

    test('写入 / 删除会通知监听者（AppState 依赖此机制刷新）', () async {
      final repo = store.transactions;
      var notifications = 0;
      repo.addListener(() => notifications++);

      await repo.save(buildTxn(id: 'a'));
      expect(notifications, 1);

      await repo.delete('a');
      expect(notifications, 2);

      await repo.clear();
      expect(notifications, 3);
    });
  });

  group('查询', () {
    test('byMonth 只返回目标月份', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'jan', date: DateTime(2026, 1, 31, 23)),
        buildTxn(id: 'feb', date: DateTime(2026, 2, 1, 0)),
        buildTxn(id: 'mar', date: DateTime(2026, 3, 15)),
      ]);

      expect(store.transactions.byMonth(2026, 2).map((t) => t.id).toList(), ['feb']);
      expect(store.transactions.byMonth(2025, 2), isEmpty);
    });

    test('inRange 含起点不含终点', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'before', date: DateTime(2026, 3, 14, 23, 59)),
        buildTxn(id: 'start', date: DateTime(2026, 3, 15)),
        buildTxn(id: 'inside', date: DateTime(2026, 3, 15, 12)),
        buildTxn(id: 'end', date: DateTime(2026, 3, 16)),
      ]);

      final result = store.transactions.inRange(DateTime(2026, 3, 15), DateTime(2026, 3, 16));
      expect(result.map((t) => t.id).toSet(), {'start', 'inside'});
    });

    test('search 命中备注、商户、分类名与金额', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'lunch', note: '午餐', categoryId: 'food', amount: 42, merchant: '麦当劳'),
        buildTxn(id: 'coffee', note: 'COFFEE', categoryId: 'food', amount: 32, merchant: '瑞幸咖啡'),
        buildTxn(id: 'salary', note: '月薪', categoryId: 'salary', amount: 8000, isIncome: true),
      ]);
      final repo = store.transactions;

      expect(repo.search('午餐').map((t) => t.id), ['lunch']);
      expect(repo.search('coffee').map((t) => t.id), ['coffee']); // 大小写不敏感
      expect(repo.search('瑞幸').map((t) => t.id), ['coffee']);
      expect(repo.search('餐饮').map((t) => t.id).toSet(), {'lunch', 'coffee'});
      expect(repo.search('42.00').map((t) => t.id), ['lunch']);
    });

    test('search 忽略首尾空白；空查询等于全量或按月', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'a', date: DateTime(2026, 2, 1)),
        buildTxn(id: 'b', date: DateTime(2026, 3, 1)),
      ]);
      final repo = store.transactions;

      expect(repo.search('   '), hasLength(2));
      expect(repo.search('', month: DateTime(2026, 2, 15)).map((t) => t.id), ['a']);
      expect(repo.search(' 午餐 ', month: DateTime(2026, 2, 15)), isEmpty);
    });

    test('search 带 month 时只在该月内匹配', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'feb', date: DateTime(2026, 2, 10), note: '咖啡'),
        buildTxn(id: 'mar', date: DateTime(2026, 3, 10), note: '咖啡'),
      ]);
      final repo = store.transactions;

      expect(repo.search('咖啡').map((t) => t.id).toSet(), {'feb', 'mar'});
      expect(repo.search('咖啡', month: DateTime(2026, 3, 1)).map((t) => t.id), ['mar']);
    });

    test('search 无命中返回空列表', () async {
      await store.transactions.save(buildTxn(id: 'a', note: '午餐'));
      expect(store.transactions.search('不存在的关键词'), isEmpty);
    });

    test('byId 命中与未命中', () async {
      await store.transactions.save(buildTxn(id: 'a'));
      expect(store.transactions.byId('a')!.id, 'a');
      expect(store.transactions.byId('b'), isNull);
    });
  });

  group('损坏数据容错', () {
    test('单条损坏 JSON 不影响其余交易读取，count 仍按箱内条数', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'a', note: '正常 1'),
        buildTxn(id: 'b', date: DateTime(2026, 3, 16), note: '正常 2'),
      ]);
      await Hive.box<String>('txns_v2').put('broken', '{ this is not json');

      expect(store.transactions.all.map((t) => t.id).toSet(), {'a', 'b'});
      expect(store.transactions.count, 3); // count 直接取箱长度，包含坏数据
    });

    test('非对象 JSON 也不会崩溃', () async {
      await store.transactions.save(buildTxn(id: 'a'));
      await Hive.box<String>('txns_v2').put('array', '[1,2,3]');
      await Hive.box<String>('txns_v2').put('string', '"hello"');

      expect(store.transactions.all.map((t) => t.id), ['a']);
    });

    test('损坏的设置 JSON 回退默认值', () async {
      await Hive.box<String>('settings_v1').put('app_settings', '{ bad json');

      final prefs = store.settings.value;
      expect(prefs.onboardingDone, isFalse);
      expect(prefs.monthlyBudget, isNull);
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.hapticsEnabled, isTrue);
    });

    test('设置 JSON 是非对象时回退默认值', () async {
      await Hive.box<String>('settings_v1').put('app_settings', '42');

      expect(store.settings.value.monthlyBudget, isNull);
      expect(store.settings.value.themeMode, ThemeMode.system);
    });
  });

  group('SettingsStore', () {
    test('无数据时返回默认值', () {
      final prefs = store.settings.value;
      expect(prefs.onboardingDone, isFalse);
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.highContrast, isFalse);
      expect(prefs.monthlyBudget, isNull);
      expect(prefs.categoryBudgets, isEmpty);
      expect(prefs.hapticsEnabled, isTrue);
      expect(prefs.biometricLock, isFalse);
    });

    test('update 后立即生效并通知监听者', () async {
      var notifications = 0;
      store.settings.addListener(() => notifications++);

      await store.settings.update(const AppSettings(
        onboardingDone: true,
        monthlyBudget: 6000,
        themeMode: ThemeMode.dark,
        highContrast: true,
        categoryBudgets: {'food': 2000},
      ));

      expect(notifications, 1);
      final prefs = store.settings.value;
      expect(prefs.onboardingDone, isTrue);
      expect(prefs.monthlyBudget, 6000);
      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.highContrast, isTrue);
      expect(prefs.categoryBudgets['food'], 2000);
    });

    test('updateWith 基于当前值变换', () async {
      await store.settings.update(const AppSettings(monthlyBudget: 5000));
      await store.settings.updateWith((current) => current.copyWith(monthlyBudget: 8000));

      expect(store.settings.value.monthlyBudget, 8000);
    });

    test('reset 恢复默认值并删除持久化内容', () async {
      await store.settings.update(const AppSettings(onboardingDone: true, monthlyBudget: 6000));

      await store.settings.reset();

      expect(store.settings.value.onboardingDone, isFalse);
      expect(store.settings.value.monthlyBudget, isNull);
      expect(Hive.box<String>('settings_v1').containsKey('app_settings'), isFalse);
    });

    test('设置跨重启持久化', () async {
      await store.settings.update(const AppSettings(
        onboardingDone: true,
        monthlyBudget: 6000,
        themeMode: ThemeMode.dark,
      ));
      await store.close();

      store = await LocalStore.openForTest(tempDir.path);

      final prefs = store.settings.value;
      expect(prefs.onboardingDone, isTrue);
      expect(prefs.monthlyBudget, 6000);
      expect(prefs.themeMode, ThemeMode.dark);
    });

    test('交易跨重启持久化且保持排序', () async {
      await store.transactions.saveAll([
        buildTxn(id: 'a', date: DateTime(2026, 2, 1)),
        buildTxn(id: 'b', date: DateTime(2026, 2, 3)),
      ]);
      await store.close();

      store = await LocalStore.openForTest(tempDir.path);

      expect(store.transactions.all.map((t) => t.id).toList(), ['b', 'a']);
    });
  });
}
