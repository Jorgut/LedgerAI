import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_state.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/root_shell.dart';
import 'ui/theme.dart';

/// 应用根组件。主题与首次引导状态通过设置通知驱动，
/// 业务数据变化由各页面通过 [AppScope] 自行订阅。
class LedgerApp extends StatelessWidget {
  const LedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    return AnimatedBuilder(
      animation: state.settings,
      builder: (context, _) {
        final prefs = state.prefs;
        return MaterialApp(
          title: '衡账',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(highContrast: prefs.highContrast),
          darkTheme: AppTheme.dark(highContrast: prefs.highContrast),
          themeMode: prefs.themeMode,
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: prefs.onboardingDone
              ? const RootShell()
              : const OnboardingScreen(onDone: _noop),
        );
      },
    );
  }

  static void _noop() {}
}
