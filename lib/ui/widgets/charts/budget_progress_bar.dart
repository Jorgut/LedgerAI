import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../motion/motion.dart';
import '../../theme.dart';

/// 预算进度条：正常为品牌绿，接近上限变琥珀色，超支变红。
///
/// [budget] <= 0 视为未设置预算，显示引导文案而不是进度。
class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    this.label,
    this.height = 10,
    this.showLabels = true,
    this.showStatus = true,
  });

  /// 已花费金额。
  final double spent;

  /// 预算上限；<= 0 表示未设置。
  final double budget;

  /// 左侧说明文字，例如「餐饮」「本月总预算」。
  final String? label;

  final double height;
  final bool showLabels;

  /// 是否在进度条下方显示百分比 / 超支说明。
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBudget = budget > 0;
    final ratio = hasBudget ? spent / budget : 0.0;
    final percent = (ratio * 100).clamp(0, 999).toDouble();
    final isOver = hasBudget && spent > budget;
    final isNear = hasBudget && !isOver && ratio >= 0.8;

    final Color barColor;
    if (!hasBudget) {
      barColor = theme.colorScheme.outline;
    } else if (isOver) {
      barColor = theme.colorScheme.error;
    } else if (isNear) {
      barColor = AppTheme.warningColorOf(context);
    } else {
      barColor = AppTheme.incomeColorOf(context);
    }

    final statusText = !hasBudget
        ? '未设置预算'
        : isNear && !isOver
            ? '预算快用完了，已用 ${percent.toStringAsFixed(0)}%'
            : '已用 ${percent.toStringAsFixed(0)}%';

    final trackColor = theme.colorScheme.surfaceContainerHighest;
    final baseStyle = theme.textTheme.bodyMedium;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '预算进度${label == null ? '' : '（$label）'}',
      value: '$statusText，已花费 ${formatMoney(spent)}，预算 ${formatMoney(budget)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabels)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  if (label != null)
                    Expanded(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      hasBudget
                          ? '${formatMoney(spent)} / ${formatMoney(budget)}'
                          : '未设置预算',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: baseStyle?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: AppTheme.tabularFigures,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 0, end: hasBudget ? ratio.clamp(0.0, 1.0) : 0),
              duration: reduceMotionOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 640),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: height,
                color: barColor,
                backgroundColor: trackColor,
              ),
            ),
          ),
          if (showStatus) const SizedBox(height: 6),
          if (showStatus)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOver || isNear) ...[
                  Icon(
                    isOver
                        ? Icons.error_outline_rounded
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: barColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    statusText,
                    style: baseStyle?.copyWith(
                      // 溢出/接近上限时用语义色图标提示，文字保持高对比度。
                      color: isOver
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isOver ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isOver)
                  Text(
                    '超支 ${formatMoney(spent - budget)}',
                    style: baseStyle?.copyWith(
                      color: theme.colorScheme.error,
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
