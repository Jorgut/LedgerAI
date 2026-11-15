import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/currency.dart';
import '../../core/format.dart';
import '../../core/money_display.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/common/app_snack.dart';

/// Default display currency plus the manual CNY rates used by the ledger.
class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(AppCurrency c) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return c.code.toLowerCase().contains(q) ||
        c.label.contains(q) ||
        c.englishName.toLowerCase().contains(q);
  }

  Future<void> _resetRates(BuildContext context) async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    await app.updateSettingsWith(
      (settings) => settings.copyWith(manualRates: defaultManualRates),
    );
    if (context.mounted) AppSnack.success(context, l10n.ratesResetDone);
  }

  Future<void> _setDefault(BuildContext context, AppCurrency currency) async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    if (!MoneyDisplay.hasRate(currency)) {
      AppSnack.show(context, l10n.rateNotSet);
      await _editRate(context, currency);
      if (!context.mounted || !MoneyDisplay.hasRate(currency)) return;
    }
    await app.updateSettingsWith(
      (settings) => settings.copyWith(defaultCurrency: currency),
    );
    app.setViewCurrency(currency);
  }

  Future<void> _editRate(BuildContext context, AppCurrency currency) async {
    final app = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final current = app.prefs.manualRates[currency.code];
    final controller = TextEditingController(
      text: current == null
          ? ''
          : (current % 1 == 0
              ? current.toStringAsFixed(0)
              : current.toStringAsFixed(4)),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rateDialogTitle(currency.code)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0.0000'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = parseAmount(controller.text);
              if (parsed == null || parsed <= 0) return;
              Navigator.pop(dialogContext, parsed);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await app.updateSettingsWith((settings) {
      final rates = Map<String, double>.from(settings.manualRates);
      rates[currency.code] = value;
      return settings.copyWith(manualRates: rates);
    });
    if (context.mounted) AppSnack.success(context, l10n.rateSaved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final prefs = app.prefs;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.currencySettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: l10n.searchCurrencyHint,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.defaultCurrencyLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final currency in AppCurrency.values.where(_matches)) ...[
                  ListTile(
                    leading: Icon(currency.icon),
                    title: Text(currency.displayName),
                    trailing: prefs.defaultCurrency == currency
                        ? Icon(Icons.check_rounded,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () => _setDefault(context, currency),
                  ),
                  if (currency != AppCurrency.values.last) const Divider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.manualRatesLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _resetRates(context),
                child: Text(l10n.ratesReset),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.manualRatesSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.ratesReferenceNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final currency in AppCurrency.values.where(_matches))
                  if (currency != AppCurrency.cny) ...[
                    ListTile(
                      leading: Icon(currency.icon),
                      title: Text(currency.displayName),
                      subtitle: Text(
                        prefs.manualRates[currency.code] == null
                            ? l10n.rateNotSet
                            : '1 ${currency.code} = ${formatNumber(prefs.manualRates[currency.code]!)} CNY',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _editRate(context, currency),
                    ),
                    const Divider(),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
