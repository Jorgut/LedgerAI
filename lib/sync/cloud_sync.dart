import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/models.dart';

/// iCloud 同步失败时的可读错误。
class CloudSyncException implements Exception {
  const CloudSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CloudSyncStatus {
  const CloudSyncStatus({
    required this.available,
    required this.message,
  });

  final bool available;
  final String message;
}

class CloudPullResult {
  const CloudPullResult({
    required this.transactions,
    required this.deletions,
  });

  final List<Txn> transactions;

  /// id -> 删除时间。
  final Map<String, DateTime> deletions;
}

class CloudSyncReport {
  const CloudSyncReport({
    required this.downloaded,
    required this.uploaded,
    required this.deleted,
  });

  final int downloaded;
  final int uploaded;
  final int deleted;
}

/// CloudKit 同步服务：数据只存在用户自己的 iCloud private database，
/// 开发者不接触、不建服务器。
class CloudSyncService {
  const CloudSyncService();

  static const MethodChannel _channel =
      MethodChannel('com.archintera.ledgerai/cloudkit');

  Future<CloudSyncStatus> status() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('status');
      final available = raw?['available'] as bool? ?? false;
      final message = raw?['message'] as String? ?? 'iCloud 不可用';
      return CloudSyncStatus(available: available, message: message);
    } on PlatformException catch (e) {
      throw CloudSyncException(e.message ?? '无法连接 iCloud');
    } on MissingPluginException {
      throw const CloudSyncException('当前系统版本不支持 iCloud 同步');
    }
  }

  Future<CloudPullResult> pull() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('pull');
      final records = raw?['records'] as List<dynamic>? ?? const [];
      final deleted = raw?['deleted'] as List<dynamic>? ?? const [];
      final transactions = <Txn>[];
      for (final item in records) {
        if (item is! Map) continue;
        final map = item.cast<String, dynamic>();
        final txn = _decode(map);
        if (txn != null) transactions.add(txn);
      }
      final deletions = <String, DateTime>{};
      for (final item in deleted) {
        if (item is! Map) continue;
        final map = item.cast<String, dynamic>();
        final id = map['id'] as String?;
        final at = map['deletedAt'] as int?;
        if (id != null && at != null) {
          deletions[id] = DateTime.fromMillisecondsSinceEpoch(at);
        }
      }
      return CloudPullResult(transactions: transactions, deletions: deletions);
    } on PlatformException catch (e) {
      throw CloudSyncException(e.message ?? '拉取 iCloud 数据失败');
    }
  }

  Future<void> push(
    List<Txn> transactions,
    Map<String, DateTime> deletions,
  ) async {
    try {
      await _channel.invokeMethod<void>('push', {
        'records': transactions.map(_encode).toList(),
        'deleted': [
          for (final entry in deletions.entries)
            {
              'id': entry.key,
              'deletedAt': entry.value.millisecondsSinceEpoch,
            },
        ],
      });
    } on PlatformException catch (e) {
      throw CloudSyncException(e.message ?? '上传到 iCloud 失败');
    }
  }

  /// 完整同步：先拉取并合并，再把本地数据推上去。
  Future<CloudSyncReport> sync(AppState app) async {
    final status = await this.status();
    if (!status.available) {
      throw CloudSyncException(status.message);
    }
    final remote = await pull();
    final local = {for (final txn in app.transactions) txn.id: txn};
    final localDeletions = app.repo.deletions;
    final toSave = <Txn>[];
    var deleted = 0;

    // 远端删除优先于更旧的本地记录。
    for (final entry in remote.deletions.entries) {
      final localTxn = local[entry.key];
      if (localTxn == null || !localTxn.updatedAt.isAfter(entry.value)) {
        await app.repo.applyRemoteDeletion(entry.key, entry.value);
        deleted++;
      }
    }

    // 远端记录：本地没有、或远端更新时覆盖；已被本地删除且删除更晚的跳过。
    for (final txn in remote.transactions) {
      final localTxn = local[txn.id];
      final localDeletedAt = localDeletions[txn.id];
      if (localDeletedAt != null && !txn.updatedAt.isAfter(localDeletedAt)) {
        continue;
      }
      if (localTxn == null || txn.updatedAt.isAfter(localTxn.updatedAt)) {
        toSave.add(txn);
      }
    }
    if (toSave.isNotEmpty) {
      await app.repo.saveAll(toSave);
    }

    // 全量推送本地账本 + 墓碑（中小数据量足够；后续可按 updatedAt 增量优化）。
    await push(app.transactions, app.repo.deletions);
    await app.updateSettingsWith(
      (settings) => settings.copyWith(lastSyncAt: DateTime.now()),
    );
    return CloudSyncReport(
      downloaded: toSave.length,
      uploaded: app.transactions.length,
      deleted: deleted,
    );
  }

  static Map<String, dynamic> _encode(Txn txn) => {
        'id': txn.id,
        'amount': txn.amount,
        'categoryId': txn.categoryId,
        'date': txn.date.millisecondsSinceEpoch,
        'note': txn.note,
        'isIncome': txn.isIncome,
        'source': txn.source.name,
        'merchant': txn.merchant,
        'updatedAt': txn.updatedAt.millisecondsSinceEpoch,
        'deletedAt': null,
      };

  static Txn? _decode(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final amount = (map['amount'] as num?)?.toDouble();
    final dateMs = map['date'] as int?;
    if (id == null || amount == null || dateMs == null) return null;
    final updatedMs = map['updatedAt'] as int? ?? dateMs;
    return Txn(
      id: id,
      amount: amount.abs(),
      categoryId: map['categoryId'] as String? ?? Category.otherExpenseId,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      note: map['note'] as String? ?? '',
      isIncome: map['isIncome'] as bool? ?? false,
      source: EntrySource.parse(map['source'] as String?),
      merchant: map['merchant'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dateMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedMs),
    );
  }
}
