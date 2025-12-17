import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/model/dto/expense.dart';
import 'package:spezza/view/screens/graphic_overview_screen.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/model/expense_model.dart';
import 'package:spezza/model/goal_expense_model.dart';
import 'package:spezza/view/widgets/dropdowns.dart';

part 'graphic_overview_view_model.g.dart';

@riverpod
class GraphicOverviewViewModel extends _$GraphicOverviewViewModel {
  @override
  GraphicOverviewState build() {
    return GraphicOverviewState.initial();
  }

  GoalExpenseModel get _goalModel => ref.watch(goalExpenseModelProvider);

  ExpenseModel get _expenseModel => ref.watch(expenseModelProvider);

  List<GoalExpense> get goals => _goalModel.goals;

  List<Expense> get expenses => _expenseModel.expense;

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

  List<GoalExpense> filteredGoals({
    required DateTime start,
    required DateTime end,
    required String category,
  }) {
    if (category == 'Tudo') {
      return _goalModel.goals.where((goal) {
        final createdAt = goal.createdAt;

        final startMatch = !createdAt.isBefore(start);
        final endMatch = !createdAt.isAfter(end);

        return startMatch && endMatch;
      }).toList();
    }

    return _goalModel.filter(
      startDate: start,
      endDate: end,
      category: category,
    );
  }

  Map<String, (double, double)> totalSpentInAGoal(List<GoalExpense> goals) {
    final Map<String, (double, double)> goalsMap = {};
    bool hasAdded = false;

    for (final goal in goals) {
      if (goal.name == null && !hasAdded) {
        goalsMap['Objetivo sem nome'] = (0.0, 0.0);
        hasAdded = true;
      }

      if (!goalsMap.containsKey(goal.name ?? 'Objetivo sem nome')) {
        goalsMap[goal.name ?? 'Objetivo sem nome'] = (goal.goal, 0.0);
      }

      double totalSpent = 0.0;

      for (final expense in goal.expenses) {
        totalSpent += expense.value;
      }

      final currentGoal = goalsMap[goal.name ?? 'Sem nome'];

      if (currentGoal != null) {
        goalsMap[goal.name ?? 'Sem nome'] = (
          currentGoal.$1,
          currentGoal.$2 + totalSpent,
        );
      }
    }

    return goalsMap;
  }

  List<Expense> getAllExpensesInPeriod({
    required List<GoalExpense> filteredGoals,
    required DateTime start,
    required DateTime end,
  }) {
    final List<Expense> expensesInPeriod = [];

    for (final goal in filteredGoals) {
      for (final expense in goal.expenses) {
        final expenseDate = expense.spentDate;

        if (!expenseDate.isBefore(start) && !expenseDate.isAfter(end)) {
          expensesInPeriod.add(expense);
        }
      }
    }

    return expensesInPeriod;
  }

  List<Expense> filteredExpenses({
    required DateTime start,
    required DateTime end,
    required String category,
  }) {
    if (category == 'Tudo') {
      return _expenseModel.expense.where((expense) {
        final createdAt = expense.spentDate;

        final startMatch = !createdAt.isBefore(start);

        final endMatch = !createdAt.isAfter(end);

        return startMatch && endMatch;
      }).toList();
    }

    return _expenseModel.filterByCategory(
      startDate: start,
      endDate: end,
      category: category,
    );
  }

  List<ChartData> totalTenExpensesByCategory(
    List<Expense> filteredExpenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    final expenses = _expenseModel.totalByCategoryAndDate(
      filteredExpenses: filteredExpenses,
      startDate: startDate,
      endDate: endDate,
    );

    final sortedEntries = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top9 = sortedEntries.take(9).toList();

    final othersTotal = sortedEntries
        .skip(9)
        .fold<double>(0, (sum, entry) => sum + entry.value);

    final List<ChartData> chartData = [
      ...top9.map(
        (entry) => ChartData(
          entry.key,
          entry.value,
          text: 'R\$ ${entry.value.toInt()}',
        ),
      ),
      if (othersTotal > 0)
        ChartData('Outros', othersTotal, text: othersTotal.toStringAsFixed(2)),
    ];

    return chartData;
  }

  List<ChartData> totalExpensesByLastWeek(
    List<Expense> expensesFiltered,
    DateTime endDate,
    int daysBack,
  ) {
    final days = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sab',
      7: 'Dom',
    };

    final expenses = _expenseModel.totalExpensesLastSevenDays(
      expensesFiltered,
      daysBack: daysBack,
      endDate: endDate,
    );

    final List<ChartData> chartData = [];

