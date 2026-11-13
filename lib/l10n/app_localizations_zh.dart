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
}
