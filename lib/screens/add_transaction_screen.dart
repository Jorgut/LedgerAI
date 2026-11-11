import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  int _selectedTab = 1;
  final _amountController = TextEditingController();
  String _category = '餐饮';
  final _noteController = TextEditingController();
  bool _isIncome = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final t = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      category: _category,
      note: _noteController.text,
      date: DateTime.now(),
      isIncome: _isIncome,
    );
    await StorageService.addTransaction(t);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记一笔'),
        backgroundColor: const Color(0xFF10B981),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          tooltip: '关闭',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isIncome = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isIncome ? const Color(0xFF10B981) : Colors.grey.shade200,
                      foregroundColor: !_isIncome ? Colors.white : Colors.black,
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('支出'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isIncome = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIncome ? const Color(0xFF10B981) : Colors.grey.shade200,
                      foregroundColor: _isIncome ? Colors.white : Colors.black,
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('收入'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '金额', border: OutlineInputBorder()),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: '分类', border: OutlineInputBorder()),
              items: ['餐饮', '交通', '购物', '工资', '其他'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _category = v ?? '餐饮'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '备注（可选）', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                child: const Text('保存记录', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
