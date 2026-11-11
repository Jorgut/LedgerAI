// 统计服务单测：summary / breakdown / trend / todayExpense / budgetRatio。
// 被测代码：lib/core/stats.dart（用真实 LocalStore + 临时目录，不 mock 存储）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/models.dart';
import 'package:ledger_ai/core/stats.dart';
import 'package:ledger_ai/core/storage.dart';

Txn buildTxn({
  required String id,
  double amount = 10,
  String categoryId = 'food',
  DateTime? date,
  bool isIncome = false,
  String note = '',
}) {
  final txnDate = date ?? DateTime(2026, 3, 15, 12);
  return Txn(
    id: id,
    amount: amount,
    categoryId: categoryId,
    date: txnDate,
    note: note,
    isIncome: isIncome,
  );
}

void main() {
  late Directory tempDir;
  late LocalStore store;
  late TransactionRepository repo;
  late StatsService stats;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledger_ai_stats_');
    store = await LocalStore.openForTest(tempDir.path);
    repo = store.transactions;
    stats = StatsService(repo);
  });

  tearDown(() async {
    await store.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('summary', () {
    test('汇总当月收入、支出、笔数与结余', () async {
      await repo.saveAll([
        buildTxn(id: 'i1', amount: 8000, categoryId: 'salary', date: DateTime(2026, 3, 5), isIncome: true),
        buildTxn(id: 'e1', amount: 42, date: DateTime(2026, 3, 6)),
        buildTxn(id: 'e2', amount: 8, categoryId: 'transport', date: DateTime(2026, 3, 7)),
        buildTxn(id: 'feb', amount: 100, date: DateTime(2026, 2, 28)),
        buildTxn(id: 'apr', amount: 999, date: DateTime(2026, 4, 1)),
      ]);

      final summary = stats.summary(2026, 3);
      expect(summary.income, 8000);
      expect(summary.expense, 50);
      expect(summary.count, 3);
      expect(summary.balance, 7950);
      expect(summary.isEmpty, isFalse);
    });

    test('空月份返回全 0，isEmpty 为 true', () {
      final summary = stats.summary(2025, 1);
      expect(summary.income, 0);
      expect(summary.expense, 0);
      expect(summary.count, 0);
      expect(summary.balance, 0);
      expect(summary.isEmpty, isTrue);
    });

    test('金额为整数的交易按 double 累计（无精度异常）', () async {
      await repo.saveAll([
        buildTxn(id: 'a', amount: 0.1, date: DateTime(2026, 3, 1)),
        buildTxn(id: 'b', amount: 0.2, date: DateTime(2026, 3, 2)),
      ]);
      expect(stats.summary(2026, 3).expense, closeTo(0.3, 1e-9));
    });
  });

  group('breakdown', () {
    test('支出分类按金额降序，ratio 合计为 1', () async {
      await repo.saveAll([
        buildTxn(id: 'f1', amount: 300, categoryId: 'food', date: DateTime(2026, 3, 1)),
        buildTxn(id: 'f2', amount: 100, categoryId: 'food', date: DateTime(2026, 3, 2)),
        buildTxn(id: 't1', amount: 200, categoryId: 'transport', date: DateTime(2026, 3, 3)),
        buildTxn(id: 's1', amount: 100, categoryId: 'shopping', date: DateTime(2026, 3, 4)),
        buildTxn(id: 'income', amount: 5000, categoryId: 'salary', date: DateTime(2026, 3, 5), isIncome: true),
      ]);

      final slices = stats.breakdown(2026, 3);
      expect(slices, hasLength(3));
      expect(slices.map((s) => s.category.id).toList(), ['food', 'transport', 'shopping']);
      expect(slices[0].amount, 400);
      expect(slices[0].ratio, closeTo(400 / 700, 1e-9));
      expect(slices[1].ratio, closeTo(200 / 700, 1e-9));
      expect(slices.fold<double>(0, (sum, s) => sum + s.ratio), closeTo(1, 1e-9));
      expect(slices.every((s) => !s.category.isIncome), isTrue);
    });

    test('收入分类统计', () async {
      await repo.saveAll([
        buildTxn(id: 'salary', amount: 8000, categoryId: 'salary', date: DateTime(2026, 3, 5), isIncome: true),
        buildTxn(id: 'bonus', amount: 2000, categoryId: 'bonus', date: DateTime(2026, 3, 6), isIncome: true),
        buildTxn(id: 'food', amount: 300, date: DateTime(2026, 3, 7)),
      ]);

      final slices = stats.breakdown(2026, 3, isIncome: true);
      expect(slices.map((s) => s.category.id).toList(), ['salary', 'bonus']);
      expect(slices[0].amount, 8000);
      expect(slices[1].ratio, closeTo(0.2, 1e-9));
      // 默认 isIncome=false，不应混入收入分类。
      expect(stats.breakdown(2026, 3).map((s) => s.category.id), ['food']);
    });

    test('无数据月份返回空列表', () {
      expect(stats.breakdown(2025, 1), isEmpty);
    });

    test('未知分类 id 回退为「其他」分类', () async {
      await repo.save(buildTxn(id: 'x', amount: 10, categoryId: 'ghost', date: DateTime(2026, 3, 1)));
      final slices = stats.breakdown(2026, 3);
      expect(slices.single.category.id, Category.otherExpenseId);
    });
  });

  group('trend', () {
    test('按时间正序返回指定月数，末位是锚点月', () async {
      await repo.saveAll([
        buildTxn(id: 'oct', amount: 100, date: DateTime(2025, 10, 5)),
        buildTxn(id: 'jan', amount: 200, date: DateTime(2026, 1, 5)),
        buildTxn(id: 'mar', amount: 300, date: DateTime(2026, 3, 5)),
      ]);

      final points = stats.trend(months: 6, end: DateTime(2026, 3, 20));
      expect(points, hasLength(6));
      expect(
        points.map((p) => '${p.year}-${p.month}').toList(),
        ['2025-10', '2025-11', '2025-12', '2026-1', '2026-2', '2026-3'],
      );
      expect(points.first.expense, 100);
      expect(points[3].expense, 200);
      expect(points.last.expense, 300);
      expect(points.last.year, 2026);
      expect(points.last.month, 3);

      // 正序：序号单调递增。
      for (var i = 1; i < points.length; i++) {
        final prev = points[i - 1].year * 12 + points[i - 1].month;
        final cur = points[i].year * 12 + points[i].month;
        expect(cur, greaterThan(prev));
      }
    });

    test('跨年回退到上一年', () async {
      final points = stats.trend(months: 3, end: DateTime(2026, 1, 15));
      expect(
        points.map((p) => '${p.year}-${p.month}').toList(),
        ['2025-11', '2025-12', '2026-1'],
      );
    });

    test('months=1 只返回锚点月', () async {
      final points = stats.trend(months: 1, end: DateTime(2026, 3, 20));
      expect(points, hasLength(1));
      expect(points.single.year, 2026);
      expect(points.single.month, 3);
    });
  });

  group('todayExpense', () {
    test('只累计今天支出，不含收入与其它日期', () async {
      await repo.saveAll([
        buildTxn(id: 'today-morning', amount: 20, date: DateTime(2026, 3, 15, 8)),
        buildTxn(id: 'today-late', amount: 5, date: DateTime(2026, 3, 15, 23, 59)),
        buildTxn(id: 'yesterday', amount: 100, date: DateTime(2026, 3, 14, 23, 59)),
        buildTxn(id: 'tomorrow', amount: 50, date: DateTime(2026, 3, 16)),
        buildTxn(id: 'income', amount: 500, date: DateTime(2026, 3, 15, 10), isIncome: true),
      ]);

      expect(stats.todayExpense(now: DateTime(2026, 3, 15, 15)), 25);
      expect(stats.todayExpense(now: DateTime(2026, 3, 16, 0)), 50);
      expect(stats.todayExpense(now: DateTime(2026, 4, 1)), 0);
    });
  });

  group('budgetRatio', () {
    test('未设置 / 非正预算返回 null', () async {
      await repo.save(buildTxn(id: 'a', amount: 500, date: DateTime(2026, 3, 1)));
      expect(stats.budgetRatio(null, 2026, 3), isNull);
      expect(stats.budgetRatio(0, 2026, 3), isNull);
      expect(stats.budgetRatio(-100, 2026, 3), isNull);
    });

    test('支出 / 预算比例', () async {
      await repo.saveAll([
        buildTxn(id: 'a', amount: 1200, date: DateTime(2026, 3, 1)),
        buildTxn(id: 'b', amount: 300, date: DateTime(2026, 3, 2)),
      ]);
      expect(stats.budgetRatio(1000, 2026, 3), closeTo(1.5, 1e-9));
      expect(stats.budgetRatio(3000, 2026, 3), closeTo(0.5, 1e-9));
    });

    test('无支出时比例为 0', () {
      expect(stats.budgetRatio(1000, 2026, 3), 0);
    });
  });
}
