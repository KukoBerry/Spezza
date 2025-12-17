import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../model/dto/expense.dart';
import '../../model/dto/goal_expense.dart';
import '../../view_model/home_view_model.dart';

class CreateExpensePage extends ConsumerStatefulWidget {
  final List<GoalExpense> goals;

  const CreateExpensePage({super.key, required this.goals});

  @override
  ConsumerState<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  GoalExpense? _selectedGoal;
  DateTime? _selectedDate;

  Future<GoalExpense?> _selectGoalModal(
    BuildContext context,
    List<GoalExpense> goals,
  ) {
    return showModalBottomSheet<GoalExpense>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return ListTile(
              title: Text(goal.name ?? 'Meta sem nome'),
              subtitle: Text(
                DateFormat("dd/MM/yyyy", 'pt_BR').format(goal.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => Navigator.pop(context, goal),
            );
          },
        );
      },
    );
  }

  bool get _canCreate =>
      _nameController.text.isNotEmpty &&
      _valueController.text.isNotEmpty &&
      _selectedGoal != null &&
      _selectedDate != null;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<DateTime?> pickDate(
    BuildContext context,
    String helper, {
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      helpText: helper,
      initialDate: DateTime.now(),
      firstDate: initialDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar novo gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do gasto',
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.local_offer),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],

              decoration: const InputDecoration(
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                labelText: 'Valor',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.attach_money),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag),
              title: Text(_selectedGoal?.name ?? 'Selecionar meta'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final goal = await _selectGoalModal(context, widget.goals);
                if (goal != null) {
                  setState(() {
                    _selectedGoal = goal;
                    _selectedDate = null;
                  });
                }
              },
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: Text(
                _selectedDate == null
                    ? 'Selecionar data'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              ),
              enabled: _selectedGoal != null,
              onTap: _selectedGoal == null
                  ? null
                  : () async {
                      final date = await pickDate(
                        context,
                        'Selecione a data do gasto',
                        initialDate: _selectedGoal!.createdAt,
                      );

                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
            ),

            const SizedBox(height: 32),

            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _canCreate ? _createExpense : null,
                child: const Text(
                  'Criar gasto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createExpense() {
    ref
        .read(homeViewModelProvider.notifier)
        .addExpense(
          Expense(
            createdAt: DateTime.now(),
            name: _nameController.text,
            category: _selectedGoal?.category ?? 'Geral',
            value: double.parse(_valueController.text.replaceAll(',', '.')),
            spentDate: _selectedDate!,
            budgetId: _selectedGoal!.id!,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto criado com sucesso!'),
        backgroundColor: Color(0xFF83814C),
      ),
    );

    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _valueController.clear();
      _selectedGoal = null;
      _selectedDate = null;
    });
  }
}
