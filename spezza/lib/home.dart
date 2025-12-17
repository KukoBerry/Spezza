import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/sidebar.dart';
import 'package:spezza/view/screens/create_expense.dart';
import 'package:spezza/view/screens/create_goal.dart';
import 'package:spezza/view/screens/goal_screen.dart';
import 'package:spezza/view/screens/goals_screen.dart';
import 'package:spezza/view_model/home_view_model.dart';
import 'package:intl/intl.dart';

import 'model/dto/expense.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).fetchGoalsAndExpenses();
    });
  }

  Widget getNavigationButton(int key, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: selected == key ? const Color(0xFF008000) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF008000), width: 0.7),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selected = key;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Text(
            title,
            style: TextStyle(
              color: selected == key ? Colors.white : const Color(0xFF008000),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void onDeleteExpense(int expenseId) {
    ref.read(homeViewModelProvider.notifier).deleteExpense(expenseId);
  }

  void onRefresh() {
    ref.read(homeViewModelProvider.notifier).fetchGoalsAndExpenses();
  }

  void onOpenGoalExpenseDetails(int goalId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalExpenseDetailsScreen(
          goal: ref.read(homeViewModelProvider.notifier).getGoalById(goalId),
        ),
      ),
    );
  }

  void showEditExpensePopup(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) {
    final goalExpense = ref
        .read(homeViewModelProvider.notifier)
        .getGoalById(expense.budgetId);

    final nameController = TextEditingController(text: expense.name ?? '');
    final valueController = TextEditingController(
      text: expense.value.toStringAsFixed(2),
    );

    DateTime selectedDate = expense.spentDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar gasto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do gasto',
                        prefixIconConstraints: BoxConstraints(minWidth: 0),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.local_offer),
                        ),
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
                        prefixIconConstraints: BoxConstraints(minWidth: 0),
                        labelText: 'Valor',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.attach_money),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Data do gasto'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          helpText: 'Selecionar data',
                          initialDate: selectedDate,
                          firstDate: goalExpense.createdAt,
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(homeViewModelProvider.notifier)
                        .updateExpense(
                          Expense(
                            id: expense.id,
                            budgetId: expense.budgetId,
                            createdAt: expense.createdAt,
                            category: expense.category,
                            name: nameController.text.trim(),
                            value: double.parse(
                              valueController.text.replaceAll(',', '.'),
                            ),
                            spentDate: selectedDate,
                          ),
                        );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto atualizado com sucesso'),
                        behavior: SnackBarBehavior.floating,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(homeViewModelProvider.notifier).sortedGoals;
    final expenses = ref.watch(homeViewModelProvider.notifier).sortedExpenses;
    final isLoading = ref.watch(homeViewModelProvider).isLoading;

    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(title: const Text('Spezza')),
      floatingActionButton: IconButton(
        onPressed: () {
          selected == 1
              ? Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateExpensePage(goals: goals),
                  ),
                )
              : Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateGoalExpensePage(),
                  ),
                );
        },
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF83814C),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(18),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 32.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      getNavigationButton(0, 'Metas'),
                      getNavigationButton(1, 'Gastos'),
                    ],
                  ),
                ),
                selected == 1
                    ? ExpensesPage(
                        onOpen: (id) => onOpenGoalExpenseDetails(id),
                        expenses: expenses,
                        onDelete: (id) => onDeleteExpense(id),
                        onChange: (expense) =>
                            showEditExpensePopup(context, ref, expense),
                      )
                    : GoalsPage(goals: goals),
              ],
            ),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  final Function(int) onDelete;
  final Function(Expense) onChange;
  final Function(int) onOpen;
  final List<Expense> expenses;

  const ExpensesPage({
    super.key,
    required this.expenses,
    required this.onDelete,
    required this.onChange,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Nenhum gasto registrado.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return ExpenseCard(
            expense: expenses[index],
            onDelete: onDelete,
            onChange: onChange,
            onOpen: onOpen,
          );
        },
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Function(int) onDelete;
  final Function(Expense) onChange;
  final Expense expense;
  final Function(int) onOpen;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onChange,
    required this.onOpen,
  });

  String formatValue(double value) {
    final formatter = NumberFormat('0.00', 'pt_BR');
    return formatter.format(value);
  }

  String getFormattedDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yy');
    return formatter.format(date);
  }

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

  void _confirmDelete(BuildContext context, int expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir gasto'),
          content: const Text(
            'Tem certeza que deseja excluir este gasto? '
            'Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onDelete(expenseId);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseOptions(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Ver meta'),
              onTap: () {
                Navigator.pop(context);
                onOpen(expense.budgetId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar gasto'),
              onTap: () {
                Navigator.pop(context);
                onChange(expense);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Excluir gasto',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, expense.id!);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                dense: true,
                trailing: IconButton(
                  onPressed: () {
                    _showExpenseOptions(context, expense);
                  },
                  icon: Icon(Icons.more_vert, color: Colors.white),
                ),
                title: Text(
                  'R\$ ${formatValue(expense.value)}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              getListTile(
                getFormattedDate(expense.spentDate),
                'Data',
                Icons.calendar_month,
              ),
              Divider(),
              getListTile(
                expense.name ?? 'Sem descrição',
                'Nome',
                Icons.local_offer,
              ),
              Divider(),
              getListTile(
                expense.category ?? 'Sem categoria',
                'Categoria',
                Icons.category,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
