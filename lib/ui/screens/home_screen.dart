import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/stats.dart';
import '../motion/motion.dart';
import '../theme.dart';
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
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '衡账',
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
          const SectionHeader(
            title: '快速记账',
            subtitle: '拍照、语音或手动，几秒记一笔',
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
                      label: '拍照记账',
                      color: AppTheme.brandText,
                      onTap: () =>
                          _openAdd(context, AddTransactionMode.receipt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.mic_rounded,
                      label: '语音记账',
                      color: const Color(0xFF5B6C8A),
                      onTap: () => _openAdd(context, AddTransactionMode.voice),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      icon: Icons.edit_note_rounded,
                      label: '手动记账',
                      color: const Color(0xFFB4845A),
                      onTap: () => _openAdd(context, AddTransactionMode.manual),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(
            title: '最近记录',
            subtitle: recent.isEmpty ? null : '最近 ${recent.length} 笔',
            trailing: TextButton(
              onPressed: onSeeAll ?? () => _openTransactions(context),
              child: const Text('查看全部'),
            ),
          ),
          if (recent.isEmpty)
            AppCard(
              padding: EdgeInsets.zero,
              child: EmptyState(
                compact: true,
                icon: Icons.receipt_long_rounded,
                title: '还没有记录',
                message: '拍一张小票、说一句话，或手动记第一笔。',
                actionLabel: '记第一笔',
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
              '数据仅保存在本机，可在「我的 → 数据导出」备份。',
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
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brand.withValues(alpha: 0.22),
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
                      const BoxDecoration(gradient: AppTheme.brandGradient),
                ),
              ),
              const Positioned.fill(child: TechBackdrop()),
              const Positioned.fill(child: SheenSweep()),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '本月结余',
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
                              '本月结余 ${formatMoney(summary.balance)} 元',
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
                            label: '收入',
                            amount: summary.income,
                            semanticLabel:
                                '本月收入 ${formatMoney(summary.income)} 元',
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
                              label: '支出',
                              amount: summary.expense,
                              semanticLabel:
                                  '本月支出 ${formatMoney(summary.expense)} 元',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (summary.isEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        '本月还没有记录，从下面快速记第一笔吧。',
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
    if (budget == null || budget! <= 0) {
      return AppCard(
        onTap: onOpenBudget,
        semanticLabel: '设置本月预算',
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
                      Text('设置本月预算', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '设置后随时看到剩余额度，超支会提醒你',
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
                label: const Text('设置预算'),
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
                : AppTheme.brand);
    final remaining = budget! - expense;
    final percent = (used * 100).clamp(0, 999).round();

    return AppCard(
      onTap: onOpenBudget,
      semanticLabel:
          '本月预算 ${formatMoney(budget!)}，已用 $percent%${over ? '，已超支' : ''}',
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
                    Text('本月预算', style: theme.textTheme.titleSmall),
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
                '已花 ${formatMoney(expense)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                over
                    ? '已超支 ${formatMoney(-remaining)}'
                    : '剩余 ${formatMoney(remaining)}',
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
        : AppTheme.brandText;
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
