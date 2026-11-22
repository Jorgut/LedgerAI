import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'currency.dart';
import 'split_calculator.dart';
import 'split_models.dart';

/// Local-first persistence for split groups, participants and expenses.
///
/// Nothing here touches the network. CloudKit sharing is a later layer and
/// will consume the same models.
class SplitRepository extends ChangeNotifier {
  SplitRepository(this._groupBox, this._participantBox, this._expenseBox);

  final Box<String> _groupBox;
  final Box<String> _participantBox;
  final Box<String> _expenseBox;
  static const Uuid _uuid = Uuid();

  List<SplitGroup>? _groupCache;
  List<SplitParticipant>? _participantCache;
  List<SplitExpense>? _expenseCache;

  List<SplitGroup> get groups {
    final cached = _groupCache;
    if (cached != null) return cached;
    final result = <SplitGroup>[];
    for (final raw in _groupBox.values) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) result.add(SplitGroup.fromJson(map));
      } catch (_) {}
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _groupCache = result;
  }

  List<SplitParticipant> get participants => _participantCache ??= _decodeParticipants();

  List<SplitExpense> get expenses => _expenseCache ??= _decodeExpenses();

  List<SplitParticipant> participantsOf(String groupId) =>
      participants.where((p) => p.groupId == groupId).toList(growable: false);

  List<SplitExpense> expensesOf(String groupId) {
    final result = expenses.where((e) => e.groupId == groupId).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  SplitGroup? groupById(String id) {
    for (final group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  Future<SplitGroup> createGroup({
    required String title,
    required SplitKind kind,
    required String ownerName,
    AppCurrency baseCurrency = AppCurrency.cny,
  }) async {
    final now = DateTime.now();
    final group = SplitGroup(
      id: _uuid.v4(),
      title: title.trim(),
      kind: kind,
      baseCurrency: baseCurrency,
      ownerId: '',
      createdAt: now,
      updatedAt: now,
    );
    final owner = SplitParticipant(
      id: _uuid.v4(),
      groupId: group.id,
      displayName: ownerName.trim().isEmpty ? 'Me' : ownerName.trim(),
      role: SplitParticipantRole.owner,
      joinedAt: now,
    );
    final withOwner = SplitGroup(
      id: group.id,
      title: group.title,
      kind: group.kind,
      baseCurrency: group.baseCurrency,
      ownerId: owner.id,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
    await _groupBox.put(withOwner.id, jsonEncode(withOwner.toJson()));
    await _participantBox.put(owner.id, jsonEncode(owner.toJson()));
    _invalidate();
    notifyListeners();
    return withOwner;
  }

  Future<SplitParticipant> addParticipant({
    required String groupId,
    required String displayName,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('participant name is empty');
    final now = DateTime.now();
    final participant = SplitParticipant(
      id: _uuid.v4(),
      groupId: groupId,
      displayName: name,
      joinedAt: now,
    );
    await _participantBox.put(participant.id, jsonEncode(participant.toJson()));
    _participantCache = null;
    notifyListeners();
    return participant;
  }

  Future<void> saveExpense(SplitExpense expense) async {
    if (expense.shares.isEmpty) {
      throw ArgumentError('expense must have shares');
    }
    final sum = expense.shares.values.fold<int>(0, (a, b) => a + b);
    if (sum != expense.amountMinor) {
      throw ArgumentError('shares do not sum to amount');
    }
    await _expenseBox.put(expense.id, jsonEncode(expense.toJson()));
    _expenseCache = null;
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
    _expenseCache = null;
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    await _groupBox.delete(id);
    for (final p in participantsOf(id)) {
      await _participantBox.delete(p.id);
    }
    for (final e in expensesOf(id)) {
      await _expenseBox.delete(e.id);
    }
    _invalidate();
    notifyListeners();
  }

  SplitSettlement settlementFor(String groupId) {
    final group = groupById(groupId);
    if (group == null) throw StateError('group not found');
    final people = participantsOf(groupId);
    return const SplitCalculator().settle(
      expenses: expensesOf(groupId),
      participantIds: [for (final p in people) p.id],
      currency: group.baseCurrency,
    );
  }

  void _invalidate() {
    _groupCache = null;
    _participantCache = null;
    _expenseCache = null;
  }

  List<SplitParticipant> _decodeParticipants() {
    final result = <SplitParticipant>[];
    for (final raw in _participantBox.values) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) {
          result.add(SplitParticipant.fromJson(map));
        }
      } catch (_) {}
    }
    return result;
  }

  List<SplitExpense> _decodeExpenses() {
    final result = <SplitExpense>[];
    for (final raw in _expenseBox.values) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) result.add(SplitExpense.fromJson(map));
      } catch (_) {}
    }
    return result;
  }
}

/// Splits can be created locally without the Pro entitlement during the beta.
/// The production gate is applied by StoreKit in a later milestone.
bool get splitBetaEnabled => true;
