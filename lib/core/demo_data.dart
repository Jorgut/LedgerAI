import 'models.dart';
import 'storage.dart';

/// 商店截图与演示用示例数据。只在 `--dart-define=DEMO=true` 且账本为空时写入。
/// 不会影响正式用户账本（正常启动不调用）。
class DemoData {
  DemoData._();

  static Future<void> seedIfEmpty(TransactionRepository repository) async {
    if (repository.all.isNotEmpty) return;
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
    record(inThisMonth(3, 9, 5), amount: 8500, categoryId: 'salary', isIncome: true, note: '月薪', merchant: '公司');
    record(inThisMonth(0, 12, 30), amount: 42, categoryId: 'food', isIncome: false, note: '午餐', merchant: '麦当劳', source: EntrySource.ocr);
    record(inThisMonth(0, 8, 15), amount: 6, categoryId: 'transport', isIncome: false, note: '地铁通勤', merchant: '地铁');
    record(inThisMonth(1, 21, 10), amount: 189, categoryId: 'shopping', isIncome: false, note: '淘宝购物', merchant: '淘宝', source: EntrySource.voice);
    record(inThisMonth(1, 15, 0), amount: 32, categoryId: 'food', isIncome: false, note: '咖啡', merchant: '瑞幸咖啡', source: EntrySource.voice);
    record(inThisMonth(2, 19, 40), amount: 156, categoryId: 'home', isIncome: false, note: '日用品', merchant: '永辉超市');
    record(inThisMonth(2, 22, 5), amount: 45, categoryId: 'transport', isIncome: false, note: '打车', merchant: '滴滴');
    record(inThisMonth(3, 20, 0), amount: 68, categoryId: 'entertainment', isIncome: false, note: '电影票', merchant: '万达影城');
    record(inThisMonth(3, 10, 0), amount: 1200, categoryId: 'bonus', isIncome: true, note: '项目奖金');
    record(inThisMonth(4, 13, 20), amount: 89, categoryId: 'education', isIncome: false, note: '书籍', merchant: '当当');
    record(inThisMonth(4, 11, 0), amount: 300, categoryId: 'social', isIncome: false, note: '随礼');

    // —— 前 5 个月，用于趋势图与建议 ——
    for (var monthsBack = 1; monthsBack <= 5; monthsBack++) {
      DateTime dayOf(int d) => DateTime(now.year, now.month - monthsBack, d, 12, 0);
      final factor = 1.0 - (monthsBack - 1) * 0.06;
      record(dayOf(1), amount: 8500, categoryId: 'salary', isIncome: true, note: '月薪');
      record(dayOf(5), amount: 780 * factor, categoryId: 'food', isIncome: false, note: '饮食');
      record(dayOf(12), amount: 620 * factor, categoryId: 'food', isIncome: false, note: '饮食');
      record(dayOf(8), amount: 260 * factor, categoryId: 'transport', isIncome: false, note: '通勤');
      record(dayOf(15), amount: 480 * factor, categoryId: 'shopping', isIncome: false, note: '网购');
      record(dayOf(10), amount: 1800, categoryId: 'home', isIncome: false, note: '房租');
      record(dayOf(18), amount: 1200 * factor, categoryId: 'entertainment', isIncome: false, note: '娱乐');
      record(dayOf(20), amount: 260, categoryId: 'medical', isIncome: false, note: '药品');
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
