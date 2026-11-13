import 'package:flutter/material.dart';

import '../core/app_settings.dart';

/// 三套主题色的实际色值。视图通过 [HengPalette.of] 读取，
/// 这样组件不再依赖全局静态品牌色，切主题时整页统一变化。
@immutable
class HengPalette extends ThemeExtension<HengPalette> {
  const HengPalette({
    required this.theme,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.field,
    required this.border,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.accent,
    required this.text,
    required this.muted,
    required this.income,
    required this.expense,
    required this.warning,
    required this.gradient,
    required this.categories,
  });

  final AppColorTheme theme;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color field;
  final Color border;
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color accent;
  final Color text;
  final Color muted;
  final Color income;
  final Color expense;
  final Color warning;
  final LinearGradient gradient;
  final Map<String, Color> categories;

  static const Map<String, Color> _freshCategories = {
    'food': Color(0xFFF59E0B),
    'transport': Color(0xFF3B82F6),
    'shopping': Color(0xFFEC4899),
    'home': Color(0xFF8B5CF6),
    'entertainment': Color(0xFF06B6D4),
    'medical': Color(0xFFEF4444),
    'education': Color(0xFF6366F1),
    'communication': Color(0xFF0EA5E9),
    'social': Color(0xFFF43F5E),
    'other_expense': Color(0xFF94A3B8),
    'salary': Color(0xFF10B981),
    'bonus': Color(0xFF22C55E),
    'investment': Color(0xFF14B8A6),
    'parttime': Color(0xFF84CC16),
    'gift': Color(0xFFF97316),
    'other_income': Color(0xFF94A3B8),
  };

  static const Map<String, Color> _forestCategories = {
    'food': Color(0xFFD9A441),
    'transport': Color(0xFF5B6C8A),
    'shopping': Color(0xFFC8553D),
    'home': Color(0xFF2A9D8F),
    'entertainment': Color(0xFF8A5A7A),
    'medical': Color(0xFFB4535A),
    'education': Color(0xFF6B8E6B),
    'communication': Color(0xFF7C8AA0),
    'social': Color(0xFFB86B5C),
    'other_expense': Color(0xFF94A0A8),
    'salary': Color(0xFF0E7C5A),
    'bonus': Color(0xFF4F9B6E),
    'investment': Color(0xFF2A9D8F),
    'parttime': Color(0xFF6B8E6B),
    'gift': Color(0xFFB4845A),
    'other_income': Color(0xFF94A0A8),
  };

  /// 介于 A 与 B 之间：保留森林主色，数据色稍微提亮。
  static const Map<String, Color> _freshForestCategories = {
    'food': Color(0xFFD9A441),
    'transport': Color(0xFF4B78A0),
    'shopping': Color(0xFFC8553D),
    'home': Color(0xFF2A9D8F),
    'entertainment': Color(0xFF8A5A7A),
    'medical': Color(0xFFB4535A),
    'education': Color(0xFF6B8E6B),
    'communication': Color(0xFF7C8AA0),
    'social': Color(0xFFB86B5C),
    'other_expense': Color(0xFF94A0A8),
    'salary': Color(0xFF0E7C5A),
    'bonus': Color(0xFF4F9B6E),
    'investment': Color(0xFF2A9D8F),
    'parttime': Color(0xFF6B8E6B),
    'gift': Color(0xFFB4845A),
    'other_income': Color(0xFF94A0A8),
  };


  static const Map<String, Color> _blushCategories = {
    'food': Color(0xFFC9826B),
    'transport': Color(0xFF8C7A96),
    'shopping': Color(0xFFB65A6A),
    'home': Color(0xFF8A9A7B),
    'entertainment': Color(0xFFA87A9A),
    'medical': Color(0xFFB4535A),
    'education': Color(0xFF7D8E9E),
    'communication': Color(0xFF9A8AA8),
    'social': Color(0xFFC07A72),
    'other_expense': Color(0xFFA89A98),
    'salary': Color(0xFF5F7F6A),
    'bonus': Color(0xFF7A9A7B),
    'investment': Color(0xFF8A9A8A),
    'parttime': Color(0xFF9A8A6A),
    'gift': Color(0xFFC08080),
    'other_income': Color(0xFFA89A98),
  };

