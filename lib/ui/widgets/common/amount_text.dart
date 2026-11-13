import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../theme.dart';
import '../../../l10n/app_localizations.dart';

/// 金额文本：等宽数字（tabular figures）+ 屏幕阅读器语义。
///
/// 用法：
/// ```dart
/// AmountText(txn.amount, style: ..., semanticLabel: '支出 ${formatMoney(txn.amount)}')
/// ```
class AmountText extends StatelessWidget {
  const AmountText(
    this.amount, {
    super.key,
    this.style,
    this.withSymbol = true,
    this.signed = false,
    this.semanticLabel,
    this.textAlign,
    this.maxLines = 1,
    this.softWrap = false,
  });

  /// 金额，可为负数（配合 [signed] 展示 -¥42.00）。
  final double amount;
  final TextStyle? style;
  final bool withSymbol;

  /// 是否显示正负号；收入传正数（+¥），支出传负数（-¥）。
  final bool signed;

  /// 屏幕阅读器标签，例如「支出 42.00 元」。不传时使用「金额 ¥42.00」。
  final String? semanticLabel;
  final TextAlign? textAlign;
  final int maxLines;
  final bool softWrap;

  String get _displayText =>
      formatMoney(amount, withSymbol: withSymbol, signed: signed);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
      fontFeatures: AppTheme.tabularFigures,
    );
    final label = semanticLabel ??
        AppLocalizations.of(context).amountSemantic(formatMoney(amount));
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Text(
        _displayText,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: softWrap ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
