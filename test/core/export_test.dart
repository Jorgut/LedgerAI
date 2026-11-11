// 导出单测：CSV 表头 / 转义 / 排序，JSON 备份往返与非法备份。
// 被测代码：lib/core/export.dart。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/export.dart';
import 'package:ledger_ai/core/models.dart';

Txn buildTxn({
  required String id,
  double amount = 42,
  String categoryId = 'food',
  DateTime? date,
  String note = '',
  bool isIncome = false,
  EntrySource source = EntrySource.manual,
  String? merchant,
}) {
  return Txn(
    id: id,
    amount: amount,
    categoryId: categoryId,
    date: date ?? DateTime(2026, 1, 5, 9, 7),
    note: note,
    isIncome: isIncome,
    source: source,
    merchant: merchant,
  );
}

void main() {
  const exporter = ExportService();

  group('buildCsv', () {
    test('表头固定且带换行', () {
      final csv = exporter.buildCsv(const []);
      expect(csv, '${ExportService.csvHeader}\n');
      expect(ExportService.csvHeader, '日期,类型,分类,金额,商户,备注,来源');
    });

    test('行内容：日期 / 类型 / 分类 / 两位小数金额 / 商户 / 备注 / 来源', () {
      final csv = exporter.buildCsv([
        buildTxn(
          id: 'a',
          amount: 42.5,
          categoryId: 'food',
          date: DateTime(2026, 1, 3, 18, 30),
          note: '午餐',
          merchant: '麦当劳',
          source: EntrySource.ocr,
        ),
        buildTxn(
          id: 'b',
          amount: 8000,
          categoryId: 'salary',
          date: DateTime(2026, 1, 5, 9, 7),
          note: '月薪',
          merchant: '公司',
          isIncome: true,
        ),
      ]);

      final lines = csv.trimRight().split('\n');
      expect(lines, hasLength(3));
      expect(lines[0], ExportService.csvHeader);
      expect(lines[1], '2026-01-03 18:30,支出,餐饮,42.50,麦当劳,午餐,拍照识别');
      expect(lines[2], '2026-01-05 09:07,收入,工资,8000.00,公司,月薪,手动');
    });

    test('按日期升序输出（与仓库倒序相反）', () {
      final csv = exporter.buildCsv([
        buildTxn(id: 'late', date: DateTime(2026, 2, 2, 23, 59)),
        buildTxn(id: 'early', date: DateTime(2026, 1, 1, 7, 5)),
        buildTxn(id: 'middle', date: DateTime(2026, 1, 20, 12, 0)),
      ]);
      final dates = csv
          .trimRight()
          .split('\n')
          .skip(1)
          .map((line) => line.split(',').first)
          .toList();
      expect(dates, ['2026-01-01 07:05', '2026-01-20 12:00', '2026-02-02 23:59']);
    });

    test('备注 / 商户含逗号时整体加引号', () {
      final csv = exporter.buildCsv([
        buildTxn(id: 'a', note: '午餐, 好吃', merchant: '便利店, 24h'),
      ]);
      final row = csv.trimRight().split('\n')[1];
      expect(row, contains('"午餐, 好吃"'));
      expect(row, contains('"便利店, 24h"'));
    });

    test('双引号按 CSV 规范转义为两个双引号', () {
      final csv = exporter.buildCsv([buildTxn(id: 'a', note: '他说"好"')]);
      final row = csv.trimRight().split('\n')[1];
      expect(row, contains('"他说""好"""'));
    });

    test('换行符出现在备注中时字段加引号', () {
      final csv = exporter.buildCsv([buildTxn(id: 'a', note: '第一行\n第二行')]);
      expect(csv, contains('"第一行\n第二行"'));
    });

    test('缺失商户与备注时输出空字段', () {
      final csv = exporter.buildCsv([buildTxn(id: 'a', note: '', merchant: null)]);
      final row = csv.trimRight().split('\n')[1];
      expect(row, '2026-01-05 09:07,支出,餐饮,42.00,,,手动');
    });

    test('三种录入来源标签映射', () {
      final csv = exporter.buildCsv([
        buildTxn(id: 'm', source: EntrySource.manual),
        buildTxn(id: 'o', source: EntrySource.ocr, date: DateTime(2026, 1, 6)),
        buildTxn(id: 'v', source: EntrySource.voice, date: DateTime(2026, 1, 7)),
      ]);
      expect(csv, contains(',拍照识别'));
      expect(csv, contains(',语音记账'));
      expect(csv, contains(',手动'));
    });
  });

  group('buildBackup / parseBackupTransactions', () {
    final txns = [
      buildTxn(
        id: 'a',
        amount: 42.5,
        date: DateTime(2026, 3, 15, 10, 30),
        note: '午餐',
        merchant: '麦当劳',
        source: EntrySource.ocr,
      ),
      buildTxn(
        id: 'b',
        amount: 8000,
        categoryId: 'salary',
        date: DateTime(2026, 3, 1, 9),
        isIncome: true,
        note: '月薪',
      ),
    ];
    const settings = AppSettings(
      onboardingDone: true,
      themeMode: ThemeMode.dark,
      monthlyBudget: 6000,
      categoryBudgets: {'food': 2000},
      highContrast: true,
    );

    test('备份 JSON 结构：app / version / 导出时间 / 设置 / 交易', () {
      final raw = exporter.buildBackup(txns, settings);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      expect(decoded['app'], 'ledger_ai');
      expect(decoded['version'], 1);
      expect(DateTime.parse(decoded['exportedAt'] as String), isA<DateTime>());
      expect(decoded['settings'], settings.toJson());
      expect(decoded['transactions'], hasLength(2));
      expect((decoded['transactions'] as List).first['id'], 'a');
    });

    test('备份往返：解析结果与原交易一致', () {
      final raw = exporter.buildBackup(txns, settings);
      final parsed = ExportService.parseBackupTransactions(raw);

      expect(parsed, isNotNull);
      expect(parsed, hasLength(2));
      expect(parsed![0], txns[0]);
      expect(parsed[1], txns[1]);
      expect(parsed[0].createdAt, txns[0].createdAt);
      expect(parsed[1].source, EntrySource.manual);
    });

    test('备份中的负数金额在解析时取绝对值', () {
      final raw = jsonEncode({
        'transactions': [
          {'id': 'x', 'amount': -42.5, 'categoryId': 'food', 'date': '2026-03-15T10:30:00.000'},
        ],
      });
      final parsed = ExportService.parseBackupTransactions(raw);
      expect(parsed, hasLength(1));
      expect(parsed!.single.amount, 42.5);
    });

    test('非法备份返回 null', () {
      expect(ExportService.parseBackupTransactions(''), isNull);
      expect(ExportService.parseBackupTransactions('not json'), isNull);
      expect(ExportService.parseBackupTransactions('null'), isNull);
      expect(ExportService.parseBackupTransactions('[]'), isNull);
      expect(ExportService.parseBackupTransactions('42'), isNull);
      expect(ExportService.parseBackupTransactions('{}'), isNull); // 缺 transactions
      expect(ExportService.parseBackupTransactions('{"transactions": "oops"}'), isNull);
      expect(
        ExportService.parseBackupTransactions('{"transactions": [{"id": "x"}]}'),
        isNull, // 缺 amount 无法构造 Txn
      );
    });

    test('transactions 为空数组时返回空列表（合法但无数据）', () {
      expect(ExportService.parseBackupTransactions('{"transactions": []}'), isEmpty);
    });

    test('非对象元素被跳过，对象元素正常解析', () {
      final raw = jsonEncode({
        'transactions': [
          1,
          'two',
          {'id': 'x', 'amount': 10, 'categoryId': 'food', 'date': '2026-03-15T10:30:00.000'},
        ],
      });
      final parsed = ExportService.parseBackupTransactions(raw);
      expect(parsed, hasLength(1));
      expect(parsed!.single.id, 'x');
    });
  });
}
