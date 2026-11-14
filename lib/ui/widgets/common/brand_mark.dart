import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// HENG wordmark with the oracle-bone seal as a small signature.
///
/// The seal is baseline-aligned to the wordmark: its bottom edge sits on the
/// HENG baseline, exactly like a stamp/signature. The seal is deliberately
/// smaller than the cap height; the glyph is slightly dilated so it stays
/// legible at 24–25 px.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.wordSize = 42,
    this.sealSize,
    this.matchCapHeight = false,
    this.sealDilation = 0.25,
    this.color,
  });

  final double wordSize;
  final double? sealSize;

  /// When true the seal is exactly the height of the HENG capital letters and
  /// aligned top-to-top and bottom-to-bottom with them.
  final bool matchCapHeight;

  /// Dilation of the white oracle glyph inside the seal.
  final double sealDilation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    const word = 'HENG';
    final ink = color ?? Theme.of(context).colorScheme.onSurface;
    final style = TextStyle(
      color: ink,
      fontSize: wordSize,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -1.2,
    );

    // Brand marks are fixed-size; dynamic type should not deform the lockup.
    final painter = TextPainter(
      text: TextSpan(text: word, style: style),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 1,
    )..layout();
    final baseline =
        painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final wordWidth = painter.width;
    final wordHeight = painter.height;
    final boxes = painter.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 4),
    );
    final capTop = boxes.isEmpty ? 0.0 : boxes.first.top;
    final capHeight = boxes.isEmpty
        ? wordSize * 0.72
        : boxes.first.bottom - boxes.first.top;
    painter.dispose();

    final seal = matchCapHeight ? capHeight : (sealSize ?? wordSize * 0.74 * 0.8);
    final gap = wordSize * 0.12;
    final totalWidth = wordWidth + gap + seal;
    final sealTop = matchCapHeight ? capTop : baseline - seal;

    return SizedBox(
      width: totalWidth,
      height: wordHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              word,
              maxLines: 1,
              textScaler: TextScaler.noScaling,
              style: style,
            ),
          ),
          Positioned(
            left: wordWidth + gap,
            top: sealTop,
            child: OracleSeal(size: seal, dilation: sealDilation),
          ),
        ],
      ),
    );
  }
}

/// Public seal widget so design reviews can compare glyph dilation.
class OracleSeal extends StatelessWidget {
  const OracleSeal({super.key, required this.size, this.dilation = 0.35});

  final double size;
  final double dilation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradientOf(context),
        borderRadius: BorderRadius.circular(size * 0.10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: size > 30 ? 0.8 : 0.6,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.dilate(radiusX: dilation, radiusY: dilation),
          child: Image.asset(
            'assets/brand/heng_glyph.png',
            fit: BoxFit.contain,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
