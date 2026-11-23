// 1.2 本地分账真机/模拟器流程测试。
//
// 运行：
//   flutter test integration_test/split_flow_test.dart \
//     -d <iOS Simulator> --dart-define=SHOW_SPLIT_PREVIEW=true
//
// 使用独立 Hive 子目录，不影响正式账本。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger_ai/app.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/app_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(
    WidgetTester tester,
    bool Function() condition, {
    required String reason,
    int attempts = 120,
  }) async {
    for (var i = 0; i < attempts; i++) {
      if (condition()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('分账流程超时：$reason');
  }

  testWidgets('首页 → 建群 → 加参与者 → 记支出 → 余额', (tester) async {
    final dir = 'qa_split_${DateTime.now().microsecondsSinceEpoch}';
    final state = await AppState.create(subDirectory: dir);
    await state.updateSettingsWith(
      (settings) => settings.copyWith(
        onboardingDone: true,
        language: AppLanguage.zhHans,
      ),
    );
    addTearDown(state.shutdown);

    await tester.pumpWidget(AppScope(state: state, child: const LedgerApp()));
    await tester.pumpAndSettle();

    // 首页真实分账入口
    expect(find.text('一起分'), findsOneWidget);
    await tester.tap(find.text('一起分'));
    await tester.pumpAndSettle();
    expect(find.text('分账'), findsOneWidget);

    // 新建群组
    await tester.tap(find.text('新建分账').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '京都旅行');
    await tester.tap(find.text('创建'));
    await waitFor(tester, () => state.split.groups.isNotEmpty, reason: '保存群组');
    await tester.pumpAndSettle();
    final group = state.split.groups.single;

    // 添加参与者
    await tester.tap(find.text('添加').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '小王');
    await tester.tap(find.text('添加').last);
    await waitFor(
      tester,
      () => state.split.participantsOf(group.id).length == 2,
      reason: '保存参与者',
    );
    await tester.pumpAndSettle();
    expect(state.split.participantsOf(group.id), hasLength(2));

    // 添加支出，默认付款人 + 全部参与者等额分摊
    await tester.tap(find.text('添加支出').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.tap(find.text('完成'));
    await waitFor(
      tester,
      () => state.split.expensesOf(group.id).isNotEmpty,
      reason: '保存分账支出',
    );
    await tester.pumpAndSettle();

    final expense = state.split.expensesOf(group.id).single;
    expect(expense.amountMinor, 10000);
    expect(expense.shares.values.reduce((a, b) => a + b), 10000);
    expect(find.text('余额'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
