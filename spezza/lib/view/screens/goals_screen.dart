import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/view/screens/goal_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sidebar.dart';
import 'package:intl/intl.dart';

import '../widgets/progress_bar.dart';

class GoalsPage extends StatelessWidget {
  final List<GoalExpense> goals;

  const GoalsPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Nenhuma meta registrada.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return GoalsCard(goal: goals[index]);
        },
      ),
    );
  }
}

class GoalsCard extends StatelessWidget {
  final GoalExpense goal;

  const GoalsCard({super.key, required this.goal});

  ListTile getListTile(String title, String subtitle, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      dense: true,
      leading: Icon(icon, color: Colors.white),
      title: Text(
        subtitle,
        style: const TextStyle(fontSize: 10, color: Colors.white70),
      ),
      subtitle: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  String getFormattedDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Color(0xFF008000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(width: 0.7, color: Color(0xFF008000)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalExpenseDetailsScreen(goal: goal),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.navigate_next, color: Colors.white),
                  ),
                  title: Text(
                    goal.name ?? 'Meta sem nome',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                GoalSummaryProgress(
                  total: goal.goal,
                  spent: goal.expenses.fold(0, (sum, e) => sum + e.value),
                ),

                getListTile(
                  getFormattedDate(goal.createdAt),
                  'Data',
                  Icons.calendar_month,
                ),
                Divider(),
                getListTile(
                  goal.category ?? 'Sem categoria',
                  'Categoria',
                  Icons.category,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoalSummaryProgress extends StatelessWidget {
  final double total;
  final double spent;
  final Color? progressColor;
  final Color? backgroundColor;

  const GoalSummaryProgress({
    super.key,
    required this.total,
    required this.spent,
    this.progressColor,
    this.backgroundColor,
  });

  double get progress {
    if (total == 0 && spent > 0) return 1.0;
    if (total == 0) return 0.0;
    return spent / total;
  }

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressBarCustom(
            progress: progress,
            height: 15,
            showPercentage: false,
            barColor: Color(0xFF87AB7B),
            backgroundColor: Color(0xFFDFF8D5),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Text(
                'R\$ ${formatValue(spent)} / R\$ ${formatValue(total)}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
