import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A currency the user can record a transaction in.
///
/// The ledger's reporting currency is fixed to CNY for 1.1; foreign entries
/// store the original amount plus the manual rate used to convert them.
enum AppCurrency {
  cny('CNY', '¥', '人民币'),
  usd('USD', r'$', '美元'),
  sgd('SGD', r'S$', '新加坡元'),
  hkd('HKD', r'HK$', '港币'),
  jpy('JPY', '¥', '日元'),
  eur('EUR', '€', '欧元'),
  gbp('GBP', '£', '英镑'),
  krw('KRW', '₩', '韩元'),
  thb('THB', '฿', '泰铢'),
  myr('MYR', 'RM', '马币'),
  aud('AUD', r'A$', '澳元'),
  cad('CAD', r'C$', '加元'),
  twd('TWD', r'NT$', '新台币'),
  kzt('KZT', '₸', '坚戈'),
  rub('RUB', '₽', '卢布'),
  aed('AED', 'د.إ', '迪拉姆'),
  idr('IDR', 'Rp', '印尼盾'),
  php('PHP', '₱', '比索'),
  vnd('VND', '₫', '越南盾'),
  nzd('NZD', r'NZ$', '新西兰元'),
  chf('CHF', 'CHF', '瑞士法郎');

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
        AppCurrency.cny || AppCurrency.jpy => Icons.currency_yen_rounded,
        AppCurrency.eur => Icons.euro_rounded,
        AppCurrency.gbp => Icons.currency_pound_rounded,
        AppCurrency.rub => Icons.currency_ruble_rounded,
        _ => Icons.payments_rounded,
      };
}
