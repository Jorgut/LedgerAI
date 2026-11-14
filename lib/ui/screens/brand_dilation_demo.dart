import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/brand_mark.dart';

/// Oracle glyph dilation comparison at signature sizes (demo only).
class BrandDilationDemo extends StatelessWidget {
  const BrandDilationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dilations = [0.0, 0.15, 0.20, 0.25, 0.35];
    return Scaffold(
      appBar: AppBar(title: const Text('Seal dilation'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text('Glyph dilation', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Same oracle glyph. Original vs 0.15 / 0.20 / 0.25 / 0.35 px dilation.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          for (final d in dilations) ...[
            AppCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DILATION  ${d.toStringAsFixed(2)} PX',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.brandTextOf(context),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final size in [22.0, 24.0, 30.0]) ...[
                        Column(
                          children: [
                            OracleSeal(size: size, dilation: d),
                            const SizedBox(height: 6),
                            Text(
                              '${size.toInt()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (size != 30) const SizedBox(width: 18),
                      ],
                      const Spacer(),
                      Text(
                        d == 0.0
                            ? 'original / true line art, fades small'
                            : d == 0.15
                                ? 'thinnest / elegant, risks fading'
                                : d == 0.20
                                    ? 'soft middle / good at 24'
                                    : d == 0.25
                                        ? 'balanced / best for 22–24'
                                        : 'boldest / risk of filling',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 8),
          Text(
            'Recommended: 0.20–0.25 for 22–24 px signatures; 0.35 for 30 px or larger. Original 0.0 only for large exhibition use.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
