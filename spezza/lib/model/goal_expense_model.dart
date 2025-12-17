import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/model/dto/goal_expense.dart';

import '../shared/repositories/goal_repository.dart';

part 'goal_expense_model.g.dart';

class GoalExpenseModel {
  final GoalRepository _repository;

  GoalExpenseModel(this._repository);

  final List<GoalExpense> _goals = [];
  final List<String> _categories = ['Tudo'];

  Future<void> deleteGoal(int id) async {
    try {
      await _repository.deleteGoal(id);
    } catch (_) {}
  }

  Future<void> addGoal(GoalExpense goal) async {
    try {
      await _repository.addGoal(goal);
    } catch (_) {
    }
  }

  Future<void> updateGoal(GoalExpense goal) async {
    try {
      await _repository.updateGoal(goal);
    } catch (_) {}
  }

  List<String> get categories => List.unmodifiable(_categories);

  List<GoalExpense> get goals => List.unmodifiable(_goals);

  Future<void> fetchGoals() async {
    try {
      final result = await _repository.fetchGoals();
      _goals
        ..clear()
        ..addAll(result);

      setCategories(result);
    } catch (_) {
    }
  }

  void setCategories(List<GoalExpense> goals) {
    final categorySet = <String>{'Tudo'};

    for (var goal in goals) {
      if (!categorySet.contains(goal.category!.toLowerCase())) {
        categorySet.add(goal.category!);
      }
    }

    _categories
      ..clear()
      ..addAll(categorySet);
  }

  List<GoalExpense> filter({
    required DateTime startDate,
    required DateTime endDate,
    required String category,
  }) {
    return _goals.where((goal) {
      final createdAt = goal.createdAt;

      final startMatch = !createdAt.isBefore(startDate);

      final endMatch = !createdAt.isAfter(endDate);

      final categoryMatch = goal.category == category;

      return startMatch && endMatch && categoryMatch;
    }).toList();
  }
}

@riverpod
GoalExpenseModel goalExpenseModel(Ref ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return GoalExpenseModel(repo);
}
