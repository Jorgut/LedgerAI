// 记账页组件测试：手动输入保存、金额校验、收支切换、编辑与删除、大字号、按钮尺寸。
// 被测页面：lib/ui/screens/add_transaction_screen.dart（真实 Hive + AppState 注入）。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/models.dart';
import 'package:ledger_ai/ui/screens/add_transaction_screen.dart';
import 'package:ledger_ai/ui/theme.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  testWidgets('手动记一笔：输入金额保存后落库并返回', (tester) async {
    await pumpPushed(tester, harness.state, const AddTransactionScreen());

    expect(find.text('记一笔'), findsOneWidget);
    expect(find.text('保存记录'), findsOneWidget);
    expect(find.text('支出'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '42.5');
    await tester.tap(find.text('保存记录'));
    await waitUntil(
      tester,
      () => harness.state.transactions.isNotEmpty,
      reason: '保存记录到 Hive',
    );
    await tester.pumpAndSettle();

    final txn = harness.state.transactions.single;
    expect(txn.amount, 42.5);
    expect(txn.isIncome, isFalse);
    expect(txn.categoryId, 'food'); // 默认第一个支出分类
    expect(txn.source, EntrySource.manual);
    // 保存成功后页面 pop，返回宿主页。
    expect(find.text('记一笔'), findsNothing);
  });

  testWidgets('金额为空或 0 时拒绝保存并提示', (tester) async {
    await pumpPushed(tester, harness.state, const AddTransactionScreen());

    await tester.tap(find.text('保存记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('请输入大于 0 的金额'), findsWidgets);
    expect(harness.state.transactions, isEmpty);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('保存记录'));
    await tester.pump();
    expect(harness.state.transactions, isEmpty);
  });

  testWidgets('切换为收入后分类列表与保存结果一致', (tester) async {
    await pumpPushed(tester, harness.state, const AddTransactionScreen());

    await tester.tap(find.text('收入'));
    await tester.pumpAndSettle();
    expect(find.text('工资'), findsOneWidget);
    expect(find.text('餐饮'), findsNothing);

    await tester.tap(find.text('工资'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '8000');
    await tester.tap(find.text('保存记录'));

    await waitUntil(
      tester,
      () => harness.state.transactions.isNotEmpty,
      reason: '保存收入记录',
    );
    final txn = harness.state.transactions.single;
    expect(txn.isIncome, isTrue);
    expect(txn.categoryId, 'salary');
    expect(txn.amount, 8000);
  });

  testWidgets('备注会随记录保存', (tester) async {
    await pumpPushed(tester, harness.state, const AddTransactionScreen());

    await tester.enterText(find.byType(TextField).first, '12');
    await tester.enterText(find.widgetWithText(TextField, '备注'), '地铁通勤');
    await tester.tap(find.text('保存记录'));

    await waitUntil(
      tester,
      () => harness.state.transactions.isNotEmpty,
      reason: '保存带备注的记录',
    );
    expect(harness.state.transactions.single.note, '地铁通勤');
  });

  testWidgets('编辑已有记录：预填金额、保存修改不新增', (tester) async {
    await tester.runAsync(() => harness.seed([
          testTxn(
            id: 'existing',
            amount: 42.5,
            categoryId: 'food',
            note: '午餐',
            date: todayAt(),
          ),
        ]));
    final existing = harness.state.transactions.single;

    await pumpPushed(
      tester,
      harness.state,
      AddTransactionScreen(transaction: existing),
    );

    expect(find.text('编辑记录'), findsOneWidget);
    expect(find.text('保存修改'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '66');
    await tester.tap(find.text('保存修改'));

    await waitUntil(
      tester,
      () => harness.state.transactions.single.amount == 66,
      reason: '更新记录金额',
    );
    expect(harness.state.transactions, hasLength(1));
    expect(harness.state.transactions.single.id, 'existing');
  });

  testWidgets('编辑时删除记录需确认，取消不删除', (tester) async {
    await tester.runAsync(
      () => harness.seed([testTxn(id: 'to-delete', date: todayAt())]),
    );
    final existing = harness.state.transactions.single;

    await pumpPushed(
      tester,
      harness.state,
      AddTransactionScreen(transaction: existing),
    );
    await tester.tap(find.byTooltip('删除这笔记录'));
    await tester.pumpAndSettle();

    expect(find.text('删除这笔记录？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(harness.state.transactions, hasLength(1));

    await tester.tap(find.byTooltip('删除这笔记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await waitUntil(
      tester,
      () => harness.state.transactions.isEmpty,
      reason: '删除记录',
    );
    await tester.pumpAndSettle();
    expect(find.text('编辑记录'), findsNothing);
  });

  testWidgets('200% 大字号下表单可滚动且不溢出', (tester) async {
    useTextScale(tester, scale: 2.0);
    await pumpPushed(tester, harness.state, const AddTransactionScreen());
    expectNoLayoutOverflow(tester);

    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pump();
    expectNoLayoutOverflow(tester);

    await pumpPushed(
      tester,
      harness.state,
      const AddTransactionScreen(),
      theme: AppTheme.dark(),
    );
    expectNoLayoutOverflow(tester);
  });

  testWidgets('保存按钮与删除按钮点击区 ≥ 48dp', (tester) async {
    await tester.runAsync(
      () => harness.seed([testTxn(id: 'x', date: todayAt())]),
    );
    final existing = harness.state.transactions.single;

    await pumpPushed(
      tester,
      harness.state,
      AddTransactionScreen(transaction: existing),
    );

    expectMinTapTarget(
      tester,
      find.widgetWithText(FilledButton, '保存修改'),
      label: '保存按钮',
    );
    expectMinTapTarget(
      tester,
      find.byTooltip('删除这笔记录'),
      label: '删除按钮',
    );
  });
}
