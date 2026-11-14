// 设置页组件测试：偏好开关写回、导出空数据提示、两次确认清空数据、大字号与点击区。
// 被测页面：lib/ui/screens/settings_screen.dart（真实 Hive + AppState 注入）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/ui/screens/settings_screen.dart';
import 'package:ledger_ai/ui/theme.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  /// 设置页是长列表，目标可能在屏幕外：先滚动到可见。
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('渲染外观 / 通用 / 数据 / 关于与版本号', (tester) async {
    await pumpScoped(tester, harness.state, const SettingsScreen());

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('浅色'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(find.text('高对比度'), findsOneWidget);
    expect(find.text('触觉反馈'), findsOneWidget);
    expect(find.text('预算管理'), findsOneWidget);
    expect(find.text('数据（只保存在本机）'), findsOneWidget);
    expectNoLayoutOverflow(tester);

    // 数据区在首屏下方。
    await scrollTo(tester, find.text('清空全部账单'));
    expect(find.text('导出 CSV 表格'), findsOneWidget);
    expect(find.text('导出 JSON 备份'), findsOneWidget);
    expect(find.text('清空全部账单'), findsOneWidget);

    await scrollTo(tester, find.text('用户协议'));
    expect(find.text('关于'), findsOneWidget);
    expect(find.text('HENG'), findsOneWidget);
    expect(find.textContaining('1.1.0'), findsWidgets);
    expect(find.text('不登录'), findsOneWidget);
    expect(find.text('不联网'), findsOneWidget);
    expect(find.text('不上传'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('用户协议'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('高对比度开关写回设置并持久化', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(onboardingDone: true)),
    );
    await pumpScoped(tester, harness.state, const SettingsScreen());
    expect(harness.state.prefs.highContrast, isFalse);

    await tester.tap(find.text('高对比度'));
    await pumpFrames(tester);

    // SettingsStore.update 会同步更新内存值，落盘在后台。
    expect(harness.state.prefs.highContrast, isTrue);
    await waitUntil(
      tester,
      () => harness.store.settings.value.highContrast,
      reason: '高对比度写入 Hive',
    );
    await pumpFrames(tester);
    expect(harness.store.settings.value.highContrast, isTrue);
  });

  testWidgets('触觉反馈开关写回设置', (tester) async {
    await pumpScoped(tester, harness.state, const SettingsScreen());
    expect(harness.state.prefs.hapticsEnabled, isTrue);

    await tester.tap(find.text('触觉反馈'));
    await tester.pumpAndSettle();

    expect(harness.state.prefs.hapticsEnabled, isFalse);
    await waitUntil(
      tester,
      () => !harness.store.settings.value.hapticsEnabled,
      reason: '触觉开关写入 Hive',
    );
  });

  testWidgets('主题切换写回 ThemeMode', (tester) async {
    await pumpScoped(tester, harness.state, const SettingsScreen());
    expect(harness.state.prefs.themeMode, ThemeMode.system);

    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(harness.state.prefs.themeMode, ThemeMode.dark);

    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle();
    expect(harness.state.prefs.themeMode, ThemeMode.light);
  });

  testWidgets('无数据时导出 CSV 给出中文提示且不调用分享插件', (tester) async {
    await pumpScoped(tester, harness.state, const SettingsScreen());

    await scrollTo(tester, find.text('导出 CSV 表格'));
    await tester.tap(find.text('导出 CSV 表格'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('还没有账单数据，先记一笔再导出'), findsOneWidget);
  });

  testWidgets('清空全部账单需两次确认，且保留设置', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(monthlyBudget: 6000)),
    );
    await seedAsync(tester, harness, [
      testTxn(id: 'a', amount: 42, note: '午餐', date: todayAt()),
    ]);
    await pumpScoped(tester, harness.state, const SettingsScreen());
    expect(harness.state.transactions, hasLength(1));

    await scrollTo(tester, find.text('清空全部账单'));
    await tester.tap(find.text('清空全部账单'));
    await tester.pumpAndSettle();

    expect(find.text('清空全部账单？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();

    expect(find.text('最后确认'), findsOneWidget);
    await tester.tap(find.text('确认清空'));
    await tester.pumpAndSettle();

    await waitUntil(
      tester,
      () => harness.state.transactions.isEmpty,
      reason: '账单清空',
    );
    await pumpFrames(tester);
    expect(find.text('已清空全部账单'), findsOneWidget);
    // 设置与预算保留。
    expect(harness.store.settings.value.monthlyBudget, 6000);
  });

  testWidgets('取消第一次确认不会删除数据', (tester) async {
    await seedAsync(tester, harness, [testTxn(id: 'a', date: todayAt())]);
    await pumpScoped(tester, harness.state, const SettingsScreen());

    await scrollTo(tester, find.text('清空全部账单'));
    await tester.tap(find.text('清空全部账单'));
    await tester.pumpAndSettle();
    expect(find.text('清空全部账单？'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.text('清空全部账单？'), findsNothing);
    expect(harness.state.transactions, hasLength(1));
  });

  testWidgets('200% 大字号下可滚动且不溢出（浅色 / 深色）', (tester) async {
    useTextScale(tester, scale: 2.0);
    await pumpScoped(tester, harness.state, const SettingsScreen());
    expectNoLayoutOverflow(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pump();
    expectNoLayoutOverflow(tester);

    await pumpScoped(
      tester,
      harness.state,
      const SettingsScreen(),
      theme: AppTheme.dark(),
    );
    expectNoLayoutOverflow(tester);
  });

  testWidgets('开关与主要列表项点击区 ≥ 48dp', (tester) async {
    await pumpScoped(tester, harness.state, const SettingsScreen());

    expectMinTapTarget(
      tester,
      find.widgetWithText(SwitchListTile, '高对比度'),
      label: '高对比度开关',
    );
    expectMinTapTarget(
      tester,
      find.widgetWithText(SwitchListTile, '触觉反馈'),
      label: '触觉反馈开关',
    );
    expectMinTapTarget(
      tester,
      find.widgetWithText(ListTile, '预算管理'),
      label: '预算管理入口',
    );
  });
}
