import 'package:flutter/material.dart';

import '../../../core/models.dart';
import '../../theme.dart';

/// 分类图标：带品牌化底色的圆角图标。
///
/// 浅色模式自动压暗前景色、深色模式自动提亮，保证图标对比度。
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 44,
    this.semanticLabel,
  });

  final Category category;
  final double size;

  /// 传入后作为独立语义节点；列表里通常由外层统一朗读，保持 null。
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final background = _background(AppTheme.categoryColorOf(context, category), isDark);
    final foreground = _foreground(AppTheme.categoryColorOf(context, category), isDark);
    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Icon(category.icon, size: size * 0.5, color: foreground),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: icon);
    return Semantics(label: semanticLabel, excludeSemantics: true, child: icon);
  }

  static Color _background(Color base, bool isDark) {
    if (isDark) {
      return Color.alphaBlend(
        base.withValues(alpha: 0.22),
        const Color(0xFF111F1A),
      );
    }
    return base.withValues(alpha: 0.14);
  }

  static Color _foreground(Color base, bool isDark) {
    final hsl = HSLColor.fromColor(base);
    if (isDark) {
      return hsl.withLightness(hsl.lightness.clamp(0.62, 0.80)).toColor();
    }
    return hsl.withLightness(hsl.lightness.clamp(0.30, 0.44)).toColor();
  }
}