    final nowWeekday = DateTime.now().weekday;
    for (int i = daysBack; i >= 0; i--) {
      final int weekday = ((nowWeekday - i - 1) % 7 + 7) % 7 + 1;

      chartData.add(ChartData(days[weekday]!, expenses[weekday] ?? 0.0));
    }
    return chartData;
  }

  List<ChartData> totalExpensesByYears(
    List<Expense> expensesFiltered,
    int yearsBack,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final expenses = _expenseModel.totalExpensesByLastYears(
      expensesFiltered,
      yearsBack: yearsBack,
      startDate: startDate,
      endDate: endDate,
    );

    final List<ChartData> chartData = [];

    final currentYear = DateTime.now().year;

    for (int i = yearsBack; i >= 1; i--) {
      final year = currentYear - i + 1;
      chartData.add(ChartData(year.toString(), expenses[year] ?? 0.0));
    }

    return chartData;
  }

  List<ChartData> totalExpensesByWeeks(
    List<Expense> expensesFiltered,
    int weeksBack,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final expenses = _expenseModel.totalExpensesByLastWeeks(
      expensesFiltered,
      weeksBack: weeksBack,
      startDate: startDate,
      endDate: endDate,
    );

    final List<ChartData> chartData = [];

    for (int i = weeksBack; i >= 1; i--) {
      chartData.add(ChartData('Sem. ${weeksBack - i + 1}', expenses[i] ?? 0.0));
    }

    return chartData;
  }

  List<ChartData> totalExpensesInLastMonths(
    List<Expense> expensesFiltered,
    int monthsBack, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final months = {
      1: 'Jan',
      2: 'Fev',
      3: 'Mar',
      4: 'Abr',
      5: 'Mai',
      6: 'Jun',
      7: 'Jul',
      8: 'Ago',
      9: 'Set',
      10: 'Out',
      11: 'Nov',
      12: 'Dez',
    };
    final expenses = _expenseModel.totalExpensesInLastTwelveMonths(
      expensesFiltered,
      monthsBack: monthsBack,
      startDate: startDate,
      endDate: endDate,
    );

    final List<ChartData> chartData = [];

    final nowMonth = DateTime.now().month;

    for (int i = monthsBack; i >= 0; i--) {
      final int month = ((nowMonth - i - 1) % 12 + 12) % 12 + 1;

      chartData.add(ChartData(months[month]!, expenses[month] ?? 0.0));
    }

    return chartData;
  }

  List<ChartData> totalExpensesInPeriod({
    required List<Expense> expensesFiltered,
    required GraphicOverviewPeriod period,
    required DateTime start,
    required DateTime end,
  }) {
    switch (period) {
      case GraphicOverviewPeriod.lastYear:
        return totalExpensesInLastMonths(
          expensesFiltered,
          11,
          startDate: start,
          endDate: end,
        );
      case GraphicOverviewPeriod.lastSixMonths:
        return totalExpensesInLastMonths(
          expensesFiltered,
          5,
          startDate: start,
          endDate: end,
        );
      case GraphicOverviewPeriod.lastWeek:
        return totalExpensesByLastWeek(expensesFiltered, end, 6);
      case GraphicOverviewPeriod.lastMonth:
        return totalExpensesByWeeks(expensesFiltered, 4, start, end);
      default:
        return totalExpensesByPeriod(expensesFiltered, start, end);
    }
  }

  List<ChartData> totalExpensesByPeriod(
    List<Expense> expensesFiltered,
    DateTime start,
    DateTime end,
  ) {
    final daysDifference = end.difference(start).inDays + 1;

    if (daysDifference <= 7) {
      return totalExpensesByLastWeek(expensesFiltered, end, daysDifference);
    }

    if (daysDifference <= 56) {
      final weeksBack = (daysDifference / 7).ceil();
      return totalExpensesByWeeks(expensesFiltered, weeksBack, start, end);
    }

    final monthsBack = (end.year - start.year) * 12 + (end.month - start.month);

    if (monthsBack <= 12) {
      return totalExpensesInLastMonths(
        expensesFiltered,
        monthsBack,
        startDate: start,
        endDate: end,
      );
    }

    final yearsBack = end.year - start.year + 1;

    return totalExpensesByYears(expensesFiltered, yearsBack, start, end);
  }

  Map<String, List<ChartData>> allExpensesByPeriods(
    List<String> categories,
    GraphicOverviewPeriod period,
    DateTime start,
    DateTime end,
  ) {
    final Map<String, List<ChartData>> dataByCategory = {};

    if (categories.isNotEmpty && categories[0] == 'Tudo') {
      final goals = filteredGoals(start: start, end: end, category: 'Tudo');

      final expenses = getAllExpensesInPeriod(
        filteredGoals: goals,
        start: start,
        end: end,
      );

      final chartData = totalExpensesInPeriod(
        expensesFiltered: expenses,
        period: period,
        start: start,
        end: end,
      );

      dataByCategory['Tudo'] = chartData;
      return dataByCategory;
    }

    for (final category in categories) {
      final goals = filteredGoals(start: start, end: end, category: category);

      final expenses = getAllExpensesInPeriod(
        filteredGoals: goals,
        start: start,
        end: end,
      );

      final chartData = totalExpensesInPeriod(
        expensesFiltered: expenses,
        period: period,
        start: start,
        end: end,
      );

      dataByCategory[category] = chartData;
    }

    return dataByCategory;
  }
}

class ChartData {
  ChartData(this.x, this.y, {this.text});

  final String? text;
  final String x;
  final double y;
}

extension StringCasing on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class GraphicOverviewState {
  final bool isLoading;

  const GraphicOverviewState({required this.isLoading});

  factory GraphicOverviewState.initial() {
    return const GraphicOverviewState(isLoading: false);
  }

  GraphicOverviewState copyWith({bool? isLoading}) {
    return GraphicOverviewState(isLoading: isLoading ?? this.isLoading);
  }
}
