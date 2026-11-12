import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/stats.dart';
import '../../motion/motion.dart';
import '../../theme.dart';

/// 分类占比环形图（自绘），中心显示当期总额。
///
/// [slices] 由 `StatsService.breakdown()` 提供，按金额降序排列；
/// [total] 为全部切片金额之和（无数据时传 0）。
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({
    super.key,
    required this.slices,
    required this.total,
    this.size = 168,
    this.strokeWidth = 22,
    this.centerLabel = '合计',
  });

  final List<CategorySlice> slices;
  final double total;
  final double size;
  final double strokeWidth;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = total > 0 && slices.isNotEmpty;
    final trackColor = theme.colorScheme.surfaceContainerHighest;
    final description = hasData
        ? slices
            .map(
              (slice) =>
                  '${slice.category.name} ${formatMoney(slice.amount)}，占 ${(slice.ratio * 100).toStringAsFixed(0)}%',
            )
            .join('；')
        : '暂无分类数据';

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '分类占比环形图，$centerLabel ${formatMoney(total)}',
      value: description,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: reduceMotionOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 820),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => CustomPaint(
                  painter: _DonutPainter(
                    slices: slices,
                    total: total,
                    strokeWidth: strokeWidth,
                    trackColor: trackColor,
                    progress: progress,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(strokeWidth + 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasData)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatMoney(total),
                          maxLines: 1,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: AppTheme.tabularFigures,
                          ),
                        ),
                      )
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '暂无数据',
                          maxLines: 1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.slices,
    required this.total,
    required this.strokeWidth,
    required this.trackColor,
    this.progress = 1,
  });

  final List<CategorySlice> slices;
  final double total;
  final double strokeWidth;
  final Color trackColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (total <= 0 || slices.isEmpty) return;

    const gap = 0.035; // 扇区之间的空隙（弧度）
    var start = -math.pi / 2;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      var sweep = slice.ratio * math.pi * 2 * progress;
      if (sweep <= 0) continue;
      final effectiveGap = slices.length > 1 ? math.min(gap, sweep * 0.4) : 0.0;
      sweep -= effectiveGap;
      if (sweep <= 0) {
        start += slice.ratio * math.pi * 2;
        continue;
      }
      arcPaint.color = slice.category.color;
      canvas.drawArc(rect, start + effectiveGap / 2, sweep, false, arcPaint);
      start += slice.ratio * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.total != total ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progress != progress;
  }
}
