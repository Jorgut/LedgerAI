import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../theme.dart';
import '../../l10n/app_localizations.dart';

/// 系统是否要求减少动态效果（无障碍设置）。所有动效都必须尊重它。
bool reduceMotionOf(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// 按下时轻微缩放 + 触感，不拦截子组件自己的点击手势。
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.pressedScale = 0.96,
    this.haptic = true,
  });

  final Widget child;
  final double pressedScale;
  final bool haptic;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    if (value && widget.haptic) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {
        // 触感不可用时忽略。
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// 入场动效：淡入 + 轻微上移。用单次 AnimationController + Interval 实现错峰，
/// 不使用 Timer / 无限循环，保证 widget 测试可以 pumpAndSettle。
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayFraction = 0,
    this.duration = const Duration(milliseconds: 520),
    this.offsetY = 0.05,
  });

  final Widget child;

  /// 0..0.6，表示在整个动画时间轴中延后多少比例才开始。
  final double delayFraction;
  final Duration duration;
  final double offsetY;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delayFraction.clamp(0.0, 0.9),
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return widget.child;
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, widget.offsetY),
          end: Offset.zero,
        ).animate(_curved),
        child: widget.child,
      ),
    );
  }
}

/// 金额数字滚动（首次出现从 0 滚动到目标值；之后的变更从当前值过渡）。
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount(
    this.amount, {
    super.key,
    this.style,
    this.signed = false,
    this.semanticLabel,
    this.duration = const Duration(milliseconds: 680),
  });

  final double amount;
  final TextStyle? style;
  final bool signed;
  final String? semanticLabel;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = reduceMotionOf(context) ? Duration.zero : duration;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: effectiveDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Semantics(
        label: semanticLabel ??
            AppLocalizations.of(context).amountSemantic(formatMoney(amount)),
        excludeSemantics: true,
        child: Text(
          formatMoney(value, signed: signed),
          style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
            fontFeatures: AppTheme.tabularFigures,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// 余额卡上的科技感背景：左上青绿光晕 + 同心 HUD 圆环 + 局部青色弧线。
class TechBackdrop extends StatelessWidget {
  const TechBackdrop({super.key, this.opacity = 1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TechBackdropPainter(opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _TechBackdropPainter extends CustomPainter {
  _TechBackdropPainter({this.opacity = 1});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.78, size.height * 0.18);
    final radius = size.shortestSide * 0.85;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2DD4BF).withValues(alpha: 0.34 * opacity),
          const Color(0xFF2DD4BF).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.10 * opacity);
    final ringCenter = Offset(size.width * 0.12, size.height * 0.12);
    for (final ratio in const [0.55, 0.78, 1.02]) {
      canvas.drawCircle(ringCenter, size.shortestSide * ratio, ringPaint);
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5EEAD4).withValues(alpha: 0.55 * opacity);
    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.86, size.height * 0.9),
      radius: size.shortestSide * 0.5,
    );
    canvas.drawArc(arcRect, -math.pi * 0.75, math.pi * 0.42, false, arcPaint);

    // 右上角微光扫过（静态），增加层质感
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16 * opacity);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width - 18 - i * 9.0, 18 + i * 9.0),
        1.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TechBackdropPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// 一次性扫光动画（余额卡），不做无限循环，避免测试与被测设备发热。
class SheenSweep extends StatefulWidget {
  const SheenSweep({super.key, this.child, this.duration = const Duration(milliseconds: 1400)});

  final Widget? child;
  final Duration duration;

  @override
  State<SheenSweep> createState() => _SheenSweepState();
}

class _SheenSweepState extends State<SheenSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SheenPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  _SheenPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = size.width * 2.2;
    final x = -size.width * 0.8 + travel * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.16),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(x - size.width * 0.35, 0, size.width * 0.7, size.height),
      );
    final path = Path()
      ..moveTo(x - size.width * 0.35, 0)
      ..lineTo(x, 0)
      ..lineTo(x - size.height * 0.45, size.height)
      ..lineTo(x - size.width * 0.35 - size.height * 0.45, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SheenPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 语音/扫码等「进行中」状态的呼吸圆环：只在 active 时循环，结束后停止。
class PulseRings extends StatefulWidget {
  const PulseRings({
    super.key,
    required this.active,
    required this.child,
    this.color,
    this.size = 88,
  });

  final bool active;
  final Widget child;
  final Color? color;
  final double size;

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PulseRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active || reduceMotionOf(context)) return widget.child;
    final color = widget.color ?? AppTheme.brandOf(context);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _PulsePainter(progress: _controller.value, color: color),
                size: Size.square(widget.size),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final t = (progress + i * 0.5) % 1.0;
      final radius = size.shortestSide * (0.28 + t * 0.24);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color.withValues(alpha: 0.42 * (1 - t));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// OCR 扫描线：只在扫描中循环。
class ScanLine extends StatefulWidget {
  const ScanLine({super.key, required this.active, this.color});

  final bool active;
  final Color? color;

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ScanLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active || reduceMotionOf(context)) return const SizedBox.shrink();
    final color = widget.color ?? AppTheme.brandOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ScanLinePainter(progress: _controller.value, color: color),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (0.1 + progress * 0.8);
    final rect = Rect.fromLTWH(0, y - 12, size.width, 24);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    final line = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
