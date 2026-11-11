// 智能建议规则单测：空数据、超预算、占比高、环比、储蓄率、最多 3 条。
// 被测代码：lib/core/insights.dart（真实存储 + 真实统计，不 mock 规则）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/insights.dart';
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
  late InsightsService insights;

  final march = DateTime(2026, 3, 15);

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledger_ai_insights_');
    store = await LocalStore.openForTest(tempDir.path);
    repo = store.transactions;
    insights = InsightsService(repo, StatsService(repo));
  });

  tearDown(() async {
    await store.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('空数据', () {
    test('本月无记录时只给引导建议', () {
      final result = insights.forMonth(march);
      expect(result, hasLength(1));
      expect(result.single.title, '本月还没有记录');
      expect(result.single.tone, InsightTone.neutral);
      expect(result.single.metric, isNull);
    });

    test('只有上月数据时，本月仍视为无数据', () async {
      await repo.save(buildTxn(id: 'feb', amount: 500, date: DateTime(2026, 2, 10)));
      final result = insights.forMonth(march);
      expect(result.single.title, '本月还没有记录');
    });
  });

  group('预算规则', () {
    test('超预算：warning + 超支 metric', () async {
      await repo.save(buildTxn(id: 'a', amount: 1200, date: DateTime(2026, 3, 5)));

      final result = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 1000));
      final budgetInsight = result.first;
      expect(budgetInsight.title, '本月已超出预算');
      expect(budgetInsight.tone, InsightTone.warning);
      expect(budgetInsight.body, contains('¥1,200.00'));
      expect(budgetInsight.body, contains('¥200.00'));
      expect(budgetInsight.metric, '超支 200');
    });

    test('预算使用 80% 及以上提示快用完', () async {
      await repo.save(buildTxn(id: 'a', amount: 850, date: DateTime(2026, 3, 5)));

      final result = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 1000));
      expect(result.first.title, '预算快用完了');
      expect(result.first.tone, InsightTone.warning);
      expect(result.first.body, contains('85%'));
      expect(result.first.body, contains('¥150.00'));
      expect(result.first.metric, '剩余 150');
    });

    test('预算健康：positive 提示可用金额', () async {
      await repo.save(buildTxn(id: 'a', amount: 500, date: DateTime(2026, 3, 5)));

      final result = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 1000));
      expect(result.first.title, '预算节奏健康');
      expect(result.first.tone, InsightTone.positive);
      expect(result.first.metric, '可用 500');
    });

    test('预算为 null 或 0 时不出现预算建议', () async {
      await repo.saveAll([
        buildTxn(id: 'a', amount: 300, categoryId: 'food', date: DateTime(2026, 3, 5)),
        buildTxn(id: 'b', amount: 200, categoryId: 'transport', date: DateTime(2026, 3, 6)),
      ]);
      for (final result in [
        insights.forMonth(march),
        insights.forMonth(march, settings: const AppSettings()),
        insights.forMonth(march, settings: const AppSettings(monthlyBudget: 0)),
      ]) {
        expect(result.any((i) => i.title.contains('预算')), isFalse);
      }
    });
  });

  group('分类占比规则', () {
    test('头部分类占比 ≥ 35% 时提示', () async {
      await repo.saveAll([
        buildTxn(id: 'a', amount: 300, categoryId: 'food', date: DateTime(2026, 3, 5)),
        buildTxn(id: 'b', amount: 200, categoryId: 'transport', date: DateTime(2026, 3, 6)),
      ]);

      final result = insights.forMonth(march);
      expect(result, hasLength(1));
      expect(result.single.title, '「餐饮」占比偏高');
      expect(result.single.body, contains('¥300.00'));
      expect(result.single.body, contains('60%'));
      expect(result.single.metric, '占 60%');
    });

    test('头部占比 < 35% 时不提示，走兜底建议', () async {
      await repo.saveAll([
        buildTxn(id: 'a', amount: 100, categoryId: 'food', date: DateTime(2026, 3, 5)),
        buildTxn(id: 'b', amount: 100, categoryId: 'transport', date: DateTime(2026, 3, 6)),
        buildTxn(id: 'c', amount: 100, categoryId: 'shopping', date: DateTime(2026, 3, 7)),
      ]);

      final result = insights.forMonth(march);
      expect(result, hasLength(1));
      expect(result.single.title, '记账习惯正在建立');
      expect(result.single.tone, InsightTone.neutral);
    });
  });

  group('环比规则', () {
    test('支出比上月高 ≥ 20%', () async {
      await repo.saveAll([
        buildTxn(id: 'feb', amount: 1000, categoryId: 'food', date: DateTime(2026, 2, 10)),
        buildTxn(id: 'mar1', amount: 700, categoryId: 'food', date: DateTime(2026, 3, 5)),
        buildTxn(id: 'mar2', amount: 600, categoryId: 'transport', date: DateTime(2026, 3, 6)),
      ]);

      final result = insights.forMonth(march);
      final mom = result.last;
      expect(mom.title, '支出比上月高');
      expect(mom.tone, InsightTone.warning);
      expect(mom.metric, '+30%');
      expect(mom.body, contains('¥300.00'));
    });

    test('支出比上月下降 ≥ 10%', () async {
      await repo.saveAll([
        buildTxn(id: 'feb', amount: 1000, categoryId: 'food', date: DateTime(2026, 2, 10)),
        buildTxn(id: 'mar1', amount: 500, categoryId: 'food', date: DateTime(2026, 3, 5)),
        buildTxn(id: 'mar2', amount: 300, categoryId: 'transport', date: DateTime(2026, 3, 6)),
      ]);

      final result = insights.forMonth(march);
      final mom = result.last;
      expect(mom.title, '支出比上月下降');
      expect(mom.tone, InsightTone.positive);
      expect(mom.metric, '-20%');
      expect(mom.body, contains('¥200.00'));
    });

    test('小幅波动（<10%）不提示环比', () async {
      await repo.saveAll([
        buildTxn(id: 'feb', amount: 1000, categoryId: 'food', date: DateTime(2026, 2, 10)),
        buildTxn(id: 'mar', amount: 950, categoryId: 'food', date: DateTime(2026, 3, 5)),
      ]);

      final result = insights.forMonth(march);
      expect(result.any((i) => i.title.contains('比上月')), isFalse);
    });
  });

  group('储蓄率规则', () {
    test('储蓄率 ≥ 30% 时给出正向建议', () async {
      await repo.saveAll([
        buildTxn(id: 'salary', amount: 3000, categoryId: 'salary', date: DateTime(2026, 3, 1), isIncome: true),
        buildTxn(id: 'food', amount: 600, categoryId: 'food', date: DateTime(2026, 3, 5)),
      ]);

      final result = insights.forMonth(march);
      final saving = result.last;
      expect(saving.title, '储蓄率不错');
      expect(saving.tone, InsightTone.positive);
      expect(saving.metric, '储蓄率 80%');
      expect(saving.body, contains('¥2,400.00'));
    });

    test('支出大于收入时提醒核对', () async {
      await repo.saveAll([
        buildTxn(id: 'income', amount: 500, categoryId: 'salary', date: DateTime(2026, 3, 1), isIncome: true),
        buildTxn(id: 'food', amount: 900, categoryId: 'food', date: DateTime(2026, 3, 5)),
      ]);

      final result = insights.forMonth(march);
      final warning = result.last;
      expect(warning.title, '本月支出大于收入');
      expect(warning.tone, InsightTone.warning);
    });
  });

  test('小额支出频繁规则', () async {
    await repo.saveAll([
      for (var i = 0; i < 5; i++)
        buildTxn(id: 'small-$i', amount: 20, date: DateTime(2026, 3, 1 + i)),
    ]);

    final result = insights.forMonth(march);
    final small = result.firstWhere((i) => i.title == '小额支出比较频繁');
    expect(small.metric, '5 笔');
    expect(small.body, contains('¥20.00'));
  });

  test('最多返回 3 条且按规则优先级截断', () async {
    await repo.saveAll([
      buildTxn(id: 'salary', amount: 5000, categoryId: 'salary', date: DateTime(2026, 3, 1), isIncome: true),
      buildTxn(id: 'food', amount: 900, categoryId: 'food', date: DateTime(2026, 3, 5)),
      buildTxn(id: 'transport', amount: 300, categoryId: 'transport', date: DateTime(2026, 3, 6)),
      buildTxn(id: 'feb', amount: 600, categoryId: 'food', date: DateTime(2026, 2, 10)),
    ]);

    final result = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 500));
    expect(result, hasLength(3));
    expect(result.map((i) => i.title).toList(), [
      '本月已超出预算',
      '「餐饮」占比偏高',
      '支出比上月高',
    ]);
    expect(result.any((i) => i.title == '储蓄率不错'), isFalse);
  });

  test('相同数据下规则结果稳定（确定性，不依赖随机/网络）', () async {
    await repo.save(buildTxn(id: 'a', amount: 300, categoryId: 'food', date: DateTime(2026, 3, 5)));
    final first = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 1000));
    final second = insights.forMonth(march, settings: const AppSettings(monthlyBudget: 1000));
    expect(first.map((i) => i.title), second.map((i) => i.title));
    expect(first.map((i) => i.body), second.map((i) => i.body));
  });
}
