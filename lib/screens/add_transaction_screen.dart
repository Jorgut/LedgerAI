import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _category;
  late bool _isIncome;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    final t = widget.transaction;
    _amountController = TextEditingController(text: t?.amount.toString() ?? '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _category = t?.category ?? '餐饮';
    _isIncome = t?.isIncome ?? false;
  }

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
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      category: _category,
      note: _noteController.text,
      date: widget.transaction?.date ?? DateTime.now(),
      isIncome: _isIncome,
    );
    await StorageService.addTransaction(t);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑交易' : '记一笔'),
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
                child: Text(_isEditing ? '保存修改' : '保存记录', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
