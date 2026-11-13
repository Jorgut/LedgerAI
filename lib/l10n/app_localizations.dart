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
  /// **'壳/首页/设置已迁移；记账、账单、报表等页面仍在逐批翻译，切换后可能出现中英混排。'**
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
