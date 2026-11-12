import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../motion/motion.dart';
import '../theme.dart';
import '../widgets/common/app_snack.dart';

/// 首次启动引导：3 屏介绍（本地隐私 / 拍照识别 / 语音记账）。
///
/// 完成后通过 [AppState] 写入 `onboardingDone = true`，再回调 [onDone]。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.lock_rounded,
      title: '你的账本，\n只在你手机里',
      body: '衡账不登录、不联网、不上传。所有账单和设置都保存在本机，随时可以导出备份。',
      points: ['完全离线运行', '不收集任何个人信息', '数据可随时导出'],
    ),
    _OnboardingPage(
      icon: Icons.document_scanner_rounded,
      title: '拍一张小票，\n就记好了',
      body: '对准小票或账单截图拍照，本机自动识别金额、商户和日期，确认一下就能保存。',
      points: ['设备端文字识别', '自动匹配分类', '识别原文可展开查看'],
    ),
    _OnboardingPage(
      icon: Icons.mic_rounded,
      title: '按住说一句，\n3 秒记一笔',
      body: '说「今天午餐花了 42 块」，自动填好金额和分类。不方便打字时尤其好用。',
      points: ['本机语音识别', '支持中文一句话', '听不清时可手动输入'],
    ),
  ];

  final PageController _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final app = AppScope.read(context);
    try {
      await app.updateSettingsWith(
          (settings) => settings.copyWith(onboardingDone: true));
    } catch (_) {
      // 写入失败时留在引导页并提示，用户可重试；绝不崩溃。
      if (!mounted) return;
      setState(() => _finishing = false);
      AppSnack.error(context, '保存设置失败，请重试');
      return;
    }
    if (!mounted) return;
    widget.onDone();
  }

  Future<void> _next() async {
    if (_page >= _pages.length - 1) {
      await _finish();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _previous() async {
    if (_page <= 0) return;
    await _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      tooltip: '上一页',
                      onPressed: _previous,
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _finishing ? null : _finish,
                      child: const Text('跳过'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => FadeSlideIn(
                  key: ValueKey(index),
                  duration: const Duration(milliseconds: 420),
                  child: _PageContent(
                    page: _pages[index],
                    textTheme: theme.textTheme,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  Semantics(
                    label: '第 ${_page + 1} 页，共 ${_pages.length} 页',
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final selected = index == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? (AppTheme.isDark(context)
                                      ? theme.colorScheme.primary
                                      : AppTheme.brandTextOf(context))
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finishing ? null : _next,
                      child: _finishing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text(isLast ? '开始记账' : '下一步'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.points,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> points;
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page, required this.textTheme});

  final _OnboardingPage page;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppTheme.isDark(context)
        ? theme.colorScheme.primary
        : AppTheme.brandTextOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 32).clamp(0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.18),
                        theme.colorScheme.primary.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Positioned.fill(
                        child: ClipOval(child: TechBackdrop(opacity: 0.55)),
                      ),
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: AppTheme.isDark(context) ? 0.35 : 0.06,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 44, color: accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  page.body,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final point in page.points)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 16, color: accent),
                            const SizedBox(width: 6),
                            Text(
                              point,
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
