// Widget 测试公用脚手架。
//
// 原则：不 mock 数据层——每个用例用真实 Hive（LocalStore.openForTest + 独立临时目录）
// 和真实 AppState（AppState.forStore），这样组件测试与 App 实际行为一致。
//
// 本文件暂不引用 lib/ui/**（UI 落地后在此补 pumpFullApp 等完整 App 启动辅助）。
// 注意：`flutter test test/widget` 只收集 *_test.dart，本文件不会被当作测试执行。
// ignore_for_file: prefer_const_constructors, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/app_settings.dart';
import 'package:ledger_ai/core/app_state.dart';
import 'package:ledger_ai/core/models.dart';
import 'package:ledger_ai/core/storage.dart';
import 'package:ledger_ai/ui/theme.dart';

/// 一个 widget 测试用例的完整环境：临时目录 + Hive box + AppState。
///
/// 用法：
/// ```dart
/// late TestHarness harness;
/// setUp(() async => harness = await TestHarness.open());
/// tearDown(() async => harness.dispose());
/// ```
/// 同一测试文件内不并行使用两个 harness（Hive box 名固定）。
class TestHarness {
  TestHarness._(this._tempDir, this.store, this.state);

  final Directory _tempDir;

  /// 真实 LocalStore，可用于读取 Hive 原始状态做断言。
  final LocalStore store;

  /// 注入 AppScope 的应用状态。
  final AppState state;

  static Future<TestHarness> open() async {
    installPlatformMocks();
    final tempDir = Directory.systemTemp.createTempSync('ledger_ai_widget_');
    final store = await LocalStore.openForTest(tempDir.path);
    return TestHarness._(tempDir, store, AppState.forStore(store));
  }

  /// 写入测试交易（金额恒为正，方向用 [Txn.isIncome]）。
  Future<void> seed(Iterable<Txn> txns) => state.repo.saveAll(txns);

  Future<void> setPrefs(AppSettings prefs) => state.updateSettings(prefs);

  /// 关闭 box、释放状态并删除临时目录；每个用例结束时调用一次。
  Future<void> dispose() async {
    state.dispose();
    await store.close();
    if (_tempDir.existsSync()) {
      _tempDir.deleteSync(recursive: true);
    }
  }
}

/// 组件测试没有原生实现：把触觉反馈、语音、OCR 通道换成桩，
/// 避免 `MissingPluginException` 被当成真实失败（App 代码会 await 触觉反馈）。
///
/// 每次测试后 flutter_test 会自动清除 mock，所以在每个用例的 setUp 里重新安装。
void installPlatformMocks() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // 触觉反馈 / 系统声音等系统调用：静默成功。
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  // 设备端语音 / OCR：测试环境视为不可用（模拟器行为），不影响手动记账。
  // 通道前缀与 lib/ai + AppDelegate 保持一致：com.archintera.ledgerai/*。
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.archintera.ledgerai/speech'),
    (call) async => call.method == 'isAvailable' ? false : null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.archintera.ledgerai/speech_events'),
    (call) async => null,
  );
  // OCR：返回空文本，页面会走“没有识别到金额”的中文提示分支。
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.archintera.ledgerai/ocr'),
    (call) async => <String, dynamic>{'text': '', 'lines': <String>[]},
  );
}

/// 构造测试交易。默认值：支出、餐饮、42 元、2026-03-15 12:00。
Txn testTxn({
  required String id,
  double amount = 42,
  String categoryId = 'food',
  DateTime? date,
  String note = '',
  bool isIncome = false,
  EntrySource source = EntrySource.manual,
  String? merchant,
}) {
  final txnDate = date ?? DateTime(2026, 3, 15, 12);
  return Txn(
    id: id,
    amount: amount,
    categoryId: categoryId,
    date: txnDate,
    note: note,
    isIncome: isIncome,
    source: source,
    merchant: merchant,
  );
}

/// 应用真实主题 + 中文 locale 的 MaterialApp（页面测试统一入口）。
Widget appShell(
  AppState state,
  Widget home, {
  ThemeData? theme,
  GlobalKey<NavigatorState>? navigatorKey,
}) =>
    AppScope(
      state: state,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: theme ?? AppTheme.light(),
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );

