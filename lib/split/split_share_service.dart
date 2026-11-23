import 'package:flutter/services.dart';

import '../core/split_models.dart';

/// Thin Dart wrapper around the native CKShare bridge.
///
/// Only metadata and UUIDs leave the device; the developer has no server.
class SplitShareService {
  const SplitShareService();

  static const MethodChannel _channel =
      MethodChannel('com.archintera.ledgerai/split_share');

  Future<({String url, String shareRecordName})> createShare({
    required SplitGroup group,
    required List<SplitParticipant> participants,
    required List<SplitExpense> expenses,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'createShare',
      {
        'group': {
          'id': group.id,
          'title': group.title,
          'kind': group.kind.name,
          'baseCurrency': group.baseCurrency.code,
          'ownerId': group.ownerId,
          'createdAt': group.createdAt.millisecondsSinceEpoch,
          'updatedAt': group.updatedAt.millisecondsSinceEpoch,
          'archived': group.archived,
        },
        'participants': [
          for (final p in participants)
            {
              'id': p.id,
              'groupId': p.groupId,
              'displayName': p.displayName,
              'role': p.role.name,
              'joinedAt': p.joinedAt.millisecondsSinceEpoch,
            }
        ],
        'expenses': [
          for (final e in expenses)
            {
              'id': e.id,
              'groupId': e.groupId,
              'payerId': e.payerId,
              'amountMinor': e.amountMinor,
              'currency': e.currency.code,
              'fxRate': e.fxRate,
              'baseAmountMinor': e.baseAmountMinor,
              'baseCurrency': e.baseCurrency.code,
              'shares': e.shares,
              'date': e.date.millisecondsSinceEpoch,
              'createdBy': e.createdBy,
              'updatedAt': e.updatedAt.millisecondsSinceEpoch,
              'categoryId': e.categoryId,
              'note': e.note,
            }
        ],
      },
    );
    final url = result?['url'] as String?;
    if (url == null || url.isEmpty) {
      throw PlatformException(code: 'share_url_missing', message: '没有生成邀请链接');
    }
    return (
      url: url,
      shareRecordName: result?['shareRecordName'] as String? ?? '',
    );
  }

  Future<bool> acceptShare(String url) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'acceptShare',
      {'url': url},
    );
    return result?['accepted'] == true;
  }

  Future<Map<String, dynamic>> fetchShared() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('fetchShared');
    return result ?? const {};
  }

}
