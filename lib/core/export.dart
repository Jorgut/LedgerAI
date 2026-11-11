import 'dart:convert';

import 'app_settings.dart';
import 'models.dart';

/// 数据导出：CSV（表格）与完整 JSON 备份。均由本机生成，不上传。
class ExportService {
  const ExportService();

  static const String csvHeader = '日期,类型,分类,金额,商户,备注,来源';

  String buildCsv(List<Txn> transactions) {
    final buffer = StringBuffer()..writeln(csvHeader);
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    for (final txn in sorted) {
      buffer.writeln([
        _csvDate(txn.date),
        txn.isIncome ? '收入' : '支出',
        txn.category.name,
        txn.amount.toStringAsFixed(2),
        txn.merchant ?? '',
        txn.note,
        txn.source.label,
      ].map(_escapeCsv).join(','));
    }
    return buffer.toString();
  }

  /// 完整备份 JSON，包含设置，便于以后做恢复功能与人工核对。
  String buildBackup(List<Txn> transactions, AppSettings settings) {
    final payload = {
      'app': 'ledger_ai',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'transactions': transactions.map((txn) => txn.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// 解析备份文件内容；格式不合法时返回 null。
  static List<Txn>? parseBackupTransactions(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final items = decoded['transactions'];
      if (items is! List) return null;
      final txns = <Txn>[];
      for (final item in items) {
        if (item is Map<String, dynamic>) txns.add(Txn.fromJson(item));
      }
      return txns;
    } catch (_) {
      return null;
    }
  }

  String _csvDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
