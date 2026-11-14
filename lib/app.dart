import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ai/parsing.dart';
import 'core/app_state.dart';
import 'l10n/app_localizations.dart';
import 'ui/brand_intro.dart';
import 'ui/screens/add_transaction_screen.dart';
import 'ui/screens/budget_screen.dart';
import 'ui/screens/brand_lockup_demo.dart';
import 'ui/screens/brand_dilation_demo.dart';
import 'ui/screens/split_demo_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/root_shell.dart';
import 'ui/theme.dart';

/// 应用根组件。主题与首次引导状态通过设置通知驱动，
/// 业务数据变化由各页面通过 [AppScope] 自行订阅。
class LedgerApp extends StatelessWidget {
  const LedgerApp({super.key});

  /// 商店截图模式（`--dart-define=DEMO_SCREEN=...`）：直接打开指定页面，
  /// 仅供本地截图/验收，正式包不设置该变量。
  static const String _demoScreen = String.fromEnvironment('DEMO_SCREEN');

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    return AnimatedBuilder(
      animation: state.settings,
      builder: (context, _) {
        final prefs = state.prefs;
        final effectiveLocale = prefs.language.locale ??
            WidgetsBinding.instance.platformDispatcher.locale;
        Intl.defaultLocale = effectiveLocale.toLanguageTag();
        final highContrast = prefs.highContrast || prefs.elderMode;
        return MaterialApp(
          title: 'HENG',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
              highContrast: highContrast, colorTheme: prefs.colorTheme),
          darkTheme: AppTheme.dark(
              highContrast: highContrast, colorTheme: prefs.colorTheme),
          themeMode: prefs.themeMode,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            var chosenScale = prefs.fontScale;
            if (prefs.elderMode && chosenScale < 1.3) chosenScale = 1.3;
            final systemFactor = media.textScaler.scale(16) / 16;
            // 应用内字号作为倍率叠加到系统字号上，同时尊重系统级无障碍放大。
            final effective = chosenScale * systemFactor;
            if ((effective - systemFactor).abs() < 0.001) return child!;
            return MediaQuery(
              data: media.copyWith(textScaler: TextScaler.linear(effective)),
              child: child!,
            );
          },
          locale: prefs.language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _buildRoot(prefs.onboardingDone),
        );
      },
    );
  }

  Widget _buildRoot(bool onboardingDone) {
    if (AppState.isDemo && _demoScreen == 'intro') {
      return BrandIntro(onFinished: _noop);
    }
    final child = _buildHome(onboardingDone);
    final skipIntro = AppState.isDemo && _demoScreen.isNotEmpty;
    return BrandIntroGate(enabled: !skipIntro, child: child);
  }

  Widget _buildHome(bool onboardingDone) {
    if (!onboardingDone) {
      return const OnboardingScreen(onDone: _noop);
    }
    if (!AppState.isDemo || _demoScreen.isEmpty) {
      return const RootShell();
    }
    switch (_demoScreen) {
      case 'onboarding':
        return const OnboardingScreen(onDone: _noop);
      case 'transactions':
        return const RootShell(initialIndex: 1);
      case 'reports':
        return const RootShell(initialIndex: 2);
      case 'reports2':
        return const RootShell(
          initialIndex: 2,
          showFab: false,
          reportsInitialScrollOffset: 430,
        );
      case 'settings':
        return const RootShell(initialIndex: 3, showFab: false);
      case 'settings2':
        return const RootShell(
          initialIndex: 3,
          showFab: false,
          settingsInitialScrollOffset: 260,
        );
      case 'budget':
        return const BudgetScreen();
      case 'brand_lockup':
        return const BrandLockupDemo();
      case 'brand_dilation':
        return const BrandDilationDemo();
      case 'trip':
        return const SplitDemoScreen();
      case 'home_split':
        return const RootShell(splitPreview: true);
      case 'add':
        return const AddTransactionScreen();
      case 'add_receipt':
        return AddTransactionScreen(
          initialReceipt: _demoReceipt,
          initialMode: AddTransactionMode.receipt,
        );
      case 'add_parsed':
        return AddTransactionScreen(initialReceipt: _demoReceipt);
      case 'add_voice':
        return const AddTransactionScreen(
            initialMode: AddTransactionMode.voice);
      default:
        return const RootShell();
    }
  }

  static ParsedReceipt get _demoReceipt {
    const english = String.fromEnvironment('DEMO_LANGUAGE') == 'en';
    return ParsedReceipt(
      amount: 42,
      merchant: english ? "McDonald's" : '麦当劳',
      categoryId: 'food',
      note: english ? 'Lunch · McDonald\'s' : '午餐 · 麦当劳',
      rawText: english
          ? 'McDonald\'s (Wanda)\n2026-11-12 12:30\nBig Mac meal ¥32.00\nFries ¥10.00\nTotal ¥42.00'
          : '麦当劳（万达店）\n2026-11-12 12:30\n巨无霸套餐 ¥32.00\n薯条 ¥10.00\n合计 ¥42.00',
    );
  }

  static void _noop() {}
}
