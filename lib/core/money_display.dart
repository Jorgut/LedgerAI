import 'package:intl/intl.dart';

import 'currency.dart';

/// Session-wide display currency and manual rates (CNY per 1 unit).
///
/// Ledger values are canonical CNY. When the user changes the display
/// currency, only presentation changes; stored amounts are untouched.
class MoneyDisplay {
  MoneyDisplay._();

  static AppCurrency currency = AppCurrency.cny;
  static Map<String, double> rates = const {};

  static void configure(AppCurrency target, Map<String, double> manualRates) {
    currency = target;
    rates = Map<String, double>.from(manualRates);
  }

  /// CNY → display currency. Falls back to CNY when the rate is missing.
  static double fromCny(double cny) {
    final rate = rateOf(currency);
    return rate == null ? cny : cny / rate;
  }

  /// Display currency → CNY. Falls back to identity when the rate is missing.
  static double toCny(double displayed) {
    final rate = rateOf(currency);
    return rate == null ? displayed : displayed * rate;
  }

  static double? rateOf(AppCurrency c) {
    if (c == AppCurrency.cny) return 1;
    final value = rates[c.code];
    return (value == null || value <= 0) ? null : value;
  }

  static bool hasRate(AppCurrency c) => rateOf(c) != null;

  static String format(double cny,
      {bool withSymbol = true, bool signed = false}) {
    return formatCurrency(fromCny(cny), currency,
        withSymbol: withSymbol, signed: signed);
  }

  static String compact(double cny) {
    final value = fromCny(cny);
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    final locale = (Intl.defaultLocale ?? 'zh').toLowerCase();
    final useK = locale.startsWith('en') || locale.startsWith('ru');
    if (abs >= 10000) {
      if (useK) {
        return '$sign${(abs / 1000).toStringAsFixed(0)}K';
      }
      final value = abs / 10000;
      final text = value >= 10
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
      return '$sign${text.replaceAll(RegExp(r'\.0$'), '')}万';
    }
    if (abs >= 1000) {
      if (useK) {
        final text = (abs / 1000).toStringAsFixed(1);
        return '$sign${text.replaceAll(RegExp(r'\.0$'), '')}K';
      }
      final text = (abs / 1000).toStringAsFixed(1);
      return '$sign${text.replaceAll(RegExp(r'\.0$'), '')}千';
    }
    return '$sign${abs.toStringAsFixed(0)}';
  }
}