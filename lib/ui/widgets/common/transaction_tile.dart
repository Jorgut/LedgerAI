import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../theme.dart';
import 'amount_text.dart';
import 'category_icon.dart';

/// 交易行：分类图标 + 标题/说明 + 金额（收入/支出着色）。
///
/// 整行使用一条连贯的屏幕阅读器语义（含收支方向与金额），避免逐字朗读。
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.txn,
    this.onTap,
    this.showDate = true,
    this.showSource = true,
    this.dense = false,
  });

  final Txn txn;
  final VoidCallback? onTap;
  final bool showDate;
  final bool showSource;
  final bool dense;

  String get _title {
    final note = txn.note.trim();
    if (note.isNotEmpty) return note;
    final merchant = txn.merchant?.trim();
    if (merchant != null && merchant.isNotEmpty) return merchant;
    return txn.category.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = txn.category;
    final isIncome = txn.isIncome;
    final amountColor =
        AppTheme.amountColor(theme.brightness, isIncome: isIncome);
    final dateLabel = formatDateLabel(txn.date);

    final subtitleParts = <String>[
      category.name,
      if (showDate) dateLabel,
      if (showSource && txn.source != EntrySource.manual) txn.source.label,
    ];

    final semantic = StringBuffer()
      ..write(_title)
      ..write('，')
      ..write(category.name)
      ..write('，')
      ..write(isIncome ? '收入' : '支出')
      ..write(' ')
      ..write(formatMoney(txn.amount, withSymbol: false))
      ..write(' 元');
    if (showDate) {
      semantic
        ..write('，')
        ..write(dateLabel);
    }
    if (showSource && txn.source != EntrySource.manual) {
      semantic
        ..write('，')
        ..write(txn.source.label);
    }

    final row = Row(
      children: [
        CategoryIcon(category: category, size: dense ? 40 : 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitleParts.join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountText(
              isIncome ? txn.amount : -txn.amount,
              signed: true,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ],
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: semantic.toString(),
      hint: onTap != null ? '双击编辑' : null,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: dense ? 10 : 12,
          ),
          child: row,
        ),
      ),
    );
  }
}
