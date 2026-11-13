import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../l10n/app_localizations.dart';

/// 月份切换器：上个月 / 当前月份 / 下个月。
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    this.canNext = true,
    this.trailing,
  });

  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canNext;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: AppLocalizations.of(context).monthPrev,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            label: formatMonthLabel(year, month, locale: Localizations.localeOf(context)),
            child: ExcludeSemantics(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatMonthLabel(year, month, locale: Localizations.localeOf(context)),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: canNext
              ? AppLocalizations.of(context).monthNext
              : AppLocalizations.of(context).monthCurrent,
          onPressed: canNext ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
