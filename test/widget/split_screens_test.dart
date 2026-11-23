import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/currency.dart';
import 'package:ledger_ai/core/split_models.dart';
import 'package:ledger_ai/ui/screens/root_shell.dart';
import 'package:ledger_ai/ui/screens/split_group_screen.dart';

import 'test_support.dart';

void main() {
  late TestHarness harness;

  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.dispose());

  testWidgets('首页分账入口打开真实群组列表并可建组', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() => harness.setPrefs(
        const AppSettings(onboardingDone: true, language: AppLanguage.zhHans)));
    await pumpScoped(tester, harness.state, const RootShell(splitPreview: true));

    await tester.tap(find.text('一起分').first);
    await tester.pumpAndSettle();
    expect(find.text('还没有分账'), findsOneWidget);

    await tester.tap(find.text('新建分账').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '京都旅行');
    await tester.tap(find.text('创建'));
    await waitUntil(
      tester,
      () => harness.state.split.groups.isNotEmpty,
      reason: '创建分账群组',
    );
    final groups = harness.state.split.groups;
    expect(groups, hasLength(1));
    expect(groups.single.title, '京都旅行');
    expect(harness.state.split.participantsOf(groups.single.id), hasLength(1));
  });

  testWidgets('分账详情显示余额并在 200% 字号下不溢出', (tester) async {
    usePhoneSurface(tester);
    await tester.runAsync(() async {
      await harness.setPrefs(const AppSettings(
          onboardingDone: true, language: AppLanguage.zhHans));
      final group = await harness.state.split.createGroup(
        title: '京都旅行',
        kind: SplitKind.trip,
        ownerName: '我',
      );
      await harness.state.split
          .addParticipant(groupId: group.id, displayName: '小王');
      final people = harness.state.split.participantsOf(group.id);
      final amount = 10000;
      final shares = SplitExpense.equalShares(
        participantIds: people.map((p) => p.id).toList(),
        amountMinor: amount,
      );
      await harness.state.split.saveExpense(SplitExpense(
        id: 'split-expense',
        groupId: group.id,
        payerId: people.first.id,
        amountMinor: amount,
        currency: AppCurrency.cny,
        fxRate: 1,
        baseAmountMinor: amount,
        baseCurrency: AppCurrency.cny,
        shares: shares,
        date: DateTime.now(),
        createdBy: people.first.id,
        updatedAt: DateTime.now(),
      ));
    });
    final group = harness.state.split.groups.single;
    await pumpScoped(
        tester, harness.state, SplitGroupScreen(groupId: group.id));
    expect(find.text('京都旅行'), findsOneWidget);
    expect(find.text('余额'), findsOneWidget);
    expect(find.text('小王'), findsWidgets);

    useTextScale(tester, scale: 2.0);
    await tester.pumpAndSettle();
    expectNoLayoutOverflow(tester);
  });

}
