// 真机 / 模拟器冒烟测试：冷启动 → 首页 → 记一笔 → 首页最近记录 → 账单列表出现。
//
// 运行方式（由 Lead 在模拟器执行）：
//   flutter test integration_test/smoke_test.dart -d <iOS Simulator>
//
// 使用独立 Hive 子目录 `qa_smoke`，不会影响正式账本数据。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger_ai/app.dart';
import 'package:ledger_ai/core/app_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 轮询等待条件成立（真机上 Hive 落盘 / 路由动画都是真实异步）。
  Future<void> waitFor(
    WidgetTester tester,
    bool Function() condition, {
    required String reason,
    int attempts = 100,
  }) async {
    for (var i = 0; i < attempts; i++) {
      if (condition()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('冒烟步骤超时：$reason');
  }

  testWidgets('启动 → 首页 → 记一笔 → 记账成功 → 账单列表出现', (tester) async {
    final state = await AppState.create(subDirectory: 'qa_smoke');
    await state.updateSettingsWith(
      (settings) => settings.copyWith(onboardingDone: true),
    );
    await state.clearTransactions();
    addTearDown(state.shutdown);

    // 1) 冷启动进入首页。
    await tester.pumpWidget(AppScope(state: state, child: const LedgerApp()));
    await tester.pumpAndSettle();
    expect(find.text('本月结余'), findsOneWidget);
    expect(find.text('还没有记录'), findsOneWidget);

    // 2) 打开记账页并输入金额。
    await tester.tap(find.byTooltip('记一笔'));
    await tester.pumpAndSettle();
    expect(find.text('记一笔'), findsOneWidget);
    expect(find.text('保存记录'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '42.5');
    await tester.pump();

    // 3) 保存后返回首页，最近记录出现。
    await tester.tap(find.text('保存记录'));
    await waitFor(
      tester,
      () => state.transactions.isNotEmpty,
      reason: '保存交易到本机',
    );
    await tester.pumpAndSettle();
    expect(find.text('最近 1 笔'), findsOneWidget);

    // 4) 切换到账单 Tab，记录出现在列表中。
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('账单'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('-¥42.50'), findsOneWidget);
    expect(state.transactions.single.amount, 42.5);

    // 5) 数据跨页面一致，且未出现任何布局异常。
    expect(tester.takeException(), isNull);
  });
}
