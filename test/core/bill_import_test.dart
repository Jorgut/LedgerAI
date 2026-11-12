import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/bill_import.dart';

void main() {
  group('BillCsvImporter', () {
    test('解析微信账单：支出/收入、跳过关闭交易', () {
      const csv = '''
微信支付账单明细,,,,,,,,
微信昵称：[测试],,,,,,,,
交易时间,交易类型,交易对方,商品,收/支,金额(元),支付方式,当前状态,交易单号,商户单号,备注
2026-01-02 12:34:56,商户消费,麦当劳,午餐,支出,¥42.00,零钱,支付成功,1001,2001,
2026-01-03 08:00:00,转账,张三,红包,收入,¥100.00,零钱,已存入零钱,1002,2002,
2026-01-04 09:00:00,商户消费,滴滴出行,打车,支出,¥25.50,零钱,交易关闭,1003,2003,
''';
      final result = const BillCsvImporter().parse(csv, fileName: 'wechat.csv');
      expect(result.transactions, hasLength(2));
      expect(result.skipped, 1);

      final expense = result.transactions.first;
      expect(expense.amount, 42.0);
      expect(expense.isIncome, isFalse);
      expect(expense.merchant, '麦当劳');
      expect(expense.note, '午餐');
      expect(expense.categoryId, 'food');
      expect(expense.date, DateTime(2026, 1, 2, 12, 34, 56));

      final income = result.transactions.last;
      expect(income.amount, 100.0);
      expect(income.isIncome, isTrue);
      expect(income.categoryId, 'gift');
    });

    test('解析支付宝账单：带引号字段、逗号、不计收支跳过', () {
      const csv = '''
支付宝交易记录明细查询
账号:[test@example.com]
交易号,商家订单号,交易创建时间,交易对方,商品名称,金额（元）,收/支,交易状态,备注
20260105120000,20260105001,2026/01/05 12:00:00,星巴克,"拿铁,中杯",¥33.00,支出,交易成功,
20260106120000,20260106001,2026/01/06 12:00:00,余额宝,收益,¥1.25,不计收支,交易成功,
20260107120000,20260107001,2026/01/07 12:00:00,公司,报销,¥200.00,收入,交易成功,
''';
      final result = const BillCsvImporter().parse(csv, fileName: 'alipay.csv');
      expect(result.transactions, hasLength(2));
      expect(result.skipped, 1);

      final coffee = result.transactions.first;
      expect(coffee.amount, 33.0);
      expect(coffee.note, '拿铁,中杯');
      expect(coffee.merchant, '星巴克');
      expect(coffee.date, DateTime(2026, 1, 5, 12));

      final income = result.transactions.last;
      expect(income.amount, 200.0);
      expect(income.isIncome, isTrue);
    });

    test('同一内容重复解析得到稳定 id', () {
      const csv = '''
交易时间,交易对方,商品,收/支,金额(元),当前状态
2026-02-01 10:00:00,便利店,矿泉水,支出,¥3.00,支付成功
''';
      final first = const BillCsvImporter().parse(csv);
      final second = const BillCsvImporter().parse(csv);
      expect(first.transactions.single.id, second.transactions.single.id);
      expect(first.transactions.single.id, startsWith('csv_'));
    });

    test('缺少表头时给出警告', () {
      final result = const BillCsvImporter().parse('随便一些内容,没有表头\n1,2,3');
      expect(result.isEmpty, isTrue);
      expect(result.warnings, isNotEmpty);
    });
  });
}
