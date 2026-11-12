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
    this.isIncome = false,
  });

  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String? categoryId;
  final String note;
  final String rawText;

  /// 收支方向：语音里识别到「收入/收到/工资」等时为 true；
  /// 小票识别默认按支出处理。
  final bool isIncome;

  bool get hasUsefulData => amount != null || merchant != null || categoryId != null;
}

/// 小票/账单文本解析：只做确定性规则，不联网。
class ReceiptParser {
  const ReceiptParser();

  // ---------------------------------------------------------------------------
  // 日期
  // ---------------------------------------------------------------------------

  /// 2026-11-12 / 2026/11/12 / 2026.11.12 / 2026年11月12日
  static final RegExp _dateYmd = RegExp(
    r'(20\d{2})\s*[-/.年]\s*(\d{1,2})\s*[-/.月]\s*(\d{1,2})\s*[日号]?',
  );

  /// 20261112
  static final RegExp _dateCompact = RegExp(
    r'(?<!\d)(20\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(?!\d)',
  );

  /// 11/12/2026（英文小票常见的 月/日/年）
  static final RegExp _dateMdy = RegExp(
    r'(?<!\d)(\d{1,2})\s*/\s*(\d{1,2})\s*/\s*(20\d{2})(?!\d)',
  );

  /// 11-12 / 11/12 / 11月12日
  static final RegExp _dateShort = RegExp(
    r'(?<![\d/.-])(\d{1,2})\s*(?:[-/]|月)\s*(\d{1,2})\s*[日号]?(?![\d/.-])',
  );

  // ---------------------------------------------------------------------------
  // 金额
  // ---------------------------------------------------------------------------

  /// 数字（允许千分位与 1~2 位小数）。
  static final RegExp _numberCore = RegExp(
    r'(\d{1,3}(?:[,，]\d{3})+|\d+)(?:\.(\d{1,2}))?',
  );

  /// 带货币符号的金额：¥1,014.50 / $32.00
  static final RegExp _currencyAmount = RegExp(
    r'[¥￥$]\s*(\d{1,3}(?:[,，]\d{3})+|\d+)(?:\.(\d{1,2}))?',
  );

  /// 裸的两位小数金额：1,014.50 / 3.50
  static final RegExp _bareDecimal = RegExp(
    r'(?<![\d.])(\d{1,7}(?:[,，]\d{3})*\.\d{1,2})(?![\d])',
  );

  /// 只有一行「¥42.00 / 42.00 / 42元」时才当作关键词下一行的金额。
  static final RegExp _standaloneAmountPattern = RegExp(
    r'^\d{1,3}(?:[,，]\d{3})*(?:\.\d{1,2})?$',
  );

  /// 最可信的「实付类」关键词，按优先级排列。
  static const List<String> _strongTotalKeywords = <String>[
    '实付',
    '实收',
    '实付款',
    '实付金额',
    '实际支付',
    '支付金额',
    '付款金额',
    '应付金额',
    '应付',
    '应收金额',
    '应收',
    'amount paid',
    'amount due',
    'net amount',
    'paid',
  ];

  /// 次一级的「合计类」关键词。
  static const List<String> _totalKeywords = <String>[
    '合计',
    '总计',
    '总额',
    '总金额',
    '合计金额',
    '金额合计',
    '消费金额',
    '本次消费',
    '本次交易',
    '订单金额',
    'grand total',
    'total',
  ];

  /// 小计（最低优先级，避免把 Subtotal 当成 Total）。
  static const List<String> _subtotalKeywords = <String>['小计', 'subtotal'];

  /// 出现这些词的行不能作为金额回退来源：找零、优惠、税、余额等都不是实付金额。
  static const List<String> _nonTotalHints = <String>[
    '找零',
    '找赎',
    'change',
    '优惠',
    '折扣',
    'discount',
    '税',
    'tax',
    '积分',
    'points',
    '余额',
    'balance',
    '单价',
    'unit price',
    '服务费',
    '配送费',
    '包装费',
    '运费',
    '押金',
    '退款',
    '抹零',
  ];

  // ---------------------------------------------------------------------------
  // 商户
  // ---------------------------------------------------------------------------

  static final RegExp _merchantNoise = RegExp(
    r'^(?:欢迎|谢谢|感谢|惠顾|小票|发票|收据|购物|销售|单号|订单|日期|时间|电话|地址|会员|收银|支付|微信|支付宝|银联|扫码|收款|付款|找零|优惠|折扣|税额|服务|终端|商户号|机器|营业员|开票|NO\.?|No\.?|Tel|Date|Time|Cashier|Order|Invoice|Receipt|Tax|Total|Amount|Qty|Item|Price|Store|Shop|Thank|Welcome|Item)',
    caseSensitive: false,
  );

