import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ledger_ai/ai/ocr_service.dart';
import 'package:ledger_ai/ai/parsing.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ocr probe on receipt image', (tester) async {
    final result = await const ReceiptOcr().recognizeFile('/tmp/receipt.png');
    // ignore: avoid_print
    print('OCR_TEXT_BEGIN\n${result?.text}\nOCR_TEXT_END');
    final parsed = const ReceiptParser().parse(result?.text ?? '');
    // ignore: avoid_print
    print('PARSED amount=${parsed.amount} date=${parsed.date} merchant=${parsed.merchant} cat=${parsed.categoryId}');
  });
}
