import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A currency the user can record a transaction in.
///
/// The ledger's reporting currency is fixed to CNY for 1.1; foreign entries
/// store the original amount plus the manual rate used to convert them.
enum AppCurrency {
  cny('CNY', '¥', '人民币', 'Chinese Yuan'),
  usd('USD', r'$', '美元', 'US Dollar'),
  sgd('SGD', r'S$', '新加坡元', 'Singapore Dollar'),
  hkd('HKD', r'HK$', '港币', 'Hong Kong Dollar'),
  jpy('JPY', '¥', '日元', 'Japanese Yen'),
  eur('EUR', '€', '欧元', 'Euro'),
  gbp('GBP', '£', '英镑', 'British Pound'),
  krw('KRW', '₩', '韩元', 'South Korean Won'),
  thb('THB', '฿', '泰铢', 'Thai Baht'),
  myr('MYR', 'RM', '马币', 'Malaysian Ringgit'),
  aud('AUD', r'A$', '澳元', 'Australian Dollar'),
  cad('CAD', r'C$', '加元', 'Canadian Dollar'),
  twd('TWD', r'NT$', '新台币', 'New Taiwan Dollar'),
  kzt('KZT', '₸', '坚戈', 'Kazakhstani Tenge'),
  rub('RUB', '₽', '卢布', 'Russian Ruble'),
  aed('AED', 'د.إ', '迪拉姆', 'UAE Dirham'),
  idr('IDR', 'Rp', '印尼盾', 'Indonesian Rupiah'),
  php('PHP', '₱', '菲律宾比索', 'Philippine Peso'),
  vnd('VND', '₫', '越南盾', 'Vietnamese Dong'),
  nzd('NZD', r'NZ$', '新西兰元', 'New Zealand Dollar'),
  chf('CHF', 'CHF', '瑞士法郎', 'Swiss Franc'),
  try_('TRY', '₺', '土耳其里拉', 'Turkish Lira'),
  ils('ILS', '₪', '以色列谢克尔', 'Israeli Shekel'),
  egp('EGP', 'E£', '埃及镑', 'Egyptian Pound'),
  mxn('MXN', r'MX$', '墨西哥比索', 'Mexican Peso'),
  brl('BRL', r'R$', '巴西雷亚尔', 'Brazilian Real'),
  ars('ARS', r'AR$', '阿根廷比索', 'Argentine Peso'),
  clp('CLP', r'CLP$', '智利比索', 'Chilean Peso'),
  cop('COP', r'COL$', '哥伦比亚比索', 'Colombian Peso'),
  pen('PEN', 'S/', '秘鲁索尔', 'Peruvian Sol'),
  bgn('BGN', 'лв', '保加利亚列弗', 'Bulgarian Lev'),
  ron('RON', 'lei', '罗马尼亚列伊', 'Romanian Leu'),
  huf('HUF', 'Ft', '匈牙利福林', 'Hungarian Forint'),
  czk('CZK', 'Kč', '捷克克朗', 'Czech Koruna'),
  pln('PLN', 'zł', '波兰兹罗提', 'Polish Zloty'),
  sek('SEK', 'kr', '瑞典克朗', 'Swedish Krona'),
  nok('NOK', 'kr', '挪威克朗', 'Norwegian Krone'),
  dkk('DKK', 'kr', '丹麦克朗', 'Danish Krone'),
  isk('ISK', 'kr', '冰岛克朗', 'Icelandic Krona'),
  zar('ZAR', 'R', '南非兰特', 'South African Rand'),
  ngn('NGN', '₦', '尼日利亚奈拉', 'Nigerian Naira'),
  kes('KES', 'KSh', '肯尼亚先令', 'Kenyan Shilling'),
  mad('MAD', 'د.م.', '摩洛哥迪拉姆', 'Moroccan Dirham'),
  tnd('TND', 'د.ت', '突尼斯第纳尔', 'Tunisian Dinar'),
  jod('JOD', 'د.ا', '约旦第纳尔', 'Jordanian Dinar'),
  qar('QAR', 'ر.ق', '卡塔尔里亚尔', 'Qatari Riyal'),
  sar('SAR', 'ر.س', '沙特里亚尔', 'Saudi Riyal'),
  omr('OMR', 'ر.ع.', '阿曼里亚尔', 'Omani Rial'),
  bhd('BHD', '.د.ب', '巴林第纳尔', 'Bahraini Dinar'),
  kwd('KWD', 'د.ك', '科威特第纳尔', 'Kuwaiti Dinar'),
  lkr('LKR', 'Rs', '斯里兰卡卢比', 'Sri Lankan Rupee'),
  npr('NPR', 'Rs', '尼泊尔卢比', 'Nepalese Rupee'),
  pkr('PKR', 'Rs', '巴基斯坦卢比', 'Pakistani Rupee'),
  bdt('BDT', '৳', '孟加拉塔卡', 'Bangladeshi Taka'),
  mmk('MMK', 'K', '缅甸缅元', 'Myanmar Kyat'),
  khr('KHR', '៛', '柬埔寨瑞尔', 'Cambodian Riel'),
  lak('LAK', '₭', '老挝基普', 'Lao Kip'),
  mnt('MNT', '₮', '蒙古图格里克', 'Mongolian Tugrik'),
  uah('UAH', '₴', '乌克兰格里夫纳', 'Ukrainian Hryvnia'),
  gel('GEL', '₾', '格鲁吉亚拉里', 'Georgian Lari'),
  amd('AMD', '֏', '亚美尼亚德拉姆', 'Armenian Dram'),
  azn('AZN', '₼', '阿塞拜疆马纳特', 'Azerbaijani Manat'),
  byn('BYN', 'Br', '白俄罗斯卢布', 'Belarusian Ruble'),
  rsd('RSD', 'дин', '塞尔维亚第纳尔', 'Serbian Dinar'),
  uzs('UZS', "so'm", '乌兹别克斯坦苏姆', 'Uzbekistani Som'),
  kgs('KGS', 'сом', '吉尔吉斯斯坦索姆', 'Kyrgyzstani Som'),
  tjs('TJS', 'ЅМ', '塔吉克斯坦索莫尼', 'Tajikistani Somoni'),
  mop('MOP', r'MOP$', '澳门元', 'Macanese Pataca'),
  bnd('BND', r'B$', '文莱元', 'Brunei Dollar'),
  fjd('FJD', r'FJ$', '斐济元', 'Fijian Dollar'),
  pgk('PGK', 'K', '巴布亚新几内亚基那', 'Papua New Guinean Kina'),
  xpf('XPF', '₣', '太平洋法郎', 'CFP Franc'),
  mur('MUR', '₨', '毛里求斯卢比', 'Mauritian Rupee'),
  mvr('MVR', 'Rf', '马尔代夫拉菲亚', 'Maldivian Rufiyaa'),
  bwp('BWP', 'P', '博茨瓦纳普拉', 'Botswana Pula'),
  nad('NAD', r'N$', '纳米比亚元', 'Namibian Dollar'),
  mzn('MZN', 'MT', '莫桑比克梅蒂卡尔', 'Mozambican Metical'),
  aoa('AOA', 'Kz', '安哥拉宽扎', 'Angolan Kwanza'),
  xof('XOF', 'CFA', '西非法郎', 'West African CFA'),
  xaf('XAF', 'FCFA', '中非法郎', 'Central African CFA'),
  etb('ETB', 'Br', '埃塞俄比亚比尔', 'Ethiopian Birr'),
  tzs('TZS', 'TSh', '坦桑尼亚先令', 'Tanzanian Shilling'),
  ugx('UGX', 'USh', '乌干达先令', 'Ugandan Shilling'),
  ghs('GHS', '₵', '加纳塞地', 'Ghanaian Cedi');