  static final RegExp _phoneLike = RegExp(r'(?:\d[\s-]?){7,}');
  static final RegExp _timeLike = RegExp(r'\d{1,2}\s*:\s*\d{2}');
  static final RegExp _merchantPrefix = RegExp(
    r'^(?:商户名称|商户|商家|门店|店名|名称|Merchant|Store|Shop)\s*[:：]\s*',
    caseSensitive: false,
  );
  static final RegExp _merchantBoost = RegExp(
    r'(?:超市|商场|商城|公司|餐厅|餐饮|饭店|酒店|宾馆|药房|药店|咖啡|便利店|广场|市场|银行|影院|影城|加油站|书店|面包|蛋糕|服装|百货|中心|馆|店)',
  );

  /// 解析小票文本。任何字段识别不出时返回 null 字段，不抛异常。
  ParsedReceipt parse(String rawText) {
    final text = _normalize(rawText);
    if (text.trim().isEmpty) return const ParsedReceipt();

    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final amount = _pickAmount(lines);
    final date = _pickDate(text);
    final merchant = _pickMerchant(lines);
    final categoryId = const TextCategorizer().categorize(
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

  String _normalize(String input) {
    final buffer = StringBuffer();
    for (final code in input.runes) {
      if (code >= 0xFF10 && code <= 0xFF19) {
        // 全角数字 ０-９
        buffer.writeCharCode(code - 0xFF10 + 0x30);
      } else if (code == 0xFF0E) {
        buffer.write('.');
      } else if (code == 0xFF0C) {
        buffer.write(',');
      } else if (code == 0xFF1A) {
        buffer.write(':');
      } else if (code == 0xFF0F) {
        buffer.write('/');
      } else if (code == 0xFF0D) {
        buffer.write('-');
      } else if (code == 0x3000) {
        buffer.write(' ');
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer
        .toString()
        .replaceAll('￥', '¥')
        .replaceAll('，', ',')
        .replaceAll('：', ':')
        .replaceAll('。', '.')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\t', ' ');
  }

  // ---------------------------------------------------------------------------
  // 金额提取
  // ---------------------------------------------------------------------------

  /// 金额扫描前先抹掉日期/时间/电话等数字，避免把「2026.07.30」当成 2026.07 元。
  String _maskNonAmountNumbers(String line) => line
      .replaceAll(_dateYmd, ' ')
      .replaceAll(_dateCompact, ' ')
      .replaceAll(_dateMdy, ' ')
      .replaceAll(_dateShort, ' ')
      .replaceAll(_timeLike, ' ')
      .replaceAll(_phoneLike, ' ');

  double? _pickAmount(List<String> rawLines) {
    final lines = rawLines.map(_maskNonAmountNumbers).toList();
    final lowerLines = lines.map((line) => line.toLowerCase()).toList();
    // 去掉空白后再匹配中文关键词，兼容 OCR 把「合 计」拆开的写法。
    final compactLines = lowerLines
        .map((line) => line.replaceAll(RegExp(r'\s+'), ''))
        .toList();

    // 1) 关键词行：实付 > 合计 > 小计。
    for (final keywords in <List<String>>[
      _strongTotalKeywords,
      _totalKeywords,
      _subtotalKeywords,
    ]) {
      for (final keyword in keywords) {
        for (var i = 0; i < lines.length; i++) {
          final segment = _segmentAfterKeyword(
            lowerLines[i],
            compactLines[i],
            keyword,
          );
          if (segment == null) continue;
          final amount = _amountFromSegment(segment);
          if (amount != null) return amount;
          // OCR 可能把金额拆到后面若干行（列被拆散时更远）；在该关键词之后
          // 找独立数字并取最大值——合计金额通常不小于任何单项，且日期/电话已抹掉。
          if (const ['金额', 'amount', 'sum', '单价', '数量', 'price', 'qty']
              .contains(keyword)) {
            continue;
          }
          final followed = _largestFollowingAmount(lines, i);
          if (followed != null) return followed;
        }
      }
    }

    // 2) 带 ¥ 的金额：排除找零/优惠等行后取最大值。
    final currencyValues = <double>[];
    for (var i = 0; i < lines.length; i++) {
      if (_isNonTotalLine(lowerLines[i])) continue;
      for (final match in _currencyAmount.allMatches(lines[i])) {
        final value = _cleanAmount(match.group(0));
        if (value != null) currencyValues.add(value);
      }
    }
    if (currencyValues.isNotEmpty) {
      currencyValues.sort();
      return currencyValues.last;
    }

    // 3) 裸的两位小数金额：同样排除非合计行，取最大值。
    final bareValues = <double>[];
    for (var i = 0; i < lines.length; i++) {
      if (_isNonTotalLine(lowerLines[i])) continue;
      for (final match in _bareDecimal.allMatches(lines[i])) {
        final value = _cleanAmount(match.group(1));
        if (value != null) bareValues.add(value);
      }
    }
    if (bareValues.isNotEmpty) {
      // 兜底再排除一次「年份区间」的数值（例如 2026.07 被拆开后仍可能残留）。
      final filtered = bareValues
          .where((value) => value < 1990 || value > 2100)
          .toList();
      final pool = filtered.isEmpty ? bareValues : filtered;
      pool.sort();
      return pool.last;
    }

    return null;
  }

  /// 关键词后面剩下的文本；英文按词边界匹配，中文先压缩空白再匹配。
  String? _segmentAfterKeyword(String line, String compactLine, String keyword) {
    if (_isAscii(keyword)) {
      final pattern = RegExp('(?<![a-z])${RegExp.escape(keyword)}(?![a-z])');
      final match = pattern.firstMatch(line);
      if (match == null) return null;
      return line.substring(match.end);
    }
    final index = compactLine.indexOf(keyword);
    if (index < 0) return null;
    return compactLine.substring(index + keyword.length);
  }

  double? _amountFromSegment(String segment) {
    final match = _numberCore.firstMatch(segment);
    if (match == null) return null;
    return _cleanAmount(match.group(0));
  }

  /// 在关键词所在行之后（最多 [maxScan] 行）找独立数字，返回其中最大值。
  double? _largestFollowingAmount(List<String> lines, int keywordLine,
      {int maxScan = 10}) {
    double? best;
    final end = (keywordLine + maxScan).clamp(0, lines.length - 1);
    for (var j = keywordLine + 1; j <= end; j++) {
      final value = _standaloneAmount(lines[j]);
      if (value == null) continue;
      if (best == null || value > best) best = value;
    }
    return best;
  }

  double? _standaloneAmount(String line) {
    var cleaned = line.trim();
    cleaned = cleaned
        .replaceAll(RegExp(r'[¥￥$\s]'), '')
        .replaceAll('元', '')
        .replaceAll('块', '')
        .trim();
    if (cleaned.isEmpty) return null;
    if (!_standaloneAmountPattern.hasMatch(cleaned)) return null;
    return _cleanAmount(cleaned);
  }

  bool _isNonTotalLine(String lowerLine) {
    for (final hint in _nonTotalHints) {
      if (lowerLine.contains(hint)) return true;
    }
    return false;
  }

  double? _cleanAmount(String? raw) {
    if (raw == null) return null;
    final value = parseAmount(raw);
    if (value == null || value <= 0 || value > 10000000) return null;
    return value;
  }

  // ---------------------------------------------------------------------------
  // 日期提取
  // ---------------------------------------------------------------------------

  DateTime? _pickDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final ymd = _dateYmd.firstMatch(text);
    if (ymd != null) {
      final parsed = _buildDate(
        int.tryParse(ymd.group(1) ?? ''),
        int.tryParse(ymd.group(2) ?? ''),
        int.tryParse(ymd.group(3) ?? ''),
      );
      if (parsed != null) return parsed;
    }

    final compact = _dateCompact.firstMatch(text);
    if (compact != null) {
      final parsed = _buildDate(
        int.tryParse(compact.group(1) ?? ''),
        int.tryParse(compact.group(2) ?? ''),
        int.tryParse(compact.group(3) ?? ''),
      );
      if (parsed != null) return parsed;
    }

    final mdy = _dateMdy.firstMatch(text);
    if (mdy != null) {
      final parsed = _buildDate(
        int.tryParse(mdy.group(3) ?? ''),
        int.tryParse(mdy.group(1) ?? ''),
        int.tryParse(mdy.group(2) ?? ''),
      );
      if (parsed != null) return parsed;
    }

    final short = _dateShort.firstMatch(text);
    if (short != null) {
      final month = int.tryParse(short.group(1) ?? '');
      final day = int.tryParse(short.group(2) ?? '');
      if (month != null && day != null && _validDate(now.year, month, day)) {
        var date = DateTime(now.year, month, day);
        // 小票日期不会明显在未来；跨年时回退一年。
        if (date.isAfter(today.add(const Duration(days: 2)))) {
          date = DateTime(now.year - 1, month, day);
        }
        return date;
      }
    }
    return null;
  }

  DateTime? _buildDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) return null;
    if (!_validDate(year, month, day)) return null;
    return DateTime(year, month, day);
  }

  bool _validDate(int year, int month, int day) {
    if (year < 2000 || year > 2100) return false;
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  // ---------------------------------------------------------------------------
  // 商户提取
  // ---------------------------------------------------------------------------

  String? _pickMerchant(List<String> lines) {
    String? fallback;
    final limit = lines.length < 8 ? lines.length : 8;
    for (var i = 0; i < limit; i++) {
      final candidate = _cleanMerchantLine(lines[i]);
      if (candidate == null) continue;
      if (_merchantBoost.hasMatch(candidate)) return candidate;
      fallback ??= candidate;
    }
    return fallback;
  }

  String? _cleanMerchantLine(String line) {
    var cleaned = line.trim();
    if (cleaned.isEmpty) return null;
    cleaned = cleaned.replaceFirst(_merchantPrefix, '');
    // 去掉括号里的分店/城市等补充信息。
    cleaned = cleaned.replaceAll(RegExp(r'[（(][^（()）]{0,20}[)）]'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'^[\s\-*#·.]+'), '').trim();
    if (cleaned.length < 2 || cleaned.length > 30) return null;
    if (_merchantNoise.hasMatch(cleaned)) return null;
    if (_phoneLike.hasMatch(cleaned)) return null;
    if (_timeLike.hasMatch(cleaned)) return null;
    if (RegExp(r'^[\d\s¥$.,:：\-/]+$').hasMatch(cleaned)) return null;
    if (cleaned.contains('@')) return null;
    final digitCount = RegExp(r'\d').allMatches(cleaned).length;
    if (digitCount > 0 && digitCount * 2 > cleaned.length) return null;
    return cleaned;
  }

  static bool _isAscii(String input) => RegExp(r'^[a-z0-9 ]+$').hasMatch(input);
}

/// 关键词分类器。返回分类 id，无法判断时返回 null。
///
/// 分类 id 与 `lib/core/models.dart` 的 [Category.id] 一致：
/// 支出 food/transport/shopping/home/entertainment/medical/education/
/// communication/social；收入 salary/bonus/investment/parttime/gift。
class TextCategorizer {
  const TextCategorizer();

  static const Map<String, List<String>> _expenseKeywords = <String, List<String>>{
    'food': <String>[
      '餐', '早餐', '午餐', '晚餐', '夜宵', '饭', '食', '面', '粉', '粥', '小吃', '烧烤', '火锅',
      '汉堡', '披萨', '寿司', '甜品', '面包', '蛋糕', '点心', '零食', '水果', '买菜', '菜市场',
      '咖啡', '奶茶', '茶饮', '饮料', '果汁', '麦当劳', '肯德基', '星巴克', '瑞幸', '喜茶',
      '蜜雪', '海底捞', '西贝', '沙县', '兰州拉面', '外卖', '美团', '饿了么', '食堂', '餐厅',
      '饭店', '馆子', '酒馆', 'restaurant', 'cafe', 'coffee', 'starbucks', 'mcdonald',
      'kfc', 'burger', 'pizza', 'sushi', 'noodle', 'noodles', 'lunch', 'dinner',
      'breakfast', 'snack', 'dessert', 'boba', 'milk tea', 'food', 'dining',
    ],
    'transport': <String>[
      '地铁', '公交', '巴士', '打车', '滴滴', '出租', '网约车', '加油', '油费', '停车', '高速',
      '高铁', '火车', '动车', '机票', '航班', '共享单车', '单车', '青桔', '哈啰', '车费', '通勤',
      '过路费', 'etc', 'taxi', 'uber', 'lyft', 'metro', 'subway', 'bus', 'train',
      'flight', 'airline', 'gas', 'fuel', 'parking', 'toll', 'transit', 'ride',
    ],
    'shopping': <String>[
      '超市', '商场', '商城', '淘宝', '京东', '拼多多', '便利店', '购物', '百货', '优衣库',
      '盒马', '沃尔玛', '永辉', '家乐福', '华润', '全家', '罗森', '7-11', 'seven eleven',
      '网购', '衣服', '鞋', '化妆品', '护肤', '数码', '家电', '日用品', '五金',
      'supermarket', 'mall', 'amazon', 'taobao', 'walmart', 'costco', 'target',
      'ikea', 'uniqlo', 'clothes', 'shoes', 'cosmetics', 'shopping', 'grocery',
    ],
    'home': <String>[
      '房租', '水费', '电费', '燃气', '物业', '家政', '家居', '家具', '维修', '装修', '房贷',
      '租金', '水电', '取暖', '保洁', '搬家',
      'rent', 'utilities', 'utility', 'electricity', 'water bill', 'furniture',
      'repair', 'renovation', 'mortgage', 'cleaning',
    ],
    'entertainment': <String>[
      '电影', '游戏', 'ktv', '娱乐', '门票', '演唱会', '剧本杀', '密室', '健身', '旅游',
      '酒店', '民宿', '会员', '视频会员', '影城', '网吧', '网咖', '桌游', '酒吧',
      'movie', 'cinema', 'game', 'netflix', 'spotify', 'concert', 'ticket', 'gym',
      'hotel', 'travel', 'museum', 'karaoke', 'bar', 'steam',
    ],
    'medical': <String>[
      '医院', '药', '药店', '药房', '诊所', '挂号', '体检', '牙科', '医疗', '门诊', '疫苗',
      '看病', '住院', '感冒药', '处方', '医保',
      'hospital', 'pharmacy', 'clinic', 'doctor', 'dental', 'medicine', 'vaccine',
      'medical',
    ],
    'education': <String>[
      '书', '书店', '教程', '课程', '培训', '教育', '文具', '得到', '学费', '考试', '报名费',
      '网课', '教材', '练习册', 'kindle', '考试费',
      'book', 'books', 'course', 'tuition', 'training', 'school', 'education',
      'stationery', 'udemy', 'coursera',
    ],
    'communication': <String>[
      '话费', '流量', '宽带', '手机', '套餐', '充值', '联通', '移动', '电信', '网费',
      'phone bill', 'mobile', 'data plan', 'broadband', 'recharge', 'telecom',
      'china mobile', 'unicom',
    ],
    'social': <String>[
      '红包', '礼金', '随礼', '礼物', '花束', '份子钱', '请客', '人情', '捐赠', '捐款',
      'red packet', 'gift', 'wedding', 'donation', 'lucky money',
    ],
  };

  static const Map<String, List<String>> _incomeKeywords = <String, List<String>>{
    'salary': <String>[
      '工资', '月薪', '薪水', '发薪', '薪资', '薪资到账', '打工',
      'salary', 'payroll', 'wage', 'wages', 'paycheck',
    ],
    'bonus': <String>[
      '奖金', '年终', '绩效', '提成', '奖励', '年终奖', '抽奖',
      'bonus', 'commission', 'incentive', 'award',
    ],
    'investment': <String>[
      '理财', '利息', '分红', '基金', '股票', '收益', '投资回报', '余额宝', '定期',
      'dividend', 'interest', 'stock', 'fund', 'investment', 'return',
    ],
    'parttime': <String>[
      '兼职', '稿费', '外包', '副业', '劳务', '接单', '私活', '咨询费',
      'freelance', 'part-time', 'side job', 'consulting', 'royalty', 'gig',
    ],
    'gift': <String>[
      '红包', '礼金', '压岁钱', '转账', '收到', '馈赠', '生日礼金',
      'red packet', 'gift', 'lucky money', 'transfer',
    ],
  };

  /// 根据文本判断分类；无法判断返回 null。
  String? categorize(String text, {required bool isIncome}) {
    final normalized = text.toLowerCase();
    if (normalized.trim().isEmpty) return null;
    final source = isIncome ? _incomeKeywords : _expenseKeywords;
    String? bestId;
    var bestScore = 0;
    var bestLength = 0;
    source.forEach((categoryId, keywords) {
      var score = 0;
      var longest = 0;
      for (final keyword in keywords) {
        if (!_containsKeyword(normalized, keyword)) continue;
        final key = keyword.toLowerCase();
        score += key.length;
        if (key.length > longest) longest = key.length;
      }
      if (score > bestScore || (score == bestScore && longest > bestLength)) {
        bestScore = score;
        bestLength = longest;
        bestId = categoryId;
      }
    });
    return bestScore > 0 ? bestId : null;
  }

  static bool _containsKeyword(String normalized, String keyword) {
    final key = keyword.toLowerCase();
    if (key.isEmpty) return false;
    if (RegExp(r'^[a-z0-9 ]+$').hasMatch(key)) {
      // 英文按词边界匹配，避免 "gas" 命中 "vegas"。
      final pattern = RegExp(
        r'(?:^|[^a-z0-9])' + RegExp.escape(key) + r'(?:[^a-z0-9]|$)',
      );
      return pattern.hasMatch(normalized);
    }
    return normalized.contains(key);
  }
}

/// 语音一句话解析：例如「今天午餐花了42块」「昨天打车35」。
class VoiceEntryParser {
  const VoiceEntryParser();

  static const Map<String, int> _digits = <String, int>{
    '零': 0,
    '〇': 0,
    '一': 1,
    '二': 2,
    '两': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
  };

  static const Map<String, int> _units = <String, int>{
    '十': 10,
    '百': 100,
    '千': 1000,
    '万': 10000,
  };

  /// 阿拉伯数字或中文数字（含「点」小数、口语省略尾数）。
  static const String _numberSource =
      r'(?:\d+(?:\.\d{1,2})?|[零〇一二三四五六七八九十百千万两]+(?:点[零〇一二三四五六七八九]+)?)';

  /// 口语里跟在数字后面、说明它不是金额的词。
  static const List<String> _nonMoneySuffixes = <String>[
    '个', '杯', '份', '次', '人', '天', '年', '月', '日', '号', '岁', '折', '件', '瓶',
    '盒', '张', '位', '公里', '米', '斤', '克', '升', '毫升', '小时', '分钟', '点', '时',
    '分', '秒', '楼', '层', '排', '座', '路', '站', '号线', '%',
  ];

  static final RegExp _chineseNumber = RegExp(
    r'[零〇一二三四五六七八九十百千万两]+(?:点[零〇一二三四五六七八九]+)?',
  );

  static final RegExp _arabicNumber = RegExp(r'\d+(?:\.\d{1,2})?');

  /// 三块五 / 42块5 / 四十二块五毛
  static final RegExp _majorMinorPattern = RegExp(
    '($_numberSource)(?:块钱|块|元|圆)\\s*([0-9零〇一二三四五六七八九])'
    r'(?:\s*(?:毛|角))?'
    r'(?![0-9零〇一二三四五六七八九十百千万月日号点个杯份])',
  );

  /// 42块 / 四十二元 / 一百零五块
  static final RegExp _unitAmountPattern = RegExp(
    '($_numberSource)\\s*(?:块钱|块|元|圆|人民币|rmb)',
    caseSensitive: false,
  );

  /// 1.5万 / 3万元
  static final RegExp _wanAmountPattern = RegExp(
    r'(\d+(?:\.\d{1,2})?)\s*万',
  );

  /// 花了42 / 收到500 / 一共120
  static final RegExp _verbAmountPattern = RegExp(
    r'(?:花了|花费|花掉|花|支出|付款|付了|支付|用了|消费了|消费|买了|买|交了|交|'
    r'收入|收到|赚了|赚到|挣了|挣到|报销了|报销|一共|总共|共计|合计|总计|充了|充值)'
    r'\s*('
    '$_numberSource'
    ')',
    caseSensitive: false,
  );

  /// 语音里表示收入的关键词。
  static const List<String> _incomeHints = <String>[
    '收入', '收到', '到账', '入账', '进账', '赚了', '赚到', '挣了', '挣到', '发工资',
    '发了工资', '薪水', '月薪', '工资', '奖金', '年终奖', '绩效', '提成', '报销', '分红',
    '利息', '收益', '退款', '退货', '收款', '中奖', '压岁钱', '礼金',
  ];

  /// 语音里明确表示支出的关键词。
  static const List<String> _expenseHints = <String>[
    '花了', '花费', '花掉', '支出', '付款', '付了', '支付', '用了', '消费', '买了',
    '还款', '充了', '充值', '交了', '转账给', '转给', '发红包', '发了红包', '给红包',
  ];

  ParsedReceipt parse(String spoken) {
    final raw = spoken.trim();
    if (raw.isEmpty) return const ParsedReceipt();
    final text = _normalize(raw);
    final isIncome = _detectIncome(text);
    final amount = _pickAmount(text);
    final date = _pickDate(text);
    final categoryId = const TextCategorizer().categorize(text, isIncome: isIncome);
    return ParsedReceipt(
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: text,
      rawText: raw,
      isIncome: isIncome,
    );
  }

  String _normalize(String input) {
    const punctuation = <int>[
      0x2c, // ,
      0x3001, // 、
      0x3002, // 。
      0xff0c, // ，
      0xff1b, // ；
      0xff01, // ！
      0xff1f, // ？
      0xff1a, // ：
      0x3b, // ;
      0x21, // !
      0x3f, // ?
      0x3a, // :
      0x3000, // 全角空格
    ];
    final buffer = StringBuffer();
    for (final code in input.runes) {
      if (code >= 0xFF10 && code <= 0xFF19) {
        // 全角数字 ０-９
        buffer.writeCharCode(code - 0xFF10 + 0x30);
      } else if (code == 0xFF0E) {
        buffer.write('.');
      } else if (punctuation.contains(code)) {
        buffer.write(' ');
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), '');
  }

  // ---------------------------------------------------------------------------
  // 收支方向
  // ---------------------------------------------------------------------------

  bool _detectIncome(String text) {
    // 红包要分方向：收红包是收入，发红包是支出。
    if (RegExp(r'收.{0,2}红包').hasMatch(text) || text.contains('抢红包')) {
      return true;
    }
    if (text.contains('发红包') || text.contains('发了红包') || text.contains('给红包')) {
      return false;
    }
    for (final hint in _expenseHints) {
      if (text.contains(hint)) return false;
    }
    for (final hint in _incomeHints) {
      if (text.contains(hint)) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // 金额
  // ---------------------------------------------------------------------------

  double? _pickAmount(String text) {
    final candidates = <_AmountCandidate>[];

    // 1) 口语「三块五」「42块5」：最强。
    for (final match in _majorMinorPattern.allMatches(text)) {
      final major = _parseNumber(match.group(1) ?? '');
      final minor = _parseNumber(match.group(2) ?? '');
      if (major == null || minor == null) continue;
      final value = major + minor / 10;
      if (_plausible(value)) {
        candidates.add(_AmountCandidate(value, match.start, 4));
      }
    }

    // 2) 数字 + 金额单位。
    for (final match in _unitAmountPattern.allMatches(text)) {
      final value = _parseNumber(match.group(1) ?? '');
      if (value == null || !_plausible(value)) continue;
      candidates.add(_AmountCandidate(value, match.start, 3.5));
    }

    // 3) 1.5万 这类口语。
    for (final match in _wanAmountPattern.allMatches(text)) {
      final base = _parseNumber(match.group(1) ?? '');
      if (base == null) continue;
      final value = base * 10000;
      if (!_plausible(value)) continue;
      if (_isNonMoneyFollow(text, match.end)) continue;
      candidates.add(_AmountCandidate(value, match.start, 3.5));
    }

    // 4) 金额动词 + 数字。
    for (final match in _verbAmountPattern.allMatches(text)) {
      final value = _parseNumber(match.group(1) ?? '');
      if (value == null || !_plausible(value)) continue;
      if (_isNonMoneyFollow(text, match.end)) continue;
      candidates.add(_AmountCandidate(value, match.start, 2.5));
    }

    // 5) 裸阿拉伯数字（优先带小数点的）。
    for (final match in _arabicNumber.allMatches(text)) {
      if (_isDateOrTimeContext(text, match.start, match.end)) continue;
      if (_isNonMoneyFollow(text, match.end)) continue;
      final raw = match.group(0) ?? '';
      final value = double.tryParse(raw);
      if (value == null || !_plausible(value)) continue;
      final hasDecimal = raw.contains('.');
      if (!hasDecimal && !_looksLikeBareAmount(raw)) continue;
      candidates.add(_AmountCandidate(value, match.start, hasDecimal ? 2 : 1.5));
    }

    // 6) 裸中文数字（至少带十/百/千/万，避免「两杯」被当成 2 块）。
    for (final match in _chineseNumber.allMatches(text)) {
      final raw = match.group(0) ?? '';
      if (!_units.keys.any((unit) => raw.contains(unit))) continue;
      if (_isDateOrTimeContext(text, match.start, match.end)) continue;
      if (_isNonMoneyFollow(text, match.end)) continue;
      final value = _parseNumber(raw);
      if (value == null || !_plausible(value)) continue;
      candidates.add(_AmountCandidate(value, match.start, 1));
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final byStrength = b.strength.compareTo(a.strength);
      if (byStrength != 0) return byStrength;
      return a.index.compareTo(b.index);
    });
    return candidates.first.value;
  }

  bool _plausible(double value) => value > 0 && value < 100000000;

  /// 单看是数量/年份而不是金额的裸数字。
  bool _looksLikeBareAmount(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 2) return false;
    final value = double.tryParse(raw);
    if (value != null && value >= 1900 && value <= 2100) return false;
    return true;
  }

  bool _isNonMoneyFollow(String text, int end) {
    if (end >= text.length) return false;
    final rest = text.substring(end);
    for (final suffix in _nonMoneySuffixes) {
      if (rest.startsWith(suffix)) return true;
    }
    return false;
  }

  bool _isDateOrTimeContext(String text, int start, int end) {
    if (start > 0) {
      final before = text[start - 1];
      if ('/-:.'.contains(before)) return true;
      if ('月日年号'.contains(before)) return true;
      if (RegExp(r'\d').hasMatch(before)) return true;
    }
    if (end < text.length) {
      final after = text[end];
      if ('/-:'.contains(after)) return true;
    }
    return false;
  }

  /// 解析阿拉伯数字或中文数字。
  double? _parseNumber(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[,，\s]'), '');
    if (cleaned.isEmpty) return null;
    if (RegExp(r'^\d+(?:\.\d+)?$').hasMatch(cleaned)) {
      return double.tryParse(cleaned);
    }
    final parts = cleaned.split('点');
    if (parts.length > 2) return null;
    final integerPart = _parseChineseInteger(parts.first);
    if (integerPart == null) return null;
    var value = integerPart.toDouble();
    if (parts.length == 2) {
      var scale = 0.1;
      for (final char in parts[1].split('')) {
        final digit = _digits[char];
        if (digit == null) return null;
        value += digit * scale;
        scale /= 10;
      }
    }
    return value;
  }

  int? _parseChineseInteger(String raw) {
    if (raw.isEmpty) return null;
    var total = 0;
    var section = 0;
    var number = 0;
    var lastUnit = 0;
    var sawUnit = false;
    var sawZero = false;
    for (final char in raw.split('')) {
      final digit = _digits[char];
      if (digit != null) {
        if (digit == 0) {
          sawZero = true;
        } else {
          number = number * 10 + digit;
        }
        continue;
      }
      final unit = _units[char];
      if (unit == null) return null;
      sawUnit = true;
      if (unit == 10000) {
        section = (section + number) * unit;
        total += section;
        section = 0;
        number = 0;
      } else {
        section += (number == 0 ? 1 : number) * unit;
        number = 0;
      }
      lastUnit = unit;
    }
    var value = total + section + number;
    // 口语省略：一百五 = 150、两千三 = 2300、一万五 = 15000。
    if (sawUnit && number > 0 && number < 10 && !sawZero) {
      final unitSize = lastUnit ~/ 10;
      if (unitSize >= 1) value += number * (unitSize - 1);
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // 日期
  // ---------------------------------------------------------------------------

  DateTime? _pickDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (text.contains('大前天')) return today.subtract(const Duration(days: 3));
    if (text.contains('前天')) return today.subtract(const Duration(days: 2));
    if (text.contains('昨天') || text.contains('昨晚') || text.contains('昨日')) {
      return today.subtract(const Duration(days: 1));
    }
    if (text.contains('今天') ||
        text.contains('今日') ||
        text.contains('今早') ||
        text.contains('今晚') ||
        text.contains('刚刚') ||
        text.contains('刚才')) {
      return today;
    }

    // 完整的年月日。
    final full = RegExp(
      r'(20\d{2})\s*[年\-/.]\s*(\d{1,2})\s*[月\-/.]\s*(\d{1,2})\s*[日号]?',
    ).firstMatch(text);
    if (full != null) {
      final parsed = _buildDate(
        int.tryParse(full.group(1) ?? ''),
        int.tryParse(full.group(2) ?? ''),
        int.tryParse(full.group(3) ?? ''),
      );
      if (parsed != null) return parsed;
    }

    // 11月5日 / 十一月五日。
    final monthDay = RegExp(
      r'(\d{1,2})\s*月\s*(\d{1,2})\s*[日号]?',
    ).firstMatch(text);
    if (monthDay != null) {
      final parsed = _resolveMonthDay(
        int.tryParse(monthDay.group(1) ?? ''),
        int.tryParse(monthDay.group(2) ?? ''),
        today,
      );
      if (parsed != null) return parsed;
    }
    final chineseMonthDay = RegExp(
      r'([零〇一二三四五六七八九十两]+)月([零〇一二三四五六七八九十两]+)[日号]?',
    ).firstMatch(text);
    if (chineseMonthDay != null) {
      final month = _parseChineseInteger(chineseMonthDay.group(1) ?? '');
      final day = _parseChineseInteger(chineseMonthDay.group(2) ?? '');
      final parsed = _resolveMonthDay(month, day, today);
      if (parsed != null) return parsed;
    }

    // 只说了「5号」。
    final dayOnly = RegExp(r'(?<![\d月])(\d{1,2})\s*[日号]').firstMatch(text);
    if (dayOnly != null) {
      final day = int.tryParse(dayOnly.group(1) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        var date = DateTime(now.year, now.month, day);
        if (date.day != day) return null;
        if (date.isAfter(today.add(const Duration(days: 2)))) {
          final previousMonth = DateTime(now.year, now.month - 1, day);
          if (previousMonth.day == day) date = previousMonth;
        }
        return date;
      }
    }
    return null;
  }

  DateTime? _buildDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) return null;
    if (year < 2000 || year > 2100) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return date;
  }

  DateTime? _resolveMonthDay(int? month, int? day, DateTime today) {
    if (month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    var date = DateTime(today.year, month, day);
    if (date.month != month || date.day != day) return null;
    if (date.isAfter(today.add(const Duration(days: 2)))) {
      final previousYear = DateTime(today.year - 1, month, day);
      if (previousYear.month == month && previousYear.day == day) {
        date = previousYear;
      }
    }
    return date;
  }
}

class _AmountCandidate {
  const _AmountCandidate(this.value, this.index, this.strength);

  final double value;
  final int index;
  final double strength;
}