  static const Map<String, Color> _peachCategories = {
    'food': Color(0xFFC97A52),
    'transport': Color(0xFF7D8A9A),
    'shopping': Color(0xFFB85C5C),
    'home': Color(0xFF8A9A72),
    'entertainment': Color(0xFFB07A8A),
    'medical': Color(0xFFB4535A),
    'education': Color(0xFF7D8E9E),
    'communication': Color(0xFF8A8AA8),
    'social': Color(0xFFC08668),
    'other_expense': Color(0xFFAA9A90),
    'salary': Color(0xFF5F7F6A),
    'bonus': Color(0xFF7A9A7B),
    'investment': Color(0xFF8A9A8A),
    'parttime': Color(0xFF9A8A6A),
    'gift': Color(0xFFC08070),
    'other_income': Color(0xFFAA9A90),
  };

  static const Map<String, Color> _lavenderCategories = {
    'food': Color(0xFFB0808A),
    'transport': Color(0xFF7A7A9A),
    'shopping': Color(0xFF9A6A8A),
    'home': Color(0xFF7A8A9A),
    'entertainment': Color(0xFF9A7AB0),
    'medical': Color(0xFFA85A6A),
    'education': Color(0xFF6F7A9A),
    'communication': Color(0xFF8A7AA8),
    'social': Color(0xFFA87A8A),
    'other_expense': Color(0xFF9A929A),
    'salary': Color(0xFF5F7A72),
    'bonus': Color(0xFF7A9A8A),
    'investment': Color(0xFF7A8A9A),
    'parttime': Color(0xFF8A8A6A),
    'gift': Color(0xFFB08090),
    'other_income': Color(0xFF9A929A),
  };

