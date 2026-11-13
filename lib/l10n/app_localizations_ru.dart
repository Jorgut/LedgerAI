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
      'Поддерживаются упрощённый и традиционный китайский, английский и русский. Изменения применяются сразу.';

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

  @override
  String get commonConfirm => 'ОК';

  @override
  String get addTitle => 'Новая запись';

  @override
  String get addEditTitle => 'Редактировать запись';

  @override
  String get addDeleteTooltip => 'Удалить эту запись';

  @override
  String get addDeleteDialogTitle => 'Удалить эту запись?';

  @override
  String get addDeleteDialogContent =>
      'Действие нельзя отменить. Удалить запись?';

  @override
  String get addDeleted => 'Удалено';

  @override
  String get addSaveRecord => 'Сохранить запись';

  @override
  String get addSaveChanges => 'Сохранить изменения';

  @override
  String get addSaved => 'Запись добавлена';

  @override
  String get addUpdated => 'Запись обновлена';

  @override
  String get addSaveFailed => 'Не удалось сохранить. Повторите попытку.';

  @override
  String get addAmountRequired => 'Введите сумму больше 0';

  @override
  String get addAmountLabel => 'Сумма';

  @override
  String get addNoteLabel => 'Заметка';

  @override
  String get addNoteHint => 'Например: обед, метро, супермаркет';

  @override
  String addMerchantChip(String merchant) {
    return 'Магазин: $merchant';
  }

  @override
  String get addClearMerchant => 'Удалить магазин';

  @override
  String get addDateLabel => 'Дата';

  @override
  String get addSelectDate => 'Выберите дату';

  @override
  String addDateSemantic(String label) {
    return 'Дата, $label, выбрать дату';
  }

  @override
  String get addDatePickerFailed =>
      'Не удалось открыть выбор даты. Повторите попытку.';

  @override
  String get addFooterSaveHint => 'Проверьте данные и нажмите «Сохранить» ниже';

  @override
  String get addRawTextTitle => 'Распознанный текст';

  @override
  String get addCollapseRawText => 'Свернуть распознанный текст';

  @override
  String get addExpandRawText => 'Развернуть распознанный текст';

  @override
  String get addReceiptFilledBanner =>
      'Заполнено по чеку. Проверьте сумму, категорию и дату перед сохранением.';

  @override
  String get addVoiceFilledBanner =>
      'Заполнено голосом. Проверьте сумму, категорию и дату перед сохранением.';

  @override
  String get addReceiptTitle => 'Сканировать чек';

  @override
  String get addReceiptBody =>
      'Наведите на чек или скриншот счёта — сумма, магазин и дата распознаются на этом устройстве. Фото не загружаются и не сохраняются в галерею.';

  @override
  String get addReceiptCamera => 'Сканировать камерой';

  @override
  String get addReceiptGallery => 'Выбрать из галереи';

  @override
  String get addReceiptRecognizing => 'Распознавание на устройстве…';

  @override
  String get addSwitchToManual => 'Перейти к ручному вводу';

  @override
  String get addVoiceTitle => 'Голосовой ввод';

  @override
  String get addVoiceBody =>
      'Удерживайте кнопку ниже и скажите, например: «Сегодня обед стоил 42». Речь распознаётся на этом устройстве, аудио не загружается и не сохраняется.';

  @override
  String get addVoiceListening => 'Слушаю — нажмите, чтобы остановить';

  @override
  String get addVoiceHoldToTalk => 'Удерживайте, чтобы говорить';

  @override
  String get addVoiceToggleHint =>
      'Дважды коснитесь, чтобы начать или остановить голосовой ввод';

  @override
  String get addVoiceTapOrHold => 'Коснитесь или удерживайте, чтобы говорить';

  @override
  String get addVoiceLivePlaceholder => 'Распознанный текст появится здесь';

  @override
  String get addVoiceExamplesTitle => 'Попробуйте сказать';

  @override
  String addVoiceExample(String example) {
    return '«$example»';
  }

  @override
  String get addVoiceChecking => 'Проверяем доступность распознавания речи…';

  @override
  String get addVoiceSwitchToManual =>
      'Неудобно говорить? Перейдите к ручному вводу';

  @override
  String get addVoiceUnavailableTitle =>
      'Распознавание речи сейчас недоступно на этом устройстве';

  @override
  String get addVoiceUnavailableBody =>
      'Возможно, устройство не поддерживает диктовку на китайском, нет разрешения на микрофон или приложение запущено в симуляторе. Ручной ввод работает полностью.';

  @override
  String get addVoiceUseManual => 'Использовать ручной ввод';

  @override
  String get addVoiceNotSupported =>
      'Это устройство не поддерживает распознавание речи. Введите вручную.';

  @override
  String get addVoiceStartFailed =>
      'Не удалось запустить распознавание речи. Используйте ручной ввод.';

  @override
  String get addVoiceNoSpeech => 'Не расслышал. Повторите или введите вручную.';

  @override
  String get addVoiceNoAmount =>
      'Не удалось распознать сумму. Повторите или введите вручную.';

  @override
  String get addVoiceRecognized => 'Распознано — проверьте и сохраните';

  @override
  String get addVoiceFallbackError =>
      'Распознавание речи недоступно. Введите вручную.';

  @override
  String get addOcrNoTextError =>
      'Текст не распознан. Попробуйте более чёткий чек или введите вручную.';

  @override
  String get addOcrNoText =>
      'Текст не распознан. Повторите или введите вручную.';

  @override
  String get addOcrNoAmountError =>
      'Текст распознан, но сумма не найдена. Разверните текст и добавьте её вручную.';

  @override
  String get addOcrNoAmount => 'Сумма не распознана. Введите её вручную.';

  @override
  String get addOcrRecognized => 'Распознано — проверьте сумму и категорию';

  @override
  String get addOcrFailedError =>
      'Не удалось распознать. Повторите или введите вручную.';

  @override
  String get addOcrFailed =>
      'Не удалось распознать. Повторите или введите вручную.';

  @override
  String get addCameraPermission =>
      'Камера недоступна. Разрешите HENG доступ к камере в настройках системы.';

  @override
  String get addPhotoPermission =>
      'Галерея недоступна. Разрешите HENG доступ к фото в настройках системы.';

  @override
  String get addCameraOpenFailed =>
      'Не удалось открыть камеру. Выберите из галереи.';

  @override
  String get addPhotoReadFailed =>
      'Не удалось прочитать фото. Повторите или введите вручную.';

  @override
  String get addModeManual => 'Вручную';

  @override
  String get addModeReceipt => 'Скан';

  @override
  String get addModeVoice => 'Голос';

  @override
  String addModeSemantic(String label) {
    return 'Ввод: $label';
  }

  @override
  String get budgetScreenTitle => 'Бюджет';

  @override
  String get budgetEmptyMessage =>
      'Задайте месячный лимит расходов — на главном экране и в отчётах появится прогресс, а при перерасходе придёт предупреждение.';

  @override
  String get budgetSetAction => 'Задать месячный бюджет';

  @override
  String get budgetCategorySection => 'Бюджеты по категориям';

  @override
  String get budgetTapCategoryHint => 'Коснитесь категории';

  @override
  String get budgetLocalNote =>
      'Бюджеты — только напоминания на этом устройстве, они не ограничивают траты. Сумма бюджетов по категориям может превышать общий.';

  @override
  String get budgetTotalLabel => 'Общий бюджет на месяц';

  @override
  String budgetTotalSemantic(String amount) {
    return 'Общий бюджет на месяц: $amount';
  }

  @override
  String budgetSpentSummary(String amount, int count) {
    return 'Потрачено в этом месяце: $amount, записей: $count';
  }

  @override
  String get budgetEditAction => 'Изменить бюджет';

  @override
  String get budgetClearAction => 'Сбросить бюджет';

  @override
  String get budgetOverBadge => 'Перерасход';

  @override
  String get budgetSetCategoryHint => 'Коснитесь, чтобы задать бюджет';

  @override
  String budgetRowNone(String amount) {
    return 'Потрачено в этом месяце: $amount';
  }

  @override
  String budgetRowDetail(String budget, String spent, String percent) {
    return 'Бюджет $budget · потрачено $spent ($percent%)';
  }

  @override
  String budgetRowDetailOver(
      String budget, String spent, String percent, String over) {
    return 'Бюджет $budget · потрачено $spent ($percent%), перерасход $over';
  }

  @override
  String budgetCategorySemantic(String category, String spent, String budget) {
    return 'Бюджет «$category»: потрачено $spent, бюджет $budget';
  }

  @override
  String budgetCategorySemanticOver(
      String category, String spent, String budget, String over) {
    return 'Бюджет «$category»: потрачено $spent, бюджет $budget, перерасход $over';
  }

  @override
  String budgetCategorySemanticNone(String category) {
    return '«$category»: бюджет не задан, коснитесь, чтобы задать';
  }

  @override
  String get budgetTotalDialogTitle => 'Задать общий месячный бюджет';

  @override
  String get budgetTotalDialogTitleEdit => 'Изменить общий месячный бюджет';

  @override
  String get budgetTotalDialogSubtitle =>
      'Месячный лимит расходов для прогресса бюджета на главном экране и в отчётах.';

  @override
  String get budgetTotalCleared => 'Месячный бюджет сброшен';

  @override
  String get budgetTotalUpdated => 'Месячный бюджет обновлён';

  @override
  String budgetCategoryDialogTitle(String category) {
    return 'Задать бюджет для категории «$category»';
  }

  @override
  String get budgetCategoryDialogSubtitle =>
      'Месячный лимит расходов по этой категории. Его можно изменить в любой момент.';

  @override
  String budgetCategoryCleared(String category) {
    return 'Бюджет категории «$category» сброшен';
  }

  @override
  String budgetCategoryUpdated(String category) {
    return 'Бюджет категории «$category» обновлён';
  }

  @override
  String get budgetClearConfirmTitle => 'Сбросить месячный бюджет?';

  @override
  String get budgetClearConfirmContent =>
      'Прогресс бюджета и напоминания о перерасходе отключатся. Записи останутся без изменений.';

  @override
  String get budgetClearDialogAction => 'Сбросить';

  @override
  String get budgetAmountError => 'Введите сумму больше 0, например 3000';

  @override
  String get budgetAmountLabel => 'Сумма (юани)';

  @override
  String get budgetDeleteAction => 'Удалить этот бюджет';

  @override
  String get onboardTitle1 => 'Ваш журнал —\nтолько на телефоне';

  @override
  String get onboardBody1 =>
      'HENG не требует входа, не подключается к сети и ничего не загружает. Все записи и настройки хранятся на устройстве, их можно экспортировать в любой момент.';

  @override
  String get onboardPoint1a => 'Полностью офлайн';

  @override
  String get onboardPoint1b => 'Личные данные не собираются';

  @override
  String get onboardPoint1c => 'Экспорт данных в любой момент';

  @override
  String get onboardTitle2 => 'Сфотографируйте чек —\nи готово';

  @override
  String get onboardBody2 =>
      'Наведите на чек или скриншот счёта: сумма, магазин и дата распознаются на устройстве. Осталось проверить и сохранить.';

  @override
  String get onboardPoint2a => 'Распознавание текста на устройстве';

  @override
  String get onboardPoint2b => 'Автоподбор категории';

  @override
  String get onboardPoint2c => 'Просмотр распознанного текста';

  @override
  String get onboardTitle3 => 'Скажите вслух —\nзапись за 3 секунды';

  @override
  String get onboardBody3 =>
      'Скажите «Сегодня обед стоил 42» — сумма и категория заполнятся сами. Удобно, когда печатать неудобно.';

  @override
  String get onboardPoint3a => 'Распознавание речи на устройстве';

  @override
  String get onboardPoint3b => 'Достаточно одной фразы';

  @override
  String get onboardPoint3c => 'Ручной ввод, если не расслышали';

  @override
  String get onboardSaveFailed =>
      'Не удалось сохранить настройки. Повторите попытку.';

  @override
  String get onboardPrevious => 'Предыдущая страница';

  @override
  String get onboardSkip => 'Пропустить';

  @override
  String onboardPageSemantic(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get onboardStart => 'Начать учёт';

  @override
  String get onboardNext => 'Далее';

  @override
  String get legalLastUpdated => 'Обновлено: ноябрь 2026 г.';

  @override
  String get privacyOneLineTitle => 'В двух словах';

  @override
  String get privacyOneLineBody =>
      'HENG — приложение для учёта с приоритетом локальной работы: без входа, без сети, ваши данные не загружаются. Распознавание текста и речи, а также аналитика выполняются на вашем iPhone.';

  @override
  String get privacyNotCollectedTitle => 'Что мы не собираем';

  @override
  String get privacyNotCollectedBody =>
      'Разработчик не собирает, не хранит и не передаёт ваши личные данные или записи. В приложении нет учётных записей и сторонних SDK аналитики, рекламы, push-уведомлений или соцвхода. Поэтому в App Store указано «Data Not Collected» (данные не собираются).';

  @override
  String get privacyStorageTitle => 'Где хранятся данные';

  @override
  String get privacyStorageBody =>
      'Записи, бюджеты и настройки хранятся только в локальной песочнице приложения на устройстве. Данные не покидают устройство, если вы сами не экспортируете и не отправите их через «Настройки → Данные».';

  @override
  String get privacyCameraTitle => 'Камера и фото';

  @override
  String get privacyCameraBody =>
      'При сканировании чека приложение получает изображение через системную камеру или галерею и извлекает текст на устройстве с помощью iOS Vision. Оригинал не сохраняется в галерею и не загружается, а после распознавания удаляется из памяти.';

  @override
  String get privacyMicTitle => 'Микрофон и речь';

  @override
  String get privacyMicBody =>
      'Голосовой ввод использует распознавание речи iOS с обязательной обработкой на устройстве. Аудио не записывается на диск и не загружается. Если система не может распознать речь на устройстве, функция сообщит о недоступности, а не переключится на облако.';

  @override
  String get privacyExportDeleteTitle => 'Экспорт и удаление';

  @override
  String get privacyExportDeleteBody =>
      'В разделе «Настройки → Данные» можно экспортировать CSV или JSON-резервную копию и распоряжаться файлом самостоятельно, а также удалить все записи через «Настройки → Удалить все записи». Удаление приложения стирает все данные на устройстве, поэтому заранее сделайте резервную копию.';

  @override
  String get privacyPermissionsTitle => 'Разрешения';

  @override
  String get privacyPermissionsBody =>
      'Разрешения на камеру, фото, микрофон и распознавание речи не обязательны и запрашиваются только при использовании соответствующей функции. Даже если отказать, ручной ввод, отчёты, бюджеты и экспорт продолжат работать.';

  @override
  String get privacyChildrenTitle => 'Конфиденциальность детей';

  @override
  String get privacyChildrenBody =>
      'Приложение не собирает данные пользователей и не содержит рекламы или стороннего трекинга, поэтому подходит всем, включая несовершеннолетних; мы не показываем детям таргетированный контент.';

  @override
  String get privacyUpdatesTitle => 'Обновления политики';

  @override
  String get privacyUpdatesBody =>
      'Если в будущих версиях изменится обработка данных, мы обновим эту страницу в приложении и соответствующим образом изменим ярлык конфиденциальности в App Store.';

  @override
  String get privacyContactTitle => 'Связаться с нами';

  @override
  String get privacyContactBody =>
      'Если у вас есть вопросы об этой политике, свяжитесь с нами по ссылке «Поддержка приложения» на странице App Store.';

  @override
  String get termsServiceTitle => 'О сервисе';

  @override
  String get termsServiceBody =>
      'HENG — бесплатный инструмент для личного учёта с приоритетом локальной работы: ручной ввод, сканирование чеков, голосовой ввод, отчёты о доходах и расходах, напоминания о бюджете и экспорт данных. Все функции работают на этом устройстве.';

  @override
  String get termsNoticeTitle => 'Правила использования';

  @override
  String get termsNoticeBody =>
      'Вы отвечаете за точность введённых данных. Распознавание чеков и речи может ошибаться из-за размытого чека, акцента или шума — проверяйте перед сохранением. Рекомендуем регулярно экспортировать JSON-резервную копию.';

  @override
  String get termsFreeTitle => 'Бесплатно, без покупок в приложении';

  @override
  String get termsFreeBody =>
      'Текущая версия бесплатна: без подписок, встроенных покупок и рекламы. Если в будущем условия изменятся, мы заранее сообщим об этом в приложении, и это не затронет данные, уже сохранённые на устройстве.';

  @override
  String get termsBackupTitle => 'Данные и резервные копии';

  @override
  String get termsBackupBody =>
      'Данные хранятся только на устройстве; разработчик не имеет к ним доступа и не может их восстановить. В пределах, допускаемых применимым правом, риск потери данных из-за утраты устройства, сбоя системы, удаления приложения или самостоятельной очистки лежит на вас. Резервную копию можно экспортировать в настройках в любой момент.';

  @override
  String get termsDisclaimerTitle => 'Отказ от ответственности';

  @override
  String get termsDisclaimerBody =>
      'Статистика, напоминания о бюджете и «Советы» формируются на устройстве по фиксированным правилам. Они служат только справочной информацией для личного учёта и не являются инвестиционной, финансовой, налоговой, юридической или медицинской рекомендацией. Ответственность за решения, принятые на основе материалов приложения, лежит на вас.';

  @override
  String get termsIpTitle => 'Интеллектуальная собственность';

  @override
  String get termsIpBody =>
      'Интерфейс, значки, тексты и код приложения принадлежат разработчику. Экспортированные личные данные можно использовать в личных целях, но не для нарушения прав других лиц.';

  @override
  String get termsChangesTitle => 'Изменение и прекращение работы';

  @override
  String get termsChangesBody =>
      'Мы можем корректировать или улучшать функции вместе с обновлениями системы. Если поддержка прекратится, мы заранее сообщим об этом в приложении; вы по-прежнему сможете пользоваться локальными данными и экспортировать резервную копию в любой момент.';

  @override
  String get termsLawTitle => 'Применимое право';

  @override
  String get termsLawBody =>
      'К настоящему соглашению применяется законодательство Китайской Народной Республики. Споры, возникающие из него, стороны сначала решают путём дружественных переговоров.';

  @override
  String get termsContactTitle => 'Связаться с нами';

  @override
  String get termsContactBody =>
      'Если у вас есть вопросы по этому соглашению, свяжитесь с нами по ссылке «Поддержка приложения» на странице App Store.';

  @override
  String get budgetBarNotSet => 'Бюджет не задан';

  @override
  String budgetBarNearLimit(String percent) {
    return 'Бюджет почти исчерпан — использовано $percent%';
  }

  @override
  String budgetBarUsed(String percent) {
    return 'Использовано $percent%';
  }

  @override
  String get budgetBarSemantic => 'Прогресс бюджета';

  @override
  String budgetBarSemanticWith(String label) {
    return 'Прогресс бюджета ($label)';
  }

  @override
  String budgetBarValue(String status, String spent, String budget) {
    return '$status, потрачено $spent, бюджет $budget';
  }

  @override
  String budgetBarOver(String amount) {
    return 'Перерасход $amount';
  }

  @override
  String get catFood => 'Еда';

  @override
  String get catTransport => 'Транспорт';

  @override
  String get catShopping => 'Покупки';

  @override
  String get catHome => 'Дом';

  @override
  String get catEntertainment => 'Развлечения';

  @override
  String get catMedical => 'Здоровье';

  @override
  String get catEducation => 'Образование';

  @override
  String get catCommunication => 'Связь';

  @override
  String get catSocial => 'Общение';

  @override
  String get catOtherExpense => 'Другое';

  @override
  String get catSalary => 'Зарплата';

  @override
  String get catBonus => 'Премия';

  @override
  String get catInvestment => 'Инвестиции';

  @override
  String get catParttime => 'Подработка';

  @override
  String get catGift => 'Подарок';

  @override
  String get catOtherIncome => 'Другое';

  @override
  String get undo => 'Отменить';

  @override
  String get monthPrev => 'Предыдущий месяц';

  @override
  String get monthNext => 'Следующий месяц';

  @override
  String get monthCurrent => 'Это текущий месяц';

  @override
  String amountSemantic(String amount) {
    return 'Сумма $amount';
  }

  @override
  String get currencyUnit => '';

  @override
  String get chartEmpty => 'Недостаточно данных для тренда';

  @override
  String chartSemantic(int count) {
    return 'Тренд доходов и расходов за $count мес.';
  }

  @override
  String get donutTotal => 'Итого';

  @override
  String get donutEmpty => 'Нет данных по категориям';

  @override
  String get donutNoData => 'Нет данных';

  @override
  String donutSemantic(String amount, String label) {
    return 'Круговая диаграмма категорий, $label $amount';
  }

  @override
  String donutDesc(String percent, String amount, String category) {
    return '$category $amount, $percent%';
  }

  @override
  String get introStarting => 'HENG запускается';

  @override
  String get introTagline => 'Учёт, который остаётся в вашем телефоне';

  @override
  String get introFooter => 'ЛОКАЛЬНО · БЕЗ ВХОДА · БЕЗ СЕТИ';

  @override
  String get sourceManual => 'Вручную';

  @override
  String get sourceOcr => 'Скан чека';

  @override
  String get sourceVoice => 'Голосом';

  @override
  String get sourceCsv => 'Импорт';
}
