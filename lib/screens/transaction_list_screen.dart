import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  Widget build(BuildContext context) {
    final transactions = StorageService.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部交易'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('暂无交易记录\n点击下方 + 号开始记账', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return Dismissible(
                  key: Key(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await StorageService.deleteTransaction(t.id);
                    setState(() {});
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (t.isIncome ? Colors.green : Colors.red).withOpacity(0.15),
                      child: Icon(_getIcon(t.category), color: t.isIncome ? Colors.green : Colors.red),
                    ),
                    title: Text(t.category),
                    subtitle: Text('${t.note.isEmpty ? '' : '${t.note} · '}${t.date.month}月${t.date.day}日'),
                    trailing: Text(
                      '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: t.isIncome ? Colors.green : Colors.red),
                    ),
                    onTap: () => _editTransaction(context, t),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon(String category) {
    switch (category) {
      case '餐饮': return Icons.restaurant;
      case '交通': return Icons.directions_car;
      case '购物': return Icons.shopping_bag;
      case '工资': return Icons.work;
      default: return Icons.category;
    }
  }

  Future<void> _editTransaction(BuildContext context, Transaction t) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: t)),
    );
    if (result == true) setState(() {});
  }
}
