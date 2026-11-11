import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = StorageService.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部交易'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('暂无交易记录'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (t.isIncome ? Colors.green : Colors.red).withOpacity(0.15),
                    child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: t.isIncome ? Colors.green : Colors.red),
                  ),
                  title: Text(t.category),
                  subtitle: Text('${t.note.isEmpty ? '' : t.note + ' · '}${t.date.month}月${t.date.day}日'),
                  trailing: Text(
                    '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: t.isIncome ? Colors.green : Colors.red),
                  ),
                );
              },
            ),
    );
  }
}
