import 'models.dart';
import 'storage.dart';

/// 商店截图与演示用示例数据。只在 `--dart-define=DEMO=true` 且账本为空时写入。
/// 不会影响正式用户账本（正常启动不调用）。
class DemoData {
  DemoData._();

  static Future<void> seedIfEmpty(TransactionRepository repository, {bool english = false}) async {
    if (repository.all.isNotEmpty) return;
    String n(String zh, String en) => english ? en : zh;
    final now = DateTime.now();
    final txns = <Txn>[];
    var serial = 0;

    Txn record(
      DateTime date, {
      required double amount,
      required String categoryId,
      required bool isIncome,
      String note = '',
      String? merchant,
      EntrySource source = EntrySource.manual,
    }) {
      final txn = Txn(
        id: 'demo-${serial++}',
        amount: amount,
        categoryId: categoryId,
        date: date,
        isIncome: isIncome,
        note: note,
        merchant: merchant,
        source: source,
      );
      txns.add(txn);
      return txn;
    }

    /// 本月内 [daysAgo] 天前的某个时刻，且绝不落到上个月。
    DateTime inThisMonth(int daysAgo, int hour, int minute) {
      final safeDaysAgo = daysAgo.clamp(0, now.day - 1);
      return DateTime(now.year, now.month, now.day - safeDaysAgo, hour, minute);
    }

    // —— 本月 ——
    record(inThisMonth(3, 9, 5), amount: 8500, categoryId: 'salary', isIncome: true, note: n('月薪','Monthly salary'), merchant: n('公司','Acme Inc.'));
    record(inThisMonth(0, 12, 30), amount: 42, categoryId: 'food', isIncome: false, note: n('午餐','Lunch'), merchant: n('麦当劳','McDonald\'s'), source: EntrySource.ocr);
    record(inThisMonth(0, 8, 15), amount: 6, categoryId: 'transport', isIncome: false, note: n('地铁通勤','Metro commute'), merchant: n('地铁','Metro'));
    record(inThisMonth(1, 21, 10), amount: 189, categoryId: 'shopping', isIncome: false, note: n('淘宝购物','Online shopping'), merchant: n('淘宝','Taobao'), source: EntrySource.voice);
    record(inThisMonth(1, 15, 0), amount: 32, categoryId: 'food', isIncome: false, note: n('咖啡','Coffee'), merchant: n('瑞幸咖啡','Luckin Coffee'), source: EntrySource.voice);
    record(inThisMonth(2, 19, 40), amount: 156, categoryId: 'home', isIncome: false, note: n('日用品','Groceries'), merchant: n('永辉超市','Yonghui'));
    record(inThisMonth(2, 22, 5), amount: 45, categoryId: 'transport', isIncome: false, note: n('打车','Taxi'), merchant: n('滴滴','DiDi'));
    record(inThisMonth(3, 20, 0), amount: 68, categoryId: 'entertainment', isIncome: false, note: n('电影票','Movie tickets'), merchant: n('万达影城','Wanda Cinema'));
    record(inThisMonth(3, 10, 0), amount: 1200, categoryId: 'bonus', isIncome: true, note: n('项目奖金','Project bonus'));
    record(inThisMonth(4, 13, 20), amount: 89, categoryId: 'education', isIncome: false, note: n('书籍','Books'), merchant: n('当当','Dangdang'));
    record(inThisMonth(4, 11, 0), amount: 300, categoryId: 'social', isIncome: false, note: n('随礼','Wedding gift'));

    // —— 前 5 个月，用于趋势图与建议 ——
    for (var monthsBack = 1; monthsBack <= 5; monthsBack++) {
      DateTime dayOf(int d) => DateTime(now.year, now.month - monthsBack, d, 12, 0);
      final factor = 1.0 - (monthsBack - 1) * 0.06;
      record(dayOf(1), amount: 8500, categoryId: 'salary', isIncome: true, note: n('月薪','Monthly salary'));
      record(dayOf(5), amount: 780 * factor, categoryId: 'food', isIncome: false, note: n('饮食','Dining'));
      record(dayOf(12), amount: 620 * factor, categoryId: 'food', isIncome: false, note: n('饮食','Dining'));
      record(dayOf(8), amount: 260 * factor, categoryId: 'transport', isIncome: false, note: n('通勤','Commute'));
      record(dayOf(15), amount: 480 * factor, categoryId: 'shopping', isIncome: false, note: n('网购','Shopping'));
      record(dayOf(10), amount: 1800, categoryId: 'home', isIncome: false, note: n('房租','Rent'));
      record(dayOf(18), amount: 1200 * factor, categoryId: 'entertainment', isIncome: false, note: n('娱乐','Entertainment'));
      record(dayOf(20), amount: 260, categoryId: 'medical', isIncome: false, note: n('药品','Pharmacy'));
    }

    await repository.saveAll(txns);
  }

  static Future<void> seedSettings(SettingsStore store) async {
    if (store.value.monthlyBudget != null) return;
    await store.update(store.value.copyWith(
      onboardingDone: true,
      monthlyBudget: 6000,
      categoryBudgets: const {
        'food': 2000,
        'transport': 600,
        'shopping': 1000,
        'entertainment': 500,
      },
    ));
  }
}
