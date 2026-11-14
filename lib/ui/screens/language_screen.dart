import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_settings.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/common/app_card.dart';

/// Dedicated language picker. Keeping this out of Settings makes the page
/// quieter and gives each language a full row with its native name.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _select(BuildContext context, AppLanguage language) async {
    await AppScope.read(context).updateSettingsWith(
      (settings) => settings.copyWith(language: language),
    );
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final current = app.prefs.language;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.language), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pageInsets,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final language in AppLanguage.values) ...[
                    _LanguageRow(
                      language: language,
                      label: language == AppLanguage.system
                          ? l10n.followSystem
                          : language.nativeLabel,
                      selected: current == language,
                      onTap: () => _select(context, language),
                    ),
                    if (language != AppLanguage.values.last)
                      Divider(
                        height: 1,
                        indent: 56,
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
                l10n.languageMigrationNote,
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

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  String get _code => switch (language) {
        AppLanguage.system => 'A',
        AppLanguage.zhHans => '简',
        AppLanguage.zhHant => '繁',
        AppLanguage.en => 'EN',
        AppLanguage.ru => 'RU',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 32,
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          _code,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
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
