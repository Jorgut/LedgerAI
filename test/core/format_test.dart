// 金额 / 日期格式化单测。
// 被测代码：lib/core/format.dart。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/format.dart';

void main() {
  group('formatMoney', () {
    test('千分位 + 两位小数 + ¥ 前缀', () {
      expect(formatMoney(0), '¥0.00');
      expect(formatMoney(42), '¥42.00');
      expect(formatMoney(1234.56), '¥1,234.56');
      expect(formatMoney(1234567.891), '¥1,234,567.89');
      expect(formatMoney(1000000), '¥1,000,000.00');
    });

    test('负号在 ¥ 之前（-¥42.00，非文档注释里写的 ¥-42.00）', () {
      expect(formatMoney(-42), '-¥42.00');
      expect(formatMoney(-1234.5), '-¥1,234.50');
    });

    test('可关闭货币符号 / 强制正号', () {
      expect(formatMoney(1234.56, withSymbol: false), '1,234.56');
      expect(formatMoney(42, signed: true), '+¥42.00');
      expect(formatMoney(42, withSymbol: false, signed: true), '+42.00');
      expect(formatMoney(-42, signed: true), '-¥42.00');
      expect(formatMoney(0, signed: true), '¥0.00');
    });

    test('四舍五入进位的千分位', () {
      expect(formatMoney(999.999), '¥1,000.00');
      expect(formatMoney(999.4), '¥999.40');
    });
  });

  group('formatCompactMoney', () {
    test('万级', () {
      expect(formatCompactMoney(10000), '1万');
      expect(formatCompactMoney(12000), '1.2万');
      expect(formatCompactMoney(15000), '1.5万');
      expect(formatCompactMoney(123456), '12万');
    });

    test('千级与千以下', () {
      expect(formatCompactMoney(1000), '1千');
      expect(formatCompactMoney(1500), '1.5千');
      expect(formatCompactMoney(850), '850');
      expect(formatCompactMoney(0), '0');
    });

    test('负数保留符号', () {
      expect(formatCompactMoney(-12000), '-1.2万');
      expect(formatCompactMoney(-850), '-850');
    });
  });

  group('formatDateLabel', () {
    final now = DateTime(2026, 11, 12, 15, 30);

    test('今天 / 昨天 / 前天', () {
      expect(formatDateLabel(DateTime(2026, 11, 12, 0, 5), now: now), '今天');
      expect(formatDateLabel(DateTime(2026, 11, 12, 23, 59), now: now), '今天');
      expect(formatDateLabel(DateTime(2026, 11, 11), now: now), '昨天');
      expect(formatDateLabel(DateTime(2026, 11, 10), now: now), '前天');
    });

    test('同年显示 M月d日，跨年带年份', () {
      expect(formatDateLabel(DateTime(2026, 11, 9), now: now), '11月9日');
      expect(formatDateLabel(DateTime(2026, 1, 5), now: now), '1月5日');
      expect(formatDateLabel(DateTime(2025, 12, 31), now: now), '2025年12月31日');
    });

    test('未来日期（倒计时为负）走同年分支', () {
      expect(formatDateLabel(DateTime(2026, 12, 1), now: now), '12月1日');
    });
  });

  group('月份 / 星期 / 期间辅助', () {
    test('月份标签', () {
      expect(formatMonthLabel(2026, 11), '2026年11月');
      expect(formatMonthLabel(2026, 1), '2026年1月');
      expect(formatMonthShort(3), '3月');
      expect(formatMonthShort(12), '12月');
    });

    test('星期标签', () {
      expect(formatWeekday(DateTime(2026, 11, 12)), '周四');
      expect(formatWeekday(DateTime(2026, 11, 15)), '周日');
      expect(formatWeekday(DateTime(2026, 11, 9)), '周一');
    });

    test('isSameMonth', () {
      expect(
          isSameMonth(DateTime(2026, 11, 1), DateTime(2026, 11, 30)), isTrue);
      expect(
          isSameMonth(DateTime(2026, 11, 30), DateTime(2026, 12, 1)), isFalse);
      expect(
          isSameMonth(DateTime(2026, 11, 1), DateTime(2025, 11, 1)), isFalse);
    });

    test('firstDayOfMonth / lastDayOfMonth', () {
      expect(firstDayOfMonth(DateTime(2026, 11, 12, 13, 5)),
          DateTime(2026, 11, 1));
      expect(lastDayOfMonth(DateTime(2026, 11, 12)), DateTime(2026, 11, 30));
      expect(lastDayOfMonth(DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
      expect(lastDayOfMonth(DateTime(2028, 2, 1)), DateTime(2028, 2, 29));
      expect(lastDayOfMonth(DateTime(2026, 12, 1)), DateTime(2026, 12, 31));
    });

    test('addMonths 结果落在目标月 1 号', () {
      expect(addMonths(DateTime(2026, 1, 15), -1), DateTime(2025, 12, 1));
      expect(addMonths(DateTime(2026, 1, 15), 0), DateTime(2026, 1, 1));
      expect(addMonths(DateTime(2026, 12, 10), 1), DateTime(2027, 1, 1));
      expect(addMonths(DateTime(2026, 6, 30), 8), DateTime(2027, 2, 1));
    });
  });

  group('parseAmount', () {
    test('常见金额写法', () {
      expect(parseAmount('42'), 42);
      expect(parseAmount('42.50'), 42.5);
      expect(parseAmount('¥42'), 42);
      expect(parseAmount('￥42.5'), 42.5);
      expect(parseAmount('42元'), 42);
      expect(parseAmount('42块'), 42);
      expect(parseAmount('1,234.56'), 1234.56);
      expect(parseAmount('1，234.56'), 1234.56);
      expect(parseAmount('  12.5 元 '), 12.5);
      expect(parseAmount('12。5'), 12.5);
    });

    test('负数按绝对值返回（UI 用 isIncome 表示方向）', () {
      expect(parseAmount('-42'), 42);
      expect(parseAmount('-42.5'), 42.5);
    });

    test('非法输入返回 null', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('   '), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('¥'), isNull);
      expect(parseAmount('12.5.6'), isNull);
      expect(parseAmount('NaN'), isNull);
      expect(parseAmount('Infinity'), isNull);
    });
  });

  test('品牌色常量', () {
    expect(kBrandColor, const Color(0xFF0B5B47));
    expect(kBrandDark, const Color(0xFF063A2C));
  });
}
