import '../core/format.dart';

/// 一句话/小票文本的本地规则解析结果。
class ParsedReceipt {
  const ParsedReceipt({
    this.amount,
    this.date,
    this.merchant,
    this.categoryId,
    this.note = '',
    this.rawText = '',
  });

  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String? categoryId;
  final String note;
  final String rawText;

  bool get hasUsefulData => amount != null || merchant != null || categoryId != null;
}

/// 小票/账单文本解析：只做确定性规则，不联网。
class ReceiptParser {
  const ReceiptParser();

  static final RegExp _dateFull = RegExp(r'(\d{4})\s*[-/年.]\s*(\d{1,2})\s*[-/月.]\s*(\d{1,2})');
  static final RegExp _dateShort = RegExp(r'(?<!\d)(\d{1,2})\s*[-/月]\s*(\d{1,2})(?!\d)');
  static final RegExp _amountAfterKeyword = RegExp(
    r'(?:合计|总计|实付|实收|应付|金额|总额|消费|收款|找零|优惠)[^\d]{0,8}([¥￥]?)\s*([\d,]+(?:\.\d{1,2})?)',
  );
  static final RegExp _currencyAmount = RegExp(r'[¥￥]\s*([\d,]+(?:\.\d{1,2})?)');
  static final RegExp _bareAmount = RegExp(r'(?<![\d.])(\d{1,6}\.\d{2})(?![\d])');
  static final RegExp _merchantNoise = RegExp(
    r'^(?:欢迎|谢谢|小票|发票|收据|购物|销售|单号|订单|日期|时间|电话|地址|会员|收银|支付|金额|合计|商品|数量|单价|备注|流水)',
  );

  ParsedReceipt parse(String rawText) {
    final text = _normalize(rawText);
    if (text.trim().isEmpty) return const ParsedReceipt();

    final amount = _pickAmount(text);
    final date = _pickDate(text);
    final merchant = _pickMerchant(text);
    final categoryId = TextCategorizer().categorize(
      [merchant ?? '', text].join(' '),
      isIncome: false,
    );
    return ParsedReceipt(
      amount: amount,
      date: date,
      merchant: merchant,
      categoryId: categoryId,
      note: merchant ?? '',
      rawText: text,
    );
  }

  String _normalize(String input) => input
      .replaceAll('￥', '¥')
      .replaceAll('，', ',')
      .replaceAll('：', ':')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'[ \t]+'), ' ');

  double? _pickAmount(String text) {
    // 1) 合计/实付等关键词后面的金额最可信。
    for (final match in _amountAfterKeyword.allMatches(text)) {
      final value = parseAmount(match.group(2) ?? '');
      if (value != null && value > 0) return value;
    }
    // 2) 带 ¥ 的金额，取最后一个（通常是小计/总计）。
    final currency = _currencyAmount.allMatches(text).toList();
    if (currency.isNotEmpty) {
      for (final match in currency.reversed) {
        final value = parseAmount(match.group(1) ?? '');
        if (value != null && value > 0) return value;
      }
    }
    // 3) 带两位小数的裸金额，取最大的一笔，避免把单价算成总额。
    final bare = _bareAmount.allMatches(text)
        .map((m) => parseAmount(m.group(1) ?? ''))
        .whereType<double>()
        .where((value) => value > 0)
        .toList();
    if (bare.isEmpty) return null;
    bare.sort();
    return bare.last;
  }

  DateTime? _pickDate(String text) {
    final full = _dateFull.firstMatch(text);
    if (full != null) {
      final year = int.tryParse(full.group(1)!);
      final month = int.tryParse(full.group(2)!);
      final day = int.tryParse(full.group(3)!);
      if (year != null && month != null && day != null && _validDate(year, month, day)) {
        return DateTime(year, month, day);
      }
    }
    final short = _dateShort.firstMatch(text);
    if (short != null) {
      final month = int.tryParse(short.group(1)!);
      final day = int.tryParse(short.group(2)!);
      final now = DateTime.now();
      if (month != null && day != null && _validDate(now.year, month, day)) {
        final date = DateTime(now.year, month, day);
        // 小票日期不会明显在未来；跨年时回退一年。
        if (date.isAfter(now.add(const Duration(days: 2)))) {
          return DateTime(now.year - 1, month, day);
        }
        return date;
      }
    }
    return null;
  }

  bool _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  String? _pickMerchant(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    for (final line in lines.take(6)) {
      if (line.length < 2 || line.length > 24) continue;
      if (_merchantNoise.hasMatch(line)) continue;
      if (RegExp(r'^[\d\s¥,.:-]+$').hasMatch(line)) continue;
      final cleaned = line.replaceAll(RegExp(r'[（(].*?[)）]'), '').trim();
      if (cleaned.length < 2) continue;
      return cleaned;
    }
    return null;
  }
}

/// 关键词分类器。返回分类 id，无法判断时返回 null。
class TextCategorizer {
  const TextCategorizer();

