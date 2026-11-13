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
      'Simplified Chinese, Traditional Chinese, English, and Russian are supported. Changes apply immediately.';

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

  @override
  String get txDeleteFailed => 'Delete failed. Try again.';

  @override
  String txDeleted(String amount, String category) {
    return 'Deleted “$category” $amount';
  }

  @override
  String get txRestored => 'Entry restored';

  @override
  String get txRestoreFailed => 'Restore failed. Please add it again.';

  @override
  String get txFilter => 'Filter';

  @override
  String get txReset => 'Reset';

  @override
  String get txType => 'Type';

  @override
  String get txAll => 'All';

  @override
  String get txCategory => 'Category';

  @override
  String get txAllCategories => 'All categories';

  @override
  String get txExpenseCategories => 'Expense categories';

  @override
  String get txIncomeCategories => 'Income categories';

  @override
  String get txDone => 'Done';

  @override
  String get txTitle => 'Transactions';

  @override
  String get txSearchHint => 'Search note, merchant, category, or amount';

  @override
  String get txClearSearch => 'Clear search';

  @override
  String get txRemoveTypeFilter => 'Remove type filter';

  @override
  String get txRemoveCategoryFilter => 'Remove category filter';

  @override
  String get txClearFilter => 'Clear filter';

  @override
  String txMonthEmpty(int month) {
    return 'No entries in $month';
  }

  @override
  String get txMonthEmptyHint =>
      'Tap + in the middle, or use receipt/voice entry.';

  @override
  String get txAddOne => 'Add entry';

  @override
  String get txNoMatch => 'No matching entries';

  @override
  String get txNoMatchHint => 'Try another keyword or clear filters.';

  @override
  String get txClearFilters => 'Clear filters';

  @override
  String get txDelete => 'Delete';

  @override
  String txExpenseFooter(String amount) {
    return 'Expenses $amount';
  }

  @override
  String txIncomeFooter(String amount) {
    return 'Income $amount';
  }

  @override
  String get rptTitle => 'Reports';

  @override
  String get rptBackMonth => 'Back to this month';

  @override
  String get rptEmpty => 'No entries this month';

  @override
  String get rptEmptyHint =>
      'Scan a receipt or hold to speak; reports will build automatically.';

  @override
  String get rptTrend => '6-month trend';

  @override
  String get rptTrendSub => 'Income vs expenses by month';

  @override
  String get rptShare => 'Category share';

  @override
  String get rptBalance => 'Balance this month';

  @override
  String rptBalanceSem(String amount) {
    return 'Balance this month $amount';
  }

  @override
  String rptCount(int count) {
    return '$count entries';
  }

  @override
  String rptAmountLabel(String amount, String label) {
    return '$label $amount';
  }

  @override
  String get rptTotalIncome => 'Total income';

  @override
  String get rptTotalExpense => 'Total expenses';

  @override
  String rptCategorySem(String amount, int percent, String category) {
    return '$category, $amount, $percent%';
  }

  @override
  String get rptInsights => 'Insights';

  @override
  String get rptLocal => 'Computed on device';

  @override
  String get commonConfirm => 'OK';

  @override
  String get addTitle => 'Add entry';

  @override
  String get addEditTitle => 'Edit entry';

  @override
  String get addDeleteTooltip => 'Delete this entry';

  @override
  String get addDeleteDialogTitle => 'Delete this entry?';

  @override
  String get addDeleteDialogContent => 'This can\'t be undone. Delete it?';

  @override
  String get addDeleted => 'Deleted';

  @override
  String get addSaveRecord => 'Save entry';

  @override
  String get addSaveChanges => 'Save changes';

  @override
  String get addSaved => 'Entry added';

  @override
  String get addUpdated => 'Entry updated';

  @override
  String get addSaveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get addAmountRequired => 'Enter an amount greater than 0';

  @override
  String get addAmountLabel => 'Amount';

  @override
  String get addNoteLabel => 'Note';

  @override
  String get addNoteHint => 'e.g. lunch, subway, groceries';

  @override
  String addMerchantChip(String merchant) {
    return 'Merchant: $merchant';
  }

  @override
  String get addClearMerchant => 'Remove merchant';

  @override
  String get addDateLabel => 'Date';

  @override
  String get addSelectDate => 'Select date';

  @override
  String addDateSemantic(String label) {
    return 'Date, $label, select date';
  }

  @override
  String get addDatePickerFailed =>
      'Couldn\'t open the date picker. Please try again.';

  @override
  String get addFooterSaveHint => 'Check the details, then tap save below';

  @override
  String get addRawTextTitle => 'Scanned text';

  @override
  String get addCollapseRawText => 'Collapse scanned text';

  @override
  String get addExpandRawText => 'Expand scanned text';

  @override
  String get addReceiptFilledBanner =>
      'Filled in from the receipt. Check the amount, category, and date before saving.';

  @override
  String get addVoiceFilledBanner =>
      'Filled in from voice. Check the amount, category, and date before saving.';

  @override
  String get addReceiptTitle => 'Scan a receipt';

  @override
  String get addReceiptBody =>
      'Point at a receipt or bill screenshot; the amount, merchant, and date are recognized on this device. Photos are never uploaded or saved to your library.';

  @override
  String get addReceiptCamera => 'Scan with camera';

  @override
  String get addReceiptGallery => 'Choose from library';

  @override
  String get addReceiptRecognizing => 'Recognizing on this device…';

  @override
  String get addSwitchToManual => 'Switch to manual entry';

  @override
  String get addVoiceTitle => 'Voice entry';

  @override
  String get addVoiceBody =>
      'Hold the button below and say something like “I spent 42 on lunch today.” Speech is recognized on this device; audio is never uploaded or saved.';

  @override
  String get addVoiceListening => 'Listening — tap to stop';

  @override
  String get addVoiceHoldToTalk => 'Hold to talk';

  @override
  String get addVoiceToggleHint => 'Double tap to start or stop voice input';

  @override
  String get addVoiceTapOrHold => 'Tap or hold to talk';

  @override
  String get addVoiceLivePlaceholder => 'Recognized text appears here';

  @override
  String get addVoiceExamplesTitle => 'Try saying';

  @override
  String addVoiceExample(String example) {
    return '“$example”';
  }

  @override
  String get addVoiceChecking => 'Checking voice recognition availability…';

  @override
  String get addVoiceSwitchToManual => 'Can\'t speak? Switch to manual entry';

  @override
  String get addVoiceUnavailableTitle =>
      'Voice recognition isn\'t available on this device right now';

  @override
  String get addVoiceUnavailableBody =>
      'It may not support Chinese dictation, voice/microphone permission may be denied, or the app may be running in a simulator. Manual entry still works fully.';

  @override
  String get addVoiceUseManual => 'Use manual entry';

  @override
  String get addVoiceNotSupported =>
      'Voice recognition isn\'t supported on this device. Please enter manually.';

  @override
  String get addVoiceStartFailed =>
      'Couldn\'t start voice recognition. Please use manual entry.';

  @override
  String get addVoiceNoSpeech =>
      'Didn\'t catch that — please say it again or enter manually';

  @override
  String get addVoiceNoAmount =>
      'Couldn\'t catch the amount — say it again or enter manually';

  @override
  String get addVoiceRecognized => 'Recognized — check it, then save';

  @override
  String get addVoiceFallbackError =>
      'Voice recognition is unavailable. Please enter manually.';

  @override
  String get addOcrNoTextError =>
      'No text recognized. Try a clearer receipt or enter manually.';

  @override
  String get addOcrNoText => 'No text recognized. Try again or enter manually.';

  @override
  String get addOcrNoAmountError =>
      'Text was recognized but no amount was found. Expand the scanned text and add it manually.';

  @override
  String get addOcrNoAmount => 'No amount recognized — please add it manually';

  @override
  String get addOcrRecognized => 'Recognized — check the amount and category';

  @override
  String get addOcrFailedError =>
      'Recognition failed. Try again or enter manually.';

  @override
  String get addOcrFailed => 'Recognition failed. Try again or enter manually.';

  @override
  String get addCameraPermission =>
      'Camera unavailable. Allow HENG to access the camera in system settings.';

  @override
  String get addPhotoPermission =>
      'Photo library unavailable. Allow HENG to access photos in system settings.';

  @override
  String get addCameraOpenFailed =>
      'Couldn\'t open the camera. Choose from the library instead.';

  @override
  String get addPhotoReadFailed =>
      'Couldn\'t read this photo. Try again or enter manually.';

  @override
  String get addModeManual => 'Manual';

  @override
  String get addModeReceipt => 'Scan';

  @override
  String get addModeVoice => 'Voice';

  @override
  String addModeSemantic(String label) {
    return '$label entry';
  }

  @override
  String get budgetScreenTitle => 'Budget';

  @override
  String get budgetEmptyMessage =>
      'Set a monthly spending limit and the home and reports screens will show progress and warn you when you overspend.';

  @override
  String get budgetSetAction => 'Set monthly budget';

  @override
  String get budgetCategorySection => 'Category budgets';

  @override
  String get budgetTapCategoryHint => 'Tap a category to set';

  @override
  String get budgetLocalNote =>
      'Budgets are only reminders on this device and never block spending. Category budgets can add up to more than the total.';

  @override
  String get budgetTotalLabel => 'Total budget this month';

  @override
  String budgetTotalSemantic(String amount) {
    return 'Total budget this month $amount';
  }

  @override
  String budgetSpentSummary(String amount, int count) {
    return 'Spent this month $amount across $count entries';
  }

  @override
  String get budgetEditAction => 'Edit budget';

  @override
  String get budgetClearAction => 'Clear budget';

  @override
  String get budgetOverBadge => 'Over';

  @override
  String get budgetSetCategoryHint => 'Tap to set a category budget';

  @override
  String budgetRowNone(String amount) {
    return 'Spent this month $amount';
  }

  @override
  String budgetRowDetail(String budget, String spent, String percent) {
    return 'Budget $budget · spent $spent ($percent%)';
  }

  @override
  String budgetRowDetailOver(
      String budget, String spent, String percent, String over) {
    return 'Budget $budget · spent $spent ($percent%), over by $over';
  }

  @override
  String budgetCategorySemantic(String category, String spent, String budget) {
    return '$category budget, spent $spent, budget $budget';
  }

  @override
  String budgetCategorySemanticOver(
      String category, String spent, String budget, String over) {
    return '$category budget, spent $spent, budget $budget, over by $over';
  }

  @override
  String budgetCategorySemanticNone(String category) {
    return '$category, no budget set, tap to set';
  }

  @override
  String get budgetTotalDialogTitle => 'Set total monthly budget';

  @override
  String get budgetTotalDialogTitleEdit => 'Edit total monthly budget';

  @override
  String get budgetTotalDialogSubtitle =>
      'The monthly spending limit used for budget progress on the home and reports screens.';

  @override
  String get budgetTotalCleared => 'Monthly budget cleared';

  @override
  String get budgetTotalUpdated => 'Monthly budget updated';

  @override
  String budgetCategoryDialogTitle(String category) {
    return 'Set a budget for “$category”';
  }

  @override
  String get budgetCategoryDialogSubtitle =>
      'The monthly spending limit for this category. You can change it anytime.';

  @override
  String budgetCategoryCleared(String category) {
    return 'Cleared the budget for “$category”';
  }

  @override
  String budgetCategoryUpdated(String category) {
    return 'Budget for “$category” updated';
  }

  @override
  String get budgetClearConfirmTitle => 'Clear the monthly budget?';

  @override
  String get budgetClearConfirmContent =>
      'Clearing it turns off budget progress and overspend reminders. Your entries are not affected.';

  @override
  String get budgetClearDialogAction => 'Clear';

  @override
  String get budgetAmountError =>
      'Enter an amount greater than 0, for example 3000';

  @override
  String get budgetAmountLabel => 'Amount (yuan)';

  @override
  String get budgetDeleteAction => 'Delete this budget';

  @override
  String get onboardTitle1 => 'Your ledger,\nonly on your phone';

  @override
  String get onboardBody1 =>
      'HENG requires no login, no network, and never uploads. All entries and settings stay on this device and can be exported anytime.';

  @override
  String get onboardPoint1a => 'Fully offline';

  @override
  String get onboardPoint1b => 'No personal data collected';

  @override
  String get onboardPoint1c => 'Export your data anytime';

  @override
  String get onboardTitle2 => 'Snap a receipt,\ndone';

  @override
  String get onboardBody2 =>
      'Point at a receipt or bill screenshot: the amount, merchant, and date are recognized on device. Just confirm and save.';

  @override
  String get onboardPoint2a => 'On-device text recognition';

  @override
  String get onboardPoint2b => 'Automatic category matching';

  @override
  String get onboardPoint2c => 'View the scanned text';

  @override
  String get onboardTitle3 => 'Say it out loud,\nlogged in 3 seconds';

  @override
  String get onboardBody3 =>
      'Say “I spent 42 on lunch today” and the amount and category are filled in. Great when typing isn\'t convenient.';

  @override
  String get onboardPoint3a => 'On-device voice recognition';

  @override
  String get onboardPoint3b => 'One sentence is enough';

  @override
  String get onboardPoint3c => 'Enter manually if unclear';

  @override
  String get onboardSaveFailed => 'Couldn\'t save settings. Please try again.';

  @override
  String get onboardPrevious => 'Previous page';

  @override
  String get onboardSkip => 'Skip';

  @override
  String onboardPageSemantic(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get onboardStart => 'Start tracking';

  @override
  String get onboardNext => 'Next';

  @override
  String get legalLastUpdated => 'Last updated: November 2026';

  @override
  String get privacyOneLineTitle => 'In one sentence';

  @override
  String get privacyOneLineBody =>
      'HENG is a local-first finance app: no sign-in, no network, and none of your ledger data is uploaded. Text recognition, voice recognition, and insights all run on your iPhone.';

  @override
  String get privacyNotCollectedTitle => 'What we don\'t collect';

  @override
  String get privacyNotCollectedBody =>
      'The developer does not collect, store, or transmit any of your personal information or ledger data. The app has no accounts and includes no third-party analytics, advertising, push, or social login SDKs. That is why the App Store privacy label says “Data Not Collected.”';

  @override
  String get privacyStorageTitle => 'Where your data lives';

  @override
  String get privacyStorageBody =>
      'Entries, budgets, and preferences are stored only in the app\'s sandboxed database on this device. Unless you explicitly export and share them from Settings → Data, this data never leaves your device.';

  @override
  String get privacyCameraTitle => 'Camera and photos';

  @override
  String get privacyCameraBody =>
      'When you scan a receipt, the app takes one image via the system camera or photo library and extracts text on-device using iOS Vision. The original image is never saved to your library or uploaded, and is released from memory once recognition finishes.';

  @override
  String get privacyMicTitle => 'Microphone and speech';

  @override
  String get privacyMicBody =>
      'Voice entry uses iOS speech recognition and requires on-device recognition. Audio is never written to disk or uploaded. If the system can\'t recognize speech on-device, the feature reports that it is temporarily unavailable rather than falling back to the cloud.';

  @override
  String get privacyExportDeleteTitle => 'Export and deletion';

  @override
  String get privacyExportDeleteBody =>
      'You can export a CSV sheet or JSON backup from Settings → Data and keep or share the file yourself; you can also delete all entries at once with Settings → Clear all entries. Uninstalling the app deletes all data stored on this device, so export a backup first.';

  @override
  String get privacyPermissionsTitle => 'Permissions';

  @override
  String get privacyPermissionsBody =>
      'Camera, photos, microphone, and speech recognition permissions are all optional and requested only when the matching feature is used. If you decline them, manual entry, reports, budgets, and export still work normally.';

  @override
  String get privacyChildrenTitle => 'Children\'s privacy';

  @override
  String get privacyChildrenBody =>
      'The app collects no user data and contains no ads or third-party tracking, so it is suitable for all users, including minors; we do not target children with tailored content.';

  @override
  String get privacyUpdatesTitle => 'Policy updates';

  @override
  String get privacyUpdatesBody =>
      'If a future version changes how data is handled, we will update this page in the app and adjust the App Store privacy label accordingly.';

  @override
  String get privacyContactTitle => 'Contact us';

  @override
  String get privacyContactBody =>
      'If you have questions about this policy, contact us through the “App Support” link on the App Store product page.';

  @override
  String get termsServiceTitle => 'About the service';

  @override
  String get termsServiceBody =>
      'HENG is a free, local-first personal finance tool offering manual entry, receipt scanning, voice entry, income and expense reports, budget reminders, and data export. All features run on this device.';

  @override
  String get termsNoticeTitle => 'Using the app';

  @override
  String get termsNoticeBody =>
      'You are responsible for the accuracy of what you enter. Receipt and voice recognition may make mistakes due to blurry receipts, accents, or background noise, so check before saving. We recommend exporting a JSON backup regularly.';

  @override
  String get termsFreeTitle => 'Free, no in-app purchases';

  @override
  String get termsFreeBody =>
      'The current version is free: no subscriptions, no in-app purchases, no ads. If pricing changes in the future, we will explain it in the app in advance and it will not affect data already stored on your device.';

  @override
  String get termsBackupTitle => 'Data and backups';

  @override
  String get termsBackupBody =>
      'Your data is stored only on this device; the developer cannot access it or restore it for you. To the extent permitted by applicable law, you are responsible for data loss caused by a lost device, system failure, uninstalling the app, or clearing data yourself. You can export a backup from Settings at any time.';

  @override
  String get termsDisclaimerTitle => 'Disclaimer';

  @override
  String get termsDisclaimerBody =>
      'Statistics, budget reminders, and “Insights” in the app are generated from on-device data using fixed rules. They are for personal record-keeping reference only and are not investment, financial, tax, legal, or medical advice. You bear the risk of any decision you make based on the app\'s content.';

  @override
  String get termsIpTitle => 'Intellectual property';

  @override
  String get termsIpBody =>
      'The app\'s interface, icons, copy, and code belong to the developer. You may use exported personal ledger data for personal purposes, but not in ways that infringe the rights of others.';

  @override
  String get termsChangesTitle => 'Changes and termination';

  @override
  String get termsChangesBody =>
      'We may adjust or improve features with system updates. If maintenance ends in the future, we will announce it in the app in advance; you can still use your local data and export a backup at any time.';

  @override
  String get termsLawTitle => 'Governing law';

  @override
  String get termsLawBody =>
      'This agreement is governed by the laws of the People\'s Republic of China. Any dispute arising from it should first be resolved through friendly negotiation.';

  @override
  String get termsContactTitle => 'Contact us';

  @override
  String get termsContactBody =>
      'If you have questions about this agreement, contact us through the “App Support” link on the App Store product page.';

  @override
  String get budgetBarNotSet => 'No budget set';

  @override
  String budgetBarNearLimit(String percent) {
    return 'Almost at your budget — $percent% used';
  }

  @override
  String budgetBarUsed(String percent) {
    return '$percent% used';
  }

  @override
  String get budgetBarSemantic => 'Budget progress';

  @override
  String budgetBarSemanticWith(String label) {
    return 'Budget progress ($label)';
  }

  @override
  String budgetBarValue(String status, String spent, String budget) {
    return '$status, spent $spent, budget $budget';
  }

  @override
  String budgetBarOver(String amount) {
    return 'Over by $amount';
  }

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catHome => 'Home';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catMedical => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catCommunication => 'Communication';

  @override
  String get catSocial => 'Social';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBonus => 'Bonus';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catParttime => 'Part-time';

  @override
  String get catGift => 'Gift';

  @override
  String get catOtherIncome => 'Other';

  @override
  String get undo => 'Undo';

  @override
  String get monthPrev => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String get monthCurrent => 'This is the current month';

  @override
  String amountSemantic(String amount) {
    return 'Amount $amount';
  }

  @override
  String get currencyUnit => '';

  @override
  String get chartEmpty => 'Not enough data for a trend yet';

  @override
  String chartSemantic(int count) {
    return 'Income and expense trend for $count months';
  }

  @override
  String get donutTotal => 'Total';

  @override
  String get donutEmpty => 'No category data';

  @override
  String get donutNoData => 'No data';

  @override
  String donutSemantic(String amount, String label) {
    return 'Category share donut, $label $amount';
  }

  @override
  String donutDesc(String percent, String amount, String category) {
    return '$category $amount, $percent%';
  }

  @override
  String get introStarting => 'HENG is starting';

  @override
  String get introTagline => 'A ledger that stays on your phone';

  @override
  String get introFooter => 'LOCAL FIRST · NO LOGIN · NO NETWORK';
}
