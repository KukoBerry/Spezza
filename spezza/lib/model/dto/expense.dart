class Expense {
  final DateTime createdAt;
  final DateTime spentDate;
  final String id;
  final double value;
  final String? category;
  final String? name;

  Expense({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.spentDate,
    this.category,
    this.name,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'].toString(),
      value: (map['value'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      spentDate: DateTime.parse(map['when_spent'] as String).toLocal(),
      category: map['category'] as String?,
      name: map['name'] as String?,
    );
  }
}