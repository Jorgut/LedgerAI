// 预算页组件测试：空状态、总预算设置 / 清除、分类预算设置、200% 字号、点击区。
// 被测页面：lib/ui/screens/budget_screen.dart（真实 Hive + AppState 注入）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/ui/screens/budget_screen.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  testWidgets('未设置预算：空状态、分类预算列表与说明', (tester) async {
    await pumpScoped(tester, harness.state, const BudgetScreen());

    expect(find.text('预算'), findsOneWidget);
    expect(find.text('还没有设置月度预算'), findsOneWidget);
    expect(find.text('设置月度预算'), findsOneWidget);
    expect(find.text('分类预算'), findsOneWidget);
    expect(find.text('点击分类设置'), findsOneWidget);
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('交通'), findsOneWidget);

    // 说明卡片在 10 个分类行之后，先滚到底再断言。
    final note = find.text('预算只用于本机提醒，不会限制消费；分类预算之和可以超过总预算。');
    await scrollTo(tester, note);
    expect(note, findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('通过底部弹窗设置月度预算并写回设置', (tester) async {
    await pumpScoped(tester, harness.state, const BudgetScreen());

    await tester.tap(find.text('设置月度预算'));
    await pumpFrames(tester);
    expect(find.text('设置月度总预算'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3000');
    await tester.tap(find.text('保存'));
    await pumpFrames(tester);

    await waitUntil(
      tester,
      () => harness.state.prefs.monthlyBudget == 3000,
      reason: '月度预算写入 Hive',
    );
    await pumpFrames(tester);

    expect(find.text('本月总预算'), findsOneWidget);
    expect(find.text('¥3,000.00'), findsOneWidget);
    expect(find.text('月度预算已更新'), findsOneWidget);
  });

  testWidgets('非法金额提示且不写入设置', (tester) async {
    await pumpScoped(tester, harness.state, const BudgetScreen());

    await tester.tap(find.text('设置月度预算'));
    await pumpFrames(tester);
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('保存'));
    await pumpFrames(tester);

    expect(find.text('请输入大于 0 的金额，例如 3000'), findsOneWidget);
    expect(harness.state.prefs.monthlyBudget, isNull);
  });

  testWidgets('已设置预算：展示进度与支出统计', (tester) async {
    await tester.runAsync(() async {
      await harness.setPrefs(const AppSettings(
        monthlyBudget: 6000,
        categoryBudgets: {'food': 2000},
      ));
      await harness.seed([
        testTxn(id: 'food', amount: 42, categoryId: 'food', date: todayAt()),
      ]);
    });
    await pumpScoped(tester, harness.state, const BudgetScreen());

    expect(find.text('本月总预算'), findsOneWidget);
    expect(find.text('¥6,000.00'), findsOneWidget);
    expect(find.text('本月已支出 ¥42.00，共 1 笔'), findsOneWidget);
    expect(find.text('编辑预算'), findsOneWidget);
    expect(find.text('清除预算'), findsOneWidget);
    expect(find.text('预算 ¥2,000.00 · 已支出 ¥42.00（2%）'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('清除月度预算需确认，确认后回到空状态', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(monthlyBudget: 6000)),
    );
    await pumpScoped(tester, harness.state, const BudgetScreen());

    await tester.tap(find.text('清除预算'));
    await pumpFrames(tester);
    expect(find.text('清除月度预算？'), findsOneWidget);

    await tester.tap(find.text('清除'));
    await pumpFrames(tester);
    await waitUntil(
      tester,
      () => harness.state.prefs.monthlyBudget == null,
      reason: '清除月度预算写入 Hive',
    );
    await pumpFrames(tester);

    expect(find.text('已清除月度预算'), findsOneWidget);
    expect(find.text('还没有设置月度预算'), findsOneWidget);
  });

  testWidgets('点击分类设置分类预算并持久化', (tester) async {
    await pumpScoped(tester, harness.state, const BudgetScreen());

    await tester.tap(find.text('餐饮'));
    await pumpFrames(tester);
    expect(find.text('设置「餐饮」预算'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '2000');
    await tester.tap(find.text('保存'));
    await pumpFrames(tester);

    await waitUntil(
      tester,
      () => harness.state.prefs.categoryBudgets['food'] == 2000,
      reason: '分类预算写入 Hive',
    );
    await pumpFrames(tester);

    expect(find.text('「餐饮」预算已更新'), findsOneWidget);
    expect(find.text('预算 ¥2,000.00 · 已支出 ¥0.00（0%）'), findsOneWidget);
  });

  testWidgets('200% 大字号下可滚动且不溢出', (tester) async {
    await tester.runAsync(() async {
      await harness.setPrefs(const AppSettings(
        monthlyBudget: 6000,
        categoryBudgets: {'food': 2000},
      ));
      await harness.seed([
        testTxn(id: 'food', amount: 42, categoryId: 'food', date: todayAt()),
      ]);
    });
    useTextScale(tester, scale: 2.0);
    await pumpScoped(tester, harness.state, const BudgetScreen());
    expectNoLayoutOverflow(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pump();
    expectNoLayoutOverflow(tester);
  });

  testWidgets('预算操作按钮与分类行点击区 ≥ 48dp', (tester) async {
    await tester.runAsync(
      () => harness.setPrefs(const AppSettings(monthlyBudget: 6000)),
    );
    await pumpScoped(tester, harness.state, const BudgetScreen());

    expectMinTapTarget(
      tester,
      find.widgetWithText(OutlinedButton, '编辑预算'),
      label: '编辑预算按钮',
    );
    expectMinTapTarget(
      tester,
      find.ancestor(of: find.text('餐饮'), matching: find.byType(InkWell)).first,
      label: '餐饮分类预算行',
    );
  });
}
