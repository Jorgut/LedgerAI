// 账单页组件测试：空状态、分组列表、搜索筛选、左滑删除与撤销、点击编辑、大字号、点击区。
// 被测页面：lib/ui/screens/transactions_screen.dart（真实 Hive + AppState 注入）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ui/screens/transactions_screen.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  String currentMonthEmptyTitle() {
    final now = DateTime.now();
    return '${now.month}月还没有记录';
  }

  testWidgets('本月无记录：空状态 + 搜索框 + 筛选入口', (tester) async {
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    expect(find.text('账单'), findsOneWidget);
    expect(find.text(currentMonthEmptyTitle()), findsOneWidget);
    expect(find.text('记一笔'), findsOneWidget);
    expect(find.text('搜索备注、商户、分类或金额'), findsOneWidget);
    expect(find.byTooltip('筛选'), findsOneWidget);
    expect(find.byTooltip('上个月'), findsOneWidget);
    expect(find.byTooltip('已经是本月'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('有数据：按日分组、收支金额与筛选筛选', (tester) async {
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
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    expect(find.text(currentMonthEmptyTitle()), findsNothing);
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('月薪'), findsOneWidget);
    expect(find.text('-¥42.00'), findsOneWidget);
    expect(find.text('+¥8,000.00'), findsOneWidget);
    expect(find.text('支出 ¥42.00'), findsOneWidget);
    expectNoLayoutOverflow(tester);
  });

  testWidgets('搜索关键词只保留匹配记录，无结果给空状态', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 42, categoryId: 'food', note: '午餐', date: todayAt()),
          testTxn(id: 'taxi', amount: 35, categoryId: 'transport', note: '打车', date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    await tester.enterText(find.byType(TextField), '午餐');
    await tester.pumpAndSettle();

    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('打车'), findsNothing);
    expect(find.byTooltip('清除搜索'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '不存在的关键词');
    await tester.pumpAndSettle();
    expect(find.text('没有符合条件的记录'), findsOneWidget);

    await tester.tap(find.byTooltip('清除搜索'));
    await tester.pumpAndSettle();
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('打车'), findsOneWidget);
  });

  testWidgets('左滑删除后可从 SnackBar 撤销', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 42, categoryId: 'food', note: '午餐', date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    await tester.drag(
      find.byKey(const ValueKey<String>('txn-food')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await waitUntil(
      tester,
      () => harness.state.transactions.isEmpty,
      reason: '左滑删除写入 Hive',
    );
    await tester.pumpAndSettle();

    expect(find.text('已删除「餐饮」¥42.00'), findsOneWidget);
    expect(find.text('撤销'), findsOneWidget);

    await tester.tap(find.text('撤销'));
    await waitUntil(
      tester,
      () => harness.state.transactions.isNotEmpty,
      reason: '撤销恢复记录',
    );
    expect(harness.state.transactions.single.id, 'food');
  });

  testWidgets('点击记录进入编辑页并预填金额', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 42.5, categoryId: 'food', note: '午餐', date: todayAt()),
        ]));
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    await tester.tap(find.text('午餐'));
    await tester.pumpAndSettle();

    expect(find.text('编辑记录'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
    expect(find.text('保存修改'), findsOneWidget);
  });

  testWidgets('200% 大字号下不溢出', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(id: 'food', amount: 123456.78, categoryId: 'food', note: '很长的备注文字', date: todayAt()),
        ]));
    useTextScale(tester, scale: 2.0);
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    expectNoLayoutOverflow(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pump();
    expectNoLayoutOverflow(tester);
  });

  testWidgets('筛选按钮与月份切换按钮点击区 ≥ 48dp', (tester) async {
    await pumpScoped(tester, harness.state, const TransactionsScreen());

    expectMinTapTarget(tester, find.byTooltip('筛选'), label: '筛选按钮');
    expectMinTapTarget(tester, find.byTooltip('上个月'), label: '上个月按钮');
  });
}
