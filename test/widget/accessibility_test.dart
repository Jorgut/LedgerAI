// 无障碍专项测试：关键点击区、大字号 + 高对比度、VoiceOver 语义标签。
// 依据 ACCESSIBILITY.md：主要按钮 ≥ 48dp、大字不溢出、金额/收支方向可朗读。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/app.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/app_state.dart';
import 'package:ledger_ai/ui/screens/reports_screen.dart';
import 'package:ledger_ai/ui/screens/transactions_screen.dart';
import 'package:ledger_ai/ui/theme.dart';
import 'package:ledger_ai/ui/widgets/common/quick_action_tile.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  Finder navLabel(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  testWidgets('关键按钮 / 入口点击区 ≥ 48dp', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(
          onboardingDone: true, language: AppLanguage.zhHans)),
    );
    usePhoneSurface(tester);
    await tester.pumpWidget(
      AppScope(state: harness.state, child: const LedgerApp()),
    );
    await tester.pumpAndSettle();

    // 首页：FAB 与三个快速入口。
    expectMinTapTarget(tester, find.byTooltip('记一笔'), label: '记一笔 FAB');
    final tiles = find.byType(QuickActionTile);
    expect(tiles, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      expectMinTapTarget(tester, tiles.at(i), label: '快速入口 $i');
    }

    // 账单页：筛选与月份切换。
    await tester.tap(navLabel('账单'));
    await tester.pumpAndSettle();
    expectMinTapTarget(tester, find.byTooltip('筛选'), label: '账单筛选');
    expectMinTapTarget(tester, find.byTooltip('上个月'), label: '账单上个月');

    // 报表页：月份切换。
    await tester.tap(navLabel('报表'));
    await tester.pumpAndSettle();
    expectMinTapTarget(tester, find.byTooltip('上个月'), label: '报表上个月');

    // 设置页：开关与列表入口。
    await tester.tap(navLabel('我的'));
    await tester.pumpAndSettle();
    expectMinTapTarget(
      tester,
      find.widgetWithText(SwitchListTile, '高对比度'),
      label: '高对比度开关',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(ListTile, '预算管理'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expectMinTapTarget(
      tester,
      find.widgetWithText(ListTile, '预算管理'),
      label: '预算管理入口',
    );
  });

  testWidgets('200% 大字号 + 高对比度（深色 / 浅色）下四个 Tab 均不溢出', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(
        onboardingDone: true,
        language: AppLanguage.zhHans,
        highContrast: true,
        themeMode: ThemeMode.dark,
      )),
    );
    useTextScale(tester, scale: 2.0);
    usePhoneSurface(tester);
    await tester.pumpWidget(
      AppScope(state: harness.state, child: const LedgerApp()),
    );
    await tester.pumpAndSettle();
    expectNoLayoutOverflow(tester);

    for (final tab in ['账单', '报表', '我的', '首页']) {
      await tester.tap(navLabel(tab));
      await tester.pumpAndSettle();
      expectNoLayoutOverflow(tester);
    }

    // 浅色 + 高对比度同样检查首页与报表。
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(
        onboardingDone: true,
        language: AppLanguage.zhHans,
        highContrast: true,
        themeMode: ThemeMode.light,
      )),
    );
    await tester.pumpAndSettle();
    expectNoLayoutOverflow(tester);

    await tester.tap(navLabel('报表'));
    await tester.pumpAndSettle();
    expectNoLayoutOverflow(tester);
  });

  testWidgets('交易行语义标签朗读备注、分类、收支方向与日期', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(
              id: 'food',
              amount: 42,
              categoryId: 'food',
              note: '午餐',
              date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    expectSemanticsLabel('午餐，餐饮，支出 42.00 元，今天');
  });

  testWidgets('报表环形图提供等价语义标签', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 42, categoryId: 'food', date: todayAt()),
        ]));
    await pumpScoped(
      tester,
      harness.state,
      const ReportsScreen(),
      theme: AppTheme.light(highContrast: true),
    );

    await scrollTo(tester, find.text('餐饮'));
    expectSemanticsLabel('分类占比环形图，总支出 ¥42.00');
  });
}
