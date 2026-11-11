import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('财务报表'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: '2026年11月',
            items: ['2026年11月', '2026年10月'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 60, color: Color(0xFF10B981)),
                  SizedBox(height: 8),
                  Text('支出分类占比'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('AI 理财建议', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Chip(label: Text('AI', style: TextStyle(fontSize: 10)), backgroundColor: Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('本月餐饮支出占比 38%，较上月上升 12%。建议每周自己做饭 2-3 次，预计可节省约 ¥400。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildProgress('餐饮', 0.38, Colors.red, '¥2,010'),
          _buildProgress('交通', 0.13, Colors.blue, '¥680'),
          _buildProgress('购物', 0.22, Colors.pink, '¥1,150'),
        ],
      ),
    );
  }

  Widget _buildProgress(String title, double value, Color color, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(amount)],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.grey.shade200),
        ],
      ),
    );
  }
}
