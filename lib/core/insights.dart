import '../l10n/app_localizations.dart';
import 'app_settings.dart';
import 'format.dart';
import 'stats.dart';
import 'storage.dart';

/// 建议的语义色调，UI 据此选图标与颜色。
enum InsightTone { positive, warning, neutral }

class Insight {
  const Insight({
    required this.title,
    required this.body,
    this.tone = InsightTone.neutral,
    this.metric,
  });

  final String title;
  final String body;
  final InsightTone tone;

  /// 可选的关键数字，例如「本月可再花 ¥1,240」。
  final String? metric;
}

/// 本地智能建议：完全基于本机数据与确定性规则，不上传任何内容。
/// 用「智能建议」而不是「大模型」表述，符合真实能力边界。
class InsightsService {
  InsightsService(this._repository, this._stats);

  final TransactionRepository _repository;
  final StatsService _stats;

  List<Insight> forMonth(
    DateTime month, {
    AppSettings? settings,
    AppLocalizations? l10n,
  }) {
    final year = month.year;
    final monthNumber = month.month;
    final summary = _stats.summary(year, monthNumber);
    final insights = <Insight>[];

    if (summary.count == 0) {
      return [
        Insight(
          title: l10n?.insightEmptyTitle ?? '本月还没有记录',
          body: l10n?.insightEmptyBody ??
              '用「拍照识别」扫一张小票，或者按住说一句话，3 秒记住一笔。',
          tone: InsightTone.neutral,
        ),
      ];
    }

    final budget = settings?.monthlyBudget;
    if (budget != null && budget > 0) {
      final ratio = summary.expense / budget;
      if (ratio > 1) {
        insights.add(Insight(
          title: l10n?.insightOverBudgetTitle ?? '本月已超出预算',
          body: l10n?.insightOverBudgetBody(
                formatMoney(summary.expense),
                formatMoney(summary.expense - budget),
              ) ??
              '支出 ${formatMoney(summary.expense)}，比预算多出 ${formatMoney(summary.expense - budget)}。接下来可以优先记录，减少非必要开支。',
          tone: InsightTone.warning,
          metric: l10n?.insightOverBudgetMetric(
                formatCompactMoney(summary.expense - budget),
              ) ??
              '超支 ${formatCompactMoney(summary.expense - budget)}',
        ));
      } else if (ratio >= 0.8) {
        insights.add(Insight(
          title: l10n?.insightBudgetNearTitle ?? '预算快用完了',
          body: l10n?.insightBudgetNearBody(
                (ratio * 100).toStringAsFixed(0),
                formatMoney(budget - summary.expense),
              ) ??
              '已使用 ${(ratio * 100).toStringAsFixed(0)}% 的月度预算，剩余 ${formatMoney(budget - summary.expense)}。',
          tone: InsightTone.warning,
          metric: l10n?.insightBudgetNearMetric(
                formatCompactMoney(budget - summary.expense),
              ) ??
              '剩余 ${formatCompactMoney(budget - summary.expense)}',
        ));
      } else {
        insights.add(Insight(
          title: l10n?.insightBudgetHealthyTitle ?? '预算节奏健康',
          body: l10n?.insightBudgetHealthyBody(
                (ratio * 100).toStringAsFixed(0),
                formatMoney(budget - summary.expense),
              ) ??
              '本月支出占预算的 ${(ratio * 100).toStringAsFixed(0)}%，还有 ${formatMoney(budget - summary.expense)} 可用。',
          tone: InsightTone.positive,
          metric: l10n?.insightBudgetHealthyMetric(
                formatCompactMoney(budget - summary.expense),
              ) ??
              '可用 ${formatCompactMoney(budget - summary.expense)}',
        ));
      }
    }

    final breakdown = _stats.breakdown(year, monthNumber);
    if (breakdown.isNotEmpty && breakdown.first.ratio >= 0.35) {
      final top = breakdown.first;
      final category = _localizedCategoryName(
        l10n,
        top.category.id,
        top.category.name,
      );
      insights.add(Insight(
        title: l10n?.insightTopCategoryTitle(category) ??
            '「$category」占比偏高',
        body: l10n?.insightTopCategoryBody(
              category,
              formatMoney(top.amount),
              (top.ratio * 100).toStringAsFixed(0),
            ) ??
            '「$category」花了 ${formatMoney(top.amount)}，占本月支出的 ${(top.ratio * 100).toStringAsFixed(0)}%。如果适当控制，每月可省下一笔。',
        tone: InsightTone.neutral,
        metric: l10n?.insightTopCategoryMetric(
              (top.ratio * 100).toStringAsFixed(0),
            ) ??
            '占 ${(top.ratio * 100).toStringAsFixed(0)}%',
      ));
    }

    final previous = DateTime(year, monthNumber - 1, 1);
    final previousSummary = _stats.summary(previous.year, previous.month);
    if (previousSummary.expense > 0) {
      final delta = summary.expense - previousSummary.expense;
      final ratio = delta / previousSummary.expense;
      if (delta > 0 && ratio >= 0.2) {
        insights.add(Insight(
          title: l10n?.insightSpendUpTitle ?? '支出比上月高',
          body: l10n?.insightSpendUpBody(
                formatMoney(summary.expense),
                formatMoney(delta),
                (ratio * 100).toStringAsFixed(0),
              ) ??
              '本月支出 ${formatMoney(summary.expense)}，比上月多 ${formatMoney(delta)}（+${(ratio * 100).toStringAsFixed(0)}%）。',
          tone: InsightTone.warning,
          metric: l10n?.insightSpendUpMetric(
                (ratio * 100).toStringAsFixed(0),
              ) ??
              '+${(ratio * 100).toStringAsFixed(0)}%',
        ));
      } else if (delta < 0 && ratio <= -0.1) {
        insights.add(Insight(
          title: l10n?.insightSpendDownTitle ?? '支出比上月下降',
          body: l10n?.insightSpendDownBody(formatMoney(-delta)) ??
              '本月支出比上月少了 ${formatMoney(-delta)}，继续保持记账习惯。',
          tone: InsightTone.positive,
          metric: l10n?.insightSpendDownMetric(
                (ratio * 100).toStringAsFixed(0),
              ) ??
              '${(ratio * 100).toStringAsFixed(0)}%',
        ));
      }
    }

    if (summary.income > 0) {
      final saving = summary.income - summary.expense;
      final rate = saving / summary.income;
      if (rate < 0) {
        insights.add(Insight(
          title: l10n?.insightSpendOverIncomeTitle ?? '本月支出大于收入',
          body: l10n?.insightSpendOverIncomeBody(
                formatMoney(summary.income),
                formatMoney(summary.expense),
              ) ??
              '收入 ${formatMoney(summary.income)}，支出 ${formatMoney(summary.expense)}，建议核对是否有大额非必要支出。',
          tone: InsightTone.warning,
        ));
      } else if (rate >= 0.3) {
        insights.add(Insight(
          title: l10n?.insightSavingTitle ?? '储蓄率不错',
          body: l10n?.insightSavingBody(
                formatMoney(saving),
                (rate * 100).toStringAsFixed(0),
              ) ??
              '本月结余 ${formatMoney(saving)}，储蓄率 ${(rate * 100).toStringAsFixed(0)}%，高于 30% 的健康线。',
          tone: InsightTone.positive,
          metric: l10n?.insightSavingMetric(
                (rate * 100).toStringAsFixed(0),
              ) ??
              '储蓄率 ${(rate * 100).toStringAsFixed(0)}%',
        ));
      }
    }

    final recent =
        _repository.byMonth(year, monthNumber).where((t) => !t.isIncome).toList();
    if (recent.length >= 5) {
      final average = summary.expense / recent.length;
      if (average < 30) {
        insights.add(Insight(
          title: l10n?.insightSmallFrequentTitle ?? '小额支出比较频繁',
          body: l10n?.insightSmallFrequentBody(
                recent.length.toString(),
                formatMoney(average),
              ) ??
              '本月共 ${recent.length} 笔支出，平均每笔 ${formatMoney(average)}。零散小支出累计起来也不少，可以合并记录或设置分类预算。',
          tone: InsightTone.neutral,
          metric: l10n?.insightSmallFrequentMetric(recent.length.toString()) ??
              '${recent.length} 笔',
        ));
      }
    }

    if (insights.isEmpty) {
      insights.add(Insight(
        title: l10n?.insightHabitTitle ?? '记账习惯正在建立',
        body: l10n?.insightHabitBody ??
            '保持每笔都记，月底的报表和建议会更准确。',
        tone: InsightTone.neutral,
      ));
    }

    return insights.take(3).toList(growable: false);
  }
}

String _localizedCategoryName(
  AppLocalizations? l10n,
  String id,
  String fallback,
) {
  if (l10n == null) return fallback;
  return switch (id) {
    'food' => l10n.catFood,
    'transport' => l10n.catTransport,
    'shopping' => l10n.catShopping,
    'home' => l10n.catHome,
    'entertainment' => l10n.catEntertainment,
    'medical' => l10n.catMedical,
    'education' => l10n.catEducation,
    'communication' => l10n.catCommunication,
    'social' => l10n.catSocial,
    'other_expense' => l10n.catOtherExpense,
    'salary' => l10n.catSalary,
    'bonus' => l10n.catBonus,
    'investment' => l10n.catInvestment,
    'parttime' => l10n.catParttime,
    'gift' => l10n.catGift,
    'other_income' => l10n.catOtherIncome,
    _ => fallback,
  };
}
