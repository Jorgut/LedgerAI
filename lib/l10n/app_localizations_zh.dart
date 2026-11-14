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
    return '本月结余 $amount 元';
  }

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String incomeSemantic(String amount) {
    return '本月收入 $amount 元';
  }

  @override
  String expenseSemantic(String amount) {
    return '本月支出 $amount 元';
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
      '已支持简体中文 / 繁體中文 / English / Русский；切换后立即生效。';

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
      '标准 / 大 / 特大 / 超大四档，下方滑块可微调；只影响衡记 App，仍会叠加系统字号。父母模式期间自动使用特大字号，关闭后回到你选择的字号。';

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
      '数据只写入你自己的 iCloud private database，衡记没有服务器；1.1 内测期间免费。';

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
  String get importJsonBackupSubtitle => '从衡记导出的备份文件合并账单与设置';

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
  String get exportCsvShareSubject => '衡记 · 账单表格';

  @override
  String get exportJsonShareSubject => '衡记 · 数据备份';

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
  String get importBackupFailed => '导入失败，请确认文件是衡记导出的 JSON 备份';

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
      '衡记是本地优先的记账 App：账单、预算和设置只保存在这台 iPhone 上，拍照与语音识别都在本机完成。卸载 App 会一并删除数据，建议定期导出备份。';

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

  @override
  String get txDeleteFailed => '删除失败，请重试';

  @override
  String txDeleted(String amount, String category) {
    return '已删除「$category」$amount';
  }

  @override
  String get txRestored => '已恢复这笔记录';

  @override
  String get txRestoreFailed => '恢复失败，请重新记一笔';

  @override
  String get txFilter => '筛选';

  @override
  String get txReset => '重置';

  @override
  String get txType => '类型';

  @override
  String get txAll => '全部';

  @override
  String get txCategory => '分类';

  @override
  String get txAllCategories => '全部分类';

  @override
  String get txExpenseCategories => '支出分类';

  @override
  String get txIncomeCategories => '收入分类';

  @override
  String get txDone => '完成';

  @override
  String get txTitle => '账单';

  @override
  String get txSearchHint => '搜索备注、商户、分类或金额';

  @override
  String get txClearSearch => '清除搜索';

  @override
  String get txRemoveTypeFilter => '移除类型筛选';

  @override
  String get txRemoveCategoryFilter => '移除分类筛选';

  @override
  String get txClearFilter => '清除筛选';

  @override
  String txMonthEmpty(int month) {
    return '$month月还没有记录';
  }

  @override
  String get txMonthEmptyHint => '点中间的「+」，或用拍照、语音快速记一笔。';

  @override
  String get txAddOne => '记一笔';

  @override
  String get txNoMatch => '没有符合条件的记录';

  @override
  String get txNoMatchHint => '换个关键词，或清除筛选后再看看。';

  @override
  String get txClearFilters => '清除筛选';

  @override
  String get txDelete => '删除';

  @override
  String txExpenseFooter(String amount) {
    return '支出 $amount';
  }

  @override
  String txIncomeFooter(String amount) {
    return '收入 $amount';
  }

  @override
  String get rptTitle => '报表';

  @override
  String get rptBackMonth => '回到本月';

  @override
  String get rptEmpty => '这个月还没有账单';

  @override
  String get rptEmptyHint => '用拍照识别扫一张小票，或按住说一句话，报表会自动汇总。';

  @override
  String get rptTrend => '近 6 个月趋势';

  @override
  String get rptTrendSub => '收入与支出按月对比';

  @override
  String get rptShare => '分类占比';

  @override
  String get rptBalance => '本月结余';

  @override
  String rptBalanceSem(String amount) {
    return '本月结余 $amount 元';
  }

  @override
  String rptCount(int count) {
    return '共 $count 笔记录';
  }

  @override
  String rptAmountLabel(String amount, String label) {
    return '$label $amount 元';
  }

  @override
  String get rptTotalIncome => '总收入';

  @override
  String get rptTotalExpense => '总支出';

  @override
  String rptCategorySem(String amount, int percent, String category) {
    return '$category，$amount 元，占 $percent%';
  }

  @override
  String get rptInsights => '智能建议';

  @override
  String get rptLocal => '本机计算';

  @override
  String get commonConfirm => '确定';

  @override
  String get addTitle => '记一笔';

  @override
  String get addEditTitle => '编辑记录';

  @override
  String get addDeleteTooltip => '删除这笔记录';

  @override
  String get addDeleteDialogTitle => '删除这笔记录？';

  @override
  String get addDeleteDialogContent => '删除后无法恢复，确定要删除吗？';

  @override
  String get addDeleted => '已删除';

  @override
  String get addSaveRecord => '保存记录';

  @override
  String get addSaveChanges => '保存修改';

  @override
  String get addSaved => '已记一笔';

  @override
  String get addUpdated => '已更新记录';

  @override
  String get addSaveFailed => '保存失败，请重试';

  @override
  String get addAmountRequired => '请输入大于 0 的金额';

  @override
  String get addAmountLabel => '金额';

  @override
  String get addNoteLabel => '备注';

  @override
  String get addNoteHint => '例如：午餐、地铁、超市';

  @override
  String addMerchantChip(String merchant) {
    return '商户：$merchant';
  }

  @override
  String get addClearMerchant => '清除商户';

  @override
  String get addDateLabel => '日期';

  @override
  String get addSelectDate => '选择日期';

  @override
  String addDateSemantic(String label) {
    return '日期，$label，选择日期';
  }

  @override
  String get addDatePickerFailed => '无法打开日期选择器，请重试';

  @override
  String get addFooterSaveHint => '确认无误后点下方按钮保存';

  @override
  String get addRawTextTitle => '识别原文';

  @override
  String get addCollapseRawText => '收起识别原文';

  @override
  String get addExpandRawText => '展开识别原文';

  @override
  String get addReceiptFilledBanner => '已从小票识别填入，请核对金额、分类和日期后保存。';

  @override
  String get addVoiceFilledBanner => '已从语音识别填入，请核对金额、分类和日期后保存。';

  @override
  String get addReceiptTitle => '拍照识别小票';

  @override
  String get addReceiptBody => '对准小票或账单截图，本机自动识别金额、商户和日期。照片不会上传，也不会保存到相册。';

  @override
  String get addReceiptCamera => '拍照识别';

  @override
  String get addReceiptGallery => '从相册选择';

  @override
  String get addReceiptRecognizing => '正在本机识别…';

  @override
  String get addSwitchToManual => '改为手动输入';

  @override
  String get addVoiceTitle => '语音记账';

  @override
  String get addVoiceBody => '按住下方按钮说一句话，例如「今天午餐花了 42 块」。语音只在本机识别，不会上传或保存音频。';

  @override
  String get addVoiceListening => '正在聆听，轻点结束';

  @override
  String get addVoiceHoldToTalk => '按住说话';

  @override
  String get addVoiceToggleHint => '双击开始或结束语音输入';

  @override
  String get addVoiceTapOrHold => '轻点或按住说话';

  @override
  String get addVoiceLivePlaceholder => '实时识别文字会显示在这里';

  @override
  String get addVoiceExamplesTitle => '可以这样说';

  @override
  String addVoiceExample(String example) {
    return '「$example」';
  }

  @override
  String get addVoiceChecking => '正在检查语音识别可用性…';

  @override
  String get addVoiceSwitchToManual => '不方便说？改为手动输入';

  @override
  String get addVoiceUnavailableTitle => '此设备暂时无法使用本机语音识别';

  @override
  String get addVoiceUnavailableBody =>
      '可能是不支持中文听写、未授予语音/麦克风权限，或正在模拟器运行。手动记账功能完全不受影响。';

  @override
  String get addVoiceUseManual => '改用手动输入';

  @override
  String get addVoiceNotSupported => '此设备暂不支持本机语音识别，请手动输入';

  @override
  String get addVoiceStartFailed => '语音识别启动失败，请改用手动输入';

  @override
  String get addVoiceNoSpeech => '没有听清，请再说一次或手动输入';

  @override
  String get addVoiceNoAmount => '没有听清金额，请再说一次，或手动输入';

  @override
  String get addVoiceRecognized => '已识别，请核对后保存';

  @override
  String get addVoiceFallbackError => '语音识别暂不可用，请手动输入';

  @override
  String get addOcrNoTextError => '没有识别到文字，请换一张清晰的小票，或手动输入。';

  @override
  String get addOcrNoText => '没有识别到文字，请重试或手动输入';

  @override
  String get addOcrNoAmountError => '识别到了文字，但没有找到金额，请展开原文手动补充。';

  @override
  String get addOcrNoAmount => '没有识别到金额，请手动补充';

  @override
  String get addOcrRecognized => '已识别，请核对金额和分类';

  @override
  String get addOcrFailedError => '识别失败，请重试或手动输入。';

  @override
  String get addOcrFailed => '识别失败，请重试或手动输入';

  @override
  String get addCameraPermission => '无法使用相机，请在系统设置中允许「衡记」访问相机。';

  @override
  String get addPhotoPermission => '无法访问相册，请在系统设置中允许「衡记」访问照片。';

  @override
  String get addCameraOpenFailed => '无法打开相机，请改用相册选择。';

  @override
  String get addPhotoReadFailed => '无法读取这张照片，请重试或手动输入。';

  @override
  String get addModeManual => '手动';

  @override
  String get addModeReceipt => '拍照';

  @override
  String get addModeVoice => '语音';

  @override
  String addModeSemantic(String label) {
    return '$label记账';
  }

  @override
  String get budgetScreenTitle => '预算';

  @override
  String get budgetEmptyMessage => '设置每月支出上限后，首页和报表会显示预算进度，花超了会提醒你。';

  @override
  String get budgetSetAction => '设置月度预算';

  @override
  String get budgetCategorySection => '分类预算';

  @override
  String get budgetTapCategoryHint => '点击分类设置';

  @override
  String get budgetLocalNote => '预算只用于本机提醒，不会限制消费；分类预算之和可以超过总预算。';

  @override
  String get budgetTotalLabel => '本月总预算';

  @override
  String budgetTotalSemantic(String amount) {
    return '本月总预算 $amount 元';
  }

  @override
  String budgetSpentSummary(String amount, int count) {
    return '本月已支出 $amount，共 $count 笔';
  }

  @override
  String get budgetEditAction => '编辑预算';

  @override
  String get budgetClearAction => '清除预算';

  @override
  String get budgetOverBadge => '超支';

  @override
  String get budgetSetCategoryHint => '点击设置分类预算';

  @override
  String budgetRowNone(String amount) {
    return '本月已支出 $amount';
  }

  @override
  String budgetRowDetail(String budget, String spent, String percent) {
    return '预算 $budget · 已支出 $spent（$percent%）';
  }

  @override
  String budgetRowDetailOver(
      String budget, String spent, String percent, String over) {
    return '预算 $budget · 已支出 $spent（$percent%），超支 $over';
  }

  @override
  String budgetCategorySemantic(String category, String spent, String budget) {
    return '$category预算，已支出 $spent 元，预算 $budget 元';
  }

  @override
  String budgetCategorySemanticOver(
      String category, String spent, String budget, String over) {
    return '$category预算，已支出 $spent 元，预算 $budget 元，已超支 $over 元';
  }

  @override
  String budgetCategorySemanticNone(String category) {
    return '$category，未设置预算，点按设置';
  }

  @override
  String get budgetTotalDialogTitle => '设置月度总预算';

  @override
  String get budgetTotalDialogTitleEdit => '修改月度总预算';

  @override
  String get budgetTotalDialogSubtitle => '每月支出的上限，用于首页和报表的预算进度提醒。';

  @override
  String get budgetTotalCleared => '已清除月度预算';

  @override
  String get budgetTotalUpdated => '月度预算已更新';

  @override
  String budgetCategoryDialogTitle(String category) {
    return '设置「$category」预算';
  }

  @override
  String get budgetCategoryDialogSubtitle => '这个分类每月的支出上限，可随时修改。';

  @override
  String budgetCategoryCleared(String category) {
    return '已清除「$category」预算';
  }

  @override
  String budgetCategoryUpdated(String category) {
    return '「$category」预算已更新';
  }

  @override
  String get budgetClearConfirmTitle => '清除月度预算？';

  @override
  String get budgetClearConfirmContent => '清除后预算进度与超支提醒会关闭，账单记录不会受影响。';

  @override
  String get budgetClearDialogAction => '清除';

  @override
  String get budgetAmountError => '请输入大于 0 的金额，例如 3000';

  @override
  String get budgetAmountLabel => '金额（元）';

  @override
  String get budgetDeleteAction => '删除该预算';

  @override
  String get onboardTitle1 => '你的账本，\n只在你手机里';

  @override
  String get onboardBody1 => '衡记不登录、不联网、不上传。所有账单和设置都保存在本机，随时可以导出备份。';

  @override
  String get onboardPoint1a => '完全离线运行';

  @override
  String get onboardPoint1b => '不收集任何个人信息';

  @override
  String get onboardPoint1c => '数据可随时导出';

  @override
  String get onboardTitle2 => '拍一张小票，\n就记好了';

  @override
  String get onboardBody2 => '对准小票或账单截图拍照，本机自动识别金额、商户和日期，确认一下就能保存。';

  @override
  String get onboardPoint2a => '设备端文字识别';

  @override
  String get onboardPoint2b => '自动匹配分类';

  @override
  String get onboardPoint2c => '识别原文可展开查看';

  @override
  String get onboardTitle3 => '按住说一句，\n3 秒记一笔';

  @override
  String get onboardBody3 => '说「今天午餐花了 42 块」，自动填好金额和分类。不方便打字时尤其好用。';

  @override
  String get onboardPoint3a => '本机语音识别';

  @override
  String get onboardPoint3b => '支持中文一句话';

  @override
  String get onboardPoint3c => '听不清时可手动输入';

  @override
  String get onboardSaveFailed => '保存设置失败，请重试';

  @override
  String get onboardPrevious => '上一页';

  @override
  String get onboardSkip => '跳过';

  @override
  String onboardPageSemantic(int current, int total) {
    return '第 $current 页，共 $total 页';
  }

  @override
  String get onboardStart => '开始记账';

  @override
  String get onboardNext => '下一步';

  @override
  String get legalLastUpdated => '最后更新：2026 年 11 月';

  @override
  String get privacyOneLineTitle => '一句话说明';

  @override
  String get privacyOneLineBody =>
      '衡记是一款本地优先的记账 App：不登录、不联网、不上传你的任何账单数据。文字识别、语音识别与统计建议全部在你的 iPhone 上完成。';

  @override
  String get privacyNotCollectedTitle => '我们不收集什么';

  @override
  String get privacyNotCollectedBody =>
      '开发者不收集、不存储、不传输你的任何个人信息或记账数据。App 没有账号体系，也不包含第三方统计、广告、推送或社交登录 SDK。因此 App Store 的隐私标签为「Data Not Collected」（不收集数据）。';

  @override
  String get privacyStorageTitle => '数据保存在哪里';

  @override
  String get privacyStorageBody =>
      '账单记录、预算和偏好设置只写入 App 在本机的沙盒数据库。除非你主动在「设置 → 数据」中导出并分享，这些数据不会离开你的设备。';

  @override
  String get privacyCameraTitle => '相机与照片';

  @override
  String get privacyCameraBody =>
      '使用拍照识别小票时，App 通过系统相机或相册获取一张图片，并使用 iOS 内置的 Vision 文字识别功能在本机提取文字。原始图片不会被保存到相册，也不会被上传；识别完成后即从内存释放。';

  @override
  String get privacyMicTitle => '麦克风与语音';

  @override
  String get privacyMicBody =>
      '语音记账使用 iOS 系统语音识别，并强制要求设备端识别。音频不会被写入磁盘，也不会被上传。若系统无法在本机完成识别，该功能会提示暂不可用，而不会改用云端识别。';

  @override
  String get privacyExportDeleteTitle => '数据导出与删除';

  @override
  String get privacyExportDeleteBody =>
      '你可以在「设置 → 数据」导出 CSV 表格或 JSON 备份，文件由你自己保存与分享；也可以在「设置 → 清空全部账单」一键删除全部账单记录。卸载 App 会删除本机保存的全部数据，请提前导出备份。';

  @override
  String get privacyPermissionsTitle => '权限说明';

  @override
  String get privacyPermissionsBody =>
      '相机、照片、麦克风与语音识别权限都是可选的，只在对应功能中按需申请。即使拒绝这些权限，手动记账、报表、预算与导出等功能仍可正常使用。';

  @override
  String get privacyChildrenTitle => '儿童隐私';

  @override
  String get privacyChildrenBody =>
      '本 App 不收集任何用户的数据，也不含广告或第三方追踪，适用于包括未成年人在内的所有用户；我们不会针对儿童推送定向内容。';

  @override
  String get privacyUpdatesTitle => '政策更新';

  @override
  String get privacyUpdatesBody =>
      '如果未来的版本改变了数据处理方式，我们会在 App 内更新本页面，并同步调整 App Store 的隐私标签。';

  @override
  String get privacyContactTitle => '联系我们';

  @override
  String get privacyContactBody =>
      '如对本政策有疑问，请联系 privacy@altn.vision；反馈问题请发 feedback@altn.vision。';

  @override
  String get termsServiceTitle => '服务说明';

  @override
  String get termsServiceBody =>
      '衡记是一款免费、本地优先的个人记账工具，提供手动记账、拍照识别、语音记账、收支统计报表、预算提醒与数据导出等功能。App 的全部功能都在这台设备上运行。';

  @override
  String get termsNoticeTitle => '使用须知';

  @override
  String get termsNoticeBody =>
      '你需要对录入信息的准确性负责。拍照识别与语音识别的结果可能因为小票模糊、口音或环境噪音出现误差，请在保存前核对。建议定期导出 JSON 备份。';

  @override
  String get termsFreeTitle => '免费与内购';

  @override
  String get termsFreeBody =>
      '当前版本免费提供，没有订阅、没有内购、没有广告。若未来调整收费方式，我们会提前在 App 内说明，不会影响你已保存在本机的数据。';

  @override
  String get termsBackupTitle => '数据与备份';

  @override
  String get termsBackupBody =>
      '你的数据只保存在本机，开发者无法访问，也无法替你恢复。因设备丢失、系统故障、卸载 App 或主动清空数据造成的数据丢失，在适用法律允许的范围内由你自行承担。你可以随时在设置中导出备份。';

  @override
  String get termsDisclaimerTitle => '免责声明';

  @override
  String get termsDisclaimerBody =>
      'App 中的统计、预算提醒与「智能建议」均基于本机数据和固定规则生成，仅作为个人记账参考，不构成投资、理财、税务、法律或医疗建议。你依据本 App 内容做出的任何决定，风险由你自行承担。';

  @override
  String get termsIpTitle => '知识产权';

  @override
  String get termsIpBody =>
      'App 的界面、图标、文案与代码归开发者所有。你可以将导出的个人账单数据用于个人用途，但不得将其用于侵犯他人权益的用途。';

  @override
  String get termsChangesTitle => '服务变更与终止';

  @override
  String get termsChangesBody =>
      '我们可能随系统版本更新调整或改进功能。若未来停止维护，会在 App 内提前告知；你仍然可以继续使用本地数据，并随时导出备份。';

  @override
  String get termsLawTitle => '适用法律';

  @override
  String get termsLawBody => '本协议适用中华人民共和国法律。因本协议产生的争议，双方应先友好协商解决。';

  @override
  String get termsContactTitle => '联系我们';

  @override
  String get termsContactBody => '如对本协议有疑问，可以通过 App Store 商品页上的「App 支持」链接联系我们。';

  @override
  String get budgetBarNotSet => '未设置预算';

  @override
  String budgetBarNearLimit(String percent) {
    return '预算快用完了，已用 $percent%';
  }

  @override
  String budgetBarUsed(String percent) {
    return '已用 $percent%';
  }

  @override
  String get budgetBarSemantic => '预算进度';

  @override
  String budgetBarSemanticWith(String label) {
    return '预算进度（$label）';
  }

  @override
  String budgetBarValue(String status, String spent, String budget) {
    return '$status，已花费 $spent，预算 $budget';
  }

  @override
  String budgetBarOver(String amount) {
    return '超支 $amount';
  }

  @override
  String get catFood => '餐饮';

  @override
  String get catTransport => '交通';

  @override
  String get catShopping => '购物';

  @override
  String get catHome => '居家';

  @override
  String get catEntertainment => '娱乐';

  @override
  String get catMedical => '医疗';

  @override
  String get catEducation => '学习';

  @override
  String get catCommunication => '通讯';

  @override
  String get catSocial => '人情';

  @override
  String get catOtherExpense => '其他';

  @override
  String get catSalary => '工资';

  @override
  String get catBonus => '奖金';

  @override
  String get catInvestment => '理财';

  @override
  String get catParttime => '兼职';

  @override
  String get catGift => '红包';

  @override
  String get catOtherIncome => '其他';

  @override
  String get undo => '撤销';

  @override
  String get monthPrev => '上个月';

  @override
  String get monthNext => '下个月';

  @override
  String get monthCurrent => '已经是本月';

  @override
  String amountSemantic(String amount) {
    return '金额 $amount';
  }

  @override
  String get currencyUnit => ' 元';

  @override
  String get chartEmpty => '还没有足够的数据生成趋势图';

  @override
  String chartSemantic(int count) {
    return '近 $count 个月收支趋势';
  }

  @override
  String get donutTotal => '合计';

  @override
  String get donutEmpty => '暂无分类数据';

  @override
  String get donutNoData => '暂无数据';

  @override
  String donutSemantic(String amount, String label) {
    return '分类占比环形图，$label $amount';
  }

  @override
  String donutDesc(String percent, String amount, String category) {
    return '$category $amount，占 $percent%';
  }

  @override
  String get introStarting => 'HENG，正在启动';

  @override
  String get introTagline => '把账本留在自己手机里';

  @override
  String get introFooter => '本地优先 · 不登录 · 不联网';

  @override
  String get sourceManual => '手动';

  @override
  String get sourceOcr => '拍照识别';

  @override
  String get sourceVoice => '语音记账';

  @override
  String get sourceCsv => '导入账单';

  @override
  String get themeBlush => 'D 玫瑰纸';

  @override
  String get themePeach => 'E 蜜桃';

  @override
  String get themeLavender => 'F 薰衣草';

  @override
  String get navTrip => '旅行';

  @override
  String get travelMode => '旅行分账';

  @override
  String get travelModeSubtitle => '和朋友一起记旅行账，自动算谁欠谁';

  @override
  String get splitMode => '一起分';

  @override
  String get splitModeSubtitle => '聚餐、房租、旅行，自动算清谁欠谁';

  @override
  String get splitBadge => '新';

  @override
  String get splitSettleUp => '结算';

  @override
  String get insightEmptyTitle => '本月还没有记录';

  @override
  String get insightEmptyBody => '用「拍照识别」扫一张小票，或者按住说一句话，3 秒记住一笔。';

  @override
  String get insightOverBudgetTitle => '本月已超出预算';

  @override
  String insightOverBudgetBody(String expense, String over) {
    return '支出 $expense，比预算多出 $over。接下来可以优先记录，减少非必要开支。';
  }

  @override
  String insightOverBudgetMetric(String amount) {
    return '超支 $amount';
  }

  @override
  String get insightBudgetNearTitle => '预算快用完了';

  @override
  String insightBudgetNearBody(String percent, String remaining) {
    return '已使用 $percent% 的月度预算，剩余 $remaining。';
  }

  @override
  String insightBudgetNearMetric(String amount) {
    return '剩余 $amount';
  }

  @override
  String get insightBudgetHealthyTitle => '预算节奏健康';

  @override
  String insightBudgetHealthyBody(String percent, String remaining) {
    return '本月支出占预算的 $percent%，还有 $remaining 可用。';
  }

  @override
  String insightBudgetHealthyMetric(String amount) {
    return '可用 $amount';
  }

  @override
  String insightTopCategoryTitle(String category) {
    return '「$category」占比偏高';
  }

  @override
  String insightTopCategoryBody(
      String category, String amount, String percent) {
    return '「$category」花了 $amount，占本月支出的 $percent%。如果适当控制，每月可省下一笔。';
  }

  @override
  String insightTopCategoryMetric(String percent) {
    return '占 $percent%';
  }

  @override
  String get insightSpendUpTitle => '支出比上月高';

  @override
  String insightSpendUpBody(String expense, String delta, String percent) {
    return '本月支出 $expense，比上月多 $delta（+$percent%）。';
  }

  @override
  String insightSpendUpMetric(String percent) {
    return '+$percent%';
  }

  @override
  String get insightSpendDownTitle => '支出比上月下降';

  @override
  String insightSpendDownBody(String amount) {
    return '本月支出比上月少了 $amount，继续保持记账习惯。';
  }

  @override
  String insightSpendDownMetric(String percent) {
    return '$percent%';
  }

  @override
  String get insightSpendOverIncomeTitle => '本月支出大于收入';

  @override
  String insightSpendOverIncomeBody(String income, String expense) {
    return '收入 $income，支出 $expense，建议核对是否有大额非必要支出。';
  }

  @override
  String get insightSavingTitle => '储蓄率不错';

  @override
  String insightSavingBody(String saving, String percent) {
    return '本月结余 $saving，储蓄率 $percent%，高于 30% 的健康线。';
  }

  @override
  String insightSavingMetric(String percent) {
    return '储蓄率 $percent%';
  }

  @override
  String get insightSmallFrequentTitle => '小额支出比较频繁';

  @override
  String insightSmallFrequentBody(String count, String average) {
    return '本月共 $count 笔支出，平均每笔 $average。零散小支出累计起来也不少，可以合并记录或设置分类预算。';
  }

  @override
  String insightSmallFrequentMetric(String count) {
    return '$count 笔';
  }

  @override
  String get insightHabitTitle => '记账习惯正在建立';

  @override
  String get insightHabitBody => '保持每笔都记，月底的报表和建议会更准确。';

  @override
  String get rptNoExpense => '本月还没有支出记录';

  @override
  String get feedback => '反馈';

  @override
  String get feedbackSettingsSubtitle => '报告问题或建议功能';

  @override
  String get feedbackTitle => '反馈';

  @override
  String get feedbackSubtitle => '告诉我们发生了什么，或你希望 HENG 改进什么。';

  @override
  String get feedbackTypeBug => '问题';

  @override
  String get feedbackTypeFeature => '功能建议';

  @override
  String get feedbackTypeOther => '其他';

  @override
  String get feedbackMessageLabel => '问题 / 建议';

  @override
  String get feedbackMessageHint => '描述发生了什么、如何复现；不要填写真实金额、姓名或商户。';

  @override
  String get feedbackIncludeInfo => '附上版本与设备信息';

  @override
  String get feedbackIncludeInfoSub => '仅包含 App 版本、iOS、语言与主题；不包含账本数据。';

  @override
  String get feedbackPrivacyNote => '反馈在本机生成，只有你选择发送方式后才会离开设备。';

  @override
  String get feedbackSend => '发送邮件反馈';

  @override
  String get feedbackCopy => '复制反馈';

  @override
  String get feedbackEmpty => '请先写一点内容。';

  @override
  String get feedbackCopied => '已复制，可粘贴到邮件或消息中。';

  @override
  String get feedbackThanks => '已打开发送面板，请选择邮件、信息或其他 App。';

  @override
  String get feedbackReportSubject => 'HENG 衡记 · App 反馈';

  @override
  String get feedbackShareHint => '将打开邮件 App，收件人已填好；没有邮件 App 时会退回到系统分享。';

  @override
  String get importFileEmpty => '文件是空的。';

  @override
  String get importNoHeader => '没有找到账单表头（需要「交易时间」和「金额」列）。';

  @override
  String get importSkippedRows => '部分行缺少金额或时间，已跳过。';

  @override
  String get importNoRecords => '没有可导入的收支记录。';

  @override
  String get icloudUnavailable => 'iCloud 暂时不可用，请检查登录状态后重试。';

  @override
  String get addVoicePermissionError => '没有麦克风或语音识别权限，请在系统设置中允许后重试。';
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
    return '本月結餘 $amount 元';
  }

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String incomeSemantic(String amount) {
    return '本月收入 $amount 元';
  }

  @override
  String expenseSemantic(String amount) {
    return '本月支出 $amount 元';
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
      '已支援簡體中文 / 繁體中文 / English / Русский；切換後立即生效。';

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
      '標準 / 大 / 特大 / 超大四檔，下方滑桿可微調；只影響衡記 App，仍會疊加系統字號。父母模式期間自動使用特大字號，關閉後回到你選擇的字號。';

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
      '資料只寫入你自己的 iCloud private database，衡記沒有伺服器；1.1 內測期間免費。';

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
  String get importJsonBackupSubtitle => '從衡記匯出的備份檔案合併帳單與設定';

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
  String get exportCsvShareSubject => '衡記 · 帳單表格';

  @override
  String get exportJsonShareSubject => '衡記 · 資料備份';

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
  String get importBackupFailed => '匯入失敗，請確認檔案是衡記匯出的 JSON 備份';

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
      '衡記是本地優先的記帳 App：帳單、預算和設定只儲存在這台 iPhone 上，拍照與語音辨識都在本機完成。解除安裝 App 會一併刪除資料，建議定期匯出備份。';

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

  @override
  String get txDeleteFailed => '刪除失敗，請重試';

  @override
  String txDeleted(String amount, String category) {
    return '已刪除「$category」$amount';
  }

  @override
  String get txRestored => '已恢復這筆記錄';

  @override
  String get txRestoreFailed => '恢復失敗，請重新記一筆';

  @override
  String get txFilter => '篩選';

  @override
  String get txReset => '重設';

  @override
  String get txType => '類型';

  @override
  String get txAll => '全部';

  @override
  String get txCategory => '分類';

  @override
  String get txAllCategories => '全部分類';

  @override
  String get txExpenseCategories => '支出分類';

  @override
  String get txIncomeCategories => '收入分類';

  @override
  String get txDone => '完成';

  @override
  String get txTitle => '帳單';

  @override
  String get txSearchHint => '搜尋備註、商戶、分類或金額';

  @override
  String get txClearSearch => '清除搜尋';

  @override
  String get txRemoveTypeFilter => '移除類型篩選';

  @override
  String get txRemoveCategoryFilter => '移除分類篩選';

  @override
  String get txClearFilter => '清除篩選';

  @override
  String txMonthEmpty(int month) {
    return '$month月還沒有記錄';
  }

  @override
  String get txMonthEmptyHint => '點中間的「+」，或用拍照、語音快速記一筆。';

  @override
  String get txAddOne => '記一筆';

  @override
  String get txNoMatch => '沒有符合條件的記錄';

  @override
  String get txNoMatchHint => '換個關鍵字，或清除篩選後再看看。';

  @override
  String get txClearFilters => '清除篩選';

  @override
  String get txDelete => '刪除';

  @override
  String txExpenseFooter(String amount) {
    return '支出 $amount';
  }

  @override
  String txIncomeFooter(String amount) {
    return '收入 $amount';
  }

  @override
  String get rptTitle => '報表';

  @override
  String get rptBackMonth => '回到本月';

  @override
  String get rptEmpty => '這個月還沒有帳單';

  @override
  String get rptEmptyHint => '用拍照識別掃一張小票，或按住說一句話，報表會自動彙總。';

  @override
  String get rptTrend => '近 6 個月趨勢';

  @override
  String get rptTrendSub => '收入與支出按月對比';

  @override
  String get rptShare => '分類佔比';

  @override
  String get rptBalance => '本月結餘';

  @override
  String rptBalanceSem(String amount) {
    return '本月結餘 $amount 元';
  }

  @override
  String rptCount(int count) {
    return '共 $count 筆記錄';
  }

  @override
  String rptAmountLabel(String amount, String label) {
    return '$label $amount 元';
  }

  @override
  String get rptTotalIncome => '總收入';

  @override
  String get rptTotalExpense => '總支出';

  @override
  String rptCategorySem(String amount, int percent, String category) {
    return '$category，$amount 元，佔 $percent%';
  }

  @override
  String get rptInsights => '智能建議';

  @override
  String get rptLocal => '本機計算';

  @override
  String get commonConfirm => '確定';

  @override
  String get addTitle => '記一筆';

  @override
  String get addEditTitle => '編輯記錄';

  @override
  String get addDeleteTooltip => '刪除這筆記錄';

  @override
  String get addDeleteDialogTitle => '刪除這筆記錄？';

  @override
  String get addDeleteDialogContent => '刪除後無法復原，確定要刪除嗎？';

  @override
  String get addDeleted => '已刪除';

  @override
  String get addSaveRecord => '儲存記錄';

  @override
  String get addSaveChanges => '儲存修改';

  @override
  String get addSaved => '已記一筆';

  @override
  String get addUpdated => '已更新記錄';

  @override
  String get addSaveFailed => '儲存失敗，請重試';

  @override
  String get addAmountRequired => '請輸入大於 0 的金額';

  @override
  String get addAmountLabel => '金額';

  @override
  String get addNoteLabel => '備註';

  @override
  String get addNoteHint => '例如：午餐、捷運、超市';

  @override
  String addMerchantChip(String merchant) {
    return '商戶：$merchant';
  }

  @override
  String get addClearMerchant => '清除商戶';

  @override
  String get addDateLabel => '日期';

  @override
  String get addSelectDate => '選擇日期';

  @override
  String addDateSemantic(String label) {
    return '日期，$label，選擇日期';
  }

  @override
  String get addDatePickerFailed => '無法開啟日期選擇器，請重試';

  @override
  String get addFooterSaveHint => '確認無誤後點下方按鈕儲存';

  @override
  String get addRawTextTitle => '辨識原文';

  @override
  String get addCollapseRawText => '收合辨識原文';

  @override
  String get addExpandRawText => '展開辨識原文';

  @override
  String get addReceiptFilledBanner => '已從收據辨識填入，請核對金額、分類和日期後儲存。';

  @override
  String get addVoiceFilledBanner => '已從語音辨識填入，請核對金額、分類和日期後儲存。';

  @override
  String get addReceiptTitle => '拍照辨識收據';

  @override
  String get addReceiptBody => '對準收據或帳單截圖，本機自動辨識金額、商戶和日期。照片不會上傳，也不會儲存到相簿。';

  @override
  String get addReceiptCamera => '拍照辨識';

  @override
  String get addReceiptGallery => '從相簿選擇';

  @override
  String get addReceiptRecognizing => '正在本機辨識…';

  @override
  String get addSwitchToManual => '改為手動輸入';

  @override
  String get addVoiceTitle => '語音記帳';

  @override
  String get addVoiceBody => '按住下方按鈕說一句話，例如「今天午餐花了 42 塊」。語音只在本機辨識，不會上傳或儲存音訊。';

  @override
  String get addVoiceListening => '正在聆聽，輕點結束';

  @override
  String get addVoiceHoldToTalk => '按住說話';

  @override
  String get addVoiceToggleHint => '點兩下開始或結束語音輸入';

  @override
  String get addVoiceTapOrHold => '輕點或按住說話';

  @override
  String get addVoiceLivePlaceholder => '即時辨識文字會顯示在這裡';

  @override
  String get addVoiceExamplesTitle => '可以這樣說';

  @override
  String addVoiceExample(String example) {
    return '「$example」';
  }

  @override
  String get addVoiceChecking => '正在檢查語音辨識可用性…';

  @override
  String get addVoiceSwitchToManual => '不方便說？改為手動輸入';

  @override
  String get addVoiceUnavailableTitle => '此裝置暫時無法使用本機語音辨識';

  @override
  String get addVoiceUnavailableBody =>
      '可能是不支援中文聽寫、未授予語音/麥克風權限，或正在模擬器執行。手動記帳功能完全不受影響。';

  @override
  String get addVoiceUseManual => '改用手動輸入';

  @override
  String get addVoiceNotSupported => '此裝置暫不支援本機語音辨識，請手動輸入';

  @override
  String get addVoiceStartFailed => '語音辨識啟動失敗，請改用手動輸入';

  @override
  String get addVoiceNoSpeech => '沒有聽清楚，請再說一次或手動輸入';

  @override
  String get addVoiceNoAmount => '沒有聽清楚金額，請再說一次，或手動輸入';

  @override
  String get addVoiceRecognized => '已辨識，請核對後儲存';

  @override
  String get addVoiceFallbackError => '語音辨識暫時無法使用，請手動輸入';

  @override
  String get addOcrNoTextError => '沒有辨識到文字，請換一張清晰的收據，或手動輸入。';

  @override
  String get addOcrNoText => '沒有辨識到文字，請重試或手動輸入';

  @override
  String get addOcrNoAmountError => '辨識到文字，但沒有找到金額，請展開原文手動補充。';

  @override
  String get addOcrNoAmount => '沒有辨識到金額，請手動補充';

  @override
  String get addOcrRecognized => '已辨識，請核對金額和分類';

  @override
  String get addOcrFailedError => '辨識失敗，請重試或手動輸入。';

  @override
  String get addOcrFailed => '辨識失敗，請重試或手動輸入';

  @override
  String get addCameraPermission => '無法使用相機，請在系統設定中允許「衡記」存取相機。';

  @override
  String get addPhotoPermission => '無法存取相簿，請在系統設定中允許「衡記」存取照片。';

  @override
  String get addCameraOpenFailed => '無法開啟相機，請改用相簿選擇。';

  @override
  String get addPhotoReadFailed => '無法讀取這張照片，請重試或手動輸入。';

  @override
  String get addModeManual => '手動';

  @override
  String get addModeReceipt => '拍照';

  @override
  String get addModeVoice => '語音';

  @override
  String addModeSemantic(String label) {
    return '$label記帳';
  }

  @override
  String get budgetScreenTitle => '預算';

  @override
  String get budgetEmptyMessage => '設定每月支出上限後，首頁和報表會顯示預算進度，花超了會提醒你。';

  @override
  String get budgetSetAction => '設定月度預算';

  @override
  String get budgetCategorySection => '分類預算';

  @override
  String get budgetTapCategoryHint => '點擊分類設定';

  @override
  String get budgetLocalNote => '預算只用於本機提醒，不會限制消費；分類預算之和可以超過總預算。';

  @override
  String get budgetTotalLabel => '本月總預算';

  @override
  String budgetTotalSemantic(String amount) {
    return '本月總預算 $amount 元';
  }

  @override
  String budgetSpentSummary(String amount, int count) {
    return '本月已支出 $amount，共 $count 筆';
  }

  @override
  String get budgetEditAction => '編輯預算';

  @override
  String get budgetClearAction => '清除預算';

  @override
  String get budgetOverBadge => '超支';

  @override
  String get budgetSetCategoryHint => '點擊設定分類預算';

  @override
  String budgetRowNone(String amount) {
    return '本月已支出 $amount';
  }

  @override
  String budgetRowDetail(String budget, String spent, String percent) {
    return '預算 $budget · 已支出 $spent（$percent%）';
  }

  @override
  String budgetRowDetailOver(
      String budget, String spent, String percent, String over) {
    return '預算 $budget · 已支出 $spent（$percent%），超支 $over';
  }

  @override
  String budgetCategorySemantic(String category, String spent, String budget) {
    return '$category預算，已支出 $spent 元，預算 $budget 元';
  }

  @override
  String budgetCategorySemanticOver(
      String category, String spent, String budget, String over) {
    return '$category預算，已支出 $spent 元，預算 $budget 元，已超支 $over 元';
  }

  @override
  String budgetCategorySemanticNone(String category) {
    return '$category，未設定預算，點按設定';
  }

  @override
  String get budgetTotalDialogTitle => '設定月度總預算';

  @override
  String get budgetTotalDialogTitleEdit => '修改月度總預算';

  @override
  String get budgetTotalDialogSubtitle => '每月支出的上限，用於首頁和報表的預算進度提醒。';

  @override
  String get budgetTotalCleared => '已清除月度預算';

  @override
  String get budgetTotalUpdated => '月度預算已更新';

  @override
  String budgetCategoryDialogTitle(String category) {
    return '設定「$category」預算';
  }

  @override
  String get budgetCategoryDialogSubtitle => '這個分類每月的支出上限，可隨時修改。';

  @override
  String budgetCategoryCleared(String category) {
    return '已清除「$category」預算';
  }

  @override
  String budgetCategoryUpdated(String category) {
    return '「$category」預算已更新';
  }

  @override
  String get budgetClearConfirmTitle => '清除月度預算？';

  @override
  String get budgetClearConfirmContent => '清除後預算進度與超支提醒會關閉，帳單記錄不會受影響。';

  @override
  String get budgetClearDialogAction => '清除';

  @override
  String get budgetAmountError => '請輸入大於 0 的金額，例如 3000';

  @override
  String get budgetAmountLabel => '金額（元）';

  @override
  String get budgetDeleteAction => '刪除該預算';

  @override
  String get onboardTitle1 => '你的帳本，\n只在你手機裡';

  @override
  String get onboardBody1 => '衡記不登入、不連網、不上傳。所有帳單和設定都儲存在本機，隨時可以匯出備份。';

  @override
  String get onboardPoint1a => '完全離線運行';

  @override
  String get onboardPoint1b => '不收集任何個人資訊';

  @override
  String get onboardPoint1c => '資料可隨時匯出';

  @override
  String get onboardTitle2 => '拍一張收據，\n就記好了';

  @override
  String get onboardBody2 => '對準收據或帳單截圖拍照，本機自動辨識金額、商戶和日期，確認一下就能儲存。';

  @override
  String get onboardPoint2a => '裝置端文字辨識';

  @override
  String get onboardPoint2b => '自動匹配分類';

  @override
  String get onboardPoint2c => '辨識原文可展開查看';

  @override
  String get onboardTitle3 => '按住說一句，\n3 秒記一筆';

  @override
  String get onboardBody3 => '說「今天午餐花了 42 塊」，自動填好金額和分類。不方便打字時尤其好用。';

  @override
  String get onboardPoint3a => '本機語音辨識';

  @override
  String get onboardPoint3b => '支援中文一句話';

  @override
  String get onboardPoint3c => '聽不清時可手動輸入';

  @override
  String get onboardSaveFailed => '儲存設定失敗，請重試';

  @override
  String get onboardPrevious => '上一頁';

  @override
  String get onboardSkip => '略過';

  @override
  String onboardPageSemantic(int current, int total) {
    return '第 $current 頁，共 $total 頁';
  }

  @override
  String get onboardStart => '開始記帳';

  @override
  String get onboardNext => '下一步';

  @override
  String get legalLastUpdated => '最後更新：2026 年 11 月';

  @override
  String get privacyOneLineTitle => '一句話說明';

  @override
  String get privacyOneLineBody =>
      '衡記是一款本地優先的記帳 App：不登入、不連網、不上傳你的任何帳單資料。文字辨識、語音辨識與統計建議全部在你的 iPhone 上完成。';

  @override
  String get privacyNotCollectedTitle => '我們不收集什麼';

  @override
  String get privacyNotCollectedBody =>
      '開發者不收集、不儲存、不傳輸你的任何個人資訊或記帳資料。App 沒有帳號系統，也不包含第三方統計、廣告、推播或社群登入 SDK。因此 App Store 的隱私標籤為「Data Not Collected」（不收集資料）。';

  @override
  String get privacyStorageTitle => '資料儲存在哪裡';

  @override
  String get privacyStorageBody =>
      '帳單記錄、預算和偏好設定只寫入 App 在本機的沙盒資料庫。除非你主動在「設定 → 資料」中匯出並分享，這些資料不會離開你的裝置。';

  @override
  String get privacyCameraTitle => '相機與照片';

  @override
  String get privacyCameraBody =>
      '使用拍照辨識收據時，App 透過系統相機或相簿取得一張圖片，並使用 iOS 內建的 Vision 文字辨識功能在本機擷取文字。原始圖片不會被儲存到相簿，也不會被上傳；辨識完成後即從記憶體釋放。';

  @override
  String get privacyMicTitle => '麥克風與語音';

  @override
  String get privacyMicBody =>
      '語音記帳使用 iOS 系統語音辨識，並強制要求裝置端辨識。音訊不會被寫入磁碟，也不會被上傳。若系統無法在本機完成辨識，該功能會提示暫不可用，而不會改用雲端辨識。';

  @override
  String get privacyExportDeleteTitle => '資料匯出與刪除';

  @override
  String get privacyExportDeleteBody =>
      '你可以在「設定 → 資料」匯出 CSV 表格或 JSON 備份，檔案由你自己儲存與分享；也可以在「設定 → 清空全部帳單」一鍵刪除全部帳單記錄。解除安裝 App 會刪除本機儲存的全部資料，請提前匯出備份。';

  @override
  String get privacyPermissionsTitle => '權限說明';

  @override
  String get privacyPermissionsBody =>
      '相機、照片、麥克風與語音辨識權限都是可選的，只在對應功能中按需申請。即使拒絕這些權限，手動記帳、報表、預算與匯出等功能仍可正常使用。';

  @override
  String get privacyChildrenTitle => '兒童隱私';

  @override
  String get privacyChildrenBody =>
      '本 App 不收集任何使用者的資料，也不含廣告或第三方追蹤，適用於包括未成年人在內的所有使用者；我們不會針對兒童推送定向內容。';

  @override
  String get privacyUpdatesTitle => '政策更新';

  @override
  String get privacyUpdatesBody =>
      '如果未來的版本改變了資料處理方式，我們會在 App 內更新本頁面，並同步調整 App Store 的隱私標籤。';

  @override
  String get privacyContactTitle => '聯絡我們';

  @override
  String get privacyContactBody =>
      '如對本政策有疑問，請聯絡 privacy@altn.vision；回饋問題請寄 feedback@altn.vision。';

  @override
  String get termsServiceTitle => '服務說明';

  @override
  String get termsServiceBody =>
      '衡記是一款免費、本地優先的個人記帳工具，提供手動記帳、拍照辨識、語音記帳、收支統計報表、預算提醒與資料匯出等功能。App 的全部功能都在這台裝置上執行。';

  @override
  String get termsNoticeTitle => '使用須知';

  @override
  String get termsNoticeBody =>
      '你需要對錄入資訊的準確性負責。拍照辨識與語音辨識的結果可能因為收據模糊、口音或環境噪音出現誤差，請在儲存前核對。建議定期匯出 JSON 備份。';

  @override
  String get termsFreeTitle => '免費與內購';

  @override
  String get termsFreeBody =>
      '目前版本免費提供，沒有訂閱、沒有內購、沒有廣告。若未來調整收費方式，我們會提前在 App 內說明，不會影響你已儲存在本機的資料。';

  @override
  String get termsBackupTitle => '資料與備份';

  @override
  String get termsBackupBody =>
      '你的資料只儲存在本機，開發者無法存取，也無法替你還原。因裝置遺失、系統故障、解除安裝 App 或主動清空資料造成的資料遺失，在適用法律允許的範圍內由你自行承擔。你可以隨時在設定中匯出備份。';

  @override
  String get termsDisclaimerTitle => '免責聲明';

  @override
  String get termsDisclaimerBody =>
      'App 中的統計、預算提醒與「智慧建議」均基於本機資料和固定規則產生，僅作為個人記帳參考，不構成投資、理財、稅務、法律或醫療建議。你依據本 App 內容做出的任何決定，風險由你自行承擔。';

  @override
  String get termsIpTitle => '智慧財產權';

  @override
  String get termsIpBody =>
      'App 的介面、圖示、文案與程式碼歸開發者所有。你可以將匯出的個人帳單資料用於個人用途，但不得將其用於侵犯他人權益的用途。';

  @override
  String get termsChangesTitle => '服務變更與終止';

  @override
  String get termsChangesBody =>
      '我們可能隨系統版本更新調整或改進功能。若未來停止維護，會在 App 內提前告知；你仍然可以繼續使用本機資料，並隨時匯出備份。';

  @override
  String get termsLawTitle => '適用法律';

  @override
  String get termsLawBody => '本協議適用中華人民共和國法律。因本協議產生的爭議，雙方應先友好協商解決。';

  @override
  String get termsContactTitle => '聯絡我們';

  @override
  String get termsContactBody => '如對本協議有疑問，可以透過 App Store 商品頁上的「App 支援」連結聯絡我們。';

  @override
  String get budgetBarNotSet => '未設定預算';

  @override
  String budgetBarNearLimit(String percent) {
    return '預算快用完了，已用 $percent%';
  }

  @override
  String budgetBarUsed(String percent) {
    return '已用 $percent%';
  }

  @override
  String get budgetBarSemantic => '預算進度';

  @override
  String budgetBarSemanticWith(String label) {
    return '預算進度（$label）';
  }

  @override
  String budgetBarValue(String status, String spent, String budget) {
    return '$status，已花費 $spent，預算 $budget';
  }

  @override
  String budgetBarOver(String amount) {
    return '超支 $amount';
  }

  @override
  String get catFood => '餐飲';

  @override
  String get catTransport => '交通';

  @override
  String get catShopping => '購物';

  @override
  String get catHome => '居家';

  @override
  String get catEntertainment => '娛樂';

  @override
  String get catMedical => '醫療';

  @override
  String get catEducation => '學習';

  @override
  String get catCommunication => '通訊';

  @override
  String get catSocial => '人情';

  @override
  String get catOtherExpense => '其他';

  @override
  String get catSalary => '工資';

  @override
  String get catBonus => '獎金';

  @override
  String get catInvestment => '理財';

  @override
  String get catParttime => '兼職';

  @override
  String get catGift => '紅包';

  @override
  String get catOtherIncome => '其他';

  @override
  String get undo => '復原';

  @override
  String get monthPrev => '上個月';

  @override
  String get monthNext => '下個月';

  @override
  String get monthCurrent => '已經是本月';

  @override
  String amountSemantic(String amount) {
    return '金額 $amount';
  }

  @override
  String get currencyUnit => ' 元';

  @override
  String get chartEmpty => '還沒有足夠的資料產生趨勢圖';

  @override
  String chartSemantic(int count) {
    return '近 $count 個月收支趨勢';
  }

  @override
  String get donutTotal => '合計';

  @override
  String get donutEmpty => '暫無分類資料';

  @override
  String get donutNoData => '暫無資料';

  @override
  String donutSemantic(String amount, String label) {
    return '分類佔比環形圖，$label $amount';
  }

  @override
  String donutDesc(String percent, String amount, String category) {
    return '$category $amount，佔 $percent%';
  }

  @override
  String get introStarting => 'HENG，正在啟動';

  @override
  String get introTagline => '把帳本留在自己手機裡';

  @override
  String get introFooter => '本地優先 · 不登入 · 不聯網';

  @override
  String get sourceManual => '手動';

  @override
  String get sourceOcr => '拍照辨識';

  @override
  String get sourceVoice => '語音記帳';

  @override
  String get sourceCsv => '匯入帳單';

  @override
  String get themeBlush => 'D 玫瑰紙';

  @override
  String get themePeach => 'E 蜜桃';

  @override
  String get themeLavender => 'F 薰衣草';

  @override
  String get navTrip => '旅行';

  @override
  String get travelMode => '旅行分帳';

  @override
  String get travelModeSubtitle => '和朋友一起記旅行帳，自動算誰欠誰';

  @override
  String get splitMode => '一起分';

  @override
  String get splitModeSubtitle => '聚餐、房租、旅行，自動算清誰欠誰';

  @override
  String get splitBadge => '新';

  @override
  String get splitSettleUp => '結清';

  @override
  String get insightEmptyTitle => '本月還沒有記錄';

  @override
  String get insightEmptyBody => '用「拍照辨識」掃一張收據，或按住說一句話，3 秒記住一筆。';

  @override
  String get insightOverBudgetTitle => '本月已超出預算';

  @override
  String insightOverBudgetBody(String expense, String over) {
    return '支出 $expense，比預算多出 $over。接下來可以優先記錄，減少非必要開支。';
  }

  @override
  String insightOverBudgetMetric(String amount) {
    return '超支 $amount';
  }

  @override
  String get insightBudgetNearTitle => '預算快用完了';

  @override
  String insightBudgetNearBody(String percent, String remaining) {
    return '已使用 $percent% 的月度預算，剩餘 $remaining。';
  }

  @override
  String insightBudgetNearMetric(String amount) {
    return '剩餘 $amount';
  }

  @override
  String get insightBudgetHealthyTitle => '預算節奏健康';

  @override
  String insightBudgetHealthyBody(String percent, String remaining) {
    return '本月支出占預算的 $percent%，還有 $remaining 可用。';
  }

  @override
  String insightBudgetHealthyMetric(String amount) {
    return '可用 $amount';
  }

  @override
  String insightTopCategoryTitle(String category) {
    return '「$category」占比偏高';
  }

  @override
  String insightTopCategoryBody(
      String category, String amount, String percent) {
    return '「$category」花了 $amount，占本月支出的 $percent%。如果適當控制，每月可省下一筆。';
  }

  @override
  String insightTopCategoryMetric(String percent) {
    return '占 $percent%';
  }

  @override
  String get insightSpendUpTitle => '支出比上月高';

  @override
  String insightSpendUpBody(String expense, String delta, String percent) {
    return '本月支出 $expense，比上月多 $delta（+$percent%）。';
  }

  @override
  String insightSpendUpMetric(String percent) {
    return '+$percent%';
  }

  @override
  String get insightSpendDownTitle => '支出比上月下降';

  @override
  String insightSpendDownBody(String amount) {
    return '本月支出比上月少了 $amount，繼續保持記帳習慣。';
  }

  @override
  String insightSpendDownMetric(String percent) {
    return '$percent%';
  }

  @override
  String get insightSpendOverIncomeTitle => '本月支出大於收入';

  @override
  String insightSpendOverIncomeBody(String income, String expense) {
    return '收入 $income，支出 $expense，建議核對是否有大額非必要支出。';
  }

  @override
  String get insightSavingTitle => '儲蓄率不錯';

  @override
  String insightSavingBody(String saving, String percent) {
    return '本月結餘 $saving，儲蓄率 $percent%，高於 30% 的健康線。';
  }

  @override
  String insightSavingMetric(String percent) {
    return '儲蓄率 $percent%';
  }

  @override
  String get insightSmallFrequentTitle => '小額支出比較頻繁';

  @override
  String insightSmallFrequentBody(String count, String average) {
    return '本月共 $count 筆支出，平均每筆 $average。零散小支出累計起來也不少，可以合併記錄或設定分類預算。';
  }

  @override
  String insightSmallFrequentMetric(String count) {
    return '$count 筆';
  }

  @override
  String get insightHabitTitle => '記帳習慣正在建立';

  @override
  String get insightHabitBody => '保持每筆都記，月底的報表和建議會更準確。';

  @override
  String get rptNoExpense => '本月還沒有支出記錄';

  @override
  String get feedback => '回饋';

  @override
  String get feedbackSettingsSubtitle => '回報問題或建議功能';

  @override
  String get feedbackTitle => '回饋';

  @override
  String get feedbackSubtitle => '告訴我們發生了什麼，或你希望 HENG 改進什麼。';

  @override
  String get feedbackTypeBug => '問題';

  @override
  String get feedbackTypeFeature => '功能建議';

  @override
  String get feedbackTypeOther => '其他';

  @override
  String get feedbackMessageLabel => '問題 / 建議';

  @override
  String get feedbackMessageHint => '描述發生了什麼、如何重現；不要填寫真實金額、姓名或商戶。';

  @override
  String get feedbackIncludeInfo => '附上版本與裝置資訊';

  @override
  String get feedbackIncludeInfoSub => '僅包含 App 版本、iOS、語言與主題；不包含帳本資料。';

  @override
  String get feedbackPrivacyNote => '回饋在本機產生，只有你選擇傳送方式後才會離開裝置。';

  @override
  String get feedbackSend => '傳送郵件回饋';

  @override
  String get feedbackCopy => '複製回饋';

  @override
  String get feedbackEmpty => '請先寫一點內容。';

  @override
  String get feedbackCopied => '已複製，可貼到郵件或訊息中。';

  @override
  String get feedbackThanks => '已開啟傳送面板，請選擇郵件、訊息或其他 App。';

  @override
  String get feedbackReportSubject => 'HENG 衡記 · App 回饋';

  @override
  String get feedbackShareHint => '將開啟郵件 App，收件人已填好；沒有郵件 App 時會退回系統分享。';

  @override
  String get importFileEmpty => '檔案是空的。';

  @override
  String get importNoHeader => '找不到帳單表頭（需要「交易時間」和「金額」欄）。';

  @override
  String get importSkippedRows => '部分列缺少金額或時間，已跳過。';

  @override
  String get importNoRecords => '沒有可匯入的收支記錄。';

  @override
  String get icloudUnavailable => 'iCloud 暫時無法使用，請檢查登入狀態後重試。';

  @override
  String get addVoicePermissionError => '沒有麥克風或語音辨識權限，請在系統設定中允許後重試。';
}
