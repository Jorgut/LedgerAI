import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

/// 冷启动后的品牌开场。
///
/// iOS 的 LaunchScreen 只能是静态图，所以这里用 Flutter 播一段 2.6s 的
/// 「景深显影」：甲骨文从轻微模糊到清晰、HENG 淡入、副标与 footer 依次出现。
/// 规则：单次、不循环、点击可跳过；系统开启 reduce motion 时退化为 400ms 淡入。
class BrandIntro extends StatefulWidget {
  const BrandIntro({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<BrandIntro> createState() => _BrandIntroState();
}

class _BrandIntroState extends State<BrandIntro>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _started = false;
  bool _finished = false;

  static const Color _deep = Color(0xFF063A2C);
  static const Color _dark = Color(0xFF0B1512);
  static const Color _cream = Color(0xFFF4F3EE);
  static const Color _mint = Color(0xFFCDEEE1);
  static const Color _muted = Color(0xFF96BEAF);
  static const Color _credit = Color(0xFF8FA69B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.duration = const Duration(milliseconds: 400);
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  void _skip() {
    if (_finished) return;
    _controller.animateTo(1,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  double _interval(double t, double begin, double end) =>
      ((t - begin) / (end - begin)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: _dark,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _skip,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final glyph = reduceMotion
                  ? 1.0
                  : Curves.easeOutCubic.transform(_interval(t, 0.0, 0.42));
              final heng = reduceMotion
                  ? 1.0
                  : Curves.easeOutCubic.transform(_interval(t, 0.31, 0.54));
              final tag = reduceMotion
                  ? 1.0
                  : Curves.easeOutCubic.transform(_interval(t, 0.58, 0.77));
              final footer = reduceMotion
                  ? 1.0
                  : Curves.easeOutCubic.transform(_interval(t, 0.81, 0.96));
              final blur = reduceMotion ? 0.0 : (1 - glyph) * 8;
              final scale = reduceMotion ? 1.0 : 1.04 - 0.04 * glyph;

              return Semantics(
                label: AppLocalizations.of(context).introStarting,
                container: true,
                child: ColoredBox(
                  color: _dark,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final s = w / 1320;
                      final glyphH = 280 * s;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_deep, _dark],
                              ),
                            ),
                          ),
                          // 极淡的顶部光晕，代替粒子/霓虹。
                          Positioned(
                            top: h * 0.08,
                            left: w * 0.18,
                            right: w * 0.18,
                            height: h * 0.34,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    _mint.withValues(alpha: 0.07),
                                    Colors.transparent
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: h * 860 / 2868,
                            left: 0,
                            right: 0,
                            height: glyphH,
                            child: Opacity(
                              opacity: glyph,
                              child: Transform.scale(
                                scale: scale,
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                      sigmaX: blur, sigmaY: blur),
                                  child: Image.asset(
                                    'assets/brand/heng_glyph.png',
                                    height: glyphH,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: h * 1270 / 2868 - (130 * s * 1.2) / 2,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: heng,
                              child: Transform.translate(
                                offset: Offset(0, (1 - heng) * 10 * s),
                                child: Text(
                                  'HENG',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica Neue',
                                    fontSize: 130 * s,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 5 * s,
                                    height: 1.0,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: h * 1410 / 2868,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: tag,
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context).introTagline,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 28 * s,
                                        color: _mint,
                                        height: 1.3,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(height: 6 * s),
                                  Text(
                                    AppLocalizations.of(context).introFooter,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18 * s,
                                        color: _muted,
                                        height: 1.3,
                                        decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 170 * s,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: footer,
                              child: Column(
                                children: [
                                  Text(
                                    'PRIVATE LEDGER',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica Neue',
                                      fontSize: 26 * s,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 3 * s,
                                      color: _cream,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(height: 5 * s),
                                  Text(
                                    'DESIGNED BY ARCHINTERA',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica Neue',
                                      fontSize: 26 * s,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 3 * s,
                                      color: _credit,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 首次冷启动时显示 [BrandIntro]，结束后淡入真正的 App。
/// 商店截图模式（DEMO_SCREEN）会跳过，避免影响自动截图。
class BrandIntroGate extends StatefulWidget {
  const BrandIntroGate({super.key, required this.enabled, required this.child});

  /// 测试/截图环境可强制跳过品牌开场。
  static bool forceDisabled = false;

  final bool enabled;
  final Widget child;

  @override
  State<BrandIntroGate> createState() => _BrandIntroGateState();
}

class _BrandIntroGateState extends State<BrandIntroGate> {
  late bool _showIntro = widget.enabled;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || BrandIntroGate.forceDisabled) return widget.child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showIntro
          ? BrandIntro(
              key: const ValueKey('brand-intro'),
              onFinished: () => setState(() => _showIntro = false),
            )
          : KeyedSubtree(key: const ValueKey('app'), child: widget.child),
    );
  }
}
