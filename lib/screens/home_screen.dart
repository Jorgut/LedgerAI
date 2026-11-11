import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final income = StorageService.getMonthlyIncome();
    final expense = StorageService.getMonthlyExpense();
    final balance = income - expense;
    final recent = StorageService.getAll().take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('衡账'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('本月结余', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text('¥ ${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('本月收入', '+${income.toStringAsFixed(0)}', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('本月支出', '-${expense.toStringAsFixed(0)}', Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('最近交易', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...recent.map((t) => ListTile(
                leading: CircleAvatar(child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward)),
                title: Text(t.category),
                subtitle: Text(t.note.isEmpty ? '无备注' : t.note),
                trailing: Text(
                  '${t.isIncome ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: t.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              )),
          if (recent.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('暂无交易记录'))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
