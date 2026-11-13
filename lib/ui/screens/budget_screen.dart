import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/charts/budget_progress_bar.dart';
import '../widgets/common/amount_text.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/category_localization.dart';
import '../widgets/common/app_snack.dart';
import '../widgets/common/empty_state.dart';

/// 预算页：设置月度总预算与分类预算，展示每项进度与超支提醒。
///
/// 预算只保存在本机设置里，用于提醒，不会限制消费。
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    AppSnack.show(context, message);
  }

  void _haptic() {
    if (AppScope.read(context).prefs.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _editTotalBudget() async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final current = app.prefs.monthlyBudget;
    final result = await _showAmountSheet(
      title: current == null
          ? l10n.budgetTotalDialogTitle
          : l10n.budgetTotalDialogTitleEdit,
      subtitle: l10n.budgetTotalDialogSubtitle,
      current: current,
      allowClear: current != null,
    );
    if (result == null) return;
    setState(() => _busy = true);
    try {
      await app.updateSettingsWith(
        (settings) => result.clear
            ? settings.copyWith(clearMonthlyBudget: true)
            : settings.copyWith(monthlyBudget: result.value),
      );
      if (!mounted) return;
      _haptic();
      _snack(result.clear ? l10n.budgetTotalCleared : l10n.budgetTotalUpdated);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editCategoryBudget(Category category) async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final current = app.prefs.categoryBudgets[category.id];
    final result = await _showAmountSheet(
      title: l10n.budgetCategoryDialogTitle(localizedCategoryName(context, category)),
      subtitle: l10n.budgetCategoryDialogSubtitle,
      current: current,
      allowClear: current != null,
    );
    if (result == null) return;
    setState(() => _busy = true);
    try {
      await app.updateSettingsWith((settings) {
        final budgets = Map<String, double>.from(settings.categoryBudgets);
        if (result.clear) {
          budgets.remove(category.id);
        } else {
          budgets[category.id] = result.value!;
        }
        return settings.copyWith(categoryBudgets: budgets);
      });
      if (!mounted) return;
      _haptic();
      _snack(
        result.clear
            ? l10n.budgetCategoryCleared(localizedCategoryName(context, category))
            : l10n.budgetCategoryUpdated(localizedCategoryName(context, category)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmClearTotal() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.budgetClearConfirmTitle),
        content: Text(l10n.budgetClearConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.budgetClearDialogAction),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _clearTotalBudget() async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    if (!await _confirmClearTotal()) return;
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await app.updateSettingsWith(
        (settings) => settings.copyWith(clearMonthlyBudget: true),
      );
      if (!mounted) return;
      _haptic();
      _snack(l10n.budgetTotalCleared);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<_AmountResult?> _showAmountSheet({
    required String title,
    required String subtitle,
    required double? current,
    required bool allowClear,
  }) {
    return showModalBottomSheet<_AmountResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => _AmountSheet(
        title: title,
        subtitle: subtitle,
        current: current,
        allowClear: allowClear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final prefs = app.prefs;
    final now = DateTime.now();
    final summary = app.stats.summary(now.year, now.month);
    final totalBudget = prefs.monthlyBudget;
    final categoryBudgets = prefs.categoryBudgets;

    final categorySpent = <String, double>{};
    for (final txn in app.transactionsOf(now)) {
      if (txn.isIncome) continue;
      categorySpent.update(
        txn.categoryId,
        (value) => value + txn.amount,
        ifAbsent: () => txn.amount,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetScreenTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pageInsets,
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            if (totalBudget == null || totalBudget <= 0)
              AppCard(
                padding: EdgeInsets.zero,
                child: EmptyState(
                  icon: Icons.savings_outlined,
                  title: l10n.noMonthlyBudget,
                  message: l10n.budgetEmptyMessage,
                  actionLabel: l10n.budgetSetAction,
                  actionIcon: Icons.edit_rounded,
                  onAction: _editTotalBudget,
                ),
              )
            else
              _TotalBudgetCard(
                budget: totalBudget,
                spent: summary.expense,
                count: summary.count,
                monthLabel: formatMonthLabel(now.year, now.month,
                    locale: Localizations.localeOf(context)),
                onEdit: _editTotalBudget,
                onClear: _clearTotalBudget,
              ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.budgetCategorySection,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            l10n.budgetTapCategoryHint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final category in Category.expenses)
                    _CategoryBudgetRow(
                      category: category,
                      spent: categorySpent[category.id] ?? 0,
                      budget: categoryBudgets[category.id],
                      onTap: () => _editCategoryBudget(category),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.budgetLocalNote,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 已设置总预算时的概览卡片。
class _TotalBudgetCard extends StatelessWidget {
  const _TotalBudgetCard({
    required this.budget,
    required this.spent,
    required this.count,
    required this.monthLabel,
    required this.onEdit,
    required this.onClear,
  });

  final double budget;
  final double spent;
  final int count;
  final String monthLabel;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.budgetTotalLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                monthLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(
              budget,
              style: theme.textTheme.headlineSmall,
              semanticLabel: l10n.budgetTotalSemantic(
                budget.toStringAsFixed(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          BudgetProgressBar(
            spent: spent,
            budget: budget,
            height: 12,
            showLabels: false,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.budgetSpentSummary(formatMoney(spent), count),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l10n.budgetEditAction),
              ),
              TextButton.icon(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.budgetClearAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 单个分类预算行：图标、名称、金额、进度与超支状态。
class _CategoryBudgetRow extends StatelessWidget {
  const _CategoryBudgetRow({
    required this.category,
    required this.spent,
    required this.budget,
    required this.onTap,
  });

  final Category category;
  final double spent;
  final double? budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasBudget = budget != null && budget! > 0;
    final effectiveBudget = hasBudget ? budget! : 0.0;
    final isOver = hasBudget && spent > effectiveBudget;
    final percent = hasBudget
        ? ((spent / effectiveBudget) * 100).clamp(0, 999).toStringAsFixed(0)
        : '';

    final semanticsLabel = hasBudget
        ? (isOver
            ? l10n.budgetCategorySemanticOver(
                localizedCategoryName(context, category),
                spent.toStringAsFixed(2),
                effectiveBudget.toStringAsFixed(2),
                (spent - effectiveBudget).toStringAsFixed(2),
              )
            : l10n.budgetCategorySemantic(
                localizedCategoryName(context, category),
                spent.toStringAsFixed(2),
                effectiveBudget.toStringAsFixed(2),
              ))
        : l10n.budgetCategorySemanticNone(localizedCategoryName(context, category));

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.categoryColorOf(context, category)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon,
                    size: 22,
                    color: AppTheme.categoryColorOf(context, category)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizedCategoryName(context, category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isOver) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.budgetOverBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (hasBudget)
                      BudgetProgressBar(
                        spent: spent,
                        budget: effectiveBudget,
                        height: 8,
                        showLabels: false,
                        showStatus: false,
                      )
                    else
                      Text(
                        l10n.budgetSetCategoryHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      hasBudget
                          ? (isOver
                              ? l10n.budgetRowDetailOver(
                                  formatMoney(effectiveBudget),
                                  formatMoney(spent),
                                  percent,
                                  formatMoney(spent - effectiveBudget),
                                )
                              : l10n.budgetRowDetail(
                                  formatMoney(effectiveBudget),
                                  formatMoney(spent),
                                  percent,
                                ))
                          : l10n.budgetRowNone(formatMoney(spent)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOver
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 金额输入弹窗的返回值：设置金额或清除。
class _AmountResult {
  const _AmountResult.value(double this.value) : clear = false;
  const _AmountResult.clear()
      : value = null,
        clear = true;

  final double? value;
  final bool clear;
}

/// 输入预算金额的底部弹窗。
class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.allowClear,
  });

  final String title;
  final String subtitle;
  final double? current;
  final bool allowClear;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatInitial(widget.current));
  }

  static String _formatInitial(double? value) {
    if (value == null) return '';
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = parseAmount(_controller.text);
    if (amount == null || amount <= 0) {
      setState(
        () => _error = AppLocalizations.of(context).budgetAmountError,
      );
      return;
    }
    Navigator.of(context).pop(_AmountResult.value(amount));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: theme.textTheme.headlineSmall,
            decoration: InputDecoration(
              labelText: l10n.budgetAmountLabel,
              prefixText: '¥ ',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
          if (widget.allowClear) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(const _AmountResult.clear()),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: theme.colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(l10n.budgetDeleteAction),
            ),
          ],
        ],
      ),
    );
  }
}
