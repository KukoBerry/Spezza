class GoalExpense {
  final DateTime createdAt;
  final String id;
  final double goal;
  final double amountSpent;
  final int periodInDays;
  final String? category;
  final String? name;

  GoalExpense({
    required this.id,
    required this.goal,
    required this.amountSpent,
    required this.periodInDays,
    required this.createdAt,
    this.category,
    this.name,
  });

  factory GoalExpense.fromMap(Map<String, dynamic> map) {
    return GoalExpense(
      id: map['id'].toString(),
      goal: (map['goalexpense'] as num).toDouble(),
      amountSpent: (map['expense'] as num).toDouble(),
      periodInDays: map['days_period'] == null ? 0 : map['days_period'] as int,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      category: map['category'] as String?,
      name: map['name'] as String?,
    );
  }
}
