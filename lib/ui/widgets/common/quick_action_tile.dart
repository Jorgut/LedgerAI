import 'package:flutter/material.dart';

import '../../motion/motion.dart';
import '../../theme.dart';

/// 首页快速入口卡片：图标 + 文字，最小高度 112dp，整块可点。
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// 图标强调色；默认品牌绿。
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
    final accent = color ?? AppTheme.brandText;
    final background = isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.20),
            const Color(0xFF111F1A),
          )
        : accent.withValues(alpha: 0.12);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: PressableScale(
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            child: Semantics(
              button: true,
              label: label,
              onTap: onTap,
              excludeSemantics: true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isDark
                            ? Color.alphaBlend(
                                Colors.white.withValues(alpha: 0.55),
                                accent,
                              )
                            : accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
