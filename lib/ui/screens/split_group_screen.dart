import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/split_models.dart';
import '../../l10n/app_localizations.dart';
import '../../split/split_share_service.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_snack.dart';
import 'add_split_expense_screen.dart';

class SplitGroupScreen extends StatelessWidget {
  const SplitGroupScreen({super.key, required this.groupId});

  final String groupId;

  Future<void> _addParticipant(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.splitAddParticipant),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.splitParticipantName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.splitAdd),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await app.split.addParticipant(groupId: groupId, displayName: name);
  }

  Future<void> _addExpense(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddSplitExpenseScreen(groupId: groupId),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final group = app.split.groupById(groupId);
    if (group == null) return;
    var url = group.cloudShareUrl;
    if (url == null || url.isEmpty) {
      try {
        final result = await const SplitShareService().createShare(
          group: group,
          participants: app.split.participantsOf(groupId),
          expenses: app.split.expensesOf(groupId),
        );
        url = result.url;
        await app.split.markShared(
          groupId: groupId,
          shareRecordName: result.shareRecordName,
          shareUrl: result.url,
        );
      } catch (e) {
        if (!context.mounted) return;
        AppSnack.error(context, l10n.splitShareFailed);
        return;
      }
    }
    if (!context.mounted) return;
    final link = url;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.splitShareTitle),
        content: SelectableText(link),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) AppSnack.success(context, l10n.splitShareCopied);
            },
            child: Text(l10n.splitShareCopy),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.splitDone),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.splitDeleteGroup),
        content: Text(l10n.splitDeleteConfirm),
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
            child: Text(l10n.splitDeleteGroup),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await app.split.deleteGroup(groupId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final group = app.split.groupById(groupId);
    if (group == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final people = app.split.participantsOf(groupId);
    final expenses = app.split.expensesOf(groupId);
    final settlement = app.split.settlementFor(groupId);
    final names = {for (final p in people) p.id: p.displayName};
    return Scaffold(
      appBar: AppBar(
        title: Text(group.title),
        actions: [
          IconButton(
            tooltip: l10n.splitShare,
            onPressed: () => _share(context),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: l10n.splitDeleteGroup,
            onPressed: () => _deleteGroup(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExpense(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.splitAddExpense),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.splitTotal,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          formatSplitMinor(
                              settlement.totalMinor, group.baseCurrency),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      settlement.transfers.isEmpty
                          ? Icons.check_circle_rounded
                          : Icons.swap_horiz_rounded,
                      size: 18,
                    ),
                    label: Text(settlement.transfers.isEmpty
                        ? l10n.splitSettled
                        : l10n.splitSettleTransfers),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: l10n.splitParticipants,
            action: TextButton.icon(
              onPressed: () => _addParticipant(context),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: Text(l10n.splitAdd),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final person in people)
                Chip(
                  avatar: CircleAvatar(
                    radius: 12,
                    child: Text(person.displayName.characters.first),
                  ),
                  label: Text(person.displayName),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: l10n.splitBalances),
          AppCard(
            child: Column(
              children: [
                for (final balance in settlement.balances)
                  ListTile(
                    dense: true,
                    title: Text(names[balance.participantId] ?? ''),
                    trailing: Text(
                      balance.netMinor >= 0
                          ? '+${formatSplitMinor(balance.netMinor, group.baseCurrency)}'
                          : '-${formatSplitMinor(-balance.netMinor, group.baseCurrency)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: balance.netMinor >= 0
                                ? AppTheme.incomeColorOf(context)
                                : AppTheme.expenseColorOf(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                if (settlement.transfers.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        for (final transfer in settlement.transfers)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${names[transfer.fromId] ?? ''} → '
                                    '${names[transfer.toId] ?? ''}',
                                  ),
                                ),
                                Text(
                                  formatSplitMinor(
                                      transfer.amountMinor, group.baseCurrency),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: l10n.splitExpenses,
            action: TextButton.icon(
              onPressed: () => _addExpense(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.splitAdd),
            ),
          ),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.splitNoExpenses)),
            )
          else
            AppCard(
              child: Column(
                children: [
                  for (final expense in expenses)
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddSplitExpenseScreen(
                            groupId: group.id,
                            expense: expense,
                          ),
                        ),
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          names[expense.payerId]?.characters.first ?? '?',
                        ),
                      ),
                      title: Text(expense.note.isEmpty
                          ? l10n.splitExpenses
                          : expense.note),
                      subtitle: Text(
                        '${l10n.splitPaidBy}: ${names[expense.payerId] ?? ''}',
                      ),
                      trailing: Text(
                        formatSplitMinor(
                            expense.baseAmountMinor, expense.baseCurrency),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
