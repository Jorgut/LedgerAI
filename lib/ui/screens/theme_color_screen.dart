import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_settings.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../color_themes.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/theme_label.dart';

/// Dedicated theme picker with visual palette previews.
class ThemeColorScreen extends StatelessWidget {
  const ThemeColorScreen({super.key});

  Future<void> _select(BuildContext context, AppColorTheme theme) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(colorTheme: theme),
    );
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final current = AppScope.of(context).prefs.colorTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pageInsets,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final option in AppColorTheme.values) ...[
                    _ThemeRow(
                      option: option,
                      label: localizedThemeLabel(l10n, option),
                      selected: current == option,
                      onTap: () => _select(context, option),
                    ),
                    if (option != AppColorTheme.values.last)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.themeColorNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.option,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppColorTheme option;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = HengPalette.forTheme(option, theme.brightness);
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 48,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              bottom: 8,
              child: _Dot(color: palette.primaryDark),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: _Dot(color: palette.accent),
            ),
            _Dot(color: palette.primary, size: 16),
          ],
        ),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
