import 'package:flutter/material.dart';

/// 金额格式：¥1,234.56 / -¥42.00（始终两位小数，千分位；负号在 ¥ 前）。
String formatMoney(double amount, {bool withSymbol = true, bool signed = false}) {
  final negative = amount < 0;
  final abs = amount.abs();
  final parts = abs.toStringAsFixed(2).split('.');
  final integer = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(',');
    buffer.write(integer[i]);
  }
  final sign = negative ? '-' : (signed && amount > 0 ? '+' : '');
  final symbol = withSymbol ? '¥' : '';
  return '$sign$symbol$buffer.${parts[1]}';
}

/// 简洁金额（用于图表坐标轴）：1.2万 / 850。
String formatCompactMoney(double amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (abs >= 10000) {
    final value = abs / 10000;
    final text = value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$sign${text.replaceAll(RegExp(r'\.0$'), '')}万';
  }
  if (abs >= 1000) {
    final text = (abs / 1000).toStringAsFixed(1);
    return '$sign${text.replaceAll(RegExp(r'\.0$'), '')}千';
  }
  return '$sign${abs.toStringAsFixed(0)}';
}

/// 日期标签：今天 / 昨天 / M月d日 / yyyy年M月d日。
String formatDateLabel(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = todayDate.difference(target).inDays;
  if (diff == 0) return '今天';
  if (diff == 1) return '昨天';
  if (diff == 2) return '前天';
  if (date.year == today.year) return '${date.month}月${date.day}日';
  return '${date.year}年${date.month}月${date.day}日';
}

/// 月份标签：2026年11月。
String formatMonthLabel(int year, int month) => '$year年$month月';

/// 月份短标签：11月。
String formatMonthShort(int month) => '$month月';

/// 星期标签：周一。
String formatWeekday(DateTime date) {
  const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[date.weekday - 1];
}

/// 两个日期是否同一个月。
bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

/// 当月第一天。
DateTime firstDayOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

/// 当月最后一天。
DateTime lastDayOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

/// 相对月份，例如 addMonths(DateTime(2026,1,15), -1) => 2025-12。
DateTime addMonths(DateTime date, int delta) => DateTime(date.year, date.month + delta, 1);

/// 解析用户输入的金额（支持「42」「42.5」「¥42」「42元」）。
double? parseAmount(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'[¥￥,，\s元块]'), '')
      .replaceAll('。', '.')
      .trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value.abs();
}

/// 主题色。全部页面统一使用这一个品牌绿。
const Color kBrandColor = Color(0xFF10B981);
const Color kBrandDark = Color(0xFF059669);

/// 浅色背景上的正文/链接用深一档的绿，保证对比度（#10B981 仅用于填充与强调）。
const Color kBrandText = Color(0xFF047857);
