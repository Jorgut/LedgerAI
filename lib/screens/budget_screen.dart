import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算管理'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('本月总预算', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('¥ 6,000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('已使用 87%', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.87, color: Colors.red, backgroundColor: Colors.grey.shade200),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('分类预算', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('+ 添加', style: TextStyle(color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 8),
          _buildBudgetItem('餐饮', '¥1,800 / ¥2,000'),
          _buildBudgetItem('交通', '¥450 / ¥600'),
          _buildBudgetItem('购物', '¥890 / ¥1,000'),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String category, String progress) {
    return ListTile(
      title: Text(category),
      trailing: Text(progress),
    );
  }
}
