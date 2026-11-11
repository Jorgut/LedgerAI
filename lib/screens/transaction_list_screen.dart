import 'package:flutter/material.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('全部交易'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索交易、备注、商家...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildItem('麦当劳', '餐饮 · 今天 12:30', '-42.00', Icons.restaurant, Colors.orange),
                _buildItem('工资', '收入 · 11月1日', '+8,500.00', Icons.work, Colors.green),
                _buildItem('淘宝购物', '购物 · 昨天', '-189.00', Icons.shopping_bag, Colors.pink),
                _buildItem('地铁通勤', '交通 · 今天', '-6.00', Icons.subway, Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String subtitle, String amount, IconData icon, Color color) {
    final isIncome = amount.startsWith('+');
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
      ),
    );
  }
}
