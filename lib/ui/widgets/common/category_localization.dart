import 'package:flutter/widgets.dart';

import '../../../core/models.dart';
import '../../../l10n/app_localizations.dart';

/// 分类名称的界面本地化。分类 id 是数据/导出层面的稳定值，不能翻译。
String localizedCategoryName(BuildContext context, Category category) {
  final l10n = AppLocalizations.of(context);
  return switch (category.id) {
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
    _ => category.name,
  };
}
