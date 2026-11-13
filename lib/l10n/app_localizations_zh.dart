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
}
