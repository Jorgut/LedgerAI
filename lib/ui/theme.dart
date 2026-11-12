import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';

export '../core/format.dart' show kBrandColor, kBrandDark, kBrandText;

/// 衡账的视觉主题与设计常量。
///
/// 设计原则：
/// - 浅色背景 `#F6F7F9` + 白色卡片；深色背景 `#0F1419` + `#161C22` 卡片。
/// - 品牌绿 [kBrandColor] 只用于填充、进度与装饰（对比度不足，禁止用作小字）。
///   浅色背景上的强调文字 / 图标 / 链接统一用 [kBrandText]（`#047857`）。
/// - 卡片圆角 16，控件圆角 14，页面水平留白 16。
/// - 金额统一使用等宽数字（[tabularFigures]）；请配合
///   `AmountText`（lib/ui/widgets/common/amount_text.dart）使用。
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // 设计常量（各页面可直接复用）
  // ---------------------------------------------------------------------------

  /// 品牌绿，仅用于填充 / 进度 / 装饰。
  static const Color brand = kBrandColor;

  /// 深一档品牌绿，用于浅色背景上的填充与按钮。
  static const Color brandDark = kBrandDark;

  /// 浅色背景上可读的强调绿（文字 / 图标 / 链接）。
  static const Color brandText = kBrandText;

  static const Color lightBackground = Color(0xFFF4F3EE);
  static const Color darkBackground = Color(0xFF0B1512);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF111F1A);

  /// 浅色主题下白字可读的绿（按钮 / 主操作）。
  static const Color lightAction = kBrandText;

  /// 收入色（语义色，按主题自动调整，见 [incomeColorOf]）。
  static const Color incomeLight = Color(0xFF0E7C5A);
  static const Color incomeDark = Color(0xFF6EE7B7);

  /// 支出色（语义色，按主题自动调整，见 [expenseColorOf]）。
  static const Color expenseLight = Color(0xFFB42318);
  static const Color expenseDark = Color(0xFFF87171);

  /// 提醒色（预算接近上限等）。
  static const Color warningLight = Color(0xFFB26A00);
  static const Color warningDark = Color(0xFFFBBF24);

  static const double radius = 16;
  static const double cardRadius = 16;
  static const double controlRadius = 14;
  static const double pagePadding = 16;

  /// 页面内容统一内边距（底部留出 FAB / 导航空间）。
  static const EdgeInsets pageInsets = EdgeInsets.fromLTRB(16, 8, 16, 120);

  /// 品牌渐变（浅色 / 深色通用）。两档绿都保证白字对比度 ≥ 5.9:1，
  /// 因此可以在渐变卡上直接放正文级白色文字。
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kBrandText, kBrandDark],
  );

  /// 等宽数字（金额专用）。
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures()
  ];

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// 收入文字色：浅色 `#047857`，深色 `#34D399`。
  static Color incomeColorOf(BuildContext context) =>
      isDark(context) ? incomeDark : incomeLight;

  /// 支出文字色：浅色 `#DC2626`，深色 `#F87171`。
  static Color expenseColorOf(BuildContext context) =>
      isDark(context) ? expenseDark : expenseLight;

  /// 提醒文字色：浅色 `#B45309`，深色 `#FBBF24`。
  static Color warningColorOf(BuildContext context) =>
      isDark(context) ? warningDark : warningLight;

  /// 按元素主题取收入 / 支出色（不依赖 BuildContext 的场景）。
  static Color amountColor(Brightness brightness, {required bool isIncome}) {
    if (isIncome) {
      return brightness == Brightness.dark ? incomeDark : incomeLight;
    }
    return brightness == Brightness.dark ? expenseDark : expenseLight;
  }

  // ---------------------------------------------------------------------------
  // 主题构建
  // ---------------------------------------------------------------------------

  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast);

  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool highContrast) {
    final isDark = brightness == Brightness.dark;
    final scheme = _scheme(brightness, highContrast);
    final cardColor = isDark ? darkSurface : lightSurface;
    final canvas = isDark ? darkBackground : lightBackground;
    final fieldFill =
        isDark ? const Color(0xFF17251F) : const Color(0xFFF1F3EE);
    final borderColor = highContrast
        ? scheme.outline
        : (isDark ? const Color(0xFF24352D) : const Color(0xFFE3E6E0));
    final actionColor = isDark
        ? scheme.primary
        : (highContrast ? const Color(0xFF063A2C) : lightAction);
    final actionForeground = isDark ? scheme.onPrimary : Colors.white;

    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      applyElevationOverlayColor: false,
    );

    final textTheme = _textTheme(base.textTheme, scheme);
    final primaryTextTheme = _textTheme(base.primaryTextTheme, scheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: AppBarThemeData(
        backgroundColor: canvas,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: fieldFill,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: actionColor),
        helperStyle:
            textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        errorMaxLines: 3,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: actionColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: actionColor,
          foregroundColor: actionForeground,
          disabledBackgroundColor:
              isDark ? const Color(0xFF2A343E) : const Color(0xFFCBD5D1),
          disabledForegroundColor:
              isDark ? const Color(0xFF6B7280) : Colors.white,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? scheme.primary : brandText,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: scheme.outline, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size(48, 48),
          iconSize: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? scheme.primary : brandDark,
        foregroundColor: isDark ? scheme.onPrimary : Colors.white,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        sizeConstraints: const BoxConstraints.tightFor(width: 58, height: 58),
        iconSize: 30,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? (isDark ? scheme.primary : brandText)
                : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? (isDark ? scheme.primary : brandText)
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium
            ?.copyWith(color: scheme.onInverseSurface, fontSize: 16),
        actionTextColor: isDark ? brandText : const Color(0xFF6EE7B7),
        elevation: 3,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 8,
        clipBehavior: Clip.antiAlias,
        dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 10,
        horizontalTitleGap: 12,
        titleTextStyle: textTheme.bodyLarge?.copyWith(fontSize: 17),
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          fontSize: 15,
        ),
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: scheme.onPrimaryContainer,
        showCheckmark: true,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? scheme.primary : brand,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 8,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: actionColor,
        selectionColor: actionColor.withValues(alpha: 0.24),
        selectionHandleColor: actionColor,
      ),
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),
    );
  }

  // ---------------------------------------------------------------------------
  // 颜色与字体
  // ---------------------------------------------------------------------------

  static ColorScheme _scheme(Brightness brightness, bool highContrast) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
    );

    if (isDark) {
      return base.copyWith(
        primary:
            highContrast ? const Color(0xFFA7F3D0) : const Color(0xFF6EE7B7),
        onPrimary: const Color(0xFF052B21),
        primaryContainer:
            highContrast ? const Color(0xFF0B5B47) : const Color(0xFF064E3B),
        onPrimaryContainer: const Color(0xFFCDEEE1),
        secondary: const Color(0xFF5EEAD4),
        onSecondary: const Color(0xFF042F2A),
        secondaryContainer: const Color(0xFF0B3B32),
        onSecondaryContainer: const Color(0xFFCCFBF1),
        tertiary: const Color(0xFFD6B48A),
        onTertiary: const Color(0xFF2B1A0E),
        tertiaryContainer: const Color(0xFF3B2A1A),
        onTertiaryContainer: const Color(0xFFF3E7DA),
        error: const Color(0xFFF87171),
        onError: const Color(0xFF450A0A),
        errorContainer: const Color(0xFF7F1D1D),
        onErrorContainer: const Color(0xFFFEE2E2),
        surface: darkSurface,
        onSurface: highContrast ? Colors.white : const Color(0xFFE8F1EC),
        onSurfaceVariant:
            highContrast ? const Color(0xFFE8F1EC) : const Color(0xFF9FB8AD),
        surfaceContainerLowest: const Color(0xFF07100C),
        surfaceContainerLow: const Color(0xFF0D1A14),
        surfaceContainer: darkSurface,
        surfaceContainerHigh: const Color(0xFF17271F),
        surfaceContainerHighest: const Color(0xFF1D3027),
        outline:
            highContrast ? const Color(0xFFA9BFB5) : const Color(0xFF3A5046),
        outlineVariant:
            highContrast ? const Color(0xFF7F978B) : const Color(0xFF24352D),
        inverseSurface: const Color(0xFFF4F3EE),
        onInverseSurface: const Color(0xFF0B1F1A),
        inversePrimary: brandText,
        surfaceTint: Colors.transparent,
      );
    }

    return base.copyWith(
      primary: highContrast ? const Color(0xFF063A2C) : brand,
      onPrimary: Colors.white,
      primaryContainer:
          highContrast ? const Color(0xFFCDEEE1) : const Color(0xFFDCEFE6),
      onPrimaryContainer: const Color(0xFF063A2C),
      secondary: const Color(0xFF147A61),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE7F2EC),
      onSecondaryContainer: const Color(0xFF063A2C),
      tertiary: const Color(0xFFB4845A),
      onTertiary: const Color(0xFF2B1A0E),
      tertiaryContainer: const Color(0xFFF3E7DA),
      onTertiaryContainer: const Color(0xFF3B2414),
      error: const Color(0xFFB42318),
      onError: Colors.white,
      errorContainer: const Color(0xFFFDE8E6),
      onErrorContainer: const Color(0xFF5A1208),
      surface: lightSurface,
      onSurface: highContrast ? Colors.black : const Color(0xFF0B1F1A),
      onSurfaceVariant:
          highContrast ? const Color(0xFF2F3E37) : const Color(0xFF5F6E67),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: lightSurface,
      surfaceContainerHigh: const Color(0xFFF7F6F1),
      surfaceContainerHighest: const Color(0xFFEFEEE8),
      outline: highContrast ? const Color(0xFF4B5B54) : const Color(0xFFD8DDD6),
      outlineVariant:
          highContrast ? const Color(0xFF6B7C75) : const Color(0xFFE3E6E0),
      inverseSurface: const Color(0xFF111F1A),
      onInverseSurface: const Color(0xFFF4F3EE),
      inversePrimary: const Color(0xFFCDEEE1),
      surfaceTint: Colors.transparent,
    );
  }

  /// 字阶：正文 16sp、重要信息 18sp+、标题 22sp+；全部启用等宽数字。
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    final text = base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.12,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.14,
          ),
          displaySmall: base.displaySmall?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.16,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.24,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.2,
          ),
        )
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );

    TextStyle? tabular(TextStyle? style) =>
        style?.copyWith(fontFeatures: tabularFigures);

    return text.copyWith(
      displayLarge: tabular(text.displayLarge),
      displayMedium: tabular(text.displayMedium),
      displaySmall: tabular(text.displaySmall),
      headlineLarge: tabular(text.headlineLarge),
      headlineMedium: tabular(text.headlineMedium),
      headlineSmall: tabular(text.headlineSmall),
      titleLarge: tabular(text.titleLarge),
      titleMedium: tabular(text.titleMedium),
      titleSmall: tabular(text.titleSmall),
      bodyLarge: tabular(text.bodyLarge),
      bodyMedium: tabular(text.bodyMedium),
      bodySmall: tabular(text.bodySmall),
      labelLarge: tabular(text.labelLarge),
      labelMedium: tabular(text.labelMedium),
      labelSmall: tabular(text.labelSmall),
    );
  }
}
