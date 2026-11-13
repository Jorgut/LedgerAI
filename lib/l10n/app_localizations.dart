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
  /// **'本月结余 {amount} 元'**
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
  /// **'本月收入 {amount} 元'**
  String incomeSemantic(String amount);

  /// No description provided for @expenseSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月支出 {amount} 元'**
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

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settingsAppearance;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get darkMode;

  /// No description provided for @highContrast.
  ///
  /// In zh, this message translates to:
  /// **'高对比度'**
  String get highContrast;

  /// No description provided for @highContrastSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'适合弱视或强光环境，文字更清晰'**
  String get highContrastSubtitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In zh, this message translates to:
  /// **'语言 / Language'**
  String get settingsLanguageSection;

  /// No description provided for @appLanguage.
  ///
  /// In zh, this message translates to:
  /// **'App 语言'**
  String get appLanguage;

  /// No description provided for @languageMigrationNote.
  ///
  /// In zh, this message translates to:
  /// **'已支持简体中文 / 繁體中文 / English / Русский；切换后立即生效。'**
  String get languageMigrationNote;

  /// No description provided for @chooseThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'选择主题色'**
  String get chooseThemeColor;

  /// No description provided for @themeColorNote.
  ///
  /// In zh, this message translates to:
  /// **'默认 A 清新；深色模式会自动使用对应深色版本。'**
  String get themeColorNote;

  /// No description provided for @settingsElderSection.
  ///
  /// In zh, this message translates to:
  /// **'适老化'**
  String get settingsElderSection;

  /// No description provided for @elderMode.
  ///
  /// In zh, this message translates to:
  /// **'父母模式'**
  String get elderMode;

  /// No description provided for @elderModeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'更大字体、更高对比、简化展示，适合长辈使用'**
  String get elderModeSubtitle;

  /// No description provided for @appFontSize.
  ///
  /// In zh, this message translates to:
  /// **'应用内字体大小'**
  String get appFontSize;

  /// No description provided for @fontScaleStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get fontScaleStandard;

  /// No description provided for @fontScaleLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get fontScaleLarge;

  /// No description provided for @fontScaleXLarge.
  ///
  /// In zh, this message translates to:
  /// **'特大'**
  String get fontScaleXLarge;

  /// No description provided for @fontScaleXXLarge.
  ///
  /// In zh, this message translates to:
  /// **'超大'**
  String get fontScaleXXLarge;

  /// No description provided for @fontScaleNote.
  ///
  /// In zh, this message translates to:
  /// **'标准 / 大 / 特大 / 超大四档，下方滑块可微调；只影响衡账 App，仍会叠加系统字号。父母模式期间自动使用特大字号，关闭后回到你选择的字号。'**
  String get fontScaleNote;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneralSection;

  /// No description provided for @haptics.
  ///
  /// In zh, this message translates to:
  /// **'触觉反馈'**
  String get haptics;

  /// No description provided for @hapticsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'记账、保存等操作时轻震一下'**
  String get hapticsSubtitle;

  /// No description provided for @budgetManagement.
  ///
  /// In zh, this message translates to:
  /// **'预算管理'**
  String get budgetManagement;

  /// No description provided for @monthlyBudgetTotal.
  ///
  /// In zh, this message translates to:
  /// **'本月总预算 {amount}'**
  String monthlyBudgetTotal(String amount);

  /// No description provided for @noMonthlyBudget.
  ///
  /// In zh, this message translates to:
  /// **'还没有设置月度预算'**
  String get noMonthlyBudget;

  /// No description provided for @icloudSync.
  ///
  /// In zh, this message translates to:
  /// **'iCloud 同步'**
  String get icloudSync;

  /// No description provided for @icloudWaitingFirstSync.
  ///
  /// In zh, this message translates to:
  /// **'已开启，等待首次同步'**
  String get icloudWaitingFirstSync;

  /// No description provided for @lastSyncAt.
  ///
  /// In zh, this message translates to:
  /// **'上次同步：{time}'**
  String lastSyncAt(String time);

  /// No description provided for @icloudSyncOffSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'多设备同步到自己的 iCloud，开发者看不到数据'**
  String get icloudSyncOffSubtitle;

  /// No description provided for @syncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get syncNow;

  /// No description provided for @syncingNow.
  ///
  /// In zh, this message translates to:
  /// **'正在同步…'**
  String get syncingNow;

  /// No description provided for @syncNowSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'把本机账单与 iCloud 合并'**
  String get syncNowSubtitle;

  /// No description provided for @icloudSyncNote.
  ///
  /// In zh, this message translates to:
  /// **'数据只写入你自己的 iCloud private database，衡账没有服务器；1.1 内测期间免费。'**
  String get icloudSyncNote;

  /// No description provided for @syncComplete.
  ///
  /// In zh, this message translates to:
  /// **'同步完成：下载 {downloaded} 笔，上传 {uploaded} 笔'**
  String syncComplete(int downloaded, int uploaded);

  /// No description provided for @syncCompleteWithDeleted.
  ///
  /// In zh, this message translates to:
  /// **'同步完成：下载 {downloaded} 笔，上传 {uploaded} 笔，删除 {deleted} 笔'**
  String syncCompleteWithDeleted(int downloaded, int uploaded, int deleted);

  /// No description provided for @syncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败：{error}'**
  String syncFailed(String error);

  /// No description provided for @dataSectionLocalOnly.
  ///
  /// In zh, this message translates to:
  /// **'数据（只保存在本机）'**
  String get dataSectionLocalOnly;

  /// No description provided for @exportCsv.
  ///
  /// In zh, this message translates to:
  /// **'导出 CSV 表格'**
  String get exportCsv;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 笔账单，可在 Excel / Numbers 中查看'**
  String exportCsvSubtitle(int count);

  /// No description provided for @exportJsonBackup.
  ///
  /// In zh, this message translates to:
  /// **'导出 JSON 备份'**
  String get exportJsonBackup;

  /// No description provided for @exportJsonBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'包含全部账单与设置，可用于迁移或找回数据'**
  String get exportJsonBackupSubtitle;

  /// No description provided for @importWechatAlipay.
  ///
  /// In zh, this message translates to:
  /// **'导入微信/支付宝账单'**
  String get importWechatAlipay;

  /// No description provided for @importWechatAlipaySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'CSV 文件，自动识别收支、商户并分类；重复记录会跳过'**
  String get importWechatAlipaySubtitle;

  /// No description provided for @importJsonBackup.
  ///
  /// In zh, this message translates to:
  /// **'导入 JSON 备份'**
  String get importJsonBackup;

  /// No description provided for @importJsonBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从衡账导出的备份文件合并账单与设置'**
  String get importJsonBackupSubtitle;

  /// No description provided for @clearAllTransactions.
  ///
  /// In zh, this message translates to:
  /// **'清空全部账单'**
  String get clearAllTransactions;

  /// No description provided for @clearDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'仅删除本机账单，预算与设置保留；需两次确认'**
  String get clearDataSubtitle;

  /// No description provided for @clearAllTransactionsConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空全部账单？'**
  String get clearAllTransactionsConfirmTitle;

  /// No description provided for @clearDataConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'将删除本机保存的 {count} 笔账单记录，预算与设置会保留。此操作无法撤销。'**
  String clearDataConfirmContent(int count);

  /// No description provided for @continueAction.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get continueAction;

  /// No description provided for @finalConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'最后确认'**
  String get finalConfirmTitle;

  /// No description provided for @finalConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复。如果还想保留账单，请先返回并导出 JSON 备份。'**
  String get finalConfirmContent;

  /// No description provided for @backAction.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get backAction;

  /// No description provided for @confirmClear.
  ///
  /// In zh, this message translates to:
  /// **'确认清空'**
  String get confirmClear;

  /// No description provided for @clearedAllTransactions.
  ///
  /// In zh, this message translates to:
  /// **'已清空全部账单'**
  String get clearedAllTransactions;

  /// No description provided for @exportNoData.
  ///
  /// In zh, this message translates to:
  /// **'还没有账单数据，先记一笔再导出'**
  String get exportNoData;

  /// No description provided for @exportCsvShareSubject.
  ///
  /// In zh, this message translates to:
  /// **'衡账 · 账单表格'**
  String get exportCsvShareSubject;

  /// No description provided for @exportJsonShareSubject.
  ///
  /// In zh, this message translates to:
  /// **'衡账 · 数据备份'**
  String get exportJsonShareSubject;

  /// No description provided for @exportCsvTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出账单 CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportJsonTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出 JSON 备份'**
  String get exportJsonTitle;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请稍后重试'**
  String get exportFailed;

  /// No description provided for @billCsvFileType.
  ///
  /// In zh, this message translates to:
  /// **'账单 CSV'**
  String get billCsvFileType;

  /// No description provided for @jsonBackupFileType.
  ///
  /// In zh, this message translates to:
  /// **'JSON 备份'**
  String get jsonBackupFileType;

  /// No description provided for @importEncodingWarning.
  ///
  /// In zh, this message translates to:
  /// **'文件编码可能不是 UTF-8，部分文字可能乱码；建议在微信/支付宝里重新导出'**
  String get importEncodingWarning;

  /// No description provided for @importNoBill.
  ///
  /// In zh, this message translates to:
  /// **'没有可导入的账单'**
  String get importNoBill;

  /// No description provided for @importAllDuplicates.
  ///
  /// In zh, this message translates to:
  /// **'这 {count} 笔记录都已经在账本里了'**
  String importAllDuplicates(int count);

  /// No description provided for @importBillTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入账单'**
  String get importBillTitle;

  /// No description provided for @importBillSummary.
  ///
  /// In zh, this message translates to:
  /// **'识别到 {total} 笔收支，{duplicates, select, some{其中 {duplicateCount} 笔已存在，} other{}}将新增 {fresh} 笔。\n{skipped, select, some{已跳过 {skippedCount} 行（不计收支/失败/重复等）。\n} other{}}导入后可在账单页修改分类和备注。'**
  String importBillSummary(int total, String duplicates, int duplicateCount,
      int fresh, String skipped, int skippedCount);

  /// No description provided for @importButtonCount.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 笔'**
  String importButtonCount(int count);

  /// No description provided for @importAction.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importAction;

  /// No description provided for @importedCount.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 笔账单'**
  String importedCount(int count);

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{error}'**
  String importFailed(String error);

  /// No description provided for @importJsonConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'将把备份中的账单合并到当前账本（同 ID 记录会覆盖），并恢复备份里的预算与偏好设置。是否继续？'**
  String get importJsonConfirmContent;

  /// No description provided for @importBackupFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败，请确认文件是衡账导出的 JSON 备份'**
  String get importBackupFailed;

  /// No description provided for @noDataToClear.
  ///
  /// In zh, this message translates to:
  /// **'当前没有账单数据'**
  String get noDataToClear;

  /// No description provided for @badgeNoLogin.
  ///
  /// In zh, this message translates to:
  /// **'不登录'**
  String get badgeNoLogin;

  /// No description provided for @badgeNoNetwork.
  ///
  /// In zh, this message translates to:
  /// **'不联网'**
  String get badgeNoNetwork;

  /// No description provided for @badgeNoUpload.
  ///
  /// In zh, this message translates to:
  /// **'不上传'**
  String get badgeNoUpload;

  /// No description provided for @versionBuild.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}（构建 {build}）'**
  String versionBuild(String version, String build);

  /// No description provided for @aboutLocalFirstNote.
  ///
  /// In zh, this message translates to:
  /// **'衡账是本地优先的记账 App：账单、预算和设置只保存在这台 iPhone 上，拍照与语音识别都在本机完成。卸载 App 会一并删除数据，建议定期导出备份。'**
  String get aboutLocalFirstNote;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @userAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get userAgreement;

  /// No description provided for @themeFresh.
  ///
  /// In zh, this message translates to:
  /// **'A 清新'**
  String get themeFresh;

  /// No description provided for @themeForest.
  ///
  /// In zh, this message translates to:
  /// **'B 森林'**
  String get themeForest;

  /// No description provided for @themeFreshForest.
  ///
  /// In zh, this message translates to:
  /// **'C 清新森林'**
  String get themeFreshForest;

  /// No description provided for @txDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败，请重试'**
  String get txDeleteFailed;

  /// No description provided for @txDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除「{category}」{amount}'**
  String txDeleted(String amount, String category);

  /// No description provided for @txRestored.
  ///
  /// In zh, this message translates to:
  /// **'已恢复这笔记录'**
  String get txRestored;

  /// No description provided for @txRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'恢复失败，请重新记一笔'**
  String get txRestoreFailed;

  /// No description provided for @txFilter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get txFilter;

  /// No description provided for @txReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get txReset;

  /// No description provided for @txType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get txType;

  /// No description provided for @txAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get txAll;

  /// No description provided for @txCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get txCategory;

  /// No description provided for @txAllCategories.
  ///
  /// In zh, this message translates to:
  /// **'全部分类'**
  String get txAllCategories;

  /// No description provided for @txExpenseCategories.
  ///
  /// In zh, this message translates to:
  /// **'支出分类'**
  String get txExpenseCategories;

  /// No description provided for @txIncomeCategories.
  ///
  /// In zh, this message translates to:
  /// **'收入分类'**
  String get txIncomeCategories;

  /// No description provided for @txDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get txDone;

  /// No description provided for @txTitle.
  ///
  /// In zh, this message translates to:
  /// **'账单'**
  String get txTitle;

  /// No description provided for @txSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索备注、商户、分类或金额'**
  String get txSearchHint;

  /// No description provided for @txClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索'**
  String get txClearSearch;

  /// No description provided for @txRemoveTypeFilter.
  ///
  /// In zh, this message translates to:
  /// **'移除类型筛选'**
  String get txRemoveTypeFilter;

  /// No description provided for @txRemoveCategoryFilter.
  ///
  /// In zh, this message translates to:
  /// **'移除分类筛选'**
  String get txRemoveCategoryFilter;

  /// No description provided for @txClearFilter.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get txClearFilter;

  /// No description provided for @txMonthEmpty.
  ///
  /// In zh, this message translates to:
  /// **'{month}月还没有记录'**
  String txMonthEmpty(int month);

  /// No description provided for @txMonthEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'点中间的「+」，或用拍照、语音快速记一笔。'**
  String get txMonthEmptyHint;

  /// No description provided for @txAddOne.
  ///
  /// In zh, this message translates to:
  /// **'记一笔'**
  String get txAddOne;

  /// No description provided for @txNoMatch.
  ///
  /// In zh, this message translates to:
  /// **'没有符合条件的记录'**
  String get txNoMatch;

  /// No description provided for @txNoMatchHint.
  ///
  /// In zh, this message translates to:
  /// **'换个关键词，或清除筛选后再看看。'**
  String get txNoMatchHint;

  /// No description provided for @txClearFilters.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get txClearFilters;

  /// No description provided for @txDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get txDelete;

  /// No description provided for @txExpenseFooter.
  ///
  /// In zh, this message translates to:
  /// **'支出 {amount}'**
  String txExpenseFooter(String amount);

  /// No description provided for @txIncomeFooter.
  ///
  /// In zh, this message translates to:
  /// **'收入 {amount}'**
  String txIncomeFooter(String amount);

  /// No description provided for @rptTitle.
  ///
  /// In zh, this message translates to:
  /// **'报表'**
  String get rptTitle;

  /// No description provided for @rptBackMonth.
  ///
  /// In zh, this message translates to:
  /// **'回到本月'**
  String get rptBackMonth;

  /// No description provided for @rptEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这个月还没有账单'**
  String get rptEmpty;

  /// No description provided for @rptEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'用拍照识别扫一张小票，或按住说一句话，报表会自动汇总。'**
  String get rptEmptyHint;

  /// No description provided for @rptTrend.
  ///
  /// In zh, this message translates to:
  /// **'近 6 个月趋势'**
  String get rptTrend;

  /// No description provided for @rptTrendSub.
  ///
  /// In zh, this message translates to:
  /// **'收入与支出按月对比'**
  String get rptTrendSub;

  /// No description provided for @rptShare.
  ///
  /// In zh, this message translates to:
  /// **'分类占比'**
  String get rptShare;

  /// No description provided for @rptBalance.
  ///
  /// In zh, this message translates to:
  /// **'本月结余'**
  String get rptBalance;

  /// No description provided for @rptBalanceSem.
  ///
  /// In zh, this message translates to:
  /// **'本月结余 {amount} 元'**
  String rptBalanceSem(String amount);

  /// No description provided for @rptCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 笔记录'**
  String rptCount(int count);

  /// No description provided for @rptAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{label} {amount} 元'**
  String rptAmountLabel(String amount, String label);

  /// No description provided for @rptTotalIncome.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get rptTotalIncome;

  /// No description provided for @rptTotalExpense.
  ///
  /// In zh, this message translates to:
  /// **'总支出'**
  String get rptTotalExpense;

  /// No description provided for @rptCategorySem.
  ///
  /// In zh, this message translates to:
  /// **'{category}，{amount} 元，占 {percent}%'**
  String rptCategorySem(String amount, int percent, String category);

  /// No description provided for @rptInsights.
  ///
  /// In zh, this message translates to:
  /// **'智能建议'**
  String get rptInsights;

  /// No description provided for @rptLocal.
  ///
  /// In zh, this message translates to:
  /// **'本机计算'**
  String get rptLocal;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @addTitle.
  ///
  /// In zh, this message translates to:
  /// **'记一笔'**
  String get addTitle;

  /// No description provided for @addEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑记录'**
  String get addEditTitle;

  /// No description provided for @addDeleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除这笔记录'**
  String get addDeleteTooltip;

  /// No description provided for @addDeleteDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除这笔记录？'**
  String get addDeleteDialogTitle;

  /// No description provided for @addDeleteDialogContent.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复，确定要删除吗？'**
  String get addDeleteDialogContent;

  /// No description provided for @addDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除'**
  String get addDeleted;

  /// No description provided for @addSaveRecord.
  ///
  /// In zh, this message translates to:
  /// **'保存记录'**
  String get addSaveRecord;

  /// No description provided for @addSaveChanges.
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get addSaveChanges;

  /// No description provided for @addSaved.
  ///
  /// In zh, this message translates to:
  /// **'已记一笔'**
  String get addSaved;

  /// No description provided for @addUpdated.
  ///
  /// In zh, this message translates to:
  /// **'已更新记录'**
  String get addUpdated;

  /// No description provided for @addSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请重试'**
  String get addSaveFailed;

  /// No description provided for @addAmountRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入大于 0 的金额'**
  String get addAmountRequired;

  /// No description provided for @addAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get addAmountLabel;

  /// No description provided for @addNoteLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get addNoteLabel;

  /// No description provided for @addNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：午餐、地铁、超市'**
  String get addNoteHint;

  /// No description provided for @addMerchantChip.
  ///
  /// In zh, this message translates to:
  /// **'商户：{merchant}'**
  String addMerchantChip(String merchant);

  /// No description provided for @addClearMerchant.
  ///
  /// In zh, this message translates to:
  /// **'清除商户'**
  String get addClearMerchant;

  /// No description provided for @addDateLabel.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get addDateLabel;

  /// No description provided for @addSelectDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get addSelectDate;

  /// No description provided for @addDateSemantic.
  ///
  /// In zh, this message translates to:
  /// **'日期，{label}，选择日期'**
  String addDateSemantic(String label);

  /// No description provided for @addDatePickerFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开日期选择器，请重试'**
  String get addDatePickerFailed;

  /// No description provided for @addFooterSaveHint.
  ///
  /// In zh, this message translates to:
  /// **'确认无误后点下方按钮保存'**
  String get addFooterSaveHint;

  /// No description provided for @addRawTextTitle.
  ///
  /// In zh, this message translates to:
  /// **'识别原文'**
  String get addRawTextTitle;

  /// No description provided for @addCollapseRawText.
  ///
  /// In zh, this message translates to:
  /// **'收起识别原文'**
  String get addCollapseRawText;

  /// No description provided for @addExpandRawText.
  ///
  /// In zh, this message translates to:
  /// **'展开识别原文'**
  String get addExpandRawText;

  /// No description provided for @addReceiptFilledBanner.
  ///
  /// In zh, this message translates to:
  /// **'已从小票识别填入，请核对金额、分类和日期后保存。'**
  String get addReceiptFilledBanner;

  /// No description provided for @addVoiceFilledBanner.
  ///
  /// In zh, this message translates to:
  /// **'已从语音识别填入，请核对金额、分类和日期后保存。'**
  String get addVoiceFilledBanner;

  /// No description provided for @addReceiptTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别小票'**
  String get addReceiptTitle;

  /// No description provided for @addReceiptBody.
  ///
  /// In zh, this message translates to:
  /// **'对准小票或账单截图，本机自动识别金额、商户和日期。照片不会上传，也不会保存到相册。'**
  String get addReceiptBody;

  /// No description provided for @addReceiptCamera.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别'**
  String get addReceiptCamera;

  /// No description provided for @addReceiptGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get addReceiptGallery;

  /// No description provided for @addReceiptRecognizing.
  ///
  /// In zh, this message translates to:
  /// **'正在本机识别…'**
  String get addReceiptRecognizing;

  /// No description provided for @addSwitchToManual.
  ///
  /// In zh, this message translates to:
  /// **'改为手动输入'**
  String get addSwitchToManual;

  /// No description provided for @addVoiceTitle.
  ///
  /// In zh, this message translates to:
  /// **'语音记账'**
  String get addVoiceTitle;

  /// No description provided for @addVoiceBody.
  ///
  /// In zh, this message translates to:
  /// **'按住下方按钮说一句话，例如「今天午餐花了 42 块」。语音只在本机识别，不会上传或保存音频。'**
  String get addVoiceBody;

  /// No description provided for @addVoiceListening.
  ///
  /// In zh, this message translates to:
  /// **'正在聆听，轻点结束'**
  String get addVoiceListening;

  /// No description provided for @addVoiceHoldToTalk.
  ///
  /// In zh, this message translates to:
  /// **'按住说话'**
  String get addVoiceHoldToTalk;

  /// No description provided for @addVoiceToggleHint.
  ///
  /// In zh, this message translates to:
  /// **'双击开始或结束语音输入'**
  String get addVoiceToggleHint;

  /// No description provided for @addVoiceTapOrHold.
  ///
  /// In zh, this message translates to:
  /// **'轻点或按住说话'**
  String get addVoiceTapOrHold;

  /// No description provided for @addVoiceLivePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'实时识别文字会显示在这里'**
  String get addVoiceLivePlaceholder;

  /// No description provided for @addVoiceExamplesTitle.
  ///
  /// In zh, this message translates to:
  /// **'可以这样说'**
  String get addVoiceExamplesTitle;

  /// No description provided for @addVoiceExample.
  ///
  /// In zh, this message translates to:
  /// **'「{example}」'**
  String addVoiceExample(String example);

  /// No description provided for @addVoiceChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检查语音识别可用性…'**
  String get addVoiceChecking;

  /// No description provided for @addVoiceSwitchToManual.
  ///
  /// In zh, this message translates to:
  /// **'不方便说？改为手动输入'**
  String get addVoiceSwitchToManual;

  /// No description provided for @addVoiceUnavailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'此设备暂时无法使用本机语音识别'**
  String get addVoiceUnavailableTitle;

  /// No description provided for @addVoiceUnavailableBody.
  ///
  /// In zh, this message translates to:
  /// **'可能是不支持中文听写、未授予语音/麦克风权限，或正在模拟器运行。手动记账功能完全不受影响。'**
  String get addVoiceUnavailableBody;

  /// No description provided for @addVoiceUseManual.
  ///
  /// In zh, this message translates to:
  /// **'改用手动输入'**
  String get addVoiceUseManual;

  /// No description provided for @addVoiceNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'此设备暂不支持本机语音识别，请手动输入'**
  String get addVoiceNotSupported;

  /// No description provided for @addVoiceStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'语音识别启动失败，请改用手动输入'**
  String get addVoiceStartFailed;

  /// No description provided for @addVoiceNoSpeech.
  ///
  /// In zh, this message translates to:
  /// **'没有听清，请再说一次或手动输入'**
  String get addVoiceNoSpeech;

  /// No description provided for @addVoiceNoAmount.
  ///
  /// In zh, this message translates to:
  /// **'没有听清金额，请再说一次，或手动输入'**
  String get addVoiceNoAmount;

  /// No description provided for @addVoiceRecognized.
  ///
  /// In zh, this message translates to:
  /// **'已识别，请核对后保存'**
  String get addVoiceRecognized;

  /// No description provided for @addVoiceFallbackError.
  ///
  /// In zh, this message translates to:
  /// **'语音识别暂不可用，请手动输入'**
  String get addVoiceFallbackError;

  /// No description provided for @addOcrNoTextError.
  ///
  /// In zh, this message translates to:
  /// **'没有识别到文字，请换一张清晰的小票，或手动输入。'**
  String get addOcrNoTextError;

  /// No description provided for @addOcrNoText.
  ///
  /// In zh, this message translates to:
  /// **'没有识别到文字，请重试或手动输入'**
  String get addOcrNoText;

  /// No description provided for @addOcrNoAmountError.
  ///
  /// In zh, this message translates to:
  /// **'识别到了文字，但没有找到金额，请展开原文手动补充。'**
  String get addOcrNoAmountError;

  /// No description provided for @addOcrNoAmount.
  ///
  /// In zh, this message translates to:
  /// **'没有识别到金额，请手动补充'**
  String get addOcrNoAmount;

  /// No description provided for @addOcrRecognized.
  ///
  /// In zh, this message translates to:
  /// **'已识别，请核对金额和分类'**
  String get addOcrRecognized;

  /// No description provided for @addOcrFailedError.
  ///
  /// In zh, this message translates to:
  /// **'识别失败，请重试或手动输入。'**
  String get addOcrFailedError;

  /// No description provided for @addOcrFailed.
  ///
  /// In zh, this message translates to:
  /// **'识别失败，请重试或手动输入'**
  String get addOcrFailed;

  /// No description provided for @addCameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'无法使用相机，请在系统设置中允许「衡账」访问相机。'**
  String get addCameraPermission;

  /// No description provided for @addPhotoPermission.
  ///
  /// In zh, this message translates to:
  /// **'无法访问相册，请在系统设置中允许「衡账」访问照片。'**
  String get addPhotoPermission;

  /// No description provided for @addCameraOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开相机，请改用相册选择。'**
  String get addCameraOpenFailed;

  /// No description provided for @addPhotoReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法读取这张照片，请重试或手动输入。'**
  String get addPhotoReadFailed;

  /// No description provided for @addModeManual.
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get addModeManual;

  /// No description provided for @addModeReceipt.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get addModeReceipt;

  /// No description provided for @addModeVoice.
  ///
  /// In zh, this message translates to:
  /// **'语音'**
  String get addModeVoice;

  /// No description provided for @addModeSemantic.
  ///
  /// In zh, this message translates to:
  /// **'{label}记账'**
  String addModeSemantic(String label);

  /// No description provided for @budgetScreenTitle.
  ///
  /// In zh, this message translates to:
  /// **'预算'**
  String get budgetScreenTitle;

  /// No description provided for @budgetEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'设置每月支出上限后，首页和报表会显示预算进度，花超了会提醒你。'**
  String get budgetEmptyMessage;

  /// No description provided for @budgetSetAction.
  ///
  /// In zh, this message translates to:
  /// **'设置月度预算'**
  String get budgetSetAction;

  /// No description provided for @budgetCategorySection.
  ///
  /// In zh, this message translates to:
  /// **'分类预算'**
  String get budgetCategorySection;

  /// No description provided for @budgetTapCategoryHint.
  ///
  /// In zh, this message translates to:
  /// **'点击分类设置'**
  String get budgetTapCategoryHint;

  /// No description provided for @budgetLocalNote.
  ///
  /// In zh, this message translates to:
  /// **'预算只用于本机提醒，不会限制消费；分类预算之和可以超过总预算。'**
  String get budgetLocalNote;

  /// No description provided for @budgetTotalLabel.
  ///
  /// In zh, this message translates to:
  /// **'本月总预算'**
  String get budgetTotalLabel;

  /// No description provided for @budgetTotalSemantic.
  ///
  /// In zh, this message translates to:
  /// **'本月总预算 {amount} 元'**
  String budgetTotalSemantic(String amount);

  /// No description provided for @budgetSpentSummary.
  ///
  /// In zh, this message translates to:
  /// **'本月已支出 {amount}，共 {count} 笔'**
  String budgetSpentSummary(String amount, int count);

  /// No description provided for @budgetEditAction.
  ///
  /// In zh, this message translates to:
  /// **'编辑预算'**
  String get budgetEditAction;

  /// No description provided for @budgetClearAction.
  ///
  /// In zh, this message translates to:
  /// **'清除预算'**
  String get budgetClearAction;

  /// No description provided for @budgetOverBadge.
  ///
  /// In zh, this message translates to:
  /// **'超支'**
  String get budgetOverBadge;

  /// No description provided for @budgetSetCategoryHint.
  ///
  /// In zh, this message translates to:
  /// **'点击设置分类预算'**
  String get budgetSetCategoryHint;

  /// No description provided for @budgetRowNone.
  ///
  /// In zh, this message translates to:
  /// **'本月已支出 {amount}'**
  String budgetRowNone(String amount);

  /// No description provided for @budgetRowDetail.
  ///
  /// In zh, this message translates to:
  /// **'预算 {budget} · 已支出 {spent}（{percent}%）'**
  String budgetRowDetail(String budget, String spent, String percent);

  /// No description provided for @budgetRowDetailOver.
  ///
  /// In zh, this message translates to:
  /// **'预算 {budget} · 已支出 {spent}（{percent}%），超支 {over}'**
  String budgetRowDetailOver(
      String budget, String spent, String percent, String over);

  /// No description provided for @budgetCategorySemantic.
  ///
  /// In zh, this message translates to:
  /// **'{category}预算，已支出 {spent} 元，预算 {budget} 元'**
  String budgetCategorySemantic(String category, String spent, String budget);

  /// No description provided for @budgetCategorySemanticOver.
  ///
  /// In zh, this message translates to:
  /// **'{category}预算，已支出 {spent} 元，预算 {budget} 元，已超支 {over} 元'**
  String budgetCategorySemanticOver(
      String category, String spent, String budget, String over);

  /// No description provided for @budgetCategorySemanticNone.
  ///
  /// In zh, this message translates to:
  /// **'{category}，未设置预算，点按设置'**
  String budgetCategorySemanticNone(String category);

  /// No description provided for @budgetTotalDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置月度总预算'**
  String get budgetTotalDialogTitle;

  /// No description provided for @budgetTotalDialogTitleEdit.
  ///
  /// In zh, this message translates to:
  /// **'修改月度总预算'**
  String get budgetTotalDialogTitleEdit;

  /// No description provided for @budgetTotalDialogSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'每月支出的上限，用于首页和报表的预算进度提醒。'**
  String get budgetTotalDialogSubtitle;

  /// No description provided for @budgetTotalCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除月度预算'**
  String get budgetTotalCleared;

  /// No description provided for @budgetTotalUpdated.
  ///
  /// In zh, this message translates to:
  /// **'月度预算已更新'**
  String get budgetTotalUpdated;

  /// No description provided for @budgetCategoryDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置「{category}」预算'**
  String budgetCategoryDialogTitle(String category);

  /// No description provided for @budgetCategoryDialogSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'这个分类每月的支出上限，可随时修改。'**
  String get budgetCategoryDialogSubtitle;

  /// No description provided for @budgetCategoryCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除「{category}」预算'**
  String budgetCategoryCleared(String category);

  /// No description provided for @budgetCategoryUpdated.
  ///
  /// In zh, this message translates to:
  /// **'「{category}」预算已更新'**
  String budgetCategoryUpdated(String category);

  /// No description provided for @budgetClearConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除月度预算？'**
  String get budgetClearConfirmTitle;

  /// No description provided for @budgetClearConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'清除后预算进度与超支提醒会关闭，账单记录不会受影响。'**
  String get budgetClearConfirmContent;

  /// No description provided for @budgetClearDialogAction.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get budgetClearDialogAction;

  /// No description provided for @budgetAmountError.
  ///
  /// In zh, this message translates to:
  /// **'请输入大于 0 的金额，例如 3000'**
  String get budgetAmountError;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In zh, this message translates to:
  /// **'金额（元）'**
  String get budgetAmountLabel;

  /// No description provided for @budgetDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除该预算'**
  String get budgetDeleteAction;

  /// No description provided for @onboardTitle1.
  ///
  /// In zh, this message translates to:
  /// **'你的账本，\n只在你手机里'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In zh, this message translates to:
  /// **'衡账不登录、不联网、不上传。所有账单和设置都保存在本机，随时可以导出备份。'**
  String get onboardBody1;

  /// No description provided for @onboardPoint1a.
  ///
  /// In zh, this message translates to:
  /// **'完全离线运行'**
  String get onboardPoint1a;

  /// No description provided for @onboardPoint1b.
  ///
  /// In zh, this message translates to:
  /// **'不收集任何个人信息'**
  String get onboardPoint1b;

  /// No description provided for @onboardPoint1c.
  ///
  /// In zh, this message translates to:
  /// **'数据可随时导出'**
  String get onboardPoint1c;

  /// No description provided for @onboardTitle2.
  ///
  /// In zh, this message translates to:
  /// **'拍一张小票，\n就记好了'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In zh, this message translates to:
  /// **'对准小票或账单截图拍照，本机自动识别金额、商户和日期，确认一下就能保存。'**
  String get onboardBody2;

  /// No description provided for @onboardPoint2a.
  ///
  /// In zh, this message translates to:
  /// **'设备端文字识别'**
  String get onboardPoint2a;

  /// No description provided for @onboardPoint2b.
  ///
  /// In zh, this message translates to:
  /// **'自动匹配分类'**
  String get onboardPoint2b;

  /// No description provided for @onboardPoint2c.
  ///
  /// In zh, this message translates to:
  /// **'识别原文可展开查看'**
  String get onboardPoint2c;

  /// No description provided for @onboardTitle3.
  ///
  /// In zh, this message translates to:
  /// **'按住说一句，\n3 秒记一笔'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In zh, this message translates to:
  /// **'说「今天午餐花了 42 块」，自动填好金额和分类。不方便打字时尤其好用。'**
  String get onboardBody3;

  /// No description provided for @onboardPoint3a.
  ///
  /// In zh, this message translates to:
  /// **'本机语音识别'**
  String get onboardPoint3a;

  /// No description provided for @onboardPoint3b.
  ///
  /// In zh, this message translates to:
  /// **'支持中文一句话'**
  String get onboardPoint3b;

  /// No description provided for @onboardPoint3c.
  ///
  /// In zh, this message translates to:
  /// **'听不清时可手动输入'**
  String get onboardPoint3c;

  /// No description provided for @onboardSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存设置失败，请重试'**
  String get onboardSaveFailed;

  /// No description provided for @onboardPrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一页'**
  String get onboardPrevious;

  /// No description provided for @onboardSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get onboardSkip;

  /// No description provided for @onboardPageSemantic.
  ///
  /// In zh, this message translates to:
  /// **'第 {current} 页，共 {total} 页'**
  String onboardPageSemantic(int current, int total);

  /// No description provided for @onboardStart.
  ///
  /// In zh, this message translates to:
  /// **'开始记账'**
  String get onboardStart;

  /// No description provided for @onboardNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get onboardNext;

  /// No description provided for @legalLastUpdated.
  ///
  /// In zh, this message translates to:
  /// **'最后更新：2026 年 11 月'**
  String get legalLastUpdated;

  /// No description provided for @privacyOneLineTitle.
  ///
  /// In zh, this message translates to:
  /// **'一句话说明'**
  String get privacyOneLineTitle;

  /// No description provided for @privacyOneLineBody.
  ///
  /// In zh, this message translates to:
  /// **'衡账是一款本地优先的记账 App：不登录、不联网、不上传你的任何账单数据。文字识别、语音识别与统计建议全部在你的 iPhone 上完成。'**
  String get privacyOneLineBody;

  /// No description provided for @privacyNotCollectedTitle.
  ///
  /// In zh, this message translates to:
  /// **'我们不收集什么'**
  String get privacyNotCollectedTitle;

  /// No description provided for @privacyNotCollectedBody.
  ///
  /// In zh, this message translates to:
  /// **'开发者不收集、不存储、不传输你的任何个人信息或记账数据。App 没有账号体系，也不包含第三方统计、广告、推送或社交登录 SDK。因此 App Store 的隐私标签为「Data Not Collected」（不收集数据）。'**
  String get privacyNotCollectedBody;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据保存在哪里'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In zh, this message translates to:
  /// **'账单记录、预算和偏好设置只写入 App 在本机的沙盒数据库。除非你主动在「设置 → 数据」中导出并分享，这些数据不会离开你的设备。'**
  String get privacyStorageBody;

  /// No description provided for @privacyCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'相机与照片'**
  String get privacyCameraTitle;

  /// No description provided for @privacyCameraBody.
  ///
  /// In zh, this message translates to:
  /// **'使用拍照识别小票时，App 通过系统相机或相册获取一张图片，并使用 iOS 内置的 Vision 文字识别功能在本机提取文字。原始图片不会被保存到相册，也不会被上传；识别完成后即从内存释放。'**
  String get privacyCameraBody;

  /// No description provided for @privacyMicTitle.
  ///
  /// In zh, this message translates to:
  /// **'麦克风与语音'**
  String get privacyMicTitle;

  /// No description provided for @privacyMicBody.
  ///
  /// In zh, this message translates to:
  /// **'语音记账使用 iOS 系统语音识别，并强制要求设备端识别。音频不会被写入磁盘，也不会被上传。若系统无法在本机完成识别，该功能会提示暂不可用，而不会改用云端识别。'**
  String get privacyMicBody;

  /// No description provided for @privacyExportDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据导出与删除'**
  String get privacyExportDeleteTitle;

  /// No description provided for @privacyExportDeleteBody.
  ///
  /// In zh, this message translates to:
  /// **'你可以在「设置 → 数据」导出 CSV 表格或 JSON 备份，文件由你自己保存与分享；也可以在「设置 → 清空全部账单」一键删除全部账单记录。卸载 App 会删除本机保存的全部数据，请提前导出备份。'**
  String get privacyExportDeleteBody;

  /// No description provided for @privacyPermissionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'权限说明'**
  String get privacyPermissionsTitle;

  /// No description provided for @privacyPermissionsBody.
  ///
  /// In zh, this message translates to:
  /// **'相机、照片、麦克风与语音识别权限都是可选的，只在对应功能中按需申请。即使拒绝这些权限，手动记账、报表、预算与导出等功能仍可正常使用。'**
  String get privacyPermissionsBody;

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In zh, this message translates to:
  /// **'儿童隐私'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenBody.
  ///
  /// In zh, this message translates to:
  /// **'本 App 不收集任何用户的数据，也不含广告或第三方追踪，适用于包括未成年人在内的所有用户；我们不会针对儿童推送定向内容。'**
  String get privacyChildrenBody;

  /// No description provided for @privacyUpdatesTitle.
  ///
  /// In zh, this message translates to:
  /// **'政策更新'**
  String get privacyUpdatesTitle;

  /// No description provided for @privacyUpdatesBody.
  ///
  /// In zh, this message translates to:
  /// **'如果未来的版本改变了数据处理方式，我们会在 App 内更新本页面，并同步调整 App Store 的隐私标签。'**
  String get privacyUpdatesBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In zh, this message translates to:
  /// **'如对本政策有疑问，可以通过 App Store 商品页上的「App 支持」链接联系我们。'**
  String get privacyContactBody;

  /// No description provided for @termsServiceTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务说明'**
  String get termsServiceTitle;

  /// No description provided for @termsServiceBody.
  ///
  /// In zh, this message translates to:
  /// **'衡账是一款免费、本地优先的个人记账工具，提供手动记账、拍照识别、语音记账、收支统计报表、预算提醒与数据导出等功能。App 的全部功能都在这台设备上运行。'**
  String get termsServiceBody;

  /// No description provided for @termsNoticeTitle.
  ///
  /// In zh, this message translates to:
  /// **'使用须知'**
  String get termsNoticeTitle;

  /// No description provided for @termsNoticeBody.
  ///
  /// In zh, this message translates to:
  /// **'你需要对录入信息的准确性负责。拍照识别与语音识别的结果可能因为小票模糊、口音或环境噪音出现误差，请在保存前核对。建议定期导出 JSON 备份。'**
  String get termsNoticeBody;

  /// No description provided for @termsFreeTitle.
  ///
  /// In zh, this message translates to:
  /// **'免费与内购'**
  String get termsFreeTitle;

  /// No description provided for @termsFreeBody.
  ///
  /// In zh, this message translates to:
  /// **'当前版本免费提供，没有订阅、没有内购、没有广告。若未来调整收费方式，我们会提前在 App 内说明，不会影响你已保存在本机的数据。'**
  String get termsFreeBody;

  /// No description provided for @termsBackupTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据与备份'**
  String get termsBackupTitle;

  /// No description provided for @termsBackupBody.
  ///
  /// In zh, this message translates to:
  /// **'你的数据只保存在本机，开发者无法访问，也无法替你恢复。因设备丢失、系统故障、卸载 App 或主动清空数据造成的数据丢失，在适用法律允许的范围内由你自行承担。你可以随时在设置中导出备份。'**
  String get termsBackupBody;

  /// No description provided for @termsDisclaimerTitle.
  ///
  /// In zh, this message translates to:
  /// **'免责声明'**
  String get termsDisclaimerTitle;

  /// No description provided for @termsDisclaimerBody.
  ///
  /// In zh, this message translates to:
  /// **'App 中的统计、预算提醒与「智能建议」均基于本机数据和固定规则生成，仅作为个人记账参考，不构成投资、理财、税务、法律或医疗建议。你依据本 App 内容做出的任何决定，风险由你自行承担。'**
  String get termsDisclaimerBody;

  /// No description provided for @termsIpTitle.
  ///
  /// In zh, this message translates to:
  /// **'知识产权'**
  String get termsIpTitle;

  /// No description provided for @termsIpBody.
  ///
  /// In zh, this message translates to:
  /// **'App 的界面、图标、文案与代码归开发者所有。你可以将导出的个人账单数据用于个人用途，但不得将其用于侵犯他人权益的用途。'**
  String get termsIpBody;

  /// No description provided for @termsChangesTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务变更与终止'**
  String get termsChangesTitle;

  /// No description provided for @termsChangesBody.
  ///
  /// In zh, this message translates to:
  /// **'我们可能随系统版本更新调整或改进功能。若未来停止维护，会在 App 内提前告知；你仍然可以继续使用本地数据，并随时导出备份。'**
  String get termsChangesBody;

  /// No description provided for @termsLawTitle.
  ///
  /// In zh, this message translates to:
  /// **'适用法律'**
  String get termsLawTitle;

  /// No description provided for @termsLawBody.
  ///
  /// In zh, this message translates to:
  /// **'本协议适用中华人民共和国法律。因本协议产生的争议，双方应先友好协商解决。'**
  String get termsLawBody;

  /// No description provided for @termsContactTitle.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get termsContactTitle;

  /// No description provided for @termsContactBody.
  ///
  /// In zh, this message translates to:
  /// **'如对本协议有疑问，可以通过 App Store 商品页上的「App 支持」链接联系我们。'**
  String get termsContactBody;

  /// No description provided for @budgetBarNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置预算'**
  String get budgetBarNotSet;

  /// No description provided for @budgetBarNearLimit.
  ///
  /// In zh, this message translates to:
  /// **'预算快用完了，已用 {percent}%'**
  String budgetBarNearLimit(String percent);

  /// No description provided for @budgetBarUsed.
  ///
  /// In zh, this message translates to:
  /// **'已用 {percent}%'**
  String budgetBarUsed(String percent);

  /// No description provided for @budgetBarSemantic.
  ///
  /// In zh, this message translates to:
  /// **'预算进度'**
  String get budgetBarSemantic;

  /// No description provided for @budgetBarSemanticWith.
  ///
  /// In zh, this message translates to:
  /// **'预算进度（{label}）'**
  String budgetBarSemanticWith(String label);

  /// No description provided for @budgetBarValue.
  ///
  /// In zh, this message translates to:
  /// **'{status}，已花费 {spent}，预算 {budget}'**
  String budgetBarValue(String status, String spent, String budget);

  /// No description provided for @budgetBarOver.
  ///
  /// In zh, this message translates to:
  /// **'超支 {amount}'**
  String budgetBarOver(String amount);

  /// No description provided for @catFood.
  ///
  /// In zh, this message translates to:
  /// **'餐饮'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In zh, this message translates to:
  /// **'购物'**
  String get catShopping;

  /// No description provided for @catHome.
  ///
  /// In zh, this message translates to:
  /// **'居家'**
  String get catHome;

  /// No description provided for @catEntertainment.
  ///
  /// In zh, this message translates to:
  /// **'娱乐'**
  String get catEntertainment;

  /// No description provided for @catMedical.
  ///
  /// In zh, this message translates to:
  /// **'医疗'**
  String get catMedical;

  /// No description provided for @catEducation.
  ///
  /// In zh, this message translates to:
  /// **'学习'**
  String get catEducation;

  /// No description provided for @catCommunication.
  ///
  /// In zh, this message translates to:
  /// **'通讯'**
  String get catCommunication;

  /// No description provided for @catSocial.
  ///
  /// In zh, this message translates to:
  /// **'人情'**
  String get catSocial;

  /// No description provided for @catOtherExpense.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In zh, this message translates to:
  /// **'工资'**
  String get catSalary;

  /// No description provided for @catBonus.
  ///
  /// In zh, this message translates to:
  /// **'奖金'**
  String get catBonus;

  /// No description provided for @catInvestment.
  ///
  /// In zh, this message translates to:
  /// **'理财'**
  String get catInvestment;

  /// No description provided for @catParttime.
  ///
  /// In zh, this message translates to:
  /// **'兼职'**
  String get catParttime;

  /// No description provided for @catGift.
  ///
  /// In zh, this message translates to:
  /// **'红包'**
  String get catGift;

  /// No description provided for @catOtherIncome.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get catOtherIncome;

  /// No description provided for @undo.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo;

  /// No description provided for @monthPrev.
  ///
  /// In zh, this message translates to:
  /// **'上个月'**
  String get monthPrev;

  /// No description provided for @monthNext.
  ///
  /// In zh, this message translates to:
  /// **'下个月'**
  String get monthNext;

  /// No description provided for @monthCurrent.
  ///
  /// In zh, this message translates to:
  /// **'已经是本月'**
  String get monthCurrent;

  /// No description provided for @amountSemantic.
  ///
  /// In zh, this message translates to:
  /// **'金额 {amount}'**
  String amountSemantic(String amount);

  /// No description provided for @currencyUnit.
  ///
  /// In zh, this message translates to:
  /// **' 元'**
  String get currencyUnit;

  /// No description provided for @chartEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有足够的数据生成趋势图'**
  String get chartEmpty;

  /// No description provided for @chartSemantic.
  ///
  /// In zh, this message translates to:
  /// **'近 {count} 个月收支趋势'**
  String chartSemantic(int count);

  /// No description provided for @donutTotal.
  ///
  /// In zh, this message translates to:
  /// **'合计'**
  String get donutTotal;

  /// No description provided for @donutEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无分类数据'**
  String get donutEmpty;

  /// No description provided for @donutNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get donutNoData;

  /// No description provided for @donutSemantic.
  ///
  /// In zh, this message translates to:
  /// **'分类占比环形图，{label} {amount}'**
  String donutSemantic(String amount, String label);

  /// No description provided for @donutDesc.
  ///
  /// In zh, this message translates to:
  /// **'{category} {amount}，占 {percent}%'**
  String donutDesc(String percent, String amount, String category);

  /// No description provided for @introStarting.
  ///
  /// In zh, this message translates to:
  /// **'HENG，正在启动'**
  String get introStarting;

  /// No description provided for @introTagline.
  ///
  /// In zh, this message translates to:
  /// **'把账本留在自己手机里'**
  String get introTagline;

  /// No description provided for @introFooter.
  ///
  /// In zh, this message translates to:
  /// **'本地优先 · 不登录 · 不联网'**
  String get introFooter;
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
