import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/brand_mark.dart';

/// 品牌落款比例对照（仅 demo/设计评审使用）。
class BrandLockupDemo extends StatelessWidget {
  const BrandLockupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Brand lockup'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(
            'Three ratios',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'The wordmark stays 42 px. The seal is either equal to the capital height, or a small baseline signature.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _LockupCard(
            label: '01  MATCH CAP HEIGHT',
            note: 'Seal height = HENG cap height · top & bottom aligned',
            child: const BrandMark(wordSize: 42, matchCapHeight: true),
          ),
          const SizedBox(height: 14),
          _LockupCard(
            label: '02  BASELINE / 24 PX',
            note: 'Seal bottom on HENG baseline · signature scale',
            child: const BrandMark(wordSize: 42, sealSize: 24),
          ),
          const SizedBox(height: 14),
          _LockupCard(
            label: '03  BASELINE / 22 PX',
            note: 'Smaller signature · bottom on HENG baseline',
            child: const BrandMark(wordSize: 42, sealSize: 22),
          ),
          const SizedBox(height: 24),
          Text(
            'HENG remains brand ink. The seal follows the active theme gradient.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockupCard extends StatelessWidget {
  const _LockupCard({
    required this.label,
    required this.note,
    required this.child,
  });

  final String label;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.brandTextOf(context),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 12),
          Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
