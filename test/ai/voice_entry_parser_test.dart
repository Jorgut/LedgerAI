import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ai/parsing.dart';

void main() {
  const parser = VoiceEntryParser();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('VoiceEntryParser 金额与分类', () {
    test('今天午餐花了四十二块', () {
      final result = parser.parse('今天午餐花了四十二块');
      expect(result.amount, 42.0);
      expect(result.date, today);
      expect(result.categoryId, 'food');
      expect(result.isIncome, isFalse);
    });

    test('昨天打车三十五块五（口语省略角）', () {
      final result = parser.parse('昨天打车三十五块五');
      expect(result.amount, 35.5);
      expect(result.date, today.subtract(const Duration(days: 1)));
      expect(result.categoryId, 'transport');
    });

    test('前天在超市买了一百零五元的东西', () {
      final result = parser.parse('前天在超市买了一百零五元的东西');
      expect(result.amount, 105.0);
      expect(result.date, today.subtract(const Duration(days: 2)));
      expect(result.categoryId, 'shopping');
    });

    test('这个月工资到账一万五（收入）', () {
      final result = parser.parse('这个月工资到账一万五');
      expect(result.amount, 15000.0);
      expect(result.isIncome, isTrue);
      expect(result.categoryId, 'salary');
    });

    test('11月5日买了咖啡花了28.5', () {
      final result = parser.parse('11月5日买了咖啡花了28.5');
      expect(result.amount, 28.5);
      expect(result.date?.month, 11);
      expect(result.date?.day, 5);
      expect(result.categoryId, 'food');
      expect(result.isIncome, isFalse);
    });

    test('收到红包两百块（收入）', () {
      final result = parser.parse('收到红包两百块');
      expect(result.amount, 200.0);
      expect(result.isIncome, isTrue);
      expect(result.categoryId, 'gift');
    });

    test('发红包给朋友50块（支出）', () {
      final result = parser.parse('发红包给朋友50块');
      expect(result.amount, 50.0);
      expect(result.isIncome, isFalse);
      expect(result.categoryId, 'social');
    });

    test('打车35（裸数字）', () {
      final result = parser.parse('打车35');
      expect(result.amount, 35.0);
      expect(result.categoryId, 'transport');
    });

    test('买了两杯咖啡花了五十块（数量不当作金额）', () {
      final result = parser.parse('买了两杯咖啡花了五十块');
      expect(result.amount, 50.0);
      expect(result.categoryId, 'food');
    });

    test('交房租三千五（三千五 = 3500）', () {
      final result = parser.parse('交房租三千五');
      expect(result.amount, 3500.0);
      expect(result.categoryId, 'home');
    });

    test('昨天电影票八十', () {
      final result = parser.parse('昨天电影票八十');
      expect(result.amount, 80.0);
      expect(result.date, today.subtract(const Duration(days: 1)));
      expect(result.categoryId, 'entertainment');
    });

    test('4月30日买菜花了23块', () {
      final result = parser.parse('4月30日买菜花了23块');
      expect(result.amount, 23.0);
      expect(result.date?.month, 4);
      expect(result.date?.day, 30);
      expect(result.categoryId, 'food');
    });

    test('昨天下午三点买了杯奶茶18块（时间不当作金额）', () {
      final result = parser.parse('昨天下午三点买了杯奶茶18块');
      expect(result.amount, 18.0);
      expect(result.date, today.subtract(const Duration(days: 1)));
      expect(result.categoryId, 'food');
    });

    test('2026年11月12日打车23元', () {
      final result = parser.parse('2026年11月12日打车23元');
      expect(result.amount, 23.0);
      expect(result.date, DateTime(2026, 11, 12));
      expect(result.categoryId, 'transport');
    });

    test('收入方向但没有明确分类时 categoryId 为空', () {
      final result = parser.parse('今天收入500');
      expect(result.amount, 500.0);
      expect(result.isIncome, isTrue);
      expect(result.categoryId, isNull);
    });

    test('收到工资8000', () {
      final result = parser.parse('收到工资8000');
      expect(result.amount, 8000.0);
      expect(result.isIncome, isTrue);
      expect(result.categoryId, 'salary');
    });

    test('报销了1200按收入处理', () {
      final result = parser.parse('报销了1200');
      expect(result.amount, 1200.0);
      expect(result.isIncome, isTrue);
    });

    test('空语音返回空结果', () {
      final result = parser.parse('   ');
      expect(result.amount, isNull);
      expect(result.date, isNull);
      expect(result.note, '');
      expect(result.hasUsefulData, isFalse);
    });
  });
}
