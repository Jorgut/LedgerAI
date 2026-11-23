import 'package:flutter/material.dart';

import 'currency.dart';

/// What kind of shared cost a group represents.
enum SplitKind { meal, trip, rent, gift, other }

enum SplitParticipantRole { owner, member }

/// One member of a split group. Participants are stored separately from the
/// group so their names can be edited without rewriting every expense.
@immutable
class SplitParticipant {
  const SplitParticipant({
    required this.id,
    required this.groupId,
    required this.displayName,
    this.role = SplitParticipantRole.member,
    this.icloudUserRecordId,
    required this.joinedAt,
  });

  final String id;
  final String groupId;
  final String displayName;
  final SplitParticipantRole role;
  final String? icloudUserRecordId;
  final DateTime joinedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'displayName': displayName,
        'role': role.name,
        if (icloudUserRecordId != null) 'icloudUserRecordId': icloudUserRecordId,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory SplitParticipant.fromJson(Map<String, dynamic> json) {
    return SplitParticipant(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      displayName: json['displayName'] as String? ?? '',
      role: SplitParticipantRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => SplitParticipantRole.member,
      ),
      icloudUserRecordId: json['icloudUserRecordId'] as String?,
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// A group of people sharing expenses. [baseCurrency] is the reporting
/// currency for the group. The default for a new group is CNY.
@immutable
class SplitGroup {
  const SplitGroup({
    required this.id,
    required this.title,
    required this.kind,
    required this.baseCurrency,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
    this.cloudShareId,
    this.cloudShareUrl,
  });

  final String id;
  final String title;
  final SplitKind kind;
  final AppCurrency baseCurrency;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  final String? cloudShareId;
  final String? cloudShareUrl;

  SplitGroup copyWith({
    String? title,
    SplitKind? kind,
    AppCurrency? baseCurrency,
    DateTime? updatedAt,
    bool? archived,
    String? cloudShareId,
    String? cloudShareUrl,
  }) {
    return SplitGroup(
      id: id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      cloudShareId: cloudShareId ?? this.cloudShareId,
      cloudShareUrl: cloudShareUrl ?? this.cloudShareUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind.name,
        'baseCurrency': baseCurrency.code,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'archived': archived,
        if (cloudShareId != null) 'cloudShareId': cloudShareId,
        if (cloudShareUrl != null) 'cloudShareUrl': cloudShareUrl,
      };

  factory SplitGroup.fromJson(Map<String, dynamic> json) {
    return SplitGroup(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      kind: SplitKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => SplitKind.other,
      ),
      baseCurrency: AppCurrency.parse(json['baseCurrency'] as String?),
      ownerId: json['ownerId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      archived: json['archived'] as bool? ?? false,
      cloudShareId: json['cloudShareId'] as String?,
      cloudShareUrl: json['cloudShareUrl'] as String?,
    );
  }
}

/// A single shared expense. [amountMinor] is in the expense currency's minor
/// unit; [baseAmountMinor] is in [SplitGroup.baseCurrency]'s minor unit and is
/// what settlement uses.
@immutable
class SplitExpense {
  const SplitExpense({
    required this.id,
    required this.groupId,
    required this.payerId,
    required this.amountMinor,
    required this.currency,
    required this.fxRate,
    required this.baseAmountMinor,
    required this.baseCurrency,
    required this.shares,
    required this.date,
    required this.createdBy,
    required this.updatedAt,
    this.categoryId = 'other_expense',
    this.note = '',
  });

  final String id;
  final String groupId;
  final String payerId;
  final int amountMinor;
  final AppCurrency currency;
  final double fxRate;
  final int baseAmountMinor;
  final AppCurrency baseCurrency;

  /// participantId -> share in the expense currency's minor unit.
  /// The sum must equal [amountMinor].
  final Map<String, int> shares;
  final DateTime date;
  final String createdBy;
  final DateTime updatedAt;
  final String categoryId;
  final String note;

  SplitExpense copyWith({
    String? payerId,
    int? amountMinor,
    AppCurrency? currency,
    double? fxRate,
    int? baseAmountMinor,
    Map<String, int>? shares,
    DateTime? date,
    DateTime? updatedAt,
    String? categoryId,
    String? note,
  }) {
    return SplitExpense(
      id: id,
      groupId: groupId,
      payerId: payerId ?? this.payerId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      fxRate: fxRate ?? this.fxRate,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      baseCurrency: baseCurrency,
      shares: shares ?? this.shares,
      date: date ?? this.date,
      createdBy: createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'payerId': payerId,
        'amountMinor': amountMinor,
        'currency': currency.code,
        'fxRate': fxRate,
        'baseAmountMinor': baseAmountMinor,
        'baseCurrency': baseCurrency.code,
        'shares': shares,
        'date': date.toIso8601String(),
        'createdBy': createdBy,
        'updatedAt': updatedAt.toIso8601String(),
        'categoryId': categoryId,
        'note': note,
      };

  factory SplitExpense.fromJson(Map<String, dynamic> json) {
    final rawShares = json['shares'];
    return SplitExpense(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      payerId: json['payerId'] as String,
      amountMinor: (json['amountMinor'] as num).toInt(),
      currency: AppCurrency.parse(json['currency'] as String?),
      fxRate: (json['fxRate'] as num?)?.toDouble() ?? 1,
      baseAmountMinor: (json['baseAmountMinor'] as num).toInt(),
      baseCurrency: AppCurrency.parse(json['baseCurrency'] as String?),
      shares: rawShares is Map
          ? rawShares.map((k, v) => MapEntry('$k', (v as num).toInt()))
          : const {},
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      categoryId: json['categoryId'] as String? ?? 'other_expense',
      note: json['note'] as String? ?? '',
    );
  }

  /// Equal split with integer remainder assigned to the first participants.
  static Map<String, int> equalShares({
    required List<String> participantIds,
    required int amountMinor,
  }) {
    if (participantIds.isEmpty) {
      throw ArgumentError('split requires at least one participant');
    }
    final base = amountMinor ~/ participantIds.length;
    final remainder = amountMinor - base * participantIds.length;
    return {
      for (var i = 0; i < participantIds.length; i++)
        participantIds[i]: base + (i < remainder ? 1 : 0),
    };
  }
}

/// Amounts and net balances in the group base currency's minor unit.
@immutable
class SplitBalance {
  const SplitBalance({
    required this.participantId,
    required this.paidMinor,
    required this.shareMinor,
    required this.netMinor,
  });

  final String participantId;
  final int paidMinor;
  final int shareMinor;
  final int netMinor;
}

@immutable
class SplitTransfer {
  const SplitTransfer({
    required this.fromId,
    required this.toId,
    required this.amountMinor,
  });

  final String fromId;
  final String toId;
  final int amountMinor;
}

@immutable
class SplitSettlement {
  const SplitSettlement({
    required this.balances,
    required this.transfers,
    required this.currency,
    required this.totalMinor,
  });

  final List<SplitBalance> balances;
  final List<SplitTransfer> transfers;
  final AppCurrency currency;
  final int totalMinor;
}

/// Number of minor units in one major unit (100 for CNY/USD, 1 for JPY/KRW).
int splitMinorFactor(AppCurrency currency) => switch (currency) {
      AppCurrency.jpy || AppCurrency.krw || AppCurrency.vnd => 1,
      _ => 100,
    };

/// Formats an integer minor-unit amount in [currency].
String formatSplitMinor(int minor, AppCurrency currency,
    {bool withSymbol = true}) {
  final factor = splitMinorFactor(currency);
  return formatCurrency(minor / factor, currency, withSymbol: withSymbol);
}
