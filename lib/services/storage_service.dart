import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class StorageService {
  static const String boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<Transaction>(boxName);
  }

  static Box<Transaction> get box => Hive.box<Transaction>(boxName);

  static Future<void> addTransaction(Transaction t) async {
    await box.put(t.id, t);
  }

  static List<Transaction> getAll() {
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static double getMonthlyIncome() {
    final now = DateTime.now();
    return getAll()
        .where((t) => t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getMonthlyExpense() {
    final now = DateTime.now();
    return getAll()
        .where((t) => !t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
