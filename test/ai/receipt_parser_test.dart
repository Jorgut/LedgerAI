import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ai/parsing.dart';

void main() {
  const parser = ReceiptParser();

  group('ReceiptParser 金额', () {
    test('中文超市小票：实付优先于合计，带千分位', () {
      final result = parser.parse('''
永辉超市（万达店）
收银小票
单号：202611120008
日期：2026-11-12 12:30:45
商品 数量 单价
牛奶 2 12.50
面包 1 8.00
合计 33.00
实付 ¥33.00
支付方式：微信
谢谢惠顾
''');
      expect(result.amount, 33.0);
      expect(result.merchant, '永辉超市');
      expect(result.categoryId, 'shopping');
    });

    test('餐饮小票：合计、应付金额取应付', () {
      final result = parser.parse('''
海底捞火锅（三里屯店）
账单号：A1024
2026年11月12日 19:08
餐位费 2 10.00
精品肥牛 1 78.00
合计：98.00
应付金额：98.00
''');
      expect(result.amount, 98.0);
      expect(result.merchant, '海底捞火锅');
      expect(result.categoryId, 'food');
    });

    test('带千分位与货币符号的金额', () {
      final result = parser.parse('''
全家便利店
2026/11/12 08:15
矿泉水 1 2.00
关东煮 1 12.50
合计 1,014.50
实付 ¥1,014.50
''');
      expect(result.amount, 1014.5);
      expect(result.merchant, '全家便利店');
      expect(result.categoryId, 'shopping');
    });

    test('优惠行不会被当成实付金额', () {
      final result = parser.parse('''
瑞幸咖啡（国贸店）
2026年11月12日 09:12:03
生椰拿铁 2 39.00
优惠 -10.00
实付 29.00
''');
      expect(result.amount, 29.0);
      expect(result.categoryId, 'food');
    });

    test('只有 ¥ 金额时取最大的一笔，不把找零算进去', () {
      final result = parser.parse('''
7-11便利店
2026-11-12
可乐 ¥3.50
薯片 ¥6.50
找零 ¥1.50
''');
      expect(result.amount, 6.5);
    });

    test('空文本不抛异常且没有可用数据', () {
      final result = parser.parse('   \n ');
      expect(result.amount, isNull);
      expect(result.date, isNull);
      expect(result.merchant, isNull);
      expect(result.hasUsefulData, isFalse);
    });
  });

  group('ReceiptParser 日期', () {
    test('2026-11-12', () {
      expect(parser.parse('超市\n日期：2026-11-12\n合计 12.00').date, DateTime(2026, 11, 12));
    });

    test('2026年11月12日', () {
      expect(
        parser.parse('餐厅\n2026年11月12日 19:08\n合计 98.00').date,
        DateTime(2026, 11, 12),
      );
    });

    test('2026.11.12 与紧凑格式 20261112', () {
      expect(parser.parse('药店\n2026.11.12\n总计 28.80').date, DateTime(2026, 11, 12));
      expect(parser.parse('药店\n日期 20261112\n总计 28.80').date, DateTime(2026, 11, 12));
    });

    test('11-12 / 11月12日 这类缺省年份的日期', () {
      final dash = parser.parse('华联超市\n11-12 18:22\n蔬菜 12.00\n合计 12.00');
      expect(dash.date?.month, 11);
      expect(dash.date?.day, 12);

      final dotted = parser.parse('幸福蛋糕店\n11月12日\n合计 58.00');
      expect(dotted.date?.month, 11);
      expect(dotted.date?.day, 12);
    });

    test('英文小票 月/日/年', () {
      final result = parser.parse(r'''
STARBUCKS COFFEE
Receipt No. 88231
Date: 11/12/2026
Latte 32.00
TOTAL 32.00
AMOUNT PAID $32.00
Thank you
''');
      expect(result.date, DateTime(2026, 11, 12));
      expect(result.amount, 32.0);
      expect(result.merchant, 'STARBUCKS COFFEE');
      expect(result.categoryId, 'food');
    });
  });

  group('ReceiptParser 商户与分类', () {
    test('跳过电话、单号、日期行取商户名', () {
      final result = parser.parse('''
发票
电话：13800138000
日期：2026-11-12
益丰大药房
阿莫西林胶囊 1 23.80
总计 28.80
''');
      expect(result.merchant, '益丰大药房');
      expect(result.categoryId, 'medical');
    });

    test('合计与金额被 OCR 拆到两行', () {
      final result = parser.parse('''
麦当劳
合计
23.50
''');
      expect(result.amount, 23.5);
      expect(result.merchant, '麦当劳');
      expect(result.categoryId, 'food');
    });

    test('带空格的中文关键词（合 计）', () {
      final result = parser.parse('''
滴滴出行
2026-11-11 22:10
里程费 18.00
时长费 5.00
合 计 23.00
''');
      expect(result.amount, 23.0);
      expect(result.categoryId, 'transport');
      expect(result.date, DateTime(2026, 11, 11));
    });

    test('原始文本被保留用于排查', () {
      final result = parser.parse(' 某某餐厅 \n合计 42.00 ');
      expect(result.rawText.contains('某某餐厅'), isTrue);
      expect(result.hasUsefulData, isTrue);
    });
  });
}
