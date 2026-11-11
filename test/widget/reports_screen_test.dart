// 报表页组件测试：空状态、有数据汇总、分类占比与收支切换、智能建议、大字号不溢出。
// 被测页面：lib/ui/screens/reports_screen.dart（真实 Hive + AppState 注入）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/format.dart';
import 'package:ledger_ai/ui/screens/reports_screen.dart';
import 'package:ledger_ai/ui/theme.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  testWidgets('空月份：汇总为 0、显示空状态与引导', (tester) async {
    await pumpScoped(tester, harness.state, const ReportsScreen());

    expect(find.text('报表'), findsOneWidget);
    expect(find.text('本月结余'), findsOneWidget);
    expect(find.text('共 0 笔记录'), findsOneWidget);
    expect(find.text('这个月还没有账单'), findsOneWidget);
    expect(find.text('近 6 个月趋势'), findsOneWidget);

    // 「分类占比」「智能建议」在首屏下方，滚动后断言。
    await scrollTo(tester, find.text('智能建议'));
    expect(find.text('分类占比'), findsOneWidget);
    expect(find.text('本月还没有支出记录'), findsOneWidget);
    expect(find.text('智能建议'), findsOneWidget);
    expect(find.text('本月还没有记录'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('有数据：收入/支出汇总、分类占比、智能建议', (tester) async {
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
    await pumpScoped(tester, harness.state, const ReportsScreen());

    expect(find.text('共 2 笔记录'), findsOneWidget);
    // 结余 8000 - 42：报表页不强制正号。
    expect(find.text('¥7,958.00'), findsOneWidget);
    expect(find.text('¥8,000.00'), findsOneWidget);
    // 支出金额同时出现在「支出」汇总与分类行。
    expect(find.text('¥42.00'), findsNWidgets(2));
    expect(find.text('这个月还没有账单'), findsNothing);

    // 分类占比与智能建议在首屏下方。
    await scrollTo(tester, find.text('智能建议'));
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    // 无预算 + 分类占比 100% + 有收入高储蓄率 → 至少两条建议。
    expect(find.text('「餐饮」占比偏高'), findsOneWidget);
    expect(find.text('储蓄率不错'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('支出/收入切换会切换分类占比数据', (tester) async {
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
    await pumpScoped(tester, harness.state, const ReportsScreen());

    final incomeSegment = find.descendant(
      of: find.byType(SegmentedButton<bool>),
      matching: find.text('收入'),
    );
    await scrollTo(tester, incomeSegment);
    expect(find.text('总支出'), findsOneWidget);
    expect(find.text('工资'), findsNothing);

    await tester.tap(incomeSegment);
    await tester.pumpAndSettle();

    expect(find.text('总收入'), findsOneWidget);
    expect(find.text('总支出'), findsNothing);
    expect(find.text('工资'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('切到上个月显示对应月份标题', (tester) async {
    await pumpScoped(tester, harness.state, const ReportsScreen());

    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1, 1);

    await tester.tap(find.byTooltip('上个月'));
    await tester.pumpAndSettle();

    expect(find.text(formatMonthLabel(previous.year, previous.month)), findsOneWidget);
    expect(find.text('回到本月'), findsOneWidget);
  });

  testWidgets('200% 大字号下不溢出（浅色 / 深色）', (tester) async {
    await tester.runAsync(() => harness.seed([
      testTxn(
        id: 'income',
        amount: 12345.67,
        categoryId: 'salary',
        isIncome: true,
        date: firstOfThisMonth(),
      ),
      testTxn(id: 'food', amount: 42.5, categoryId: 'food', date: todayAt()),
      testTxn(id: 'transport', amount: 8, categoryId: 'transport', date: todayAt()),
    ]));

    useTextScale(tester, scale: 2.0);
    await pumpScoped(tester, harness.state, const ReportsScreen());
    expectNoLayoutOverflow(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pump();
    expectNoLayoutOverflow(tester);

    // 深色主题同样不溢出。
    await pumpScoped(
      tester,
      harness.state,
      const ReportsScreen(),
      theme: AppTheme.dark(),
    );
    expectNoLayoutOverflow(tester);
  });

  testWidgets('月份切换按钮点击区 ≥ 48dp', (tester) async {
    await pumpScoped(tester, harness.state, const ReportsScreen());

    expectMinTapTarget(tester, find.byTooltip('上个月'), label: '上个月按钮');
    expectMinTapTarget(tester, find.byTooltip('已经是本月'), label: '下个月禁用按钮');
  });

  testWidgets('分类占比与金额语义标签可被读出（VoiceOver 依据）', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.runAsync(() => harness.seed([
      testTxn(id: 'food', amount: 60, categoryId: 'food', date: todayAt()),
      testTxn(id: 'transport', amount: 40, categoryId: 'transport', date: todayAt()),
    ]));
    await pumpScoped(tester, harness.state, const ReportsScreen());

    expect(find.bySemanticsLabel('支出 100.00 元'), findsOneWidget);
    expect(find.bySemanticsLabel('收入 0.00 元'), findsOneWidget);

    await scrollTo(tester, find.text('餐饮'));
    expect(find.bySemanticsLabel('餐饮，60.00 元，占 60%'), findsOneWidget);
    expect(find.bySemanticsLabel('交通，40.00 元，占 40%'), findsOneWidget);
  });
}
