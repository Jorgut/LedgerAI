import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/insights.dart';
import '../../core/stats.dart';
import '../theme.dart';
import '../widgets/charts/category_donut.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/common/category_localization.dart';
import '../widgets/charts/chart_placeholder.dart';
import '../widgets/charts/trend_chart.dart';
import '../widgets/common/amount_text.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/month_switcher.dart';
import '../widgets/common/section_header.dart';

/// 报表页：月份切换、收支汇总、近 6 个月趋势、分类占比与列表、智能建议。
///
/// 所有数据都由本机 `StatsService` / `InsightsService` 实时计算。
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.initialScrollOffset = 0});

  /// 仅截图/演示模式使用。
  final double initialScrollOffset;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ScrollController _scrollController =
      ScrollController(initialScrollOffset: widget.initialScrollOffset);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _month = firstDayOfMonth(DateTime.now());
  bool _showIncome = false;

  DateTime get _currentMonth => firstDayOfMonth(DateTime.now());

  bool get _isCurrentMonth =>
      _month.year == _currentMonth.year && _month.month == _currentMonth.month;

  bool get _canGoNext => _month.isBefore(_currentMonth);

  void _shiftMonth(int delta) {
    final next = addMonths(_month, delta);
    if (next.isAfter(_currentMonth)) return;
    setState(() => _month = next);
  }

  void _goToCurrentMonth() {
    setState(() => _month = _currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final summary = app.stats.summary(_month.year, _month.month);
    final trend = app.stats.trend(months: 6, end: _month);
    final slices = app.stats.breakdown(
      _month.year,
      _month.month,
      isIncome: _showIncome,
    );
    final insights = app.insights.forMonth(_month, settings: app.prefs, l10n: l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rptTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: AppTheme.pageInsets,
          children: [
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: MonthSwitcher(
                year: _month.year,
                month: _month.month,
                onPrevious: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
                canNext: _canGoNext,
                trailing: _isCurrentMonth
                    ? null
                    : TextButton(
                        onPressed: _goToCurrentMonth,
                        child: Text(l10n.rptBackMonth),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            _SummaryCard(summary: summary),
            if (summary.isEmpty) ...[
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: EmptyState(
                  compact: true,
                  icon: Icons.receipt_long_rounded,
                  title: l10n.rptEmpty,
                  message: l10n.rptEmptyHint,
                ),
              ),
            ],
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.rptTrend,
                    subtitle: l10n.rptTrendSub,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  TrendChart(points: trend),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.rptShare,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  _TypeToggle(
                    isIncome: _showIncome,
                    onChanged: (value) => setState(() => _showIncome = value),
                  ),
                  const SizedBox(height: 12),
                  _CategoryBreakdown(
                    slices: slices,
                    total: _showIncome ? summary.income : summary.expense,
                    isIncome: _showIncome,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InsightsSection(insights: insights),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 收支汇总卡片。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StatCell(
                  label: l10n.income,
                  amount: summary.income,
                  color: AppTheme.incomeColorOf(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCell(
                  label: l10n.expense,
                  amount: summary.expense,
                  color: AppTheme.expenseColorOf(context),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                l10n.rptBalance,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AmountText(
                    summary.balance,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.end,
                    semanticLabel:
                        l10n.rptBalanceSem(summary.balance.toStringAsFixed(2)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.rptCount(summary.count),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AmountText(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
            semanticLabel:
                AppLocalizations.of(context).rptAmountLabel(
                    label, amount.toStringAsFixed(2)),
          ),
        ),
      ],
    );
  }
}

/// 支出 / 收入 切换。
class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.isIncome, required this.onChanged});

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll<Size>(Size(0, 48)),
      ),
      segments: [
        ButtonSegment<bool>(value: false, label: Text(AppLocalizations.of(context).expense)),
        ButtonSegment<bool>(value: true, label: Text(AppLocalizations.of(context).income)),
      ],
      selected: <bool>{isIncome},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// 环形图 + 分类列表。
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.slices,
    required this.total,
    required this.isIncome,
  });

  final List<CategorySlice> slices;
  final double total;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty || total <= 0) {
      return ChartPlaceholder(
        message: AppLocalizations.of(context).rptEmpty,
        icon: Icons.pie_chart_outline_rounded,
        height: 160,
      );
    }

    final donut = CategoryDonut(
      slices: slices,
      total: total,
      centerLabel: isIncome
          ? AppLocalizations.of(context).rptTotalIncome
          : AppLocalizations.of(context).rptTotalExpense,
    );
    final list = Column(
      children: [
        for (final slice in slices)
          _CategoryRow(slice: slice, maxRatio: _maxRatio),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        final stacked = constraints.maxWidth < 320 || largeText;
        if (stacked) {
          return Column(
            children: [
              Center(child: donut),
              const SizedBox(height: 16),
              list,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            donut,
            const SizedBox(width: 20),
            Expanded(child: list),
          ],
        );
      },
    );
  }

  double get _maxRatio {
    var max = 0.0;
    for (final slice in slices) {
      if (slice.ratio > max) max = slice.ratio;
    }
    return max <= 0 ? 1 : max;
  }
}

/// 单条分类：名称、金额、占比与比例条。
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.slice, required this.maxRatio});

  final CategorySlice slice;
  final double maxRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = slice.category;
    final amount = slice.amount;
    final percent = (slice.ratio * 100).toStringAsFixed(0);

    return Semantics(
      container: true,
      label: AppLocalizations.of(context).rptCategorySem(
          amount.toStringAsFixed(2), int.tryParse(percent) ?? 0, category.name),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.categoryColorOf(context, category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizedCategoryName(context, category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatMoney(amount),
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$percent%',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (slice.ratio / maxRatio).clamp(0.0, 1.0),
                minHeight: 6,
                color: AppTheme.categoryColorOf(context, category),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 智能建议区域。
class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.insights});

  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.rptInsights,
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          trailing: Text(
            l10n.rptLocal,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final insight in insights)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _InsightCard(insight: insight),
          ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
    final Color accent;
    final IconData icon;
    switch (insight.tone) {
      case InsightTone.positive:
        accent = AppTheme.incomeColorOf(context);
        icon = Icons.trending_up_rounded;
      case InsightTone.warning:
        accent = AppTheme.warningColorOf(context);
        icon = Icons.warning_amber_rounded;
      case InsightTone.neutral:
        accent = theme.colorScheme.onSurfaceVariant;
        icon = Icons.lightbulb_outline_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      color: accent.withValues(alpha: isDark ? 0.16 : 0.07),
      borderColor: accent.withValues(alpha: 0.28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (insight.metric != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      insight.metric!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
