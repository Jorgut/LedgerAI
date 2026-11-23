import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/split_models.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/common/app_snack.dart';

class AddSplitExpenseScreen extends StatefulWidget {
  const AddSplitExpenseScreen({
    super.key,
    required this.groupId,
    this.expense,
  });

  final String groupId;
  final SplitExpense? expense;

  @override
  State<AddSplitExpenseScreen> createState() => _AddSplitExpenseScreenState();
}

class _AddSplitExpenseScreenState extends State<AddSplitExpenseScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _uuid = const Uuid();
  final _shareControllers = <String, TextEditingController>{};
  final Set<String> _selected = {};
  String? _payerId;
  bool _custom = false;
  bool _saving = false;
  bool _initialized = false;

  bool get _editing => widget.expense != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final app = AppScope.read(context);
    final people = app.split.participantsOf(widget.groupId);
    final expense = widget.expense;
    final factor = expense == null
        ? 1
        : splitMinorFactor(expense.currency);
    if (expense != null) {
      _amount.text = _formatMinorInput(expense.amountMinor, factor);
      _note.text = expense.note;
      _payerId = expense.payerId;
      _selected.addAll(expense.shares.keys
          .where((id) => people.any((p) => p.id == id)));
      _custom = !_looksEqual(expense, people);
    } else {
      _selected.addAll(people.map((p) => p.id));
      _payerId = people.isNotEmpty ? people.first.id : null;
    }
    if (_payerId == null && people.isNotEmpty) _payerId = people.first.id;
    for (final person in people) {
      final minor = expense?.shares[person.id] ??
          (expense == null || expense.amountMinor == 0
              ? 0
              : expense.amountMinor ~/ people.length);
      _shareControllers[person.id] = TextEditingController(
        text: _formatMinorInput(minor, factor),
      );
    }
    _syncShareControllers();
  }

  bool _looksEqual(SplitExpense expense, List<SplitParticipant> people) {
    if (people.isEmpty) return true;
    final base = expense.amountMinor ~/ people.length;
    final remainder = expense.amountMinor - base * people.length;
    for (var i = 0; i < people.length; i++) {
      final expected = base + (i < remainder ? 1 : 0);
      if (expense.shares[people[i].id] != expected) return false;
    }
    return true;
  }

  static String _formatMinorInput(int minor, int factor) {
    final value = minor / factor;
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncShareControllers() {
    final group = AppScope.read(context).split.groupById(widget.groupId);
    if (group == null) return;
    final factor = splitMinorFactor(group.baseCurrency);
    final amount = parseAmount(_amount.text);
    final amountMinor =
        amount == null ? 0 : (amount * factor).round();
    if (_selected.isEmpty || amountMinor <= 0) return;
    final equal = SplitExpense.equalShares(
      participantIds: _selected.toList(),
      amountMinor: amountMinor,
    );
    for (final entry in equal.entries) {
      final controller = _shareControllers[entry.key];
      if (controller != null) {
        controller.text = _formatMinorInput(entry.value, factor);
      }
    }
  }

  Future<void> _delete() async {
    if (!_editing) return;
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.splitDeleteExpense),
        content: Text(l10n.splitDeleteExpenseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.splitDeleteExpense),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await app.split.deleteExpense(widget.expense!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final group = app.split.groupById(widget.groupId);
    if (group == null) return;
    final factor = splitMinorFactor(group.baseCurrency);
    final amount = parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      AppSnack.error(context, l10n.splitInvalidAmount);
      return;
    }
    if (_selected.isEmpty || _payerId == null) {
      AppSnack.error(context, l10n.splitSelectParticipants);
      return;
    }
    final amountMinor = (amount * factor).round();
    Map<String, int> shares;
    if (_custom) {
      shares = {};
      var total = 0;
      for (final id in _selected) {
        final value = parseAmount(_shareControllers[id]?.text ?? '');
        if (value == null || value < 0) {
          AppSnack.error(context, l10n.splitInvalidAmount);
          return;
        }
        final minor = (value * factor).round();
        shares[id] = minor;
        total += minor;
      }
      if (total != amountMinor) {
        AppSnack.error(context, l10n.splitSharesMismatch);
        return;
      }
    } else {
      shares = SplitExpense.equalShares(
        participantIds: _selected.toList(),
        amountMinor: amountMinor,
      );
    }
    final now = DateTime.now();
    final existing = widget.expense;
    final expense = SplitExpense(
      id: existing?.id ?? _uuid.v4(),
      groupId: group.id,
      payerId: _payerId!,
      amountMinor: amountMinor,
      currency: group.baseCurrency,
      fxRate: 1,
      baseAmountMinor: amountMinor,
      baseCurrency: group.baseCurrency,
      shares: shares,
      date: existing?.date ?? now,
      createdBy: existing?.createdBy ?? group.ownerId,
      updatedAt: now,
      note: _note.text.trim(),
    );
    setState(() => _saving = true);
    try {
      await app.split.saveExpense(expense);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.error(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final group = app.split.groupById(widget.groupId);
    if (group == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final people = app.split.participantsOf(widget.groupId);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.splitEditExpense : l10n.splitAddExpense),
        actions: [
          if (_editing)
            IconButton(
              tooltip: l10n.splitDeleteExpense,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.splitDone),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: !_editing,
            style: Theme.of(context).textTheme.headlineMedium,
            onChanged: (_) {
              if (!_custom) _syncShareControllers();
            },
            decoration: InputDecoration(
              labelText: l10n.splitAmount,
              prefixText: '${group.baseCurrency.symbol} ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: l10n.splitNote,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _payerId,
            decoration: InputDecoration(
              labelText: l10n.splitPaidBy,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final person in people)
                DropdownMenuItem(
                  value: person.id,
                  child: Text(person.displayName),
                ),
            ],
            onChanged: (value) => setState(() => _payerId = value),
          ),
          const SizedBox(height: 20),
          Text(l10n.splitParticipants,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final person in people)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(person.displayName),
              value: _selected.contains(person.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(person.id);
                  } else {
                    _selected.remove(person.id);
                  }
                  if (!_custom) _syncShareControllers();
                });
              },
            ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.balance_rounded, size: 18),
                label: Text(l10n.splitEqual),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l10n.splitCustom),
              ),
            ],
            selected: {_custom},
            onSelectionChanged: (selection) {
              setState(() => _custom = selection.first);
              if (!_custom) _syncShareControllers();
            },
          ),
          if (_custom) ...[
            const SizedBox(height: 16),
            for (final person in people)
              if (_selected.contains(person.id))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _shareControllers[person.id],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText:
                          l10n.splitShareFor(person.displayName),
                      prefixText: '${group.baseCurrency.symbol} ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
