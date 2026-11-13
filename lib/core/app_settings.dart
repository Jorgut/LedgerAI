import 'package:flutter/material.dart';

/// App 语言。默认跟随系统；当前 i18n 迁移未完成时由设置页显式选择。
enum AppLanguage {
  system('跟随系统', 'System'),
  zhHans('简体中文', '简体中文'),
  zhHant('繁體中文', '繁體中文'),
  en('English', 'English'),
  ru('Русский', 'Русский');

  const AppLanguage(this.label, this.nativeLabel);

  final String label;
  final String nativeLabel;

  Locale? get locale => switch (this) {
        AppLanguage.system => null,
        AppLanguage.zhHans => const Locale('zh', 'CN'),
        AppLanguage.zhHant => const Locale('zh', 'TW'),
        AppLanguage.en => const Locale('en'),
        AppLanguage.ru => const Locale('ru'),
      };
}

/// 三套主题色。默认 [fresh]（A 清新）。
enum AppColorTheme {
  fresh('A 清新', '高明度、冷背景、明快绿'),
  forest('B 森林', '暖纸色、深绿、沉稳'),
  freshForest('C 清新森林', '冷白绿底、深绿主色、薄荷高光');

  const AppColorTheme(this.label, this.description);

  final String label;
  final String description;
}

/// 用户偏好设置。全部保存在本机 Hive box 中。
@immutable
class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.themeMode = ThemeMode.system,
    this.highContrast = false,
    this.monthlyBudget,
    this.categoryBudgets = const {},
    this.hapticsEnabled = true,
    this.biometricLock = false,
    this.elderMode = false,
    this.fontScale = 1.0,
    this.icloudSyncEnabled = false,
    this.lastSyncAt,
    this.colorTheme = AppColorTheme.fresh,
    this.language = AppLanguage.system,
  });

  /// 是否已完成首次引导。
  final bool onboardingDone;

  /// 深色 / 浅色 / 跟随系统。
  final ThemeMode themeMode;

  /// 高对比度模式（适老化）。
  final bool highContrast;

  /// 每月总预算，null 表示未设置。
  final double? monthlyBudget;

  /// 分类预算：categoryId -> 月度上限。
  final Map<String, double> categoryBudgets;

  /// 关键操作触觉反馈。
  final bool hapticsEnabled;

  /// 是否启用 Face ID / Touch ID 解锁（v1 预留，默认关闭）。
  final bool biometricLock;

  /// 适老化/父母模式：放大字体、提高对比度、简化展示。
  final bool elderMode;

  /// 应用内字体缩放（1.0 = 标准；1.15 大；1.3 特大；1.5 超大）。
  /// 与系统字号叠加时取较大值由 app 层控制。
  final double fontScale;

  /// 是否启用 iCloud 同步（CloudKit，数据只进用户自己的 iCloud）。
  final bool icloudSyncEnabled;

  /// 上次成功同步时间。
  final DateTime? lastSyncAt;

  /// 主题色；默认 A 清新。
  final AppColorTheme colorTheme;

  /// App 语言；默认跟随系统。
  final AppLanguage language;

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    bool? onboardingDone,
    ThemeMode? themeMode,
    bool? highContrast,
    double? monthlyBudget,
    bool clearMonthlyBudget = false,
    Map<String, double>? categoryBudgets,
    bool? hapticsEnabled,
    bool? biometricLock,
    bool? elderMode,
    double? fontScale,
    bool? icloudSyncEnabled,
    DateTime? lastSyncAt,
    bool clearLastSyncAt = false,
    AppColorTheme? colorTheme,
    AppLanguage? language,
  }) {
    return AppSettings(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      themeMode: themeMode ?? this.themeMode,
      highContrast: highContrast ?? this.highContrast,
      monthlyBudget:
          clearMonthlyBudget ? null : (monthlyBudget ?? this.monthlyBudget),
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      biometricLock: biometricLock ?? this.biometricLock,
      elderMode: elderMode ?? this.elderMode,
      fontScale: fontScale ?? this.fontScale,
      icloudSyncEnabled: icloudSyncEnabled ?? this.icloudSyncEnabled,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      colorTheme: colorTheme ?? this.colorTheme,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingDone': onboardingDone,
        'themeMode': themeMode.name,
        'highContrast': highContrast,
        'monthlyBudget': monthlyBudget,
        'categoryBudgets': categoryBudgets,
        'hapticsEnabled': hapticsEnabled,
        'biometricLock': biometricLock,
        'elderMode': elderMode,
        'fontScale': fontScale,
        'icloudSyncEnabled': icloudSyncEnabled,
        'lastSyncAt': lastSyncAt?.toIso8601String(),
        'colorTheme': colorTheme.name,
        'language': language.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawTheme = json['themeMode'] as String?;
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == rawTheme,
      orElse: () => ThemeMode.system,
    );
    final rawBudgets = json['categoryBudgets'];
    return AppSettings(
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      themeMode: themeMode,
      highContrast: json['highContrast'] as bool? ?? false,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      categoryBudgets: rawBudgets is Map
          ? rawBudgets
              .map((key, value) => MapEntry('$key', (value as num).toDouble()))
          : const {},
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      biometricLock: json['biometricLock'] as bool? ?? false,
      elderMode: json['elderMode'] as bool? ?? false,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      icloudSyncEnabled: json['icloudSyncEnabled'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] is String
          ? DateTime.tryParse(json['lastSyncAt'] as String)
          : null,
      colorTheme: AppColorTheme.values.firstWhere(
        (theme) => theme.name == json['colorTheme'],
        orElse: () => AppColorTheme.fresh,
      ),
      language: AppLanguage.values.firstWhere(
        (lang) => lang.name == json['language'],
        orElse: () => AppLanguage.system,
      ),
    );
  }
}
