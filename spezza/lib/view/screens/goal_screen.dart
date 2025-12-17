import 'package:flutter/services.dart';

import '../../model/dto/expense.dart';
import '../../model/dto/goal_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../view_model/home_view_model.dart';
import '../widgets/progress_bar.dart';
import '../widgets/total_card.dart';

class GoalExpenseDetailsScreen extends ConsumerStatefulWidget {
  final GoalExpense goal;

  const GoalExpenseDetailsScreen({super.key, required this.goal});

  @override
  GoalExpenseDetailsScreenState createState() =>
      GoalExpenseDetailsScreenState();
}

class GoalExpenseDetailsScreenState
    extends ConsumerState<GoalExpenseDetailsScreen> {
  double get totalExpenseValue {
    return widget.goal.expenses.fold(0.0, (sum, e) => sum + e.value);
  }

  double get progress {
    if (widget.goal.goal == 0) return 0.0;
    return totalExpenseValue / widget.goal.goal;
  }

  void showDeleteGoalConfirmPopup(BuildContext context, int goalId) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Excluir meta'),
          content: const Text(
            'Tem certeza que deseja excluir esta meta? '
            'Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC3700),
              ),
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).deleteGoal(goalId);
                ref.invalidate(homeViewModelProvider);
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meta excluída com sucesso'),
                    backgroundColor: Color(0xFF83814C),
                  ),
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditGoalPopup(
    BuildContext context,
    WidgetRef ref,
    GoalExpense goal,
  ) {
    final nameController = TextEditingController(text: goal.name ?? '');
    final categoryController = TextEditingController(text: goal.category ?? '');
    final valueController = TextEditingController(
      text: goal.goal.toStringAsFixed(2),
    );
    final periodController = TextEditingController(
      text: goal.periodInDays?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar meta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da meta',
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor da meta',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: periodController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Período (dias)',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008000),
              ),
              onPressed: () {
                ref
                    .read(homeViewModelProvider.notifier)
                    .updateGoal(
                      GoalExpense(
                        id: goal.id,
                        userId: goal.userId,
                        createdAt: goal.createdAt,
                        expenses: goal.expenses,
                        name: nameController.text.trim(),
                        category: categoryController.text.trim(),
                        goal: double.parse(
                          valueController.text.replaceAll(',', '.'),
                        ),
                        periodInDays: int.tryParse(periodController.text),
                      ),
                    );
                ref.invalidate(homeViewModelProvider);

                Navigator.popUntil(context, (route) => route.isFirst);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meta atualizada com sucesso'),
                    backgroundColor: Color(0xFF83814C),
                  ),
                );
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goal.name ?? 'Detalhes da Meta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                TotalCard(
                  title: 'META',
                  values: [widget.goal],
                  icon: const Icon(Icons.flag, color: Color(0xFF008000)),
                ),
                const SizedBox(width: 12),
                TotalCard(
                  title: 'GASTOS',
                  values: widget.goal.expenses,
                  icon: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF83814C),
                  ),
                  hasBorder: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            GoalExpenseProgress(
              goal: widget.goal,
              totalExpenseValue: totalExpenseValue,
              progress: progress,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: IndividualExpenseList(expenses: widget.goal.expenses),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF83814C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    showEditGoalPopup(context, ref, widget.goal);
                  },
                  child: const Text(
                    'Editar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC3700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    showDeleteGoalConfirmPopup(context, widget.goal.id!);
                  },
                  child: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalExpenseProgress extends StatelessWidget {
  final GoalExpense goal;
  final double totalExpenseValue;
  final double progress;

  const GoalExpenseProgress({
    super.key,
    required this.goal,
    required this.totalExpenseValue,
    required this.progress,
  });

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: 0.7, color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progresso da meta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ProgressBarCustom(progress: progress),

            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  'R\$ ${formatValue(totalExpenseValue)} / R\$ ${formatValue(goal.goal)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IndividualExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const IndividualExpenseList({super.key, required this.expenses});

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Nenhum gasto registrado'));
    }

    return ListView.separated(
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            expense.name ?? 'Sem nome',
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            'R\$ ${formatValue(expense.value)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF83814C),
            ),
          ),
        );
      },
    );
  }
}
