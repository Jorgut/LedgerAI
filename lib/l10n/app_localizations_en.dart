// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HENG';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme color';

  @override
  String get about => 'About';

  @override
  String get privacy => 'Privacy';

  @override
  String get support => 'Support';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get fabAdd => 'Add';

  @override
  String get homeBrand => 'HENG';

  @override
  String get quickActions => 'Quick entry';

  @override
  String get quickActionsSubtitle =>
      'Receipt, voice, or manual — a few seconds each';

  @override
  String get photoEntry => 'Scan receipt';

  @override
  String get voiceEntry => 'Voice entry';

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get recentRecords => 'Recent';

  @override
  String recentCount(int count) {
    return 'Last $count entries';
  }

  @override
  String get viewAll => 'View all';

  @override
  String get emptyRecordsTitle => 'No entries yet';

  @override
  String get emptyRecordsMessage =>
      'Scan a receipt, speak an expense, or add the first one manually.';

  @override
  String get recordFirst => 'Add first entry';

  @override
  String get localOnlyNote =>
      'Your data stays on this device. Back it up in Settings → Data export.';

  @override
  String get balanceLabel => 'This month';

  @override
  String balanceSemantic(String amount) {
    return 'This month balance $amount';
  }

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expenses';

  @override
  String incomeSemantic(String amount) {
    return 'Income this month $amount';
  }

  @override
  String expenseSemantic(String amount) {
    return 'Expenses this month $amount';
  }

  @override
  String get emptyMonth =>
      'No entries this month yet. Start with a quick entry below.';

  @override
  String get setBudgetTitle => 'Set a monthly budget';

  @override
  String get setBudgetHint =>
      'See what is left at a glance, and get warned before you overspend.';

  @override
  String get setBudgetButton => 'Set budget';

  @override
  String get budgetTitle => 'Monthly budget';

  @override
  String spentAmount(String amount) {
    return 'Spent $amount';
  }

  @override
  String remainingAmount(String amount) {
    return 'Left $amount';
  }

  @override
  String overspentAmount(String amount) {
    return 'Over by $amount';
  }

  @override
  String monthBudgetSemantic(String amount, String percent) {
    return 'Monthly budget $amount, $percent% used';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get followSystem => 'Follow system';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastSubtitle =>
      'Easier to read with low vision or in bright light';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageMigrationNote =>
      'The shell, home, and settings are localized; entry, transactions, and reports are still being translated, so you may see mixed languages after switching.';

  @override
  String get chooseThemeColor => 'Choose theme color';

  @override
  String get themeColorNote =>
      'Defaults to A Fresh; dark mode automatically uses the matching dark version.';

  @override
  String get settingsElderSection => 'Accessibility';

  @override
  String get elderMode => 'Parent mode';

  @override
  String get elderModeSubtitle =>
      'Larger text, higher contrast, and a simpler layout — easier for elders';

  @override
  String get appFontSize => 'In-app text size';

  @override
  String get fontScaleStandard => 'Standard';

  @override
  String get fontScaleLarge => 'Large';

  @override
  String get fontScaleXLarge => 'Extra large';

  @override
  String get fontScaleXXLarge => 'Huge';

  @override
  String get fontScaleNote =>
      'Four presets — Standard, Large, Extra large, and Huge — with fine-tuning via the slider below. This only affects HENG and still stacks on your system text size. Parent mode uses Extra large automatically and returns to your chosen size when turned off.';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get hapticsSubtitle => 'A light tap when you add or save an entry';

  @override
  String get budgetManagement => 'Budgets';

  @override
  String monthlyBudgetTotal(String amount) {
    return 'Total monthly budget $amount';
  }

  @override
  String get noMonthlyBudget => 'No monthly budget set yet';

  @override
  String get icloudSync => 'iCloud sync';

  @override
  String get icloudWaitingFirstSync => 'On — waiting for the first sync';

  @override
  String lastSyncAt(String time) {
    return 'Last sync: $time';
  }

  @override
  String get icloudSyncOffSubtitle =>
      'Syncs across your devices through your own iCloud; the developer cannot see your data';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncingNow => 'Syncing…';

  @override
  String get syncNowSubtitle => 'Merge this device\'s entries with iCloud';

  @override
  String get icloudSyncNote =>
      'Data is written only to your own iCloud private database. HENG has no server; free during the 1.1 beta.';

  @override
  String syncComplete(int downloaded, int uploaded) {
    return 'Sync complete: $downloaded downloaded, $uploaded uploaded';
  }

  @override
  String syncCompleteWithDeleted(int downloaded, int uploaded, int deleted) {
    return 'Sync complete: $downloaded downloaded, $uploaded uploaded, $deleted deleted';
  }

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get dataSectionLocalOnly => 'Data (stored on this device only)';

  @override
  String get exportCsv => 'Export CSV sheet';

  @override
  String exportCsvSubtitle(int count) {
    return '$count entries in total, viewable in Excel / Numbers';
  }

  @override
  String get exportJsonBackup => 'Export JSON backup';

  @override
  String get exportJsonBackupSubtitle =>
      'Includes all entries and settings; use it to migrate or recover data';

  @override
  String get importWechatAlipay => 'Import WeChat/Alipay bill';

  @override
  String get importWechatAlipaySubtitle =>
      'CSV file — income, expense, merchant, and category are detected automatically; duplicates are skipped';

  @override
  String get importJsonBackup => 'Import JSON backup';

  @override
  String get importJsonBackupSubtitle =>
      'Merge entries and settings from a HENG backup file';

  @override
  String get clearAllTransactions => 'Clear all entries';

  @override
  String get clearDataSubtitle =>
      'Deletes entries on this device only; budgets and settings stay. Requires two confirmations';

  @override
  String get clearAllTransactionsConfirmTitle => 'Clear all entries?';

  @override
  String clearDataConfirmContent(int count) {
    return 'This will delete the $count entries saved on this device. Budgets and settings will stay. This cannot be undone.';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get finalConfirmTitle => 'Final confirmation';

  @override
  String get finalConfirmContent =>
      'Deleted entries cannot be recovered. To keep them, go back and export a JSON backup first.';

  @override
  String get backAction => 'Back';

  @override
  String get confirmClear => 'Yes, clear all';

  @override
  String get clearedAllTransactions => 'All entries cleared';

  @override
  String get exportNoData => 'No entries yet — add one before exporting';

  @override
  String get exportCsvShareSubject => 'HENG · Transactions CSV';

  @override
  String get exportJsonShareSubject => 'HENG · Data backup';

  @override
  String get exportCsvTitle => 'Export transactions CSV';

  @override
  String get exportJsonTitle => 'Export JSON backup';

  @override
  String get exportFailed => 'Export failed. Please try again later.';

  @override
  String get billCsvFileType => 'Bill CSV';

  @override
  String get jsonBackupFileType => 'JSON backup';

  @override
  String get importEncodingWarning =>
      'The file may not be UTF-8, so some text could be garbled; consider re-exporting from WeChat/Alipay.';

  @override
  String get importNoBill => 'No entries to import';

  @override
  String importAllDuplicates(int count) {
    return 'All $count of these entries are already in this ledger';
  }

  @override
  String get importBillTitle => 'Import bill';

  @override
  String importBillSummary(int total, String duplicates, int duplicateCount,
      int fresh, String skipped, int skippedCount) {
    String _temp0 = intl.Intl.selectLogic(
      duplicates,
      {
        'some': '$duplicateCount already exist; ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      skipped,
      {
        'some':
            '$skippedCount rows skipped (not income/expense, failed, or duplicate).\n',
        'other': '',
      },
    );
    return 'Detected $total income/expense entries. ${_temp0}This import adds $fresh.\n${_temp1}You can adjust categories and notes on the transactions page after importing.';
  }

  @override
  String importButtonCount(int count) {
    return 'Import $count';
  }

  @override
  String get importAction => 'Import';

  @override
  String importedCount(int count) {
    return 'Imported $count entries';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importJsonConfirmContent =>
      'Entries from the backup will be merged into this ledger (records with the same ID will be overwritten), and the budgets and preferences in the backup will be restored. Continue?';

  @override
  String get importBackupFailed =>
      'Import failed. Make sure the file is a JSON backup exported from HENG.';

  @override
  String get noDataToClear => 'There are no entries to clear';

  @override
  String get badgeNoLogin => 'No sign-in';

  @override
  String get badgeNoNetwork => 'No network';

  @override
  String get badgeNoUpload => 'No uploads';

  @override
  String versionBuild(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get aboutLocalFirstNote =>
      'HENG is a local-first bookkeeping app: entries, budgets, and settings stay on this iPhone, and photo and voice recognition run on-device. Deleting the app also deletes the data, so export a backup regularly.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get userAgreement => 'User agreement';

  @override
  String get themeFresh => 'A Fresh';

  @override
  String get themeForest => 'B Forest';

  @override
  String get themeFreshForest => 'C Fresh Forest';
}
