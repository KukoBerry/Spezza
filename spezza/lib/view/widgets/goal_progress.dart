import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/expense.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/view/widgets/progress_bar.dart';
import 'package:intl/intl.dart';
import 'package:spezza/view_model/graphic_overview_view_model.dart';

class GoalProgress extends ConsumerWidget {
  final List<GoalExpense> goals;

  late double progressValue;
  late double totalGoalValue;
  late double totalExpenseValue;

  GoalProgress(this.goals, {super.key}) {
    calculateProgress();
  }

  void calculateProgress() {
    double totalGoal = 0;
    double totalExpense = 0;

    for (var goal in goals) {
      totalGoal += goal.goal;

      double goalExpensesTotal = goal.expenses.fold(
        0.0,
        (previousValue, expense) => previousValue + expense.value,
      );

      totalExpense += goalExpensesTotal;
    }

    totalGoalValue = totalGoal;
    totalExpenseValue = totalExpense;
    progressValue = totalGoal == 0 ? 1 : (totalExpense / totalGoal);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;

    final spentByCategory = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .totalSpentInAGoal(goals);

    final expanded = ref.watch(goalProgressExpandedProvider);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: 0.7, color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progresso das metas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),
            ProgressBarCustom(progress: progressValue),

            Center(
              child: IconButton(
                onPressed: () {
                  ref.read(goalProgressExpandedProvider.notifier).state =
                      !expanded;
                },
                icon: AnimatedRotation(
                  turns: expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, color: borderColor),
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: expanded
                  ? Column(
                      children: [
                        IndividualGoalProgress(
                          goalProgressData: spentByCategory,
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class IndividualGoalProgress extends StatelessWidget {
  final Map<String, (double, double)> goalProgressData;

  const IndividualGoalProgress({super.key, required this.goalProgressData});

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  Widget buildGoalProgressRow(
    BuildContext context,
    String goalName,
    double goal,
    double spent,
  ) {
    double progress;

    if (goal == 0 && spent > 0) {
      progress = 1.0;
    } else {
      progress = goal == 0 ? 0.0 : (spent / goal);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Divider(color: borderColor),
        SizedBox(height: 8),
        Text(
          goalName,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        ProgressBarCustom(progress: progress, height: 7, showPercentage: false),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'R\$ ${formatValue(spent)} / R\$ ${formatValue(goal)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> buildGoalProgressList(BuildContext context) {
    List<Widget> goalProgressWidgets = [];

    goalProgressData.forEach((goalName, values) {
      double goal = values.$1;
      double spent = values.$2;

      goalProgressWidgets.add(
        buildGoalProgressRow(context, goalName, goal, spent),
      );
    });

    return goalProgressWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: buildGoalProgressList(context));
  }
}

class GoalProgressExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final goalProgressExpandedProvider =
    NotifierProvider<GoalProgressExpandedNotifier, bool>(
      GoalProgressExpandedNotifier.new,
    );
