import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/dto/goal_expense.dart';
import '../../view_model/home_view_model.dart';

class CreateGoalExpensePage extends ConsumerStatefulWidget {
  const CreateGoalExpensePage({super.key});

  @override
  ConsumerState<CreateGoalExpensePage> createState() =>
      _CreateGoalExpensePageState();
}

class _CreateGoalExpensePageState extends ConsumerState<CreateGoalExpensePage> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _goalValueController = TextEditingController();
  final _periodController = TextEditingController();

  bool get _canCreate =>
      _goalValueController.text.isNotEmpty &&
      _periodController.text.isNotEmpty &&
      _nameController.text.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _goalValueController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar nova meta'),
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
                labelText: 'Nome da meta',
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.flag),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.category),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _goalValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Valor da meta',
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.attach_money),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _periodController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Período (em dias)',
                prefixIconConstraints: BoxConstraints(minWidth: 0),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.calendar_month),
                ),
              ),
              onChanged: (_) => setState(() {}),
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
                onPressed: _canCreate ? _createGoal : null,
                child: const Text(
                  'Criar meta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createGoal() {
    ref
        .read(homeViewModelProvider.notifier)
        .addGoal(
          GoalExpense(
            goal: double.parse(_goalValueController.text.replaceAll(',', '.')),
            periodInDays: int.parse(_periodController.text),
            createdAt: DateTime.now(),
            expenses: const [],
            name: _nameController.text,
            category: _categoryController.text.isEmpty
                ? null
                : _categoryController.text,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meta criada com sucesso!'),
        backgroundColor: Color(0xFF83814C),
      ),
    );

    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _categoryController.clear();
      _goalValueController.clear();
      _periodController.clear();
    });
  }
}