/// 把单个页面挂到真实 [AppScope] 下（应用真实主题 + 中文 locale），便于单页测试。
Widget scopedApp(AppState state, Widget child, {ThemeData? theme}) =>
    appShell(state, child, theme: theme);

/// pump 一个挂在 AppScope 下的页面并稳定（页面无无限动画时使用）。
Future<void> pumpScoped(
  WidgetTester tester,
  AppState state,
  Widget child, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(scopedApp(state, child, theme: theme));
  await tester.pumpAndSettle();
}

/// 从一个空白宿主页 push 目标页面，用于验证「保存/删除后 pop」的流程。
Future<void> pumpPushed(
  WidgetTester tester,
  AppState state,
  Widget page, {
  ThemeData? theme,
}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    appShell(
      state,
      const SizedBox.shrink(),
      theme: theme,
      navigatorKey: navigatorKey,
    ),
  );
  await tester.pumpAndSettle();
  unawaited(
    navigatorKey.currentState!.push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 今天（保留当前年月日，便于按月/按日统计的页面）。
DateTime todayAt({int hour = 12, int minute = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// 本月 1 号（用于把交易放进“本月”）。
DateTime firstOfThisMonth({int hour = 9}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1, hour);
}

/// 滚动到指定控件可见（长页面断言/点击前调用）。
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 240,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// 推进固定帧数，代替可能永不稳定的 `pumpAndSettle`：
/// 页面里有输入框光标闪烁、SnackBar、进度动画时，用限定次数的 pump。
Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 10,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// 断言存在指定的屏幕阅读器标签（比对 Semantics widget 的 label 属性）。
/// 比 `find.bySemanticsLabel` 更稳：不依赖语义树合并/节点归属细节。
void expectSemanticsLabel(String label) {
  final finder = find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
  expect(finder, findsWidgets, reason: '缺少语义标签：$label');
}

/// 轮询等待真实异步（如 Hive 落盘）完成；widget 测试里涉及真实 IO 时使用。
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  String? reason,
  int attempts = 200,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (condition()) return;
    // runAsync 让真实 dart:io 事件循环推进，pump 让 fake-zone 里的回调继续。
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
  fail('等待条件超时：${reason ?? '未命名条件'}');
}

/// 在真实事件循环里写入测试交易（避免 FakeAsync 卡住 Hive 落盘）。
Future<void> seedAsync(WidgetTester tester, TestHarness harness, Iterable<Txn> txns) =>
    tester.runAsync(() => harness.seed(txns)).then((_) {});

/// 使用 iPhone 竖屏尺寸（390×844pt）跑组件测试，避免默认 800×600 横屏
/// 造成与真机差异过大的布局结论。测试结束自动复位。
void usePhoneSurface(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 模拟系统大字号（默认 200%）。测试结束自动复位。
void useTextScale(WidgetTester tester, {double scale = 2.0}) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// 断言本帧没有布局溢出（RenderFlex overflow 等会以异常形式暴露）。
void expectNoLayoutOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull, reason: '出现布局溢出或渲染异常');
}

/// 断言匹配控件全部满足点击区域 ≥ 48×48dp（ACCESSIBILITY.md 底线）。
void expectMinTapTarget(WidgetTester tester, Finder finder, {String? label}) {
  final description = label ?? finder.toString();
  final elements = finder.evaluate().toList();
  expect(elements, isNotEmpty, reason: '未找到目标控件：$description');
  for (final element in elements) {
    final renderObject = element.renderObject;
    expect(renderObject, isA<RenderBox>(), reason: '目标控件不可测量：$description');
    final size = (renderObject! as RenderBox).size;
    expect(size.width, greaterThanOrEqualTo(48.0), reason: '$description 宽度 ${size.width} < 48dp');
    expect(size.height, greaterThanOrEqualTo(48.0), reason: '$description 高度 ${size.height} < 48dp');
  }
}
