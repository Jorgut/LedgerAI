import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/section_header.dart';
import '../../l10n/app_localizations.dart';

/// 分账概念页（仅 demo/宣发使用；正式数据模型在 1.2 接入）。
class SplitDemoScreen extends StatelessWidget {
  const SplitDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kyoto · 4 travelers'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Trip settings',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          _TripHero(theme: theme),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Who owes whom',
            subtitle: 'Equal split · 4 people',
            trailing: TextButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context).splitSettleUp),
            ),
          ),
          Card(
            child: Column(
              children: const [
                _SettleRow(from: 'A', to: 'D', amount: 750),
                Divider(height: 1, indent: 16, endIndent: 16),
                _SettleRow(from: 'B', to: 'D', amount: 2550),
                Divider(height: 1, indent: 16, endIndent: 16),
                _SettleRow(from: 'C', to: 'D', amount: 1350),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Shared expenses',
            subtitle: '4 entries · ¥13,400',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Add'),
            ),
          ),
          Card(
            child: Column(
              children: const [
                _ExpenseRow(
                  initial: 'A',
                  title: 'Hotel',
                  payer: 'A paid',
                  amount: 2600,
                  icon: Icons.hotel_rounded,
                ),
                Divider(height: 1, indent: 64, endIndent: 16),
                _ExpenseRow(
                  initial: 'B',
                  title: 'Car rental',
                  payer: 'B paid',
                  amount: 800,
                  icon: Icons.directions_car_rounded,
                ),
                Divider(height: 1, indent: 64, endIndent: 16),
                _ExpenseRow(
                  initial: 'C',
                  title: 'Dinner',
                  payer: 'C paid',
                  amount: 2000,
                  icon: Icons.restaurant_rounded,
                ),
                Divider(height: 1, indent: 64, endIndent: 16),
                _ExpenseRow(
                  initial: 'D',
                  title: 'Flights',
                  payer: 'D paid',
                  amount: 8000,
                  icon: Icons.flight_takeoff_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded, color: AppTheme.brandTextOf(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invite via iCloud link. Everyone sees the same trip, no account needed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripHero extends StatelessWidget {
  const _TripHero({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.brandGradientOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'KYOTO · NOV 12–18',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Avatar(label: 'A'),
              _Avatar(label: 'B', overlap: true),
              _Avatar(label: 'C', overlap: true),
              _Avatar(label: 'D', overlap: true),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Total spent',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(13400),
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _HeroStat(label: 'Per person', value: '¥3,350.00'),
              ),
              Container(width: 1, height: 34, color: Colors.white24),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: _HeroStat(label: 'Settled', value: '3 of 4'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label, this.overlap = false});
  final String label;
  final bool overlap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }
}

class _SettleRow extends StatelessWidget {
  const _SettleRow({required this.from, required this.to, required this.amount});
  final String from;
  final String to;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: Text(from, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
      ),
      title: Text('$from → $to', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text('Equal split'),
      trailing: Text(
        formatMoney(amount),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.initial,
    required this.title,
    required this.payer,
    required this.amount,
    required this.icon,
  });
  final String initial;
  final String title;
  final String payer;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$payer · split 4 ways'),
      trailing: Text(
        formatMoney(amount),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
