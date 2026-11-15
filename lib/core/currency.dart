import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A currency the user can record a transaction in.
///
/// The ledger's reporting currency is fixed to CNY for 1.1; foreign entries
/// store the original amount plus the manual rate used to convert them.
enum AppCurrency {
  cny('CNY', '¥', '人民币'),
  usd('USD', r'$', '美元'),
  eur('EUR', '€', '欧元'),
  kzt('KZT', '₸', '坚戈'),
  rub('RUB', '₽', '卢布'),
  jpy('JPY', '¥', '日元'),
  gbp('GBP', '£', '英镑'),
  hkd('HKD', r'HK$', '港币');

  const AppCurrency(this.code, this.symbol, this.label);

  final String code;
  final String symbol;
  final String label;

  static AppCurrency parse(String? code) => AppCurrency.values.firstWhere(
        (c) => c.code == code,
        orElse: () => AppCurrency.cny,
      );
}

/// Formats an amount in [currency]. The app's grouping style follows the UI
/// locale, matching [formatMoney] elsewhere.
String formatCurrency(double amount, AppCurrency currency,
    {bool withSymbol = true, bool signed = false}) {
  final negative = amount < 0;
  final abs = amount.abs();
  final fixed = abs.toStringAsFixed(2);
  final parts = fixed.split('.');
  final locale = (Intl.defaultLocale ?? 'zh').toLowerCase();
  final grouped = locale.startsWith('ru')
      ? parts[0].replaceAll(',', '\u00A0')
      : _group(parts[0]);
  final sign = negative ? '-' : (signed && amount > 0 ? '+' : '');
  final symbol = withSymbol ? currency.symbol : '';
  final separator = locale.startsWith('ru') ? ',' : '.';
  return '$sign$symbol$grouped$separator${parts[1]}';
}

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Convenience for tooltips / settings rows.
extension AppCurrencyDisplay on AppCurrency {
  String get displayName => '$code · $label';

  IconData get icon => switch (this) {
        AppCurrency.cny => Icons.currency_yen_rounded,
        AppCurrency.usd => Icons.attach_money_rounded,
        AppCurrency.eur => Icons.euro_rounded,
        AppCurrency.kzt => Icons.payments_rounded,
        AppCurrency.rub => Icons.currency_ruble_rounded,
        AppCurrency.jpy => Icons.currency_yen_rounded,
        AppCurrency.gbp => Icons.currency_pound_rounded,
        AppCurrency.hkd => Icons.attach_money_rounded,
      };
}
