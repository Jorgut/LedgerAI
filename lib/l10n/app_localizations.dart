import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'HENG'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In zh, this message translates to:
  /// **'账单'**
  String get navTransactions;

  /// No description provided for @navReports.
  ///
  /// In zh, this message translates to:
  /// **'报表'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get theme;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @privacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私说明'**
  String get privacy;

  /// No description provided for @support.
  ///
  /// In zh, this message translates to:
  /// **'支持'**
  String get support;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @fabAdd.
  ///
  /// In zh, this message translates to:
  /// **'记一笔'**
  String get fabAdd;

  /// No description provided for @homeBrand.
  ///
  /// In zh, this message translates to:
  /// **'HENG'**
  String get homeBrand;

  /// No description provided for @quickActions.
  ///
  /// In zh, this message translates to:
  /// **'快速记账'**
  String get quickActions;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照、语音或手动，几秒记一笔'**
  String get quickActionsSubtitle;

  /// No description provided for @photoEntry.
  ///
  /// In zh, this message translates to:
  /// **'拍照记账'**
  String get photoEntry;

  /// No description provided for @voiceEntry.
  ///
  /// In zh, this message translates to:
  /// **'语音记账'**
  String get voiceEntry;

  /// No description provided for @manualEntry.
  ///
  /// In zh, this message translates to:
  /// **'手动记账'**
  String get manualEntry;

  /// No description provided for @recentRecords.
  ///
  /// In zh, this message translates to:
  /// **'最近记录'**
  String get recentRecords;

  /// No description provided for @recentCount.
  ///
  /// In zh, this message translates to:
  /// **'最近 {count} 笔'**
  String recentCount(int count);

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @emptyRecordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有记录'**
  String get emptyRecordsTitle;

  /// No description provided for @emptyRecordsMessage.
  ///
  /// In zh, this message translates to:
  /// **'拍一张小票、说一句话，或手动记第一笔。'**
  String get emptyRecordsMessage;

  /// No description provided for @recordFirst.
  ///
  /// In zh, this message translates to:
  /// **'记第一笔'**
  String get recordFirst;

  /// No description provided for @localOnlyNote.
  ///
  /// In zh, this message translates to:
  /// **'数据仅保存在本机，可在「我的 → 数据导出」备份。'**
  String get localOnlyNote;

  /// No description provided for @balanceLabel.
  ///
  /// In zh, this message translates to:
  /// **'本月结余'**
  String get balanceLabel;

  /// No description provided for @balanceSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月结余 {amount}'**
  String balanceSemantic(String amount);

  /// No description provided for @income.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get expense;

  /// No description provided for @incomeSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月收入 {amount}'**
  String incomeSemantic(String amount);

  /// No description provided for @expenseSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月支出 {amount}'**
  String expenseSemantic(String amount);

  /// No description provided for @emptyMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月还没有记录，从下面快速记第一笔吧。'**
  String get emptyMonth;

  /// No description provided for @setBudgetTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置本月预算'**
  String get setBudgetTitle;

  /// No description provided for @setBudgetHint.
  ///
  /// In zh, this message translates to:
  /// **'设置后随时看到剩余额度，超支会提醒你'**
  String get setBudgetHint;

  /// No description provided for @setBudgetButton.
  ///
  /// In zh, this message translates to:
  /// **'设置预算'**
  String get setBudgetButton;

  /// No description provided for @budgetTitle.
  ///
  /// In zh, this message translates to:
  /// **'本月预算'**
  String get budgetTitle;

  /// No description provided for @spentAmount.
  ///
  /// In zh, this message translates to:
  /// **'已花 {amount}'**
  String spentAmount(String amount);

  /// No description provided for @remainingAmount.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @overspentAmount.
  ///
  /// In zh, this message translates to:
  /// **'已超支 {amount}'**
  String overspentAmount(String amount);

  /// No description provided for @monthBudgetSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月预算 {amount}，已用 {percent}%'**
  String monthBudgetSemantic(String amount, String percent);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
