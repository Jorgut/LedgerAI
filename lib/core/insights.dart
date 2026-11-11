import 'app_settings.dart';
import 'format.dart';
import 'models.dart';
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

  List<Insight> forMonth(DateTime month, {AppSettings? settings}) {
    final year = month.year;
    final monthNumber = month.month;
    final summary = _stats.summary(year, monthNumber);
    final insights = <Insight>[];

    if (summary.count == 0) {
      return const [
        Insight(
          title: '本月还没有记录',
          body: '用「拍照识别」扫一张小票，或者按住说一句话，3 秒记住一笔。',
          tone: InsightTone.neutral,
        ),
      ];
    }

    final budget = settings?.monthlyBudget;
    if (budget != null && budget > 0) {
      final ratio = summary.expense / budget;
      if (ratio > 1) {
        insights.add(Insight(
          title: '本月已超出预算',
          body: '支出 ${formatMoney(summary.expense)}，比预算多出 ${formatMoney(summary.expense - budget)}。接下来可以优先记录，减少非必要开支。',
          tone: InsightTone.warning,
          metric: '超支 ${formatCompactMoney(summary.expense - budget)}',
        ));
      } else if (ratio >= 0.8) {
        insights.add(Insight(
          title: '预算快用完了',
          body: '已使用 ${(ratio * 100).toStringAsFixed(0)}% 的月度预算，剩余 ${formatMoney(budget - summary.expense)}。',
          tone: InsightTone.warning,
          metric: '剩余 ${formatCompactMoney(budget - summary.expense)}',
        ));
      } else {
        insights.add(Insight(
          title: '预算节奏健康',
          body: '本月支出占预算的 ${(ratio * 100).toStringAsFixed(0)}%，还有 ${formatMoney(budget - summary.expense)} 可用。',
          tone: InsightTone.positive,
          metric: '可用 ${formatCompactMoney(budget - summary.expense)}',
        ));
      }
    }

    final breakdown = _stats.breakdown(year, monthNumber);
    if (breakdown.isNotEmpty && breakdown.first.ratio >= 0.35) {
      final top = breakdown.first;
      insights.add(Insight(
        title: '「${top.category.name}」占比偏高',
        body:
            '「${top.category.name}」花了 ${formatMoney(top.amount)}，占本月支出的 ${(top.ratio * 100).toStringAsFixed(0)}%。如果适当控制，每月可省下一笔。',
        tone: InsightTone.neutral,
        metric: '占 ${(top.ratio * 100).toStringAsFixed(0)}%',
      ));
    }

    final previous = DateTime(year, monthNumber - 1, 1);
    final previousSummary = _stats.summary(previous.year, previous.month);
    if (previousSummary.expense > 0) {
      final delta = summary.expense - previousSummary.expense;
      final ratio = delta / previousSummary.expense;
      if (delta > 0 && ratio >= 0.2) {
        insights.add(Insight(
          title: '支出比上月高',
          body: '本月支出 ${formatMoney(summary.expense)}，比上月多 ${formatMoney(delta)}（+${(ratio * 100).toStringAsFixed(0)}%）。',
          tone: InsightTone.warning,
          metric: '+${(ratio * 100).toStringAsFixed(0)}%',
        ));
      } else if (delta < 0 && ratio <= -0.1) {
        insights.add(Insight(
          title: '支出比上月下降',
          body: '本月支出比上月少了 ${formatMoney(-delta)}，继续保持记账习惯。',
          tone: InsightTone.positive,
          metric: '${(ratio * 100).toStringAsFixed(0)}%',
        ));
      }
    }

    if (summary.income > 0) {
      final saving = summary.income - summary.expense;
      final rate = saving / summary.income;
      if (rate < 0) {
        insights.add(Insight(
          title: '本月支出大于收入',
          body: '收入 ${formatMoney(summary.income)}，支出 ${formatMoney(summary.expense)}，建议核对是否有大额非必要支出。',
          tone: InsightTone.warning,
        ));
      } else if (rate >= 0.3) {
        insights.add(Insight(
          title: '储蓄率不错',
          body: '本月结余 ${formatMoney(saving)}，储蓄率 ${(rate * 100).toStringAsFixed(0)}%，高于 30% 的健康线。',
          tone: InsightTone.positive,
          metric: '储蓄率 ${(rate * 100).toStringAsFixed(0)}%',
        ));
      }
    }

    final recent = _repository.byMonth(year, monthNumber).where((t) => !t.isIncome).toList();
    if (recent.length >= 5) {
      final average = summary.expense / recent.length;
      if (average < 30) {
        insights.add(Insight(
          title: '小额支出比较频繁',
          body: '本月共 ${recent.length} 笔支出，平均每笔 ${formatMoney(average)}。零散小支出累计起来也不少，可以合并记录或设置分类预算。',
          tone: InsightTone.neutral,
          metric: '${recent.length} 笔',
        ));
      }
    }

    if (insights.isEmpty) {
      insights.add(const Insight(
        title: '记账习惯正在建立',
        body: '保持每笔都记，月底的报表和建议会更准确。',
        tone: InsightTone.neutral,
      ));
    }

    return insights.take(3).toList(growable: false);
  }
}
