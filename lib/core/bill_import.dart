import 'dart:convert';

import '../ai/parsing.dart';
import 'models.dart';

/// 解析微信/支付宝导出的账单 CSV，转换为 [Txn]。
///
/// 只做本机解析：不联网、不上传。支持微信账单与支付宝账单的常见列名，
/// 自动跳过「不计收支」、失败/关闭交易；无法识别的行计入 [BillImportResult.skipped]。
class BillCsvImporter {
  const BillCsvImporter();

  static const List<String> _timeKeys = [
    '交易时间',
    '交易创建时间',
    '创建时间',
    '时间',
    '交易日期',
  ];
  static const List<String> _merchantKeys = [
    '交易对方',
    '交易对方名称',
    '商户名称',
    '商户',
    '对方',
  ];
  static const List<String> _productKeys = [
    '商品',
    '商品说明',
    '商品名称',
    '交易内容',
    '备注',
  ];
  static const List<String> _directionKeys = [
    '收/支',
    '收支',
    '资金流向',
    '收支类型',
  ];
  static const List<String> _amountKeys = ['金额', '金额(元)', '金额（元）', '交易金额'];
  static const List<String> _statusKeys = ['当前状态', '交易状态', '状态'];

  BillImportResult parse(String content, {String fileName = ''}) {
    final warnings = <String>[];
    var text = content;
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    final lines = text
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return BillImportResult(
        transactions: const [],
        skipped: 0,
        warnings: const ['文件是空的'],
        source: fileName,
      );
    }

    // 微信/支付宝的导出文件前面常带几行说明，找到真正的表头行。
    var headerIndex = -1;
    for (var i = 0; i < lines.length && i < 30; i++) {
      final cells = _parseLine(lines[i]);
      if (_findIndex(cells, _timeKeys) >= 0 &&
          _findIndex(cells, _amountKeys) >= 0) {
        headerIndex = i;
        break;
      }
    }
    if (headerIndex < 0) {
      return BillImportResult(
        transactions: const [],
        skipped: lines.length,
        warnings: const ['没有找到账单表头（需要包含「交易时间」和「金额」列）'],
        source: fileName,
      );
    }

    final headers = _parseLine(lines[headerIndex]);
    final timeIndex = _findIndex(headers, _timeKeys);
    final merchantIndex = _findIndex(headers, _merchantKeys);
    final productIndex = _findIndex(headers, _productKeys);
    final directionIndex = _findIndex(headers, _directionKeys);
    final amountIndex = _findIndex(headers, _amountKeys);
    final statusIndex = _findIndex(headers, _statusKeys);

    final transactions = <Txn>[];
    var skipped = 0;
    final seen = <String>{};

    for (var i = headerIndex + 1; i < lines.length; i++) {
      final cells = _parseLine(lines[i]);
      if (cells.every((cell) => cell.trim().isEmpty)) continue;
      final rawAmount = _cell(cells, amountIndex);
      final amount = _parseAmount(rawAmount);
      final date = _parseDate(_cell(cells, timeIndex));
      if (amount == null || amount <= 0 || date == null) {
        skipped++;
        if (warnings.length < 8) warnings.add('第 ${i + 1} 行缺少金额或时间，已跳过');
        continue;
      }

      final status = _cell(cells, statusIndex);
      if (_isFailedOrClosed(status)) {
        skipped++;
        continue;
      }

      final direction = _cell(cells, directionIndex);
      final isIncome = _isIncome(direction);
      if (!isIncome && !_isExpense(direction)) {
        // 不计收支 / 中性交易 / 空方向：跳过，避免污染账本。
        skipped++;
        continue;
      }

      final merchant = _cell(cells, merchantIndex).trim();
      final product = _cell(cells, productIndex).trim();
      final note = _buildNote(product: product, merchant: merchant);
      final textForCategory = '$merchant $product $note';
      final categoryId = const TextCategorizer().categorize(
            textForCategory,
            isIncome: isIncome,
          ) ??
          (isIncome ? Category.otherIncomeId : Category.otherExpenseId);

      final fingerprint =
          '${date.toIso8601String()}|${amount.toStringAsFixed(2)}|$isIncome|$merchant|$note';
      if (!seen.add(fingerprint)) {
        skipped++;
        continue;
      }

      transactions.add(
        Txn(
          id: _stableId(fingerprint),
          amount: amount,
          categoryId: categoryId,
          date: date,
          note: note,
          isIncome: isIncome,
          source: EntrySource.csv,
          merchant: merchant.isEmpty ? null : merchant,
        ),
      );
    }

