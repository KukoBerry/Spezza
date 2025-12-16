import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../shared/repositories/expense_repository.dart';
import 'dto/expense.dart';

part 'expense_model.g.dart';

class ExpenseModel {
  final ExpenseRepository _repository;

  ExpenseModel(this._repository);

  final List<Expense> _expenses = [];

  List<Expense> get expense => List.unmodifiable(_expenses);

  Future<void> fetchExpenses() async {
    try {
      final result = await _repository.fetchExpenses();
      _expenses
        ..clear()
        ..addAll(result);
    } catch (e) {
      print('Error fetching goals: $e');
    } finally {
      print('Fetched ${_expenses.length} expenses.');

    }
  }

  List<Expense> filterByCategory({
    required DateTime startDate,
    required DateTime endDate,
    required String category,
  }) {
    return _expenses.where((goal) {
      final createdAt = goal.spentDate;

      final startMatch = !createdAt.isBefore(startDate);

      final endMatch = !createdAt.isAfter(endDate);

      final categoryMatch = goal.category == category;

      return startMatch && endMatch && categoryMatch;
    }).toList();
  }

  Map<String, double> totalByCategoryAndDate({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filteredExpenses = filterByDate(
      startDate: startDate,
      endDate: endDate,
    );

    final Map<String, double> totals = {};

    for (var expense in filteredExpenses) {
      final category = expense.category ?? 'Geral';
      totals[category] = (totals[category] ?? 0) + expense.value;
    }

    return totals;
  }

  List<Expense> filterByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _expenses.where((expense) {
      final spentDate = expense.spentDate;

      final startMatch = !spentDate.isBefore(startDate);

      final endMatch = !spentDate.isAfter(endDate);

      return startMatch && endMatch;
    }).toList();
  }



  Map<String, double> totalExpensesByCategory() {
    final Map<String, double> totals = {};

    for (var expense in _expenses) {
      final category = expense.category ?? 'Geral';
      totals[category] = (totals[category] ?? 0) + expense.value;
    }

    return totals;
  }

  Map<int, double> totalExpensesByLastWeeks(
    List<Expense> expenses, {
    int weeksBack = 2,
        DateTime? startDate,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(Duration(days: weeksBack * 7));
    final Map<int, double> totals = createMap(
      weeksBack,
      8,
      weeksBack,
    );

    for (var expense in expenses) {
      final date = expense.spentDate;

      if (date.isBefore(start) ||
          date.isAfter(end)) {
        continue;
      }

      final daysDiff = end.difference(date).inDays;

      final weekIndex = (daysDiff ~/ 7) + 1;

      if (weekIndex < weeksBack) {
        totals[weekIndex] =
            (totals[weekIndex] ?? 0) + expense.value;
      }
    }

    return totals;
  }

  Map<int, double> totalExpensesByLastYears(
    List<Expense> expenses, {
    int yearsBack = 2,
        DateTime? startDate,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start =
        startDate ?? DateTime(end.year - yearsBack, 1, 1);

    final Map<int, double> totals = createMap(
        end.year,
        12,
        yearsBack
    );

    for (var expense in expenses) {
      final yearKey = expense.spentDate.year;

      if (expense.spentDate.isBefore(start) ||
          expense.spentDate.isAfter(end)) {
        continue;
      }

      totals[yearKey] = (totals[yearKey] ?? 0) + expense.value;
    }

    return totals;
  }

  Map<int, double> totalExpensesInLastTwelveMonths(
    List<Expense> expenses, {
    int monthsBack = 11,
        DateTime? startDate,
        DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? DateTime(end.year, end.month - monthsBack, 1);

    final Map<int, double> totals = createMap(
      end.month,
      12,
      monthsBack,
    );

    for (var expense in expenses) {
      final monthKey = expense.spentDate.month;

      if (expense.spentDate.isBefore(start) ||
          expense.spentDate.isAfter(end)) {
        continue;
      }

      totals[monthKey] = (totals[monthKey] ?? 0) + expense.value;
    }

    return totals;
  }

  Map<int, double> createMap(int start, int max, int back) {
    return {
      for (int i = 0; i < back; i++)
        (((start - i - 1) % max + max) % max + 1): 0.0,
    };
  }

  Map<int, double> totalExpensesLastSevenDays(
    List<Expense> expenses, {
    int daysBack = 7,
    DateTime? endDate,
  }) {
    endDate = endDate ?? DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));
    final Map<int, double> totals = createMap(startDate.weekday, 7, daysBack);

    for (var expense in expenses) {
      final dayKey = expense.spentDate.weekday;
      final date = expense.spentDate;

      if (date.isBefore(startDate)) {
        continue;
      }

      totals[dayKey] = (totals[dayKey] ?? 0) + expense.value;
    }

    return totals;
  }
}

@riverpod
ExpenseModel expenseModel(Ref ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpenseModel(repo);
}
