import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:spezza/model/dto/expense.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/view/widgets/expense_graphic_circular.dart';
import 'package:spezza/view/widgets/expense_graphic_linear.dart';
import 'package:spezza/view/widgets/expense_graphic_overview.dart';
import 'package:spezza/view/widgets/goal_progress.dart';
import 'package:spezza/view/widgets/linear_graphic_with_select.dart';
import 'package:spezza/view/widgets/progress_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:spezza/view_model/graphic_overview_view_model.dart';
import 'package:spezza/view/widgets/dropdowns.dart';
import 'package:spezza/view/widgets/total_card.dart';

class GraphicOverviewScreen extends ConsumerStatefulWidget {
  const GraphicOverviewScreen({super.key});

  @override
  ConsumerState<GraphicOverviewScreen> createState() =>
      _GraphicOverviewScreenState();
}

class _GraphicOverviewScreenState extends ConsumerState<GraphicOverviewScreen> {
  DateTime? startPeriod;
  DateTime? endPeriod;
  String? selectedCategory;
  GraphicOverviewPeriod? overview;

  DateTime getNowDate({bool? isBeginDate}) {
    final date = DateTime.now();

    if (isBeginDate != null && isBeginDate) {
      return DateTime(date.year, date.month, date.day, 0, 0, 0);
    }

    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  DateTime getStartDateByMonth(int monthsBack, {bool isBeginDate = true}) {
    final nowDate = getNowDate(isBeginDate: isBeginDate);
    return DateTime(nowDate.year, nowDate.month - monthsBack, nowDate.day);
  }

  DateTime getStartDateByDay(int daysBack, {bool isBeginDate = true}) {
    final nowDate = getNowDate(isBeginDate: isBeginDate);
    return DateTime(nowDate.year, nowDate.month, nowDate.day - daysBack);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(graphicOverviewViewModelProvider.notifier)
          .fetchGoalsAndExpenses();
    });

    if (startPeriod == null) {
      endPeriod = getNowDate(isBeginDate: false);
      startPeriod = getStartDateByDay(7, isBeginDate: true);
      selectedCategory = 'Tudo';
      overview = GraphicOverviewPeriod.lastWeek;
    }
  }

  void onSelectDropDown(
    GraphicOverviewPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    DateTime start, end = getNowDate();
    switch (period) {
      case GraphicOverviewPeriod.lastWeek:
        start = getStartDateByDay(7);
        break;
      case GraphicOverviewPeriod.lastMonth:
        start = getStartDateByMonth(1);
        break;
      case GraphicOverviewPeriod.lastSixMonths:
        start = getStartDateByMonth(6);
        break;
      case GraphicOverviewPeriod.lastYear:
        start = getStartDateByMonth(12);
        break;
      default:
        start = startDate!;
        end = DateTime(endDate!.year, endDate.month, endDate.day, 23, 59, 59);
    }

    setState(() {
      startPeriod = start;
      endPeriod = end;
      overview = period;
    });
  }

  void onSelectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(graphicOverviewViewModelProvider);

    final categories = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .categories;

    final filteredGoals = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .filteredGoals(
          start: startPeriod!,
          end: endPeriod!,
          category: selectedCategory!,
        );

    final filteredExpenses = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .getAllExpensesInPeriod(
          filteredGoals: filteredGoals,
          start: startPeriod!,
          end: endPeriod!,
        );

    final totalExpensesByPeriod = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .totalExpensesInPeriod(
          expensesFiltered: filteredExpenses,
          period: overview!,
          start: startPeriod!,
          end: endPeriod!,
        );

    final totalExpensesByCategory = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .totalTenExpensesByCategory(filteredExpenses, startPeriod!, endPeriod!);

    final hasGoals = filteredGoals.isNotEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black54;
    final iconColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão geral'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Sidebar(),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: startPeriod == null || endPeriod == null
                  ? CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GraphicOverviewPeriodDropdown(
                              onSelect: (value, startDate, endDate) =>
                                  onSelectDropDown(value, startDate, endDate),
                            ),
                            Padding(padding: EdgeInsets.all(4)),
                            Expanded(
                              child: CategoryDropDown(
                                onSelect: onSelectCategory,
                                categories: categories,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        !hasGoals
                            ? Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: iconColor,
                                        ),
                                        child: Icon(
                                          Icons.money_off,
                                          size: 36,
                                          color: Color(0xFF008000),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        textAlign: TextAlign.center,
                                        'Nenhuma meta encontrada para os filtros selecionados.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          TotalCard(
                                            title: 'METAS',
                                            values: filteredGoals,
                                            icon: const Icon(
                                              Icons.savings,
                                              color: Color(0xFF008000),
                                            ),
                                          ),
                                          TotalCard(
                                            title: 'GASTOS',
                                            values: filteredExpenses,
                                            icon: const Icon(
                                              Icons.attach_money,
                                              color: Color(0xFF83814C),
                                            ),
                                            hasBorder: true,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      selectedCategory == 'Tudo'
                                          ? ExpenseGraphicCircular(
                                              totalExpensesByCategory:
                                                  totalExpensesByCategory,
                                            )
                                          : GoalProgress(filteredGoals),

                                      const SizedBox(height: 16),

                                      ExpenseGraphicOverview(
                                        totalExpensesByMonth:
                                            totalExpensesByPeriod,
                                      ),
                                      const SizedBox(height: 16),
                                      LinearGraphicWithSelect(
                                        categories: categories
                                            .where((c) => c != 'Tudo')
                                            .toList(),
                                        startPeriod!,
                                        endPeriod!,
                                        overview!,
                                        selectedCategory,
                                      ),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
            ),
    );
  }
}