  static HengPalette forTheme(
    AppColorTheme theme,
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final dark = brightness == Brightness.dark;
    switch (theme) {
      case AppColorTheme.fresh:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.fresh,
                brightness: Brightness.dark,
                background: Color(0xFF0F1419),
                surface: Color(0xFF161C22),
                field: Color(0xFF1B242D),
                border: Color(0xFF232D37),
                primary: Color(0xFF34D399),
                primaryDark: Color(0xFF10B981),
                onPrimary: Color(0xFF022C22),
                accent: Color(0xFF10B981),
                text: Color(0xFFE5E7EB),
                muted: Color(0xFF9CA3AF),
                income: Color(0xFF34D399),
                expense: Color(0xFFF87171),
                warning: Color(0xFFFBBF24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF065F46), Color(0xFF022C22)],
                ),
                categories: _freshCategories,
              )
            : HengPalette(
                theme: AppColorTheme.fresh,
                brightness: Brightness.light,
                background: const Color(0xFFF6F7F9),
                surface: Colors.white,
                field: const Color(0xFFF1F3F5),
                border: const Color(0xFFE9ECF0),
                primary: const Color(0xFF047857),
                primaryDark: const Color(0xFF065F46),
                onPrimary: Colors.white,
                accent: const Color(0xFF10B981),
                text: const Color(0xFF111827),
                muted: const Color(0xFF6B7280),
                income: const Color(0xFF047857),
                expense: const Color(0xFFDC2626),
                warning: const Color(0xFFB45309),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                categories: _freshCategories,
              );
      case AppColorTheme.forest:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.forest,
                brightness: Brightness.dark,
                background: Color(0xFF0B1512),
                surface: Color(0xFF111F1A),
                field: Color(0xFF17251F),
                border: Color(0xFF24352D),
                primary: Color(0xFF6EE7B7),
                primaryDark: Color(0xFF0B5B47),
                onPrimary: Color(0xFF052B21),
                accent: Color(0xFF5EEAD4),
                text: Color(0xFFE8F1EC),
                muted: Color(0xFF9FB8AD),
                income: Color(0xFF6EE7B7),
                expense: Color(0xFFF87171),
                warning: Color(0xFFFBBF24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B5B47), Color(0xFF07100C)],
                ),
                categories: _forestCategories,
              )
            : const HengPalette(
                theme: AppColorTheme.forest,
                brightness: Brightness.light,
                background: Color(0xFFF4F3EE),
                surface: Colors.white,
                field: Color(0xFFF1F3EE),
                border: Color(0xFFE3E6E0),
                primary: Color(0xFF0B5B47),
                primaryDark: Color(0xFF063A2C),
                onPrimary: Colors.white,
                accent: Color(0xFF147A61),
                text: Color(0xFF0B1F1A),
                muted: Color(0xFF5F6E67),
                income: Color(0xFF0E7C5A),
                expense: Color(0xFFB42318),
                warning: Color(0xFF8A5300),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B5B47), Color(0xFF063A2C)],
                ),
                categories: _forestCategories,
              );
      case AppColorTheme.freshForest:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.freshForest,
                brightness: Brightness.dark,
                background: Color(0xFF0A1411),
                surface: Color(0xFF10201A),
                field: Color(0xFF162820),
                border: Color(0xFF233A30),
                primary: Color(0xFF6EE7B7),
                primaryDark: Color(0xFF0B5B47),
                onPrimary: Color(0xFF052B21),
                accent: Color(0xFF5EEAD4),
                text: Color(0xFFE8F1EC),
                muted: Color(0xFF9FB8AD),
                income: Color(0xFF6EE7B7),
                expense: Color(0xFFF87171),
                warning: Color(0xFFFBBF24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B5B47), Color(0xFF07100C)],
                ),
                categories: _freshForestCategories,
              )
            : const HengPalette(
                theme: AppColorTheme.freshForest,
                brightness: Brightness.light,
                background: Color(0xFFF7FAF7),
                surface: Colors.white,
                field: Color(0xFFF0F5F0),
                border: Color(0xFFE2EAE3),
                primary: Color(0xFF0B5B47),
                primaryDark: Color(0xFF063A2C),
                onPrimary: Colors.white,
                accent: Color(0xFF10B981),
                text: Color(0xFF0B1F1A),
                muted: Color(0xFF5F6E67),
                income: Color(0xFF0E7C5A),
                expense: Color(0xFFB42318),
                warning: Color(0xFF8A5300),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B5B47), Color(0xFF063A2C)],
                ),
                categories: _freshForestCategories,
              );
      case AppColorTheme.blush:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.blush,
                brightness: Brightness.dark,
                background: Color(0xFF140E10),
                surface: Color(0xFF1E1518),
                field: Color(0xFF271B1F),
                border: Color(0xFF3A2A2F),
                primary: Color(0xFFF0A6B2),
                primaryDark: Color(0xFF8A4654),
                onPrimary: Color(0xFF3A1620),
                accent: Color(0xFFD98A96),
                text: Color(0xFFF5E9E7),
                muted: Color(0xFFC4AEB0),
                income: Color(0xFF9ED4B0),
                expense: Color(0xFFF08A94),
                warning: Color(0xFFF0C08A),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7A3A48), Color(0xFF2A1219)],
                ),
                categories: _blushCategories,
              )
            : const HengPalette(
                theme: AppColorTheme.blush,
                brightness: Brightness.light,
                background: Color(0xFFFBF6F3),
                surface: Colors.white,
                field: Color(0xFFF5ECE8),
                border: Color(0xFFEADDD8),
                primary: Color(0xFFA64B5A),
                primaryDark: Color(0xFF7A3541),
                onPrimary: Colors.white,
                accent: Color(0xFFD98A96),
                text: Color(0xFF2B1B1C),
                muted: Color(0xFF7C6667),
                income: Color(0xFF5F7F6A),
                expense: Color(0xFFB42318),
                warning: Color(0xFF8A5300),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB85C6B), Color(0xFF8A3D4A)],
                ),
                categories: _blushCategories,
              );
      case AppColorTheme.peach:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.peach,
                brightness: Brightness.dark,
                background: Color(0xFF170F0B),
                surface: Color(0xFF231811),
                field: Color(0xFF2E1F16),
                border: Color(0xFF433026),
                primary: Color(0xFFF0B08A),
                primaryDark: Color(0xFF9A5A38),
                onPrimary: Color(0xFF3D2418),
                accent: Color(0xFFE8A27D),
                text: Color(0xFFF7EAE2),
                muted: Color(0xFFC8B2A4),
                income: Color(0xFF9ED4B0),
                expense: Color(0xFFF08A84),
                warning: Color(0xFFF0C08A),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8A4A2E), Color(0xFF2A1810)],
                ),
                categories: _peachCategories,
              )
            : const HengPalette(
                theme: AppColorTheme.peach,
                brightness: Brightness.light,
                background: Color(0xFFFFF7F0),
                surface: Colors.white,
                field: Color(0xFFF8EDE3),
                border: Color(0xFFEEDFD2),
                primary: Color(0xFFA94E33),
                primaryDark: Color(0xFF7A3A24),
                onPrimary: Colors.white,
                accent: Color(0xFFE8A27D),
                text: Color(0xFF2D1C14),
                muted: Color(0xFF80665A),
                income: Color(0xFF5F7F6A),
                expense: Color(0xFFB42318),
                warning: Color(0xFF8A5300),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC46A48), Color(0xFF9A4A2E)],
                ),
                categories: _peachCategories,
              );
      case AppColorTheme.lavender:
        return dark
            ? const HengPalette(
                theme: AppColorTheme.lavender,
                brightness: Brightness.dark,
                background: Color(0xFF120D16),
                surface: Color(0xFF1C1420),
                field: Color(0xFF261A2C),
                border: Color(0xFF382942),
                primary: Color(0xFFD6B8F0),
                primaryDark: Color(0xFF7A5B93),
                onPrimary: Color(0xFF2B1638),
                accent: Color(0xFFB9A0D0),
                text: Color(0xFFF1E9F5),
                muted: Color(0xFFBDAEC8),
                income: Color(0xFF9ED4B0),
                expense: Color(0xFFF08A94),
                warning: Color(0xFFF0C08A),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5A3D72), Color(0xFF1C1026)],
                ),
                categories: _lavenderCategories,
              )
            : const HengPalette(
                theme: AppColorTheme.lavender,
                brightness: Brightness.light,
                background: Color(0xFFF8F5FA),
                surface: Colors.white,
                field: Color(0xFFF1EBF5),
                border: Color(0xFFE4DAEC),
                primary: Color(0xFF72558A),
                primaryDark: Color(0xFF4F3A62),
                onPrimary: Colors.white,
                accent: Color(0xFFB9A0D0),
                text: Color(0xFF241A2B),
                muted: Color(0xFF6F6278),
                income: Color(0xFF5F7F6A),
                expense: Color(0xFFB42318),
                warning: Color(0xFF8A5300),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF83659A), Color(0xFF5A3D72)],
                ),
                categories: _lavenderCategories,
              );
    }
  }

  static HengPalette of(BuildContext context) =>
      Theme.of(context).extension<HengPalette>() ??
      forTheme(AppColorTheme.fresh, Theme.of(context).brightness);

  @override
  HengPalette copyWith({
    AppColorTheme? theme,
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? field,
    Color? border,
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? accent,
    Color? text,
    Color? muted,
    Color? income,
    Color? expense,
    Color? warning,
    LinearGradient? gradient,
    Map<String, Color>? categories,
  }) {
    return HengPalette(
      theme: theme ?? this.theme,
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      field: field ?? this.field,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      gradient: gradient ?? this.gradient,
      categories: categories ?? this.categories,
    );
  }

  @override
  HengPalette lerp(ThemeExtension<HengPalette>? other, double t) {
    if (other is! HengPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return HengPalette(
      theme: t < 0.5 ? theme : other.theme,
      brightness: t < 0.5 ? brightness : other.brightness,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      field: c(field, other.field),
      border: c(border, other.border),
      primary: c(primary, other.primary),
      primaryDark: c(primaryDark, other.primaryDark),
      onPrimary: c(onPrimary, other.onPrimary),
      accent: c(accent, other.accent),
      text: c(text, other.text),
      muted: c(muted, other.muted),
      income: c(income, other.income),
      expense: c(expense, other.expense),
      warning: c(warning, other.warning),
      gradient: LinearGradient(
        begin: gradient.begin,
        end: gradient.end,
        colors: [
          c(gradient.colors.first, other.gradient.colors.first),
          c(gradient.colors.last, other.gradient.colors.last),
        ],
      ),
      categories: {
        for (final id in categories.keys)
          id: c(categories[id]!, other.categories[id] ?? categories[id]!),
      },
    );
  }
}
