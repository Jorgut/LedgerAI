// 应用壳集成式组件测试：首次引导、四个 Tab、FAB 记账闭环、保存后首页/账单同步。
// 被测组件：lib/app.dart（LedgerApp）+ lib/ui/screens/root_shell.dart，真实 AppState + Hive。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/app.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/app_state.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  /// 启动完整 App（LedgerApp 自带 MaterialApp，因此只在外层包 AppScope）。
  Future<void> pumpApp(WidgetTester tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(
      AppScope(state: harness.state, child: const LedgerApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('首次启动显示引导，「跳过」后进入首页并写入设置', (tester) async {
    await pumpApp(tester);

    expect(find.text('跳过'), findsOneWidget);
    expect(find.textContaining('只在你手机里'), findsOneWidget);
    expect(find.text('本月结余'), findsNothing);

    await tester.tap(find.text('跳过'));
    await waitUntil(
      tester,
      () => find.text('本月结余').evaluate().isNotEmpty,
      reason: '引导完成并进入首页',
    );
    await pumpFrames(tester);
    expect(harness.state.prefs.onboardingDone, isTrue);

    expect(find.text('本月结余'), findsOneWidget);
    expect(find.text('快速记账'), findsOneWidget);
  });

  testWidgets('四个 Tab 可切换且显示各自页面', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(onboardingDone: true)),
    );
    await pumpApp(tester);

    expect(find.text('本月结余'), findsOneWidget);

    Finder navLabel(String label) => find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );

    await tester.tap(navLabel('账单'));
    await tester.pumpAndSettle();
    expect(find.text('搜索备注、商户、分类或金额'), findsOneWidget);

    await tester.tap(navLabel('报表'));
    await tester.pumpAndSettle();
    expect(find.text('近 6 个月趋势'), findsOneWidget);

    await tester.tap(navLabel('我的'));
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('高对比度'), findsOneWidget);

    await tester.tap(navLabel('首页'));
    await tester.pumpAndSettle();
    expect(find.text('本月结余'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('FAB 记一笔：保存后首页最近记录与账单列表都出现', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(onboardingDone: true)),
    );
    await pumpApp(tester);

    expect(find.text('还没有记录'), findsOneWidget);

    await tester.tap(find.byTooltip('记一笔'));
    await tester.pumpAndSettle();
    expect(find.text('保存记录'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '42.5');
    await tester.tap(find.text('保存记录'));
    await waitUntil(
      tester,
      () => harness.state.transactions.isNotEmpty,
      reason: '保存一笔记录',
    );
    await pumpFrames(tester);

    // 回到首页：最近记录出现。
    expect(find.text('最近 1 笔'), findsOneWidget);
    expect(find.text('餐饮'), findsOneWidget);

    // 账单 Tab：分组列表出现该笔记录。
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('账单'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('餐饮'), findsWidgets);
    expect(find.text('-¥42.50'), findsOneWidget);
    expect(harness.state.transactions.single.amount, 42.5);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('200% 大字号下四个 Tab 均不溢出', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(onboardingDone: true)),
    );
    useTextScale(tester, scale: 2.0);
    await pumpApp(tester);
    expectNoLayoutOverflow(tester);

    Finder navLabel(String label) => find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );

    for (final tab in ['账单', '报表', '我的', '首页']) {
      await tester.tap(navLabel(tab));
      await tester.pumpAndSettle();
      expectNoLayoutOverflow(tester);
    }
  });
}
