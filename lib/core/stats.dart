import 'models.dart';
import 'storage.dart';

/// 单月汇总。
class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.count,
  });

  final double income;
  final double expense;
  final int count;

  double get balance => income - expense;

  bool get isEmpty => count == 0;
}

/// 分类占比条目。
class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.ratio,
  });

  final Category category;
  final double amount;

  /// 0..1，占当期该类总额的比例。
  final double ratio;
}

/// 趋势图上的一个月。
class MonthPoint {
  const MonthPoint({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  final int year;
  final int month;
  final double income;
  final double expense;
}

/// 记账统计。所有结果由本机数据实时计算。
class StatsService {
  StatsService(this._repository);

  final TransactionRepository _repository;

  MonthSummary summary(int year, int month) {
    var income = 0.0;
    var expense = 0.0;
    var count = 0;
    for (final txn in _repository.byMonth(year, month)) {
      count++;
      if (txn.isIncome) {
        income += txn.amount;
      } else {
        expense += txn.amount;
      }
    }
    return MonthSummary(income: income, expense: expense, count: count);
  }

  /// 分类支出/收入占比，按金额降序。
  List<CategorySlice> breakdown(
    int year,
    int month, {
    bool isIncome = false,
  }) {
    final totals = <String, double>{};
    for (final txn in _repository.byMonth(year, month)) {
      if (txn.isIncome != isIncome) continue;
      totals.update(txn.categoryId, (value) => value + txn.amount, ifAbsent: () => txn.amount);
    }
    final sum = totals.values.fold(0.0, (a, b) => a + b);
    final slices = totals.entries
        .map((entry) => CategorySlice(
              category: Category.byId(entry.key),
              amount: entry.value,
              ratio: sum <= 0 ? 0 : entry.value / sum,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return slices;
  }

  /// 最近 [months] 个月的趋势（含当月，按时间正序）。
  List<MonthPoint> trend({int months = 6, DateTime? end}) {
    final anchor = end ?? DateTime.now();
    final points = <MonthPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(anchor.year, anchor.month - i, 1);
      final monthSummary = summary(monthDate.year, monthDate.month);
      points.add(MonthPoint(
        year: monthDate.year,
        month: monthDate.month,
        income: monthSummary.income,
        expense: monthSummary.expense,
      ));
    }
    return points;
  }

  /// 今日支出合计。
  double todayExpense({DateTime? now}) {
    final today = now ?? DateTime.now();
    return _repository
        .inRange(DateTime(today.year, today.month, today.day),
            DateTime(today.year, today.month, today.day + 1))
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// 某月支出预算使用比例（0..∞）。未设置预算返回 null。
  double? budgetRatio(double? monthlyBudget, int year, int month) {
    if (monthlyBudget == null || monthlyBudget <= 0) return null;
    return summary(year, month).expense / monthlyBudget;
  }
}
