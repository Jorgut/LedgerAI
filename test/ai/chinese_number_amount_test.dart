import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ai/parsing.dart';

/// 中文数字金额的口语化处理：既要支持「四十二」「一百零五」这种标准读法，
/// 也要支持「三块五」「两千三」「一万五」这种省略说法。
void main() {
  const parser = VoiceEntryParser();

  group('中文数字金额', () {
    test('四十二块 / 四十二元', () {
      expect(parser.parse('午餐四十二块').amount, 42.0);
      expect(parser.parse('午餐四十二元').amount, 42.0);
    });

    test('一百零五块 / 一百零五元', () {
      expect(parser.parse('买书一百零五块').amount, 105.0);
      expect(parser.parse('买书一百零五元').amount, 105.0);
    });

    test('一百二十块 / 一百二十三块', () {
      expect(parser.parse('一百二十块').amount, 120.0);
      expect(parser.parse('一百二十三块').amount, 123.0);
    });

    test('口语省略尾数：一百五 = 150', () {
      expect(parser.parse('一百五').amount, 150.0);
      expect(parser.parse('两百三').amount, 230.0);
      expect(parser.parse('两千三').amount, 2300.0);
      expect(parser.parse('三千五块').amount, 3500.0);
      expect(parser.parse('一万五').amount, 15000.0);
    });

    test('带「零」时按个位读：一百零五 = 105', () {
      expect(parser.parse('一百零五').amount, 105.0);
      expect(parser.parse('两千零三').amount, 2003.0);
      expect(parser.parse('一千零一十').amount, 1010.0);
    });

    test('块 + 角的口语：三块五 = 3.5，四十二块五 = 42.5', () {
      expect(parser.parse('花了三块五').amount, 3.5);
      expect(parser.parse('三块五毛').amount, 3.5);
      expect(parser.parse('四十二块五').amount, 42.5);
      expect(parser.parse('四十二块五毛').amount, 42.5);
    });

    test('阿拉伯数字 + 块 + 角：42块5 = 42.5', () {
      expect(parser.parse('42块5').amount, 42.5);
      expect(parser.parse('35块8').amount, 35.8);
      expect(parser.parse('花了35.8元').amount, 35.8);
    });

    test('万元口语：1.5万 = 15000', () {
      expect(parser.parse('花了1.5万').amount, 15000.0);
      expect(parser.parse('花了2万元').amount, 20000.0);
    });

    test('数量词后面的数字不当作金额', () {
      expect(parser.parse('买了两杯美式花了25块').amount, 25.0);
      expect(parser.parse('昨天走了五公里').amount, isNull);
      expect(parser.parse('中午12点吃饭').amount, isNull);
    });

    test('年份/日期不会被当成金额', () {
      expect(parser.parse('2026年11月12日打车23元').amount, 23.0);
      final result = parser.parse('2026年11月12日');
      expect(result.amount, isNull);
      expect(result.date, DateTime(2026, 11, 12));
    });
  });
}
