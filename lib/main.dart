import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_state.dart';
import 'core/demo_data.dart';
import 'core/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.create();

  // 商店截图模式：`flutter run --dart-define=DEMO=true`，只在空账本时写入示例数据。
  if (AppState.isDemo) {
    const demoLanguage = String.fromEnvironment('DEMO_LANGUAGE');
    await DemoData.seedIfEmpty(state.repo, english: demoLanguage == 'en');
    await DemoData.seedSettings(state.settings);
    if (demoLanguage.isNotEmpty) {
      final language = AppLanguage.values.firstWhere(
        (l) => l.name == demoLanguage,
        orElse: () => AppLanguage.system,
      );
      await state.settings
          .update(state.settings.value.copyWith(language: language));
    }
    const demoFontScale = String.fromEnvironment('DEMO_FONT_SCALE');
    if (demoFontScale.isNotEmpty) {
      final scale = double.tryParse(demoFontScale);
      if (scale != null) {
        await state.settings.update(
          state.settings.value.copyWith(fontScale: scale),
        );
      }
    }
    const demoTheme = String.fromEnvironment('DEMO_THEME');
    const demoColorTheme = String.fromEnvironment('DEMO_COLOR_THEME');
    if (demoTheme.isNotEmpty || demoColorTheme.isNotEmpty) {
      final themeMode = demoTheme == 'dark'
          ? ThemeMode.dark
          : demoTheme == 'light'
              ? ThemeMode.light
              : state.settings.value.themeMode;
      final colorTheme = demoColorTheme.isEmpty
          ? state.settings.value.colorTheme
          : AppColorTheme.values.firstWhere(
              (c) => c.name == demoColorTheme,
              orElse: () => AppColorTheme.fresh,
            );
      await state.settings.update(state.settings.value.copyWith(
        themeMode: themeMode,
        colorTheme: colorTheme,
      ));
    }
  }

  runApp(AppScope(state: state, child: const LedgerApp()));
}
