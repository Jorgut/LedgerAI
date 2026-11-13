// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HENG';

  @override
  String get navHome => '首页';

  @override
  String get navTransactions => '账单';

  @override
  String get navReports => '报表';

  @override
  String get navSettings => '我的';

  @override
  String get settingsTitle => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题色';

  @override
  String get about => '关于';

  @override
  String get privacy => '隐私说明';

  @override
  String get support => '支持';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get fabAdd => '记一笔';

  @override
  String get homeBrand => 'HENG';

  @override
  String get quickActions => '快速记账';

  @override
  String get quickActionsSubtitle => '拍照、语音或手动，几秒记一笔';

  @override
  String get photoEntry => '拍照记账';

  @override
  String get voiceEntry => '语音记账';

  @override
  String get manualEntry => '手动记账';

  @override
  String get recentRecords => '最近记录';

  @override
  String recentCount(int count) {
    return '最近 $count 笔';
  }

  @override
  String get viewAll => '查看全部';

  @override
  String get emptyRecordsTitle => '还没有记录';

  @override
  String get emptyRecordsMessage => '拍一张小票、说一句话，或手动记第一笔。';

  @override
  String get recordFirst => '记第一笔';

  @override
  String get localOnlyNote => '数据仅保存在本机，可在「我的 → 数据导出」备份。';

  @override
  String get balanceLabel => '本月结余';

  @override
  String balanceSemantic(String amount) {
    return '本月结余 $amount';
  }

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String incomeSemantic(String amount) {
    return '本月收入 $amount';
  }

  @override
  String expenseSemantic(String amount) {
    return '本月支出 $amount';
  }

  @override
  String get emptyMonth => '本月还没有记录，从下面快速记第一笔吧。';

  @override
  String get setBudgetTitle => '设置本月预算';

  @override
  String get setBudgetHint => '设置后随时看到剩余额度，超支会提醒你';

  @override
  String get setBudgetButton => '设置预算';

  @override
  String get budgetTitle => '本月预算';

  @override
  String spentAmount(String amount) {
    return '已花 $amount';
  }

  @override
  String remainingAmount(String amount) {
    return '剩余 $amount';
  }

  @override
  String overspentAmount(String amount) {
    return '已超支 $amount';
  }

  @override
  String monthBudgetSemantic(String amount, String percent) {
    return '本月预算 $amount，已用 $percent%';
  }

  @override
  String get settingsAppearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get highContrast => '高对比度';

  @override
  String get highContrastSubtitle => '适合弱视或强光环境，文字更清晰';

  @override
  String get settingsLanguageSection => '语言 / Language';

  @override
  String get appLanguage => 'App 语言';

  @override
  String get languageMigrationNote =>
      '壳/首页/设置已迁移；记账、账单、报表等页面仍在逐批翻译，切换后可能出现中英混排。';

  @override
  String get chooseThemeColor => '选择主题色';

  @override
  String get themeColorNote => '默认 A 清新；深色模式会自动使用对应深色版本。';

  @override
  String get settingsElderSection => '适老化';

  @override
  String get elderMode => '父母模式';

  @override
  String get elderModeSubtitle => '更大字体、更高对比、简化展示，适合长辈使用';

  @override
  String get appFontSize => '应用内字体大小';

  @override
  String get fontScaleStandard => '标准';

  @override
  String get fontScaleLarge => '大';

  @override
  String get fontScaleXLarge => '特大';

  @override
  String get fontScaleXXLarge => '超大';

  @override
  String get fontScaleNote =>
      '标准 / 大 / 特大 / 超大四档，下方滑块可微调；只影响衡账 App，仍会叠加系统字号。父母模式期间自动使用特大字号，关闭后回到你选择的字号。';

  @override
  String get settingsGeneralSection => '通用';

  @override
  String get haptics => '触觉反馈';

  @override
  String get hapticsSubtitle => '记账、保存等操作时轻震一下';

  @override
  String get budgetManagement => '预算管理';

  @override
  String monthlyBudgetTotal(String amount) {
    return '本月总预算 $amount';
  }

  @override
  String get noMonthlyBudget => '还没有设置月度预算';

  @override
  String get icloudSync => 'iCloud 同步';

  @override
  String get icloudWaitingFirstSync => '已开启，等待首次同步';

  @override
  String lastSyncAt(String time) {
    return '上次同步：$time';
  }

  @override
  String get icloudSyncOffSubtitle => '多设备同步到自己的 iCloud，开发者看不到数据';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncingNow => '正在同步…';

  @override
  String get syncNowSubtitle => '把本机账单与 iCloud 合并';

  @override
  String get icloudSyncNote =>
      '数据只写入你自己的 iCloud private database，衡账没有服务器；1.1 内测期间免费。';

  @override
  String syncComplete(int downloaded, int uploaded) {
    return '同步完成：下载 $downloaded 笔，上传 $uploaded 笔';
  }

  @override
  String syncCompleteWithDeleted(int downloaded, int uploaded, int deleted) {
    return '同步完成：下载 $downloaded 笔，上传 $uploaded 笔，删除 $deleted 笔';
  }

  @override
  String syncFailed(String error) {
    return '同步失败：$error';
  }

  @override
  String get dataSectionLocalOnly => '数据（只保存在本机）';

  @override
  String get exportCsv => '导出 CSV 表格';

  @override
  String exportCsvSubtitle(int count) {
    return '共 $count 笔账单，可在 Excel / Numbers 中查看';
  }

  @override
  String get exportJsonBackup => '导出 JSON 备份';

  @override
  String get exportJsonBackupSubtitle => '包含全部账单与设置，可用于迁移或找回数据';

  @override
  String get importWechatAlipay => '导入微信/支付宝账单';

  @override
  String get importWechatAlipaySubtitle => 'CSV 文件，自动识别收支、商户并分类；重复记录会跳过';

  @override
  String get importJsonBackup => '导入 JSON 备份';

  @override
  String get importJsonBackupSubtitle => '从衡账导出的备份文件合并账单与设置';

  @override
  String get clearAllTransactions => '清空全部账单';

  @override
  String get clearDataSubtitle => '仅删除本机账单，预算与设置保留；需两次确认';

  @override
  String get clearAllTransactionsConfirmTitle => '清空全部账单？';

  @override
  String clearDataConfirmContent(int count) {
    return '将删除本机保存的 $count 笔账单记录，预算与设置会保留。此操作无法撤销。';
  }

  @override
  String get continueAction => '继续';

  @override
  String get finalConfirmTitle => '最后确认';

  @override
  String get finalConfirmContent => '删除后无法恢复。如果还想保留账单，请先返回并导出 JSON 备份。';

  @override
  String get backAction => '返回';

  @override
  String get confirmClear => '确认清空';

  @override
  String get clearedAllTransactions => '已清空全部账单';

  @override
  String get exportNoData => '还没有账单数据，先记一笔再导出';

  @override
  String get exportCsvShareSubject => '衡账 · 账单表格';

  @override
  String get exportJsonShareSubject => '衡账 · 数据备份';

  @override
  String get exportCsvTitle => '导出账单 CSV';

  @override
  String get exportJsonTitle => '导出 JSON 备份';

  @override
  String get exportFailed => '导出失败，请稍后重试';

  @override
  String get billCsvFileType => '账单 CSV';

  @override
  String get jsonBackupFileType => 'JSON 备份';

  @override
  String get importEncodingWarning => '文件编码可能不是 UTF-8，部分文字可能乱码；建议在微信/支付宝里重新导出';

  @override
  String get importNoBill => '没有可导入的账单';

  @override
  String importAllDuplicates(int count) {
    return '这 $count 笔记录都已经在账本里了';
  }

  @override
  String get importBillTitle => '导入账单';

  @override
  String importBillSummary(int total, String duplicates, int duplicateCount,
      int fresh, String skipped, int skippedCount) {
    String _temp0 = intl.Intl.selectLogic(
      duplicates,
      {
        'some': '其中 $duplicateCount 笔已存在，',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      skipped,
      {
        'some': '已跳过 $skippedCount 行（不计收支/失败/重复等）。\n',
        'other': '',
      },
    );
    return '识别到 $total 笔收支，$_temp0将新增 $fresh 笔。\n$_temp1导入后可在账单页修改分类和备注。';
  }

  @override
  String importButtonCount(int count) {
    return '导入 $count 笔';
  }

  @override
  String get importAction => '导入';

  @override
  String importedCount(int count) {
    return '已导入 $count 笔账单';
  }

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get importJsonConfirmContent =>
      '将把备份中的账单合并到当前账本（同 ID 记录会覆盖），并恢复备份里的预算与偏好设置。是否继续？';

  @override
  String get importBackupFailed => '导入失败，请确认文件是衡账导出的 JSON 备份';

  @override
  String get noDataToClear => '当前没有账单数据';

  @override
  String get badgeNoLogin => '不登录';

  @override
  String get badgeNoNetwork => '不联网';

  @override
  String get badgeNoUpload => '不上传';

  @override
  String versionBuild(String version, String build) {
    return '版本 $version（构建 $build）';
  }

  @override
  String get aboutLocalFirstNote =>
      '衡账是本地优先的记账 App：账单、预算和设置只保存在这台 iPhone 上，拍照与语音识别都在本机完成。卸载 App 会一并删除数据，建议定期导出备份。';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get userAgreement => '用户协议';

  @override
  String get themeFresh => 'A 清新';

  @override
  String get themeForest => 'B 森林';

  @override
  String get themeFreshForest => 'C 清新森林';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'HENG';

  @override
  String get navHome => '首頁';

  @override
  String get navTransactions => '帳單';

  @override
  String get navReports => '報表';

  @override
  String get navSettings => '我的';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '語言';

  @override
  String get theme => '主題色';

  @override
  String get about => '關於';

  @override
  String get privacy => '隱私說明';

  @override
  String get support => '支援';

  @override
  String get commonSave => '儲存';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get fabAdd => '記一筆';

  @override
  String get homeBrand => 'HENG';

  @override
  String get quickActions => '快速記帳';

  @override
  String get quickActionsSubtitle => '拍照、語音或手動，幾秒記一筆';

  @override
  String get photoEntry => '拍照記帳';

  @override
  String get voiceEntry => '語音記帳';

  @override
  String get manualEntry => '手動記帳';

  @override
  String get recentRecords => '最近記錄';

  @override
  String recentCount(int count) {
    return '最近 $count 筆';
  }

  @override
  String get viewAll => '查看全部';

  @override
  String get emptyRecordsTitle => '還沒有記錄';

  @override
  String get emptyRecordsMessage => '拍一張小票、說一句話，或手動記第一筆。';

  @override
  String get recordFirst => '記第一筆';

  @override
  String get localOnlyNote => '資料僅保存在本機，可在「我的 → 資料匯出」備份。';

  @override
  String get balanceLabel => '本月結餘';

  @override
  String balanceSemantic(String amount) {
    return '本月結餘 $amount';
  }

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String incomeSemantic(String amount) {
    return '本月收入 $amount';
  }

  @override
  String expenseSemantic(String amount) {
    return '本月支出 $amount';
  }

  @override
  String get emptyMonth => '本月還沒有記錄，從下面快速記第一筆吧。';

  @override
  String get setBudgetTitle => '設定本月預算';

  @override
  String get setBudgetHint => '設定後隨時看到剩餘額度，超支會提醒你';

  @override
  String get setBudgetButton => '設定預算';

  @override
  String get budgetTitle => '本月預算';

  @override
  String spentAmount(String amount) {
    return '已花 $amount';
  }

  @override
  String remainingAmount(String amount) {
    return '剩餘 $amount';
  }

  @override
  String overspentAmount(String amount) {
    return '已超支 $amount';
  }

  @override
  String monthBudgetSemantic(String amount, String percent) {
    return '本月預算 $amount，已用 $percent%';
  }

  @override
  String get settingsAppearance => '外觀';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get lightMode => '淺色';

  @override
  String get darkMode => '深色';

  @override
  String get highContrast => '高對比度';

  @override
  String get highContrastSubtitle => '適合弱視或強光環境，文字更清晰';

  @override
  String get settingsLanguageSection => '語言 / Language';

  @override
  String get appLanguage => 'App 語言';

  @override
  String get languageMigrationNote =>
      '殼/首頁/設定已遷移；記帳、帳單、報表等頁面仍在逐批翻譯，切換後可能出現中英混排。';

  @override
  String get chooseThemeColor => '選擇主題色';

  @override
  String get themeColorNote => '預設 A 清新；深色模式會自動使用對應深色版本。';

  @override
  String get settingsElderSection => '適老化';

  @override
  String get elderMode => '父母模式';

  @override
  String get elderModeSubtitle => '更大字體、更高對比、簡化展示，適合長輩使用';

  @override
  String get appFontSize => '應用內字體大小';

  @override
  String get fontScaleStandard => '標準';

  @override
  String get fontScaleLarge => '大';

  @override
  String get fontScaleXLarge => '特大';

  @override
  String get fontScaleXXLarge => '超大';

  @override
  String get fontScaleNote =>
      '標準 / 大 / 特大 / 超大四檔，下方滑桿可微調；只影響衡賬 App，仍會疊加系統字號。父母模式期間自動使用特大字號，關閉後回到你選擇的字號。';

  @override
  String get settingsGeneralSection => '一般';

  @override
  String get haptics => '觸覺回饋';

  @override
  String get hapticsSubtitle => '記帳、儲存等操作時輕震一下';

  @override
  String get budgetManagement => '預算管理';

  @override
  String monthlyBudgetTotal(String amount) {
    return '本月總預算 $amount';
  }

  @override
  String get noMonthlyBudget => '還沒有設定月度預算';

  @override
  String get icloudSync => 'iCloud 同步';

  @override
  String get icloudWaitingFirstSync => '已開啟，等待首次同步';

  @override
  String lastSyncAt(String time) {
    return '上次同步：$time';
  }

  @override
  String get icloudSyncOffSubtitle => '多裝置同步到自己的 iCloud，開發者看不到資料';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncingNow => '正在同步…';

  @override
  String get syncNowSubtitle => '把本機帳單與 iCloud 合併';

  @override
  String get icloudSyncNote =>
      '資料只寫入你自己的 iCloud private database，衡賬沒有伺服器；1.1 內測期間免費。';

  @override
  String syncComplete(int downloaded, int uploaded) {
    return '同步完成：下載 $downloaded 筆，上傳 $uploaded 筆';
  }

  @override
  String syncCompleteWithDeleted(int downloaded, int uploaded, int deleted) {
    return '同步完成：下載 $downloaded 筆，上傳 $uploaded 筆，刪除 $deleted 筆';
  }

  @override
  String syncFailed(String error) {
    return '同步失敗：$error';
  }

  @override
  String get dataSectionLocalOnly => '資料（只儲存在本機）';

  @override
  String get exportCsv => '匯出 CSV 表格';

  @override
  String exportCsvSubtitle(int count) {
    return '共 $count 筆帳單，可在 Excel / Numbers 中檢視';
  }

  @override
  String get exportJsonBackup => '匯出 JSON 備份';

  @override
  String get exportJsonBackupSubtitle => '包含全部帳單與設定，可用於遷移或找回資料';

  @override
  String get importWechatAlipay => '匯入微信/支付寶帳單';

  @override
  String get importWechatAlipaySubtitle => 'CSV 檔案，自動識別收支、商家並分類；重複記錄會跳過';

  @override
  String get importJsonBackup => '匯入 JSON 備份';

  @override
  String get importJsonBackupSubtitle => '從衡賬匯出的備份檔案合併帳單與設定';

  @override
  String get clearAllTransactions => '清空全部帳單';

  @override
  String get clearDataSubtitle => '僅刪除本機帳單，預算與設定保留；需兩次確認';

  @override
  String get clearAllTransactionsConfirmTitle => '清空全部帳單？';

  @override
  String clearDataConfirmContent(int count) {
    return '將刪除本機儲存的 $count 筆帳單記錄，預算與設定會保留。此操作無法復原。';
  }

  @override
  String get continueAction => '繼續';

  @override
  String get finalConfirmTitle => '最後確認';

  @override
  String get finalConfirmContent => '刪除後無法復原。如果還想保留帳單，請先返回並匯出 JSON 備份。';

  @override
  String get backAction => '返回';

  @override
  String get confirmClear => '確認清空';

  @override
  String get clearedAllTransactions => '已清空全部帳單';

  @override
  String get exportNoData => '還沒有帳單資料，先記一筆再匯出';

  @override
  String get exportCsvShareSubject => '衡賬 · 帳單表格';

  @override
  String get exportJsonShareSubject => '衡賬 · 資料備份';

  @override
  String get exportCsvTitle => '匯出帳單 CSV';

  @override
  String get exportJsonTitle => '匯出 JSON 備份';

  @override
  String get exportFailed => '匯出失敗，請稍後重試';

  @override
  String get billCsvFileType => '帳單 CSV';

  @override
  String get jsonBackupFileType => 'JSON 備份';

  @override
  String get importEncodingWarning => '檔案編碼可能不是 UTF-8，部分文字可能亂碼；建議在微信/支付寶裡重新匯出';

  @override
  String get importNoBill => '沒有可匯入的帳單';

  @override
  String importAllDuplicates(int count) {
    return '這 $count 筆記錄都已經在帳本裡了';
  }

  @override
  String get importBillTitle => '匯入帳單';

  @override
  String importBillSummary(int total, String duplicates, int duplicateCount,
      int fresh, String skipped, int skippedCount) {
    String _temp0 = intl.Intl.selectLogic(
      duplicates,
      {
        'some': '其中 $duplicateCount 筆已存在，',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      skipped,
      {
        'some': '已跳過 $skippedCount 行（不計收支/失敗/重複等）。\n',
        'other': '',
      },
    );
    return '識別到 $total 筆收支，$_temp0將新增 $fresh 筆。\n$_temp1匯入後可在帳單頁修改分類和備註。';
  }

  @override
  String importButtonCount(int count) {
    return '匯入 $count 筆';
  }

  @override
  String get importAction => '匯入';

  @override
  String importedCount(int count) {
    return '已匯入 $count 筆帳單';
  }

  @override
  String importFailed(String error) {
    return '匯入失敗：$error';
  }

  @override
  String get importJsonConfirmContent =>
      '將把備份中的帳單合併到目前帳本（同 ID 記錄會覆寫），並還原備份裡的預算與偏好設定。是否繼續？';

  @override
  String get importBackupFailed => '匯入失敗，請確認檔案是衡賬匯出的 JSON 備份';

  @override
  String get noDataToClear => '目前沒有帳單資料';

  @override
  String get badgeNoLogin => '不登入';

  @override
  String get badgeNoNetwork => '不連網';

  @override
  String get badgeNoUpload => '不上傳';

  @override
  String versionBuild(String version, String build) {
    return '版本 $version（建置 $build）';
  }

  @override
  String get aboutLocalFirstNote =>
      '衡賬是本地優先的記帳 App：帳單、預算和設定只儲存在這台 iPhone 上，拍照與語音辨識都在本機完成。解除安裝 App 會一併刪除資料，建議定期匯出備份。';

  @override
  String get privacyPolicy => '隱私政策';

  @override
  String get userAgreement => '使用者協議';

  @override
  String get themeFresh => 'A 清新';

  @override
  String get themeForest => 'B 森林';

  @override
  String get themeFreshForest => 'C 清新森林';
}
