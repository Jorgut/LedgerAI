import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的账本'),
        backgroundColor: const Color(0xFF10B981),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: '通知',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            label: '总资产 28560.80 元，本月结余增加 3240 元',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text('总资产', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('¥ 28,560.80', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('本月结余 +¥ 3,240', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('本月收入', '+8,500', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('本月支出', '-5,260', Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('最近交易', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTransactionItem('麦当劳', '餐饮 · 今天', '-42.00', Icons.restaurant),
          _buildTransactionItem('地铁', '交通 · 今天', '-6.00', Icons.subway),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Semantics(
      label: '$title $amount 元',
      child: Container(
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
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String amount, IconData icon) {
    return Semantics(
      label: '$title，$subtitle，金额 $amount 元',
      button: true,
      child: ListTile(
        minVerticalPadding: 16,
        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Icon(icon, color: Colors.orange)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: Text(amount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
