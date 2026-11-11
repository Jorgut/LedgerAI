import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ai/parsing.dart';

void main() {
  const categorizer = TextCategorizer();

  group('TextCategorizer 支出分类', () {
    test('餐饮关键词（中英）', () {
      expect(categorizer.categorize('午餐', isIncome: false), 'food');
      expect(categorizer.categorize('星巴克', isIncome: false), 'food');
      expect(categorizer.categorize('瑞幸咖啡', isIncome: false), 'food');
      expect(categorizer.categorize('Starbucks coffee', isIncome: false), 'food');
    });

    test('交通关键词（中英）', () {
      expect(categorizer.categorize('地铁', isIncome: false), 'transport');
      expect(categorizer.categorize('滴滴出行', isIncome: false), 'transport');
      expect(categorizer.categorize('taxi ride', isIncome: false), 'transport');
    });

    test('购物 / 居家 / 娱乐 / 医疗 / 学习 / 通讯', () {
      expect(categorizer.categorize('超市', isIncome: false), 'shopping');
      expect(categorizer.categorize('房租', isIncome: false), 'home');
      expect(categorizer.categorize('电影票', isIncome: false), 'entertainment');
      expect(categorizer.categorize('医院挂号', isIncome: false), 'medical');
      expect(categorizer.categorize('书店买教材', isIncome: false), 'education');
      expect(categorizer.categorize('话费充值', isIncome: false), 'communication');
    });

    test('人情支出与收入方向的红包不是同一分类', () {
      expect(categorizer.categorize('红包', isIncome: false), 'social');
      expect(categorizer.categorize('红包', isIncome: true), 'gift');
    });

    test('无法判断时返回 null', () {
      expect(categorizer.categorize('随便写点什么', isIncome: false), isNull);
      expect(categorizer.categorize('   ', isIncome: false), isNull);
    });

    test('英文按词边界匹配，不做子串误判', () {
      expect(categorizer.categorize('vegas trip', isIncome: false), isNot('transport'));
      expect(categorizer.categorize('bus ride', isIncome: false), 'transport');
    });
  });

  group('TextCategorizer 收入分类', () {
    test('工资 / 奖金 / 理财 / 兼职', () {
      expect(categorizer.categorize('工资', isIncome: true), 'salary');
      expect(categorizer.categorize('月薪到账', isIncome: true), 'salary');
      expect(categorizer.categorize('奖金', isIncome: true), 'bonus');
      expect(categorizer.categorize('基金收益', isIncome: true), 'investment');
      expect(categorizer.categorize('兼职', isIncome: true), 'parttime');
    });

    test('收入文本不会命中支出分类', () {
      expect(categorizer.categorize('工资', isIncome: false), isNull);
      expect(categorizer.categorize('房租', isIncome: true), isNull);
    });
  });
}
