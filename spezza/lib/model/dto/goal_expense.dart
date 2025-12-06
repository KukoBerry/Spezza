class GoalExpense {
  final DateTime createdAt;
  final String id;
  final double goal;
  final double amountSpent;
  final int periodInDays;

  GoalExpense({
    required this.id,
    required this.goal,
    required this.amountSpent,
    required this.periodInDays,
    required this.createdAt,
  });

  factory GoalExpense.fromMap(Map<String, dynamic> map) {
    return GoalExpense(
      id: map['id'].toString(),
      goal: (map['goalexpense'] as num).toDouble(),
      amountSpent: (map['expense'] as num).toDouble(),
      periodInDays: map['days_period'] == null ? 0 : map['days_period'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
