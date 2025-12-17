class Expense {
  final DateTime createdAt;
  final DateTime spentDate;
  final int? id;
  final double value;
  final String? category;
  final String? name;
  final int budgetId;

  Expense({
    this.id,
    required this.value,
    required this.createdAt,
    required this.spentDate,
    required this.budgetId,
    this.category,
    this.name,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      budgetId: map['budgetgoal_id'] as int,
      value: (map['value'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      spentDate: DateTime.parse(map['when_spent'] as String).toLocal(),
      category: map['category'] as String?,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'budgetgoal_id': budgetId,
      'value': value,
      'created_at': createdAt.toUtc().toIso8601String(),
      'when_spent': spentDate.toUtc().toIso8601String(),
      'category': category,
      'name': name,
    };
  }
}
