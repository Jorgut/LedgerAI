import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_ai/core/models.dart';
import 'package:ledger_ai/core/storage.dart';

Txn txn(String id) => Txn(
      id: id,
      amount: 12,
      categoryId: 'food',
      date: DateTime(2026, 5, 1, 9),
      note: '测试',
    );

void main() {
  late Directory tempDir;
  late LocalStore store;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledger_ai_tombstone_');
    store = await LocalStore.openForTest(tempDir.path);
  });

  tearDown(() async {
    await store.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('删除记录会留下墓碑', () async {
    await store.transactions.save(txn('a1'));
    await store.transactions.delete('a1');
    expect(store.transactions.all, isEmpty);
    expect(store.transactions.deletions.keys, contains('a1'));
  });

  test('重新保存同 id 会清除墓碑（远端修改胜出）', () async {
    await store.transactions.save(txn('a2'));
    await store.transactions.delete('a2');
    await store.transactions.save(txn('a2'));
    expect(store.transactions.deletions.containsKey('a2'), isFalse);
    expect(store.transactions.all, hasLength(1));
  });

  test('应用远端删除会写入墓碑时间', () async {
    final at = DateTime(2026, 6, 1, 8, 30);
    await store.transactions.applyRemoteDeletion('a3', at);
    expect(
      store.transactions.deletions['a3']!.millisecondsSinceEpoch,
      at.millisecondsSinceEpoch,
    );
  });

  test('Txn updatedAt 缺省等于 createdAt，并可 JSON 往返', () {
    final original = txn('a4');
    expect(original.updatedAt, original.createdAt);
    final restored = Txn.fromJson(original.toJson());
    expect(restored.updatedAt, original.updatedAt);
  });
}
