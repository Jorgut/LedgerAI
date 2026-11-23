import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/currency.dart';
import '../../core/split_models.dart';
import '../../l10n/app_localizations.dart';
import '../../split/split_share_service.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_snack.dart';
import 'split_group_screen.dart';

/// Local split-group list. CloudKit sharing is added in the next milestone.
class SplitGroupsScreen extends StatelessWidget {
  const SplitGroupsScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final title = TextEditingController();
    var kind = SplitKind.trip;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(l10n.splitNewGroup,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.splitGroupName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.splitKind,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in SplitKind.values)
                    ChoiceChip(
                      label: Text(_kindLabel(l10n, item)),
                      selected: kind == item,
                      onSelected: (_) => setSheetState(() => kind = item),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: Text(l10n.splitCreate),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
    final name = title.text.trim();
    if (created != true || !context.mounted) return;
    if (name.isEmpty) return;
    final group = await app.split.createGroup(
      title: name,
      kind: kind,
      ownerName: l10n.splitMe,
      baseCurrency: AppCurrency.cny,
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SplitGroupScreen(groupId: group.id)),
    );
  }

  Future<void> _join(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.read(context);
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.splitJoinShared),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: l10n.splitJoinHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.splitJoinShared),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    try {
      final service = const SplitShareService();
      final accepted = await service.acceptShare(url);
      if (!accepted) throw StateError('share not accepted');
      final data = await service.fetchShared();
      await app.split.importShared(data, shareUrl: url);
      if (context.mounted) {
        AppSnack.success(context, l10n.splitJoined);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnack.error(context, l10n.splitJoinFailed);
      }
    }
  }

  static String _kindLabel(AppLocalizations l10n, SplitKind kind) =>
      switch (kind) {
        SplitKind.meal => l10n.splitKindMeal,
        SplitKind.trip => l10n.splitKindTrip,
        SplitKind.rent => l10n.splitKindRent,
        SplitKind.gift => l10n.splitKindGift,
        SplitKind.other => l10n.splitKindOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final groups = app.split.groups;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.splitGroupsTitle),
        actions: [
          IconButton(
            tooltip: l10n.splitJoinShared,
            onPressed: () => _join(context),
            icon: const Icon(Icons.group_add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.splitNewGroup),
      ),
      body: groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_split_rounded,
                        size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(l10n.splitNoGroups,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final group = groups[index];
                final people = app.split.participantsOf(group.id).length;
                final expenses = app.split.expensesOf(group.id);
                final total = expenses.fold<int>(
                    0, (sum, e) => sum + e.baseAmountMinor);
                return AppCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => SplitGroupScreen(groupId: group.id)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.group_rounded,
                          color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    title: Text(group.title),
                    subtitle: Text(
                      '${_kindLabel(l10n, group.kind)} · $people · '
                      '${formatSplitMinor(total, group.baseCurrency)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                );
              },
            ),
    );
  }
}
