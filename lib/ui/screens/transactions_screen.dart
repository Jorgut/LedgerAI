import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_snack.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/month_switcher.dart';
import '../widgets/common/transaction_tile.dart';
import '../../l10n/app_localizations.dart';
import 'add_transaction_screen.dart';

/// 账单页：月份切换、搜索、类型/分类筛选、按日分组、左滑删除（可撤销）、点击编辑。
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool? _typeFilter;
  String? _categoryFilter;

  bool get _hasFilters => _typeFilter != null || _categoryFilter != null;

  int get _filterCount =>
      (_typeFilter != null ? 1 : 0) + (_categoryFilter != null ? 1 : 0);

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    final next = addMonths(_month, delta);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    if (delta > 0 && next.isAfter(currentMonth)) return;
    setState(() => _month = next);
  }

  void _clearFilters() {
    setState(() {
      _typeFilter = null;
      _categoryFilter = null;
    });
  }

  void _clearAll() {
    _searchController.clear();
    setState(() {
      _typeFilter = null;
      _categoryFilter = null;
    });
  }

  List<Txn> _visibleTransactions(AppState app) {
    final keyword = _searchController.text.trim();
    var items = keyword.isEmpty
        ? app.transactionsOf(_month)
        : app.repo.search(keyword, month: _month);
    if (_typeFilter != null) {
      items = items
          .where((txn) => txn.isIncome == _typeFilter)
          .toList(growable: false);
    }
    if (_categoryFilter != null) {
      items = items
          .where((txn) => txn.categoryId == _categoryFilter)
          .toList(growable: false);
    }
    return items;
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => const AddTransactionScreen(),
      ),
    );
  }

  Future<void> _openEdit(Txn txn) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => AddTransactionScreen(transaction: txn),
      ),
    );
  }

  Future<void> _deleteTransaction(Txn txn) async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final haptics = app.prefs.hapticsEnabled;
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await app.deleteTransaction(txn.id);
    } catch (_) {
      if (!mounted) return;
      AppSnack.error(context, l10n.txDeleteFailed);
      // Dismissible 已经把行移出树，恢复数据后重建列表。
      setState(() {});
      return;
    }

    // 删除已经成功：触觉/撤销提示的异常不能被误报为「删除失败」。
    if (!mounted) return;
    if (haptics) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {
        // 触觉反馈失败不影响已删除的数据。
      }
    }
    if (!mounted) return;
    AppSnack.undo(
      context,
      message: l10n.txDeleted(txn.category.name, formatMoney(txn.amount)),
      onUndo: () async {
        try {
          await app.saveTransaction(txn);
          if (!mounted) return;
          messenger?.showSnackBar(
            SnackBar(content: Text(l10n.txRestored)),
          );
        } catch (_) {
          if (!mounted) return;
          AppSnack.error(context, l10n.txRestoreFailed);
        }
      },
    );
  }

  Future<void> _openFilters() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            void apply(VoidCallback change) {
              setState(change);
              setSheetState(() {});
            }

            void selectType(bool? value) {
              apply(() {
                _typeFilter = value;
                if (value != null && _categoryFilter != null) {
                  final category = Category.byId(_categoryFilter);
                  if (category.isIncome != value) _categoryFilter = null;
                }
              });
            }

            Widget categoryChips(List<Category> categories) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categories)
                    ChoiceChip(
                      label: Text(category.name),
                      selected: _categoryFilter == category.id,
                      onSelected: (_) => apply(() {
                        _categoryFilter =
                            _categoryFilter == category.id ? null : category.id;
                      }),
                    ),
                ],
              );
            }

            return SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(l10n.txFilter, style: theme.textTheme.titleLarge),
                          ),
                          TextButton(
                            onPressed: () => apply(() {
                              _typeFilter = null;
                              _categoryFilter = null;
                            }),
                            child: Text(l10n.txReset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.txType, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.txAll),
                            selected: _typeFilter == null,
                            onSelected: (_) => selectType(null),
                          ),
                          ChoiceChip(
                            label: Text(l10n.expense),
                            selected: _typeFilter == false,
                            onSelected: (_) => selectType(false),
                          ),
                          ChoiceChip(
                            label: Text(l10n.income),
                            selected: _typeFilter == true,
                            onSelected: (_) => selectType(true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child:
                                Text(l10n.txCategory, style: theme.textTheme.titleSmall),
                          ),
                          ChoiceChip(
                            label: Text(l10n.txAllCategories),
                            selected: _categoryFilter == null,
                            onSelected: (_) =>
                                apply(() => _categoryFilter = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_typeFilter == null) ...[
                        Text(
                          l10n.txExpenseCategories,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        categoryChips(Category.expenses),
                        const SizedBox(height: 16),
                        Text(
                          l10n.txIncomeCategories,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        categoryChips(Category.incomes),
                      ] else if (_typeFilter == true)
                        categoryChips(Category.incomes)
                      else
                        categoryChips(Category.expenses),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(l10n.txDone),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final canNext = _month.isBefore(DateTime(now.year, now.month, 1));
    final items = _visibleTransactions(app);
    final monthItems = app.transactionsOf(_month);
    final filtering = _isSearching || _hasFilters;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txTitle),
        actions: [
          IconButton(
            tooltip: l10n.txFilter,
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _filterCount > 0,
              label: Text('$_filterCount'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              children: [
                MonthSwitcher(
                  year: _month.year,
                  month: _month.month,
                  onPrevious: () => _changeMonth(-1),
                  onNext: () => _changeMonth(1),
                  canNext: canNext,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.txSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _isSearching
                          ? IconButton(
                              tooltip: l10n.txClearSearch,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ),
                ),
                if (_hasFilters)
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          if (_typeFilter != null)
                            InputChip(
                              label: Text(_typeFilter! ? l10n.income : l10n.expense),
                              deleteButtonTooltipMessage: l10n.txRemoveTypeFilter,
                              onDeleted: () =>
                                  setState(() => _typeFilter = null),
                            ),
                          if (_typeFilter != null && _categoryFilter != null)
                            const SizedBox(width: 8),
                          if (_categoryFilter != null)
                            InputChip(
                              label: Text(
                                Category.byId(_categoryFilter).name,
                              ),
                              deleteButtonTooltipMessage: l10n.txRemoveCategoryFilter,
                              onDeleted: () =>
                                  setState(() => _categoryFilter = null),
                            ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: _clearFilters,
                            child: Text(l10n.txClearFilters),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildList(
              context,
              items: items,
              monthItems: monthItems,
              filtering: filtering,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context, {
    required List<Txn> items,
    required List<Txn> monthItems,
    required bool filtering,
  }) {
    final l10n = AppLocalizations.of(context);
    if (monthItems.isEmpty && !filtering) {
      return Center(
        child: SingleChildScrollView(
          child: EmptyState(
            icon: Icons.receipt_long_rounded,
            title: l10n.txMonthEmpty(_month.month),
            message: l10n.txMonthEmptyHint,
            actionLabel: l10n.txAddOne,
            actionIcon: Icons.add_rounded,
            onAction: _openAdd,
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.txNoMatch,
            message: l10n.txNoMatchHint,
            actionLabel: l10n.txClearFilters,
            actionIcon: Icons.filter_alt_off_rounded,
            onAction: _clearAll,
          ),
        ),
      );
    }

    final groups = _groupByDay(items);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        for (final group in groups) ...[
          _DayHeader(group: group),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 72),
                  _buildDismissible(context, group.items[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildDismissible(BuildContext context, Txn txn) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey<String>('txn-${txn.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.onError,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context).txDelete,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _deleteTransaction(txn),
      child: TransactionTile(
        txn: txn,
        onTap: () => _openEdit(txn),
      ),
    );
  }

  List<_DayGroup> _groupByDay(List<Txn> items) {
    final grouped = <DateTime, List<Txn>>{};
    for (final txn in items) {
      final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
      grouped.putIfAbsent(day, () => <Txn>[]).add(txn);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in days) _DayGroup(day: day, items: grouped[day]!),
    ];
  }
}

class _DayGroup {
  const _DayGroup({required this.day, required this.items});

  final DateTime day;
  final List<Txn> items;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group});

  final _DayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = group.items
        .where((txn) => !txn.isIncome)
        .fold<double>(0, (sum, txn) => sum + txn.amount);
    final income = group.items
        .where((txn) => txn.isIncome)
        .fold<double>(0, (sum, txn) => sum + txn.amount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 2,
              children: [
                Text(
                  formatDateLabel(group.day, locale: Localizations.localeOf(context)),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  formatWeekday(group.day, locale: Localizations.localeOf(context)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (expense > 0)
            Text(
              AppLocalizations.of(context).txExpenseFooter(formatMoney(expense)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else if (income > 0)
            Text(
              AppLocalizations.of(context).txIncomeFooter(formatMoney(income)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
