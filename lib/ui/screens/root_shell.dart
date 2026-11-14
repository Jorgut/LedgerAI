import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

import '../theme.dart';
import 'add_transaction_screen.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'split_demo_screen.dart';
import 'transactions_screen.dart';

/// 主壳：首页 / 账单 / 报表 / 我的 四个 Tab + 中央「记一笔」FAB。
///
/// 使用 [IndexedStack] 保留各 Tab 的滚动位置与筛选状态。
class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    this.initialIndex = 0,
    this.showFab = true,
    this.reportsInitialScrollOffset = 0,
    this.settingsInitialScrollOffset = 0,
    this.splitPreview = const bool.fromEnvironment('SHOW_SPLIT_PREVIEW'),
  });

  /// 启动时选中的 Tab（0 首页 / 1 账单 / 2 报表 / 3 我的）。
  /// 商店截图与演示模式可用来直接打开指定页；越界值会被夹到 0..3。
  final int initialIndex;

  /// 截图/演示模式可隐藏中央 FAB，避免遮挡内容。
  final bool showFab;

  /// 截图/演示模式用于直接定位报表页滚动位置。
  final double reportsInitialScrollOffset;

  /// 截图/演示模式用于直接定位设置页滚动位置。
  final double settingsInitialScrollOffset;

  /// Demo/1.2 preview: show the Split entry on Home (no bottom tab).
  final bool splitPreview;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3).toInt();
  }

  void _selectTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  Future<void> _openSplitPreview() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SplitDemoScreen()),
    );
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      // AppScope 会自动通知数据页面刷新；这里再触发一次 shell 重建，
      // 保证不依赖 AppScope 的页面（如纯静态组件）也能拿到最新数据。
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navBackground =
        theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSeeAll: () => _selectTab(1),
            onOpenSplit: widget.splitPreview ? _openSplitPreview : null,
          ),
          const TransactionsScreen(),
          ReportsScreen(initialScrollOffset: widget.reportsInitialScrollOffset),
          SettingsScreen(initialScrollOffset: widget.settingsInitialScrollOffset),
        ],
      ),
      floatingActionButton: widget.showFab
          ? _AddButton(
              surfaceColor: navBackground,
              onPressed: _openAdd,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: navBackground,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
              tooltip: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l10n.navTransactions,
              tooltip: l10n.navTransactions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights_rounded),
              label: l10n.navReports,
              tooltip: l10n.navReports,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navSettings,
              tooltip: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// 中央 FAB：外层浅色圆环制造「嵌在导航栏里」的缺口效果。
class _AddButton extends StatelessWidget {
  const _AddButton({required this.surfaceColor, required this.onPressed});

  final Color surfaceColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: AppTheme.isDark(context) ? 0.45 : 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        tooltip: AppLocalizations.of(context).fabAdd,
        onPressed: onPressed,
        shape: const CircleBorder(),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }
}
