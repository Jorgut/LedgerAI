import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/stats.dart';
import '../motion/motion.dart';
import '../theme.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/quick_action_tile.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'budget_screen.dart';
import 'transactions_screen.dart';

/// 首页：本月概览、预算进度、快速记账入口、最近记录。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// 「查看全部」回调；由 RootShell 切换到账单 Tab。为 null 时打开账单页。
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final summary = app.stats.summary(now.year, now.month);
    final budget = app.prefs.monthlyBudget;
    final budgetRatio = app.stats.budgetRatio(budget, now.year, now.month);
    final recent = app.transactions.take(5).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppTheme.pagePadding,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradientOf(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/brand/heng_glyph.png',
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                l10n.homeBrand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          FadeSlideIn(child: _BalanceCard(summary: summary, now: now)),
          const SizedBox(height: 16),
          FadeSlideIn(
            delayFraction: 0.06,
            child: _BudgetCard(
              budget: budget,
              ratio: budgetRatio,
              expense: summary.expense,
              now: now,
              onOpenBudget: () => _openBudget(context),
            ),
          ),
          const SizedBox(height: 8),
          SectionHeader(
            title: l10n.quickActions,
            subtitle: l10n.quickActionsSubtitle,
          ),
          FadeSlideIn(
            delayFraction: 0.12,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.document_scanner_rounded,
                      label: l10n.photoEntry,
                      color: AppTheme.brandTextOf(context),
                      onTap: () =>
                          _openAdd(context, AddTransactionMode.receipt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.mic_rounded,
                      label: l10n.voiceEntry,
                      color: const Color(0xFF5B6C8A),
                      onTap: () => _openAdd(context, AddTransactionMode.voice),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.edit_note_rounded,
                      label: l10n.manualEntry,
                      color: const Color(0xFFB4845A),
                      onTap: () => _openAdd(context, AddTransactionMode.manual),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(
            title: l10n.recentRecords,
            subtitle: recent.isEmpty ? null : l10n.recentCount(recent.length),
            trailing: TextButton(
              onPressed: onSeeAll ?? () => _openTransactions(context),
              child: Text(l10n.viewAll),
            ),
          ),
          if (recent.isEmpty)
            AppCard(
              padding: EdgeInsets.zero,
              child: EmptyState(
                compact: true,
                icon: Icons.receipt_long_rounded,
                title: l10n.emptyRecordsTitle,
                message: l10n.emptyRecordsMessage,
                actionLabel: l10n.recordFirst,
                onAction: () => _openAdd(context, AddTransactionMode.manual),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 72),
                    FadeSlideIn(
                      delayFraction: 0.16 + i * 0.05,
                      child: TransactionTile(
                        txn: recent[i],
                        dense: true,
                        onTap: () => _openEdit(context, recent[i]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.localOnlyNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAdd(BuildContext context, AddTransactionMode mode) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => AddTransactionScreen(initialMode: mode),
      ),
    );
  }

  void _openEdit(BuildContext context, Txn txn) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => AddTransactionScreen(transaction: txn),
      ),
    );
  }

  void _openBudget(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const BudgetScreen()),
    );
  }

  void _openTransactions(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.now});

  final MonthSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandOf(context).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(gradient: AppTheme.brandGradientOf(context)),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.8, -1.1),
                        radius: 1.35,
                        colors: [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.balanceLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.94),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            formatMonthLabel(now.year, now.month),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedAmount(
                          summary.balance,
                          signed: true,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          semanticLabel:
                              l10n.balanceSemantic(formatMoney(summary.balance)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: l10n.income,
                            amount: summary.income,
                            semanticLabel:
                                l10n.incomeSemantic(formatMoney(summary.income)),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: _HeroStat(
                              label: l10n.expense,
                              amount: summary.expense,
                              semanticLabel:
                                  l10n.expenseSemantic(formatMoney(summary.expense)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (summary.isEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        l10n.emptyMonth,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.amount,
    required this.semanticLabel,
  });

  final String label;
  final double amount;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.90),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              amount,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.ratio,
    required this.expense,
    required this.now,
    required this.onOpenBudget,
  });

  final double? budget;
  final double? ratio;
  final double expense;
  final DateTime now;
  final VoidCallback onOpenBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    if (budget == null || budget! <= 0) {
      return AppCard(
        onTap: onOpenBudget,
        semanticLabel: l10n.setBudgetTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBadge(icon: Icons.savings_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.setBudgetTitle, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        l10n.setBudgetHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenBudget,
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: Text(l10n.setBudgetButton),
              ),
            ),
          ],
        ),
      );
    }

    final used = ratio ?? 0;
    final over = used > 1;
    final near = used >= 0.8 && !over;
    final progressColor = over
        ? theme.colorScheme.error
        : near
            ? AppTheme.warningColorOf(context)
            : (AppTheme.isDark(context)
                ? theme.colorScheme.primary
                : AppTheme.brandOf(context));
    final remaining = budget! - expense;
    final percent = (used * 100).clamp(0, 999).round();

    return AppCard(
      onTap: onOpenBudget,
      semanticLabel: l10n.monthBudgetSemantic(
          formatMoney(budget!), '$percent${over ? '!' : ''}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBadge(icon: Icons.savings_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.budgetTitle, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      formatMonthLabel(now.year, now.month),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$percent%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: used.clamp(0, 1),
              minHeight: 10,
              color: progressColor,
              backgroundColor:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                l10n.spentAmount(formatMoney(expense)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                over
                    ? l10n.overspentAmount(formatMoney(-remaining))
                    : l10n.remainingAmount(formatMoney(remaining)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppTheme.isDark(context)
        ? theme.colorScheme.primary
        : AppTheme.brandTextOf(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: accent),
    );
  }
}
