import 'package:spezza/model/dto/expense.dart';

class GoalExpense {
  final DateTime createdAt;
  final int? id;
  final double goal;
  final int? periodInDays;
  final String? category;
  final String? name;
  final int? userId;
  final List<Expense> expenses;

  GoalExpense({
    this.id,
    this.userId,
    this.periodInDays,
    required this.goal,
    required this.createdAt,
    required this.expenses,
    this.category,
    this.name,
  });

  factory GoalExpense.fromMap(Map<String, dynamic> map) {
    return GoalExpense(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      goal: (map['goalexpense'] as num).toDouble(),
      periodInDays: map['daysperiod'] == null ? 0 : map['daysperiod'] as int,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      category: map['category'] as String?,
      name: map['name'] as String?,
      expenses: map['expenses'] != null
          ? (map['expenses'] as List)
                .map((e) => Expense.fromMap(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId ?? 1,
      'goalexpense': goal,
      'daysperiod': periodInDays,
      'created_at': createdAt.toUtc().toIso8601String(),
      'category': category,
      'name': name,
    };
  }
}
