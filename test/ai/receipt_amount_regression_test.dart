import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/ai/parsing.dart';

  // 真实 iPhone / iOS Vision 识别原始文本（应用内 OCR 实测，2026-11-12）。
  const realDeviceOcrText = '''XX小酒香菜馆
收银员：001
餐位：88
时间：2026.07.30 21:33
菜品 数量 单价 金额
爽口拍黄瓜 18 18 1
夫妻肺片 46 1 46
凉拌木耳菜 25 25 1
酱牛肉 66 96 1
清蒸鲈鱼 108 108 1
香辣小龙虾 108 108 1
东坡肉 68 68 1
清炒时蔬 32 32
1
官保鸡丁 38 1 38
蒜蓉枌丝蒸扇贝 68
68
扬州炒饭
29 28 1
玉米排骨汤
18 18 1
餐位费
0 6 0 6位费
小计： 652
小酒香土菜馆（兴民北路店）
（010） 52161179''';

void main() {
  const parser = ReceiptParser();

  // 真实用户小票（macOS Vision 识别 + 行合并后的文本）。
  const groupedReceiptText = '''XX小酒香菜馆
收银员：001
餐位：88
时 间：2026.07.30 21:33
菜品 数量 单价 金额
爽口拍黄瓜 1 18 18
夫妻肺片 1 46 46
涼拌木耳菜 1 25 25
酱牛肉 1 96 66
清蒸鲈鱼 1 108 108
香辣小龙虾 1 108 108
东坡肉 1 68 68
清炒时蔬 1 32 32
宫保鸡丁 1 38 38
蒜蓉粉丝蒸扇贝 1 68 68
扬州炒饭 1 28 29
玉米排骨汤 1 18 18
餐位费
6位费 6 0 0
小计： 652
小酒香土菜馆（兴民北路店）
（010） 52161179''';

  // OCR 未按视觉行合并时的原始顺序（列被拆散）。
  const columnSplitReceiptText = '''XX小酒香菜馆
收银员：001
餐位：88
时 间：2026.07.30 21:33
菜品 数量 单价 金额
爽口拍黄瓜
夫妻肺片
清蒸鲈鱼
小计：
小酒香土菜馆（兴民北路店）
（010） 52161179
18
46
108
652''';

  test('真实设备 OCR：金额取小计 652，而不是日期或 1', () {
    final parsed = parser.parse(realDeviceOcrText);
    expect(parsed.amount, 652);
    expect(parsed.date, DateTime(2026, 7, 30));
    expect(parsed.merchant, 'XX小酒香菜馆');
    expect(parsed.categoryId, 'food');
  });

  test('真实小票：金额取小计而不是日期 2026.07', () {
    final parsed = parser.parse(groupedReceiptText);
    expect(parsed.amount, 652);
    expect(parsed.date, DateTime(2026, 7, 30));
    expect(parsed.merchant, 'XX小酒香菜馆');
    expect(parsed.categoryId, 'food');
  });

  test('列被拆散时仍取小计金额', () {
    final parsed = parser.parse(columnSplitReceiptText);
    expect(parsed.amount, 652);
  });

  test('只有日期没有合计时不应把日期当金额', () {
    final parsed = parser.parse('''小店
时间：2026.07.30 21:33
青菜 12
米饭 3''');
    expect(parsed.amount, isNull);
    expect(parsed.date, DateTime(2026, 7, 30));
  });
}
