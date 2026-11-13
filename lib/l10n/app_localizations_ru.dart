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

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get followSystem => 'Как в системе';

  @override
  String get lightMode => 'Светлая';

  @override
  String get darkMode => 'Тёмная';

  @override
  String get highContrast => 'Высокий контраст';

  @override
  String get highContrastSubtitle =>
      'Удобнее читать при слабом зрении или ярком свете';

  @override
  String get settingsLanguageSection => 'Язык';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get languageMigrationNote =>
      'Оболочка, главная и настройки переведены; ввод, операции и отчёты ещё переводятся, поэтому после переключения возможна смесь языков.';

  @override
  String get chooseThemeColor => 'Выберите цвет темы';

  @override
  String get themeColorNote =>
      'По умолчанию A Fresh; в тёмной теме автоматически используется тёмный вариант.';

  @override
  String get settingsElderSection => 'Доступность';

  @override
  String get elderMode => 'Режим для родителей';

  @override
  String get elderModeSubtitle =>
      'Крупнее текст, выше контраст, проще вид — удобно для старших';

  @override
  String get appFontSize => 'Размер текста в приложении';

  @override
  String get fontScaleStandard => 'Стандартный';

  @override
  String get fontScaleLarge => 'Крупный';

  @override
  String get fontScaleXLarge => 'Очень крупный';

  @override
  String get fontScaleXXLarge => 'Огромный';

  @override
  String get fontScaleNote =>
      'Четыре уровня — стандартный, крупный, очень крупный и огромный — с точной настройкой ползунком ниже. Действует только в HENG и складывается с системным размером. В режиме для родителей автоматически используется очень крупный шрифт, после выключения возвращается ваш выбор.';

  @override
  String get settingsGeneralSection => 'Общие';

  @override
  String get haptics => 'Тактильная отдача';

  @override
  String get hapticsSubtitle => 'Короткая вибрация при записи и сохранении';

  @override
  String get budgetManagement => 'Бюджеты';

  @override
  String monthlyBudgetTotal(String amount) {
    return 'Общий бюджет на месяц $amount';
  }

  @override
  String get noMonthlyBudget => 'Бюджет на месяц не задан';

  @override
  String get icloudSync => 'Синхронизация iCloud';

  @override
  String get icloudWaitingFirstSync => 'Включено, ждём первой синхронизации';

  @override
  String lastSyncAt(String time) {
    return 'Последняя синхронизация: $time';
  }

  @override
  String get icloudSyncOffSubtitle =>
      'Синхронизация между вашими устройствами через ваш iCloud; разработчик не видит данные';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncingNow => 'Синхронизация…';

  @override
  String get syncNowSubtitle => 'Объединить записи этого устройства с iCloud';

  @override
  String get icloudSyncNote =>
      'Данные записываются только в вашу приватную базу iCloud. У HENG нет сервера; бесплатно в бета-версии 1.1.';

  @override
  String syncComplete(int downloaded, int uploaded) {
    return 'Синхронизация завершена: скачано $downloaded, загружено $uploaded';
  }

  @override
  String syncCompleteWithDeleted(int downloaded, int uploaded, int deleted) {
    return 'Синхронизация завершена: скачано $downloaded, загружено $uploaded, удалено $deleted';
  }

  @override
  String syncFailed(String error) {
    return 'Ошибка синхронизации: $error';
  }

  @override
  String get dataSectionLocalOnly => 'Данные (только на этом устройстве)';

  @override
  String get exportCsv => 'Экспорт таблицы CSV';

  @override
  String exportCsvSubtitle(int count) {
    return 'Всего $count записей; открывается в Excel / Numbers';
  }

  @override
  String get exportJsonBackup => 'Экспорт резервной копии JSON';

  @override
  String get exportJsonBackupSubtitle =>
      'Включает все записи и настройки; подходит для переноса или восстановления';

  @override
  String get importWechatAlipay => 'Импорт выписки WeChat/Alipay';

  @override
  String get importWechatAlipaySubtitle =>
      'Файл CSV — доход/расход, продавец и категория определяются автоматически; повторы пропускаются';

  @override
  String get importJsonBackup => 'Импорт резервной копии JSON';

  @override
  String get importJsonBackupSubtitle =>
      'Объединить записи и настройки из файла резервной копии HENG';

  @override
  String get clearAllTransactions => 'Удалить все записи';

  @override
  String get clearDataSubtitle =>
      'Удаляет записи только на этом устройстве; бюджеты и настройки сохраняются. Нужно два подтверждения';

  @override
  String get clearAllTransactionsConfirmTitle => 'Удалить все записи?';

  @override
  String clearDataConfirmContent(int count) {
    return 'Будут удалены $count записей, сохранённых на этом устройстве. Бюджеты и настройки сохранятся. Отменить это нельзя.';
  }

  @override
  String get continueAction => 'Продолжить';

  @override
  String get finalConfirmTitle => 'Последнее подтверждение';

  @override
  String get finalConfirmContent =>
      'Удалённые записи не восстановить. Если они нужны, вернитесь и сначала экспортируйте резервную копию JSON.';

  @override
  String get backAction => 'Назад';

  @override
  String get confirmClear => 'Да, удалить';

  @override
  String get clearedAllTransactions => 'Все записи удалены';

  @override
  String get exportNoData => 'Записей пока нет — добавьте одну перед экспортом';

  @override
  String get exportCsvShareSubject => 'HENG · Таблица операций';

  @override
  String get exportJsonShareSubject => 'HENG · Резервная копия';

  @override
  String get exportCsvTitle => 'Экспорт операций в CSV';

  @override
  String get exportJsonTitle => 'Экспорт резервной копии JSON';

  @override
  String get exportFailed => 'Ошибка экспорта. Повторите позже.';

  @override
  String get billCsvFileType => 'Выписка CSV';

  @override
  String get jsonBackupFileType => 'Резервная копия JSON';

  @override
  String get importEncodingWarning =>
      'Возможно, файл не в UTF-8, поэтому часть текста может отображаться неверно; лучше выгрузить заново из WeChat/Alipay.';

  @override
  String get importNoBill => 'Нет записей для импорта';

  @override
  String importAllDuplicates(int count) {
    return 'Все $count записей уже есть в этой книге';
  }

  @override
  String get importBillTitle => 'Импорт выписки';

  @override
  String importBillSummary(int total, String duplicates, int duplicateCount,
      int fresh, String skipped, int skippedCount) {
    String _temp0 = intl.Intl.selectLogic(
      duplicates,
      {
        'some': 'Уже есть: $duplicateCount; ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      skipped,
      {
        'some':
            'Пропущено строк: $skippedCount (не доход/расход, ошибка или дубль).\n',
        'other': '',
      },
    );
    return 'Обнаружено $total записей доходов/расходов. $_temp0Будет добавлено: $fresh.\n$_temp1После импорта категории и заметки можно изменить на странице операций.';
  }

  @override
  String importButtonCount(int count) {
    return 'Импортировать $count';
  }

  @override
  String get importAction => 'Импортировать';

  @override
  String importedCount(int count) {
    return 'Импортировано $count записей';
  }

  @override
  String importFailed(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get importJsonConfirmContent =>
      'Записи из резервной копии будут объединены с текущей книгой (записи с тем же ID перезапишутся), а бюджеты и настройки из копии будут восстановлены. Продолжить?';

  @override
  String get importBackupFailed =>
      'Ошибка импорта. Убедитесь, что файл — резервная копия JSON, экспортированная из HENG.';

  @override
  String get noDataToClear => 'Записей для удаления нет';

  @override
  String get badgeNoLogin => 'Без входа';

  @override
  String get badgeNoNetwork => 'Без сети';

  @override
  String get badgeNoUpload => 'Без загрузки';

  @override
  String versionBuild(String version, String build) {
    return 'Версия $version (сборка $build)';
  }

  @override
  String get aboutLocalFirstNote =>
      'HENG — приложение для учёта с локальным хранением: записи, бюджеты и настройки остаются на этом iPhone, а распознавание фото и голоса выполняется на устройстве. При удалении приложения данные тоже удаляются, поэтому регулярно экспортируйте резервную копию.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get userAgreement => 'Пользовательское соглашение';

  @override
  String get themeFresh => 'A Свежая';

  @override
  String get themeForest => 'B Лес';

  @override
  String get themeFreshForest => 'C Свежий лес';

  @override
  String get txDeleteFailed => 'Не удалось удалить. Повторите.';

  @override
  String txDeleted(String amount, String category) {
    return 'Удалено «$category» $amount';
  }

  @override
  String get txRestored => 'Запись восстановлена';

  @override
  String get txRestoreFailed => 'Не удалось восстановить. Добавьте снова.';

  @override
  String get txFilter => 'Фильтр';

  @override
  String get txReset => 'Сбросить';

  @override
  String get txType => 'Тип';

  @override
  String get txAll => 'Все';

  @override
  String get txCategory => 'Категория';

  @override
  String get txAllCategories => 'Все категории';

  @override
  String get txExpenseCategories => 'Категории расходов';

  @override
  String get txIncomeCategories => 'Категории доходов';

  @override
  String get txDone => 'Готово';

  @override
  String get txTitle => 'Операции';

  @override
  String get txSearchHint => 'Поиск по заметке, магазину, категории или сумме';

  @override
  String get txClearSearch => 'Очистить поиск';

  @override
  String get txRemoveTypeFilter => 'Убрать фильтр типа';

  @override
  String get txRemoveCategoryFilter => 'Убрать фильтр категории';

  @override
  String get txClearFilter => 'Сбросить фильтр';

  @override
  String txMonthEmpty(int month) {
    return 'В $month нет записей';
  }

  @override
  String get txMonthEmptyHint => 'Нажмите «+» или используйте чек/голос.';

  @override
  String get txAddOne => 'Добавить';

  @override
  String get txNoMatch => 'Нет подходящих записей';

  @override
  String get txNoMatchHint => 'Измените запрос или сбросьте фильтры.';

  @override
  String get txClearFilters => 'Сбросить фильтры';

  @override
  String get txDelete => 'Удалить';

  @override
  String txExpenseFooter(String amount) {
    return 'Расход $amount';
  }

  @override
  String txIncomeFooter(String amount) {
    return 'Доход $amount';
  }

  @override
  String get rptTitle => 'Отчёты';

  @override
  String get rptBackMonth => 'К текущему месяцу';

  @override
  String get rptEmpty => 'В этом месяце нет записей';

  @override
  String get rptEmptyHint =>
      'Сканируйте чек или удерживайте для голоса; отчёт соберётся сам.';

  @override
  String get rptTrend => 'Тренд за 6 месяцев';

  @override
  String get rptTrendSub => 'Доходы и расходы по месяцам';

  @override
  String get rptShare => 'Доли категорий';

  @override
  String get rptBalance => 'Баланс за месяц';

  @override
  String rptBalanceSem(String amount) {
    return 'Баланс за месяц $amount';
  }

  @override
  String rptCount(int count) {
    return '$count записей';
  }

  @override
  String rptAmountLabel(String amount, String label) {
    return '$label $amount';
  }

  @override
  String get rptTotalIncome => 'Всего доходов';

  @override
  String get rptTotalExpense => 'Всего расходов';

  @override
  String rptCategorySem(String amount, int percent, String category) {
    return '$category, $amount, $percent%';
  }

  @override
  String get rptInsights => 'Советы';

  @override
  String get rptLocal => 'Расчёт на устройстве';
}