  const AppCurrency(this.code, this.symbol, this.label, this.englishName);

  final String code;
  final String symbol;
  final String label;
  final String englishName;

  static AppCurrency parse(String? code) => AppCurrency.values.firstWhere(
        (c) => c.code == code,
        orElse: () => AppCurrency.cny,
      );
}

/// Realistic, editable reference rates: 1 unit of currency = N CNY.
/// These are seed values only; users can change them in Settings.
const Map<String, double> defaultManualRates = <String, double>{
  'USD': 7.15,
  'SGD': 5.35,
  'HKD': 0.918,
  'JPY': 0.0475,
  'EUR': 7.8,
  'GBP': 9.15,
  'KRW': 0.0052,
  'THB': 0.205,
  'MYR': 1.62,
  'AUD': 4.75,
  'CAD': 5.25,
  'TWD': 0.223,
  'KZT': 0.0135,
  'RUB': 0.078,
  'AED': 1.95,
  'IDR': 0.00045,
  'PHP': 0.125,
  'VND': 0.00028,
  'NZD': 4.35,
  'CHF': 8.05,
  'TRY': 0.2,
  'ILS': 1.95,
  'EGP': 0.145,
  'MXN': 0.39,
  'BRL': 1.3,
  'ARS': 0.007,
  'CLP': 0.0075,
  'COP': 0.0018,
  'PEN': 1.9,
  'BGN': 3.99,
  'RON': 1.57,
  'HUF': 0.02,
  'CZK': 0.31,
  'PLN': 1.8,
  'SEK': 0.68,
  'NOK': 0.67,
  'DKK': 1.04,
  'ISK': 0.052,
  'ZAR': 0.39,
  'NGN': 0.0047,
  'KES': 0.055,
  'MAD': 0.72,
  'TND': 2.3,
  'JOD': 10.1,
  'QAR': 1.96,
  'SAR': 1.9,
  'OMR': 18.6,
  'BHD': 19.0,
  'KWD': 23.3,
  'LKR': 0.024,
  'NPR': 0.054,
  'PKR': 0.025,
  'BDT': 0.06,
  'MMK': 0.0034,
  'KHR': 0.0018,
  'LAK': 0.00033,
  'MNT': 0.0021,
  'UAH': 0.17,
  'GEL': 2.65,
  'AMD': 0.018,
  'AZN': 4.2,
  'BYN': 2.2,
  'RSD': 0.066,
  'UZS': 0.00056,
  'KGS': 0.082,
  'TJS': 0.66,
  'MOP': 0.89,
  'BND': 5.35,
  'FJD': 3.15,
  'PGK': 1.8,
  'XPF': 0.064,
  'MUR': 0.155,
  'MVR': 0.46,
  'BWP': 0.53,
  'NAD': 0.39,
  'MZN': 0.11,
  'AOA': 0.0078,
  'XOF': 0.0118,
  'XAF': 0.0118,
  'ETB': 0.055,
  'TZS': 0.0027,
  'UGX': 0.0019,
  'GHS': 0.48,
};

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
