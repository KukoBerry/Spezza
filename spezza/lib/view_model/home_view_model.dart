import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/dto/expense.dart';
import '../model/dto/goal_expense.dart';
import '../model/expense_model.dart';
import '../model/goal_expense_model.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return HomeState.initial();
  }

  GoalExpenseModel get _goalModel => ref.watch(goalExpenseModelProvider);

  ExpenseModel get _expenseModel => ref.watch(expenseModelProvider);

  List<GoalExpense> get goals => _goalModel.goals;

  List<GoalExpense> get sortedGoals {
    final sortedList = List<GoalExpense>.from(goals);
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList;
  }

  List<Expense> get expenses => _expenseModel.expense;

  List<Expense> get sortedExpenses {
    final sortedList = List<Expense>.from(expenses);
    sortedList.sort((a, b) => b.spentDate.compareTo(a.spentDate));
    return sortedList;
  }

  void deleteExpense(int id) async {
    await _expenseModel.deleteExpense(id);
    fetchGoalsAndExpenses();
  }

  void deleteGoal(int id) async {
    await _goalModel.deleteGoal(id);
    await fetchGoalsAndExpenses();
  }

  void addGoal(GoalExpense goal) async {
    await _goalModel.addGoal(goal);
    await fetchGoalsAndExpenses();
  }

  void updateGoal(GoalExpense goal) async {
    await _goalModel.updateGoal(goal);
    await fetchGoalsAndExpenses();
  }

  void addExpense(Expense expense) async {
    await _expenseModel.addExpense(expense);
    await fetchGoalsAndExpenses();
  }

  GoalExpense getGoalById(int id) {
    return goals.firstWhere((goal) => goal.id == id);
  }

  void updateExpense(Expense expense) async {
    await _expenseModel.updateExpense(expense);
    await fetchGoalsAndExpenses();
  }

  bool get isLoading => state.isLoading;

  void startLoading() {
    state = state.copyWith(isLoading: true);

    ref.notifyListeners();
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
    ref.notifyListeners();
  }

  Future<void> fetchGoalsAndExpenses() async {
    startLoading();

    await _goalModel.fetchGoals();
    await _expenseModel.fetchExpenses();
    ref.notifyListeners();

    stopLoading();
  }

  List<String> get categories => _goalModel.categories;
}

class HomeState {
  final bool isLoading;

  const HomeState({required this.isLoading});

  factory HomeState.initial() {
    return const HomeState(isLoading: false);
  }

  HomeState copyWith({bool? isLoading}) {
    return HomeState(isLoading: isLoading ?? this.isLoading);
  }
}
