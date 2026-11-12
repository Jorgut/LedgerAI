// 首页组件测试：空状态、有数据概览、预算卡、快速入口跳转、大字号、语义。
// 被测页面：lib/ui/screens/home_screen.dart（真实 Hive + AppState 注入）。
// 注意：统一用 iPhone 390×844 画布；首屏下方内容先 scrollTo 再断言/点击。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/ui/screens/home_screen.dart';
import 'package:ledger_ai/ui/theme.dart';
import 'package:ledger_ai/ui/widgets/common/quick_action_tile.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  testWidgets('空账本：显示 0 结余、空状态与快速入口', (tester) async {
    usePhoneSurface(tester);
    await pumpScoped(tester, harness.state, const HomeScreen());

    expect(find.text('衡账'), findsOneWidget);
    expect(find.text('本月结余'), findsOneWidget);
    expect(find.text('¥0.00'), findsNWidgets(3)); // 结余 / 收入 / 支出
    expect(find.text('快速记账'), findsOneWidget);
    expect(find.text('拍照记账'), findsOneWidget);
    expect(find.text('语音记账'), findsOneWidget);
    expect(find.text('手动记账'), findsOneWidget);
    expect(find.text('设置本月预算'), findsOneWidget);
    expect(find.text('设置预算'), findsOneWidget);

    // 最近记录区在首屏下方。
    await scrollTo(tester, find.text('还没有记录'));
    expect(find.text('还没有记录'), findsOneWidget);
    expect(find.text('记第一笔'), findsOneWidget);
    expect(find.text('最近记录'), findsOneWidget);
    expect(find.text('查看全部'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('有数据：本月收入 / 支出 / 结余与最近记录', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() => harness.seed([
          testTxn(
            id: 'income',
            amount: 8000,
            categoryId: 'salary',
            isIncome: true,
            note: '月薪',
            date: firstOfThisMonth(),
          ),
          testTxn(id: 'food', amount: 42, categoryId: 'food', note: '午餐', date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const HomeScreen());

    expect(find.text('+¥7,958.00'), findsOneWidget); // 结余（带正号）
    expect(find.text('¥8,000.00'), findsOneWidget); // 收入
    expect(find.text('¥42.00'), findsOneWidget); // 支出

    // 最近记录在首屏下方。
    await scrollTo(tester, find.text('最近 2 笔'));
    expect(find.text('最近 2 笔'), findsOneWidget);
    expect(find.text('月薪'), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('还没有记录'), findsNothing);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('设置预算后显示进度与剩余金额', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() async {
      await harness.setPrefs(const AppSettings(monthlyBudget: 6000));
      await harness.seed([
        testTxn(id: 'food', amount: 42, categoryId: 'food', date: todayAt()),
      ]);
    });
    await pumpScoped(tester, harness.state, const HomeScreen());

    expect(find.text('本月预算'), findsOneWidget);
    expect(find.text('已花 ¥42.00'), findsOneWidget);
    expect(find.text('剩余 ¥5,958.00'), findsOneWidget);
    expect(find.text('设置本月预算'), findsNothing);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('快速入口「手动记账」打开记账页', (tester) async {
    usePhoneSurface(tester);
    await pumpScoped(tester, harness.state, const HomeScreen());

    await scrollTo(tester, find.text('手动记账'));
    await tester.tap(find.text('手动记账'));
    await tester.pumpAndSettle();

    expect(find.text('记一笔'), findsOneWidget);
    expect(find.text('保存记录'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('「查看全部」打开账单页', (tester) async {
    usePhoneSurface(tester);
    await pumpScoped(tester, harness.state, const HomeScreen());

    await scrollTo(tester, find.text('查看全部'));
    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();

    expect(find.text('账单'), findsOneWidget);
    expect(find.byTooltip('筛选'), findsOneWidget);
  });

  testWidgets('金额语义标签包含收支方向（VoiceOver）', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() => harness.seed([
          testTxn(
            id: 'income',
            amount: 8000,
            categoryId: 'salary',
            isIncome: true,
            date: firstOfThisMonth(),
          ),
          testTxn(id: 'food', amount: 42, categoryId: 'food', date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const HomeScreen());

    expectSemanticsLabel('本月结余 ¥7,958.00 元');
    expectSemanticsLabel('本月收入 ¥8,000.00 元');
    expectSemanticsLabel('本月支出 ¥42.00 元');
  });

  testWidgets('200% 大字号下不溢出（浅色 / 深色）', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 123456.78, categoryId: 'food', date: todayAt()),
        ]));
    useTextScale(tester, scale: 2.0);

    await pumpScoped(tester, harness.state, const HomeScreen());
    expectNoLayoutOverflow(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pump();
    expectNoLayoutOverflow(tester);

    await pumpScoped(
      tester,
      harness.state,
      const HomeScreen(),
      theme: AppTheme.dark(),
    );
    expectNoLayoutOverflow(tester);
  });

  testWidgets('快速入口整块点击区 ≥ 48dp', (tester) async {
    usePhoneSurface(tester);
    await pumpScoped(tester, harness.state, const HomeScreen());

    final tiles = find.byType(QuickActionTile);
    expect(tiles, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      expectMinTapTarget(tester, tiles.at(i), label: '快速记账入口 $i');
    }
  });
}
