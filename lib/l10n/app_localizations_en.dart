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
}
