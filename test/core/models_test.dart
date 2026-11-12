// 数据模型单测：EntrySource / Txn / Category 的序列化与拷贝语义。
// 被测代码：lib/core/models.dart（只读，勿按想象写断言）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/models.dart';

/// 构造一条字段齐全的交易，未指定字段使用固定默认值。
Txn buildTxn({
  String id = 't1',
  double amount = 42.5,
  String categoryId = 'food',
  DateTime? date,
  String note = '午餐',
  bool isIncome = false,
  EntrySource source = EntrySource.manual,
  String? merchant = '麦当劳',
  DateTime? createdAt,
}) {
  final txnDate = date ?? DateTime(2026, 3, 15, 12, 30);
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
  group('EntrySource', () {
    test('四个枚举值的中文标签', () {
      expect(EntrySource.values, hasLength(4));
      expect(EntrySource.manual.label, '手动');
      expect(EntrySource.ocr.label, '拍照识别');
      expect(EntrySource.voice.label, '语音记账');
      expect(EntrySource.csv.label, '导入账单');
    });

    test('parse 按 name 解析，未知值回退 manual', () {
      expect(EntrySource.parse('manual'), EntrySource.manual);
      expect(EntrySource.parse('ocr'), EntrySource.ocr);
      expect(EntrySource.parse('voice'), EntrySource.voice);
      expect(EntrySource.parse('csv'), EntrySource.csv);
      expect(EntrySource.parse('ocr '), EntrySource.manual); // 不做 trim
      expect(EntrySource.parse('camera'), EntrySource.manual);
      expect(EntrySource.parse(''), EntrySource.manual);
      expect(EntrySource.parse(null), EntrySource.manual);
    });
  });

  group('Txn 序列化', () {
    test('toJson 输出全部字段，source 存 name', () {
      final date = DateTime(2026, 3, 15, 10, 30, 45);
      final createdAt = DateTime(2026, 3, 15, 10, 31, 5);
      final txn = buildTxn(
        id: 'abc',
        amount: 42.5,
        categoryId: 'transport',
        date: date,
        note: '地铁',
        isIncome: true,
        source: EntrySource.voice,
        merchant: 'Metro',
        createdAt: createdAt,
      );

      final json = txn.toJson();
      expect(json['id'], 'abc');
      expect(json['amount'], 42.5);
      expect(json['categoryId'], 'transport');
      expect(json['date'], date.toIso8601String());
      expect(json['note'], '地铁');
      expect(json['isIncome'], isTrue);
      expect(json['source'], 'voice');
      expect(json['merchant'], 'Metro');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('JSON 字符串往返后字段一致（含 createdAt）', () {
      final txn = buildTxn(
        source: EntrySource.ocr,
        merchant: '瑞幸咖啡',
        date: DateTime(2026, 1, 2, 8, 5, 6, 7),
        createdAt: DateTime(2026, 1, 2, 8, 6),
      );
      final decoded =
          jsonDecode(jsonEncode(txn.toJson())) as Map<String, dynamic>;
      final restored = Txn.fromJson(decoded);

      expect(restored, txn);
      expect(restored.hashCode, txn.hashCode);
      expect(restored.categoryId, 'food');
      expect(restored.createdAt, txn.createdAt);
    });

    test('fromJson 对金额取绝对值', () {
      final txn = Txn.fromJson(<String, dynamic>{
        'id': 'x',
        'amount': -42.5,
        'categoryId': 'food',
        'date': '2026-03-15T10:30:00.000',
      });
      expect(txn.amount, 42.5);
    });

    test('fromJson 缺省字段的兜底值', () {
      final before = DateTime.now();
      final txn = Txn.fromJson(<String, dynamic>{'id': 'x', 'amount': 7});
      final after = DateTime.now();

      expect(txn.categoryId, Category.otherExpenseId);
      expect(txn.note, '');
      expect(txn.isIncome, isFalse);
      expect(txn.source, EntrySource.manual);
      expect(txn.merchant, isNull);
      // date 缺失时取当前时间，createdAt 跟随 date。
      expect(txn.date.isBefore(before), isFalse);
      expect(txn.date.isAfter(after), isFalse);
      expect(txn.createdAt, txn.date);
    });

    test('fromJson 未知 source 回退 manual', () {
      final txn = Txn.fromJson(<String, dynamic>{
        'id': 'x',
        'amount': 1,
        'source': 'nfc',
      });
      expect(txn.source, EntrySource.manual);
    });

    test('金额为整数的 JSON 转成 double', () {
      final txn = Txn.fromJson(<String, dynamic>{'id': 'x', 'amount': 500});
      expect(txn.amount, 500.0);
      expect(txn.amount, isA<double>());
    });
  });

  group('Txn.copyWith', () {
    test('只覆盖传入字段，其余保留', () {
      final original = buildTxn();
      final updated =
          original.copyWith(amount: 100, note: '晚餐', isIncome: true);

      expect(updated.amount, 100);
      expect(updated.note, '晚餐');
      expect(updated.isIncome, isTrue);
      expect(updated.id, original.id);
      expect(updated.categoryId, original.categoryId);
      expect(updated.date, original.date);
      expect(updated.source, original.source);
      expect(updated.merchant, original.merchant);
      expect(updated.createdAt, original.createdAt);
    });

    test('可以用空字符串清空备注', () {
      final updated = buildTxn(note: '有备注').copyWith(note: '');
      expect(updated.note, '');
    });

    test('不传参数返回内容相等的副本', () {
      final original = buildTxn();
      final copy = original.copyWith();
      expect(copy, original);
      expect(identical(copy, original), isFalse);
    });
  });

  group('Txn 相等性', () {
    test('字段相同即相等（不含 createdAt）', () {
      final a = buildTxn(createdAt: DateTime(2026, 3, 15, 12));
      final b = buildTxn(createdAt: DateTime(2026, 3, 16, 9));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('金额或备注不同则不相等', () {
      final a = buildTxn();
      expect(a == a.copyWith(amount: 1), isFalse);
      expect(a == a.copyWith(note: '别的'), isFalse);
      expect(a == a.copyWith(source: EntrySource.voice), isFalse);
    });
  });

  group('Txn.category', () {
    test('按 categoryId 返回内置分类', () {
      expect(buildTxn(categoryId: 'food').category.name, '餐饮');
      expect(
          buildTxn(categoryId: 'salary', isIncome: true).category.name, '工资');
      expect(buildTxn(categoryId: 'salary').category.isIncome, isTrue);
    });

    test('未知分类 id 回退到「其他支出」', () {
      final txn = Txn.fromJson(
          <String, dynamic>{'id': 'x', 'amount': 1, 'categoryId': 'ghost'});
      expect(txn.category.id, Category.otherExpenseId);
      expect(txn.category.name, '其他');
    });
  });

  group('Category', () {
    test('内置分类数量与收支属性', () {
      expect(Category.expenses, hasLength(10));
      expect(Category.incomes, hasLength(6));
      expect(Category.all, hasLength(16));
      expect(Category.expenses.every((c) => !c.isIncome), isTrue);
      expect(Category.incomes.every((c) => c.isIncome), isTrue);
    });

    test('byId 命中已知 id，未知 / null 回退其他支出', () {
      expect(Category.byId('food').name, '餐饮');
      expect(Category.byId('salary').isIncome, isTrue);
      expect(Category.byId('nope').id, Category.otherExpenseId);
      expect(Category.byId(null).id, Category.otherExpenseId);
    });

    test('forType 按收支类型返回分类列表', () {
      expect(Category.forType(false), same(Category.expenses));
      expect(Category.forType(true), same(Category.incomes));
      expect(Category.forType(true).every((c) => c.isIncome), isTrue);
    });

    test('分类 id 全局唯一且稳定常量在列表中', () {
      final ids = Category.all.map((c) => c.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, contains(Category.otherExpenseId));
      expect(ids, contains(Category.otherIncomeId));
    });
  });
}
