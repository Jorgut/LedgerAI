import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/stats.dart';
import '../../motion/motion.dart';
import '../../theme.dart';
import '../../../l10n/app_localizations.dart';
import 'chart_placeholder.dart';

/// 近几个月「收入 / 支出」柱状趋势图。
///
/// 全部使用 [CustomPainter] 自绘，不依赖任何图表库；月份标签与金额刻度
/// 随系统字体大小缩放，空间不足时自动隔月显示月份标签。
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    this.height = 200,
    this.showIncome = true,
    this.showExpense = true,
  });

  /// 按时间正序的月份数据（由 `StatsService.trend()` 提供）。
  final List<MonthPoint> points;

  final double height;
  final bool showIncome;
  final bool showExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasData = points.any(
      (point) =>
          (showIncome && point.income > 0) ||
          (showExpense && point.expense > 0),
    );
    if (points.isEmpty || !hasData) {
      return ChartPlaceholder(
        message: l10n.chartEmpty,
        icon: Icons.bar_chart_rounded,
        height: height,
      );
    }

    final incomeColor = AppTheme.incomeColorOf(context);
    final expenseColor = AppTheme.expenseColorOf(context);
    final gridColor = theme.colorScheme.outlineVariant;
    final labelColor = theme.colorScheme.onSurfaceVariant;
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
          color: labelColor,
          fontSize: 14,
          fontFeatures: AppTheme.tabularFigures,
        ) ??
        TextStyle(color: labelColor, fontSize: 12);

    final description = points
        .map(
          (point) => '${formatMonthShort(point.month)}：'
              '${showIncome ? l10n.txIncomeFooter(formatMoney(point.income)) : ''}'
              '${showIncome && showExpense ? ', ' : ''}'
              '${showExpense ? l10n.txExpenseFooter(formatMoney(point.expense)) : ''}',
        )
        .join('；');

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: l10n.chartSemantic(points.length),
      value: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (showIncome) _LegendDot(color: incomeColor, label: l10n.income),
              if (showExpense) _LegendDot(color: expenseColor, label: l10n.expense),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            width: double.infinity,
            child: RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: reduceMotionOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 760),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => CustomPaint(
                  painter: _TrendChartPainter(
                    points: points,
                    showIncome: showIncome,
                    showExpense: showExpense,
                    incomeColor: incomeColor,
                    expenseColor: expenseColor,
                    gridColor: gridColor,
                    labelStyle: labelStyle,
                    textScaler: textScaler,
                    progress: progress,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.showIncome,
    required this.showExpense,
    required this.incomeColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelStyle,
    required this.textScaler,
    this.progress = 1,
  });

  final List<MonthPoint> points;
  final bool showIncome;
  final bool showExpense;
  final Color incomeColor;
  final Color expenseColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final TextScaler textScaler;

  /// 0..1，柱状图生长进度（首屏一次入场动画）。
  final double progress;

  static const int _gridLines = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    var maxValue = 0.0;
    for (final point in points) {
      if (showIncome) maxValue = math.max(maxValue, point.income);
      if (showExpense) maxValue = math.max(maxValue, point.expense);
    }
    maxValue = _niceMax(maxValue * 1.08);
    if (maxValue <= 0) maxValue = 100;

    // 先量尺子：取所有刻度标签里最宽的一个，决定左侧留白。
    TextPainter measure(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      return painter;
    }

    final tickLabels = <String>[];
    for (var i = 0; i <= _gridLines; i++) {
      tickLabels.add(formatCompactMoney(maxValue / _gridLines * i));
    }
    var maxLabelWidth = 0.0;
    for (final label in tickLabels) {
      maxLabelWidth = math.max(maxLabelWidth, measure(label).width);
    }
    final leftPadding =
        math.min(maxLabelWidth + 10, size.width * 0.38).toDouble();
    final bottomPadding = _labelHeight() + 10;
    final topPadding = 6.0;
    final plotWidth = math.max(size.width - leftPadding - 4, 0.0);
    final plotHeight = math.max(size.height - topPadding - bottomPadding, 0.0);
    if (plotWidth <= 0 || plotHeight <= 0) return;

    double yFor(double value) =>
        topPadding + plotHeight - (value / maxValue) * plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= _gridLines; i++) {
      final y = yFor(maxValue / _gridLines * i);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      final painter = measure(tickLabels[i]);
      painter.paint(
        canvas,
        Offset(
          leftPadding - painter.width - 8,
          y - painter.height / 2,
        ),
      );
    }

    // 柱状：每个月一组，收入在左、支出在右。
    final slotWidth = plotWidth / points.length;
    final barCount = (showIncome ? 1 : 0) + (showExpense ? 1 : 0);
    final groupedBarWidth = math.min(14.0, slotWidth * 0.24);
    final barGap = math.min(4.0, slotWidth * 0.06);
    final groupWidth = groupedBarWidth * barCount + barGap * (barCount - 1);

    final barPaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final slotLeft = leftPadding + slotWidth * i;
      var x = slotLeft + (slotWidth - groupWidth) / 2;

      void drawBar(double value, Color color) {
        final top = yFor(value * progress);
        final barHeight = plotHeight - (top - topPadding);
        if (barHeight <= 0.4) return;
        barPaint.color = color;
        final rect = Rect.fromLTWH(
          x,
          top,
          groupedBarWidth,
          barHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(math.min(4, groupedBarWidth / 2)),
          ),
          barPaint,
        );
        x += groupedBarWidth + barGap;
      }

      if (showIncome) drawBar(point.income, incomeColor);
      if (showExpense) drawBar(point.expense, expenseColor);
    }

    // 月份标签：空间不足时隔月显示，避免大字号下互相重叠。
    final monthLabels = points.map((point) {
      final painter = measure(formatMonthShort(point.month));
      return painter;
    }).toList();
    final labelWidth = monthLabels.fold<double>(
      0,
      (value, painter) => math.max(value, painter.width),
    );
    final showEveryMonth = labelWidth * points.length <= plotWidth;
    final labelHeight = _labelHeight();
    for (var i = 0; i < points.length; i++) {
      if (!showEveryMonth && i.isOdd) continue;
      final painter = monthLabels[i];
      final centerX = leftPadding + slotWidth * (i + 0.5);
      painter.paint(
        canvas,
        Offset(
          centerX - painter.width / 2,
          size.height - labelHeight - 2,
        ),
      );
    }
  }

  double _labelHeight() {
    final painter = TextPainter(
      text: TextSpan(text: '00', style: labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.height;
  }

  /// 把最大值向上取整到 1 / 2 / 5 / 10 的倍数，让刻度更干净。
  double _niceMax(double value) {
    if (value <= 0) return 0;
    final exponent = (math.log(value) / math.ln10).floor();
    final power = math.pow(10, exponent).toDouble();
    final fraction = value / power;
    final double niceFraction;
    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
    return niceFraction * power;
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.showIncome != showIncome ||
        oldDelegate.showExpense != showExpense ||
        oldDelegate.incomeColor != incomeColor ||
        oldDelegate.expenseColor != expenseColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.textScaler != textScaler ||
        oldDelegate.progress != progress;
  }
}
