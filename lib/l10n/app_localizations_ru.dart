// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HENG';

  @override
  String get navHome => 'Главная';

  @override
  String get navTransactions => 'Операции';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Цвет темы';

  @override
  String get about => 'О приложении';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get support => 'Поддержка';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get fabAdd => 'Добавить';

  @override
  String get homeBrand => 'HENG';

  @override
  String get quickActions => 'Быстрый ввод';

  @override
  String get quickActionsSubtitle =>
      'Чек, голос или вручную — несколько секунд';

  @override
  String get photoEntry => 'Скан чека';

  @override
  String get voiceEntry => 'Голосом';

  @override
  String get manualEntry => 'Вручную';

  @override
  String get recentRecords => 'Недавние';

  @override
  String recentCount(int count) {
    return 'Последние $count';
  }

  @override
  String get viewAll => 'Все';

  @override
  String get emptyRecordsTitle => 'Пока нет записей';

  @override
  String get emptyRecordsMessage =>
      'Отсканируйте чек, скажите сумму или добавьте запись вручную.';

  @override
  String get recordFirst => 'Добавить первую';

  @override
  String get localOnlyNote =>
      'Данные хранятся только на этом устройстве. Резервная копия — в Настройки → Экспорт.';

  @override
  String get balanceLabel => 'За этот месяц';

  @override
  String balanceSemantic(String amount) {
    return 'Баланс за месяц $amount';
  }

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String incomeSemantic(String amount) {
    return 'Доход за месяц $amount';
  }

  @override
  String expenseSemantic(String amount) {
    return 'Расход за месяц $amount';
  }

  @override
  String get emptyMonth =>
      'В этом месяце пока нет записей. Начните с быстрого ввода ниже.';

  @override
  String get setBudgetTitle => 'Задать бюджет на месяц';

  @override
  String get setBudgetHint =>
      'Сразу видно остаток, и предупреждение до перерасхода.';

  @override
  String get setBudgetButton => 'Задать бюджет';

  @override
  String get budgetTitle => 'Бюджет на месяц';

  @override
  String spentAmount(String amount) {
    return 'Потрачено $amount';
  }

  @override
  String remainingAmount(String amount) {
    return 'Осталось $amount';
  }

  @override
  String overspentAmount(String amount) {
    return 'Перерасход $amount';
  }

  @override
  String monthBudgetSemantic(String amount, String percent) {
    return 'Бюджет $amount, использовано $percent%';
  }
}
