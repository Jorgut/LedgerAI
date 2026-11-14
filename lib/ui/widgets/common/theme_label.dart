import '../../../core/app_settings.dart';
import '../../../l10n/app_localizations.dart';

String localizedThemeLabel(AppLocalizations l10n, AppColorTheme theme) =>
    switch (theme) {
      AppColorTheme.fresh => l10n.themeFresh,
      AppColorTheme.forest => l10n.themeForest,
      AppColorTheme.freshForest => l10n.themeFreshForest,
      AppColorTheme.blush => l10n.themeBlush,
      AppColorTheme.peach => l10n.themePeach,
      AppColorTheme.lavender => l10n.themeLavender,
    };
