import 'package:flutter/material.dart';

/// 一条交易记录的录入来源。用于统计与「AI 记账」体验展示。
enum EntrySource {
  manual('手动'),
  ocr('拍照识别'),
  voice('语音记账'),
  csv('导入账单');

  const EntrySource(this.label);
  final String label;

  static EntrySource parse(String? value) {
    return EntrySource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EntrySource.manual,
    );
  }
}

/// 交易记录。金额恒为正数，收支方向由 [isIncome] 决定。
@immutable
class Txn {
  const Txn({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.isIncome = false,
    this.source = EntrySource.manual,
    this.merchant,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? date,
        updatedAt = updatedAt ?? createdAt ?? date;

  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;
  final bool isIncome;
  final EntrySource source;
  final String? merchant;
  final DateTime createdAt;

  /// 最后修改时间（同步用 LWW 合并）。
  final DateTime updatedAt;

  Category get category => Category.byId(categoryId);

  Txn copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    bool? isIncome,
    EntrySource? source,
    String? merchant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Txn(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      source: source ?? this.source,
      merchant: merchant ?? this.merchant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
        'isIncome': isIncome,
        'source': source.name,
        'merchant': merchant,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Txn.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final rawCreated = json['createdAt'];
    final date = rawDate is String ? DateTime.parse(rawDate) : DateTime.now();
    return Txn(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble().abs(),
      categoryId: json['categoryId'] as String? ?? Category.otherExpenseId,
      date: date,
      note: json['note'] as String? ?? '',
      isIncome: json['isIncome'] as bool? ?? false,
      source: EntrySource.parse(json['source'] as String?),
      merchant: json['merchant'] as String?,
      createdAt: rawCreated is String ? DateTime.parse(rawCreated) : date,
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : (rawCreated is String ? DateTime.parse(rawCreated) : date),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Txn &&
          other.id == id &&
          other.amount == amount &&
          other.categoryId == categoryId &&
          other.date == date &&
          other.note == note &&
          other.isIncome == isIncome &&
          other.source == source &&
          other.merchant == merchant;

  @override
  int get hashCode => Object.hash(
        id,
        amount,
        categoryId,
        date,
        note,
        isIncome,
        source,
        merchant,
      );

  @override
  String toString() =>
      'Txn($id, $amount, $categoryId, ${date.toIso8601String()})';
}

/// 内置分类。id 稳定不可改，用于存储与导出。
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isIncome = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  static const String otherExpenseId = 'other_expense';
  static const String otherIncomeId = 'other_income';

  static const List<Category> expenses = [
    Category(
        id: 'food',
        name: '餐饮',
        icon: Icons.restaurant_rounded,
        color: Color(0xFFD9A441)),
    Category(
        id: 'transport',
        name: '交通',
        icon: Icons.directions_bus_rounded,
        color: Color(0xFF5B6C8A)),
    Category(
        id: 'shopping',
        name: '购物',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFC8553D)),
    Category(
        id: 'home',
        name: '居家',
        icon: Icons.home_rounded,
        color: Color(0xFF2A9D8F)),
    Category(
        id: 'entertainment',
        name: '娱乐',
        icon: Icons.sports_esports_rounded,
        color: Color(0xFF8A5A7A)),
    Category(
        id: 'medical',
        name: '医疗',
        icon: Icons.local_hospital_rounded,
        color: Color(0xFFB4535A)),
    Category(
        id: 'education',
        name: '学习',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF6B8E6B)),
    Category(
        id: 'communication',
        name: '通讯',
        icon: Icons.phone_iphone_rounded,
        color: Color(0xFF7C8AA0)),
    Category(
        id: 'social',
        name: '人情',
        icon: Icons.card_giftcard_rounded,
        color: Color(0xFFB86B5C)),
    Category(
        id: otherExpenseId,
        name: '其他',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF94A0A8)),
  ];

  static const List<Category> incomes = [
    Category(
        id: 'salary',
        name: '工资',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF0E7C5A),
        isIncome: true),
    Category(
        id: 'bonus',
        name: '奖金',
        icon: Icons.emoji_events_rounded,
        color: Color(0xFF4F9B6E),
        isIncome: true),
    Category(
        id: 'investment',
        name: '理财',
        icon: Icons.trending_up_rounded,
        color: Color(0xFF2A9D8F),
        isIncome: true),
    Category(
        id: 'parttime',
        name: '兼职',
        icon: Icons.work_rounded,
        color: Color(0xFF6B8E6B),
        isIncome: true),
    Category(
        id: 'gift',
        name: '红包',
        icon: Icons.redeem_rounded,
        color: Color(0xFFB4845A),
        isIncome: true),
    Category(
        id: otherIncomeId,
        name: '其他',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF94A0A8),
        isIncome: true),
  ];

  static const List<Category> all = [...expenses, ...incomes];

  static Category byId(String? id) {
    for (final category in all) {
      if (category.id == id) return category;
    }
    return expenses.last;
  }

  static List<Category> forType(bool isIncome) => isIncome ? incomes : expenses;
}