    if (transactions.isEmpty) {
      warnings.add('没有可导入的收支记录（微信/支付宝的「不计收支」会被跳过）');
    }
    return BillImportResult(
      transactions: transactions,
      skipped: skipped,
      warnings: warnings,
      source: fileName,
    );
  }

  static String _cell(List<String> cells, int index) =>
      index >= 0 && index < cells.length ? cells[index].trim() : '';

  static int _findIndex(List<String> headers, List<String> candidates) {
    for (var i = 0; i < headers.length; i++) {
      final h = _normalizeHeader(headers[i]);
      for (final candidate in candidates) {
        if (h == _normalizeHeader(candidate) ||
            h.contains(_normalizeHeader(candidate))) {
          return i;
        }
      }
    }
    return -1;
  }

  static String _normalizeHeader(String value) =>
      value.replaceAll(RegExp(r'\s+'), '').replaceAll('"', '').trim();

  static bool _isIncome(String value) {
    final v = value.replaceAll(RegExp(r'\s+'), '');
    return v == '收入' || v == '收' || v == '转入' || v == '收款' || v == '退款';
  }

  static bool _isExpense(String value) {
    final v = value.replaceAll(RegExp(r'\s+'), '');
    return v == '支出' || v == '支' || v == '转出' || v == '付款';
  }

  static bool _isFailedOrClosed(String status) {
    final s = status.replaceAll(RegExp(r'\s+'), '');
    if (s.isEmpty) return false;
    const skipped = [
      '交易关闭',
      '已关闭',
      '支付失败',
      '交易失败',
      '已撤销',
      '已退款',
      '全额退款',
      '退款成功',
    ];
    return skipped.any(s.contains);
  }

  static String _buildNote(
      {required String product, required String merchant}) {
    if (product.isEmpty && merchant.isEmpty) return '导入账单';
    if (product.isEmpty) return merchant;
    if (merchant.isEmpty || product.contains(merchant)) return product;
    return product;
  }

  static double? _parseAmount(String raw) {
    if (raw.isEmpty) return null;
    final cleaned = raw
        .replaceAll(RegExp(r'[¥￥,\s]'), '')
        .replaceAll('元', '')
        .replaceAll('"', '');
    return double.tryParse(cleaned)?.abs();
  }

  static DateTime? _parseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final normalized = value
        .replaceAll('年', '-')
        .replaceAll('月', '-')
        .replaceAll('日', ' ')
        .replaceAll('/', '-')
        .replaceAll('.', '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed;
    final match = RegExp(
      r'(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?',
    ).firstMatch(normalized);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.tryParse(match.group(4) ?? '') ?? 0,
      int.tryParse(match.group(5) ?? '') ?? 0,
      int.tryParse(match.group(6) ?? '') ?? 0,
    );
  }

  /// 简单 CSV 解析：支持双引号包裹、字段内逗号、双引号转义。
  static List<String> _parseLine(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    cells.add(buffer.toString());
    return cells;
  }

  static String _stableId(String fingerprint) {
    // 用内容哈希生成稳定 id，重复导入同一文件时不会产生重复记录。
    var hash = 2166136261;
    for (final code in utf8.encode(fingerprint)) {
      hash ^= code;
      hash = (hash * 16777619) & 0xFFFFFFFF;
    }
    return 'csv_${hash.toRadixString(16)}';
  }
}

class BillImportResult {
  const BillImportResult({
    required this.transactions,
    required this.skipped,
    required this.warnings,
    required this.source,
  });

  final List<Txn> transactions;
  final int skipped;
  final List<String> warnings;
  final String source;

  bool get isEmpty => transactions.isEmpty;
}