  static const Map<String, List<String>> _expenseKeywords = {
    'food': [
      '餐', '饭', '食', '面', '粉', '粥', '小吃', '烧烤', '火锅', '汉堡', '披萨', '寿司', '甜品',
      '咖啡', '奶茶', '茶饮', '饮料', '麦当劳', '肯德基', '星巴克', '瑞幸', '喜茶', '蜜雪',
      '外卖', '美团', '饿了么', '食堂', '早餐', '午餐', '晚餐', '夜宵',
    ],
    'transport': [
      '地铁', '公交', '巴士', '打车', '滴滴', '出租', '网约车', '加油', '油费', '停车', '高速',
      '高铁', '火车', '动车', '机票', '航班', '共享单车', '单车', '青桔', '哈啰', '车费', '通勤',
    ],
    'shopping': [
      '超市', '商场', '淘宝', '京东', '拼多多', '便利店', '购物', '百货', '优衣库', '盒马',
      '沃尔玛', '永辉', '网购', '衣服', '鞋', '化妆品', '数码', '家电', '日用品',
    ],
    'home': ['房租', '水费', '电费', '燃气', '物业', '家政', '家居', '家具', '维修', '装修', '房贷'],
    'entertainment': ['电影', '游戏', 'KTV', '娱乐', '门票', '演唱会', '剧本杀', '健身', '旅游', '酒店', '会员'],
    'medical': ['医院', '药', '诊所', '挂号', '体检', '牙科', '医疗', '门诊', '疫苗'],
    'education': ['书', '教程', '课程', '培训', '教育', '文具', '得到', '学费', '考试'],
    'communication': ['话费', '流量', '宽带', '手机', '套餐', '充值'],
    'social': ['红包', '礼金', '随礼', '礼物', '花束', '份子钱'],
  };

  static const Map<String, List<String>> _incomeKeywords = {
    'salary': ['工资', '月薪', '薪水', '发薪', '薪资'],
    'bonus': ['奖金', '年终', '绩效', '提成'],
    'investment': ['理财', '利息', '分红', '基金', '股票', '收益'],
    'parttime': ['兼职', '稿费', '外包', '副业', '劳务'],
    'gift': ['红包', '礼金', '压岁钱', '转账'],
  };

  String? categorize(String text, {required bool isIncome}) {
    final source = isIncome ? _incomeKeywords : _expenseKeywords;
    final normalized = text.toLowerCase();
    String? bestId;
    var bestScore = 0;
    source.forEach((categoryId, keywords) {
      var score = 0;
      for (final keyword in keywords) {
        if (normalized.contains(keyword.toLowerCase())) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestId = categoryId;
      }
    });
    return bestId;
  }
}

/// 语音一句话解析：例如「今天午餐花了42块」「昨天打车35」。
class VoiceEntryParser {
  const VoiceEntryParser();

  static final RegExp _amountRegExp = RegExp(
    r'([零一二三四五六七八九十百千万两\d,]+(?:\.\d+)?)\s*(?:块|元|圆|rmb|人民币)?',
    caseSensitive: false,
  );

  static const Map<String, int> _digits = {
    '零': 0, '一': 1, '二': 2, '两': 2, '三': 3, '四': 4,
    '五': 5, '六': 6, '七': 7, '八': 8, '九': 9,
  };
  static const Map<String, int> _units = {'十': 10, '百': 100, '千': 1000, '万': 10000};

  ParsedReceipt parse(String spoken) {
    final text = spoken.trim();
    if (text.isEmpty) return const ParsedReceipt();
    final normalized = text.replaceAll(' ', '');
    final isIncome = const ['收入', '收到', '赚了', '发了', '到账', '工资', '奖金', '报销']
        .any(normalized.contains);
    final amount = _pickAmount(normalized);
    final date = _pickDate(normalized);
    final categoryId = TextCategorizer().categorize(normalized, isIncome: isIncome);
    return ParsedReceipt(
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: normalized,
      rawText: spoken,
    );
  }

  double? _pickAmount(String text) {
    final matches = _amountRegExp.allMatches(text).toList();
    for (final match in matches.reversed) {
      final raw = match.group(1);
      if (raw == null || raw.isEmpty) continue;
      final value = _parseNumber(raw);
      if (value != null && value > 0 && value < 100000000) return value;
    }
    return null;
  }

  double? _parseNumber(String raw) {
    final cleaned = raw.replaceAll(',', '');
    final direct = double.tryParse(cleaned);
    if (direct != null) return direct;
    // 中文数字（支持 0-9999 万级别）。
    var total = 0.0;
    var section = 0.0;
    var number = 0.0;
    var decimal = false;
    var decimalScale = 0.1;
    for (final char in cleaned.split('')) {
      if (char == '点') {
        decimal = true;
        continue;
      }
      if (decimal) {
        final digit = _digits[char];
        if (digit == null) return null;
        total += digit * decimalScale;
        decimalScale /= 10;
        continue;
      }
      final digit = _digits[char];
      if (digit != null) {
        number = number * 10 + digit;
        continue;
      }
      final unit = _units[char];
      if (unit != null) {
        if (unit == 10000) {
          section = (section + number) * unit;
          total += section;
          section = 0;
          number = 0;
        } else {
          section += (number == 0 ? 1 : number) * unit;
          number = 0;
        }
        continue;
      }
      return null;
    }
    return total + section + number;
  }

  DateTime? _pickDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (text.contains('前天')) return today.subtract(const Duration(days: 2));
    if (text.contains('昨天') || text.contains('昨晚')) return today.subtract(const Duration(days: 1));
    if (text.contains('今天') || text.contains('今早') || text.contains('今晚') || text.contains('中午')) {
      return today;
    }
    final match = RegExp(r'(\d{1,2})月(\d{1,2})[日号]?').firstMatch(text);
    if (match != null) {
      final month = int.tryParse(match.group(1)!);
      final day = int.tryParse(match.group(2)!);
      if (month != null && day != null && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        var date = DateTime(now.year, month, day);
        if (date.isAfter(today)) date = DateTime(now.year - 1, month, day);
        return date;
      }
    }
    return null;
  }
}
