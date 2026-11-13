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
    await DemoData.seedIfEmpty(state.repo);
    await DemoData.seedSettings(state.settings);
    const demoLanguage = String.fromEnvironment('DEMO_LANGUAGE');
    if (demoLanguage.isNotEmpty) {
      final language = AppLanguage.values.firstWhere(
        (l) => l.name == demoLanguage,
        orElse: () => AppLanguage.system,
      );
      await state.settings
          .update(state.settings.value.copyWith(language: language));
    }
  }

  runApp(AppScope(state: state, child: const LedgerApp()));
}
