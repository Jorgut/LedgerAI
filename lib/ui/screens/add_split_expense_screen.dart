import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/split_models.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/common/app_snack.dart';

class AddSplitExpenseScreen extends StatefulWidget {
  const AddSplitExpenseScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<AddSplitExpenseScreen> createState() => _AddSplitExpenseScreenState();
}

class _AddSplitExpenseScreenState extends State<AddSplitExpenseScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _uuid = const Uuid();
  final Set<String> _selected = {};
  String? _payerId;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selected.isNotEmpty) return;
    final app = AppScope.read(context);
    final people = app.split.participantsOf(widget.groupId);
    _selected.addAll(people.map((p) => p.id));
    _payerId = people.isNotEmpty ? people.first.id : null;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final group = app.split.groupById(widget.groupId);
    if (group == null) return;
    final amount = parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      AppSnack.error(context, l10n.splitInvalidAmount);
      return;
    }
    if (_selected.isEmpty || _payerId == null) {
      AppSnack.error(context, l10n.splitSelectParticipants);
      return;
    }
    final factor = splitMinorFactor(group.baseCurrency);
    final amountMinor = (amount * factor).round();
    final shares = SplitExpense.equalShares(
      participantIds: _selected.toList(),
      amountMinor: amountMinor,
    );
    final now = DateTime.now();
    final expense = SplitExpense(
      id: _uuid.v4(),
      groupId: group.id,
      payerId: _payerId!,
      amountMinor: amountMinor,
      currency: group.baseCurrency,
      fxRate: 1,
      baseAmountMinor: amountMinor,
      baseCurrency: group.baseCurrency,
      shares: shares,
      date: now,
      createdBy: group.ownerId,
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
        title: Text(l10n.splitAddExpense),
        actions: [
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
            autofocus: true,
            style: Theme.of(context).textTheme.headlineMedium,
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
                });
              },
            ),
        ],
      ),
    );
  }
}
