import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/ui/screens/root_shell.dart';

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
}
