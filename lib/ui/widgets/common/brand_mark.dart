import 'package:flutter/material.dart';

import '../../theme.dart';

/// HENG wordmark with the oracle-bone seal as a signature at its lower right.
///
/// The wordmark is intentionally larger than body text and slightly bold;
/// the seal is small, like a stamp/signature. Text scaling is clamped so the
/// brand mark never crowds the AppBar under large Dynamic Type settings.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.wordSize = 42,
    this.sealSize = 18,
    this.color,
  });

  final double wordSize;
  final double sealSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? Theme.of(context).colorScheme.onSurface;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'HENG',
            maxLines: 1,
            style: TextStyle(
              color: ink,
              fontSize: wordSize,
              fontWeight: FontWeight.w800,
              height: 0.96,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(width: 5),
          Transform.translate(
            offset: const Offset(0, 2),
            child: Container(
              width: sealSize,
              height: sealSize,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradientOf(context),
                borderRadius: BorderRadius.circular(2.5),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 0.8,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(sealSize * 0.11),
                child: Image.asset(
                  'assets/brand/heng_glyph.png',
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
