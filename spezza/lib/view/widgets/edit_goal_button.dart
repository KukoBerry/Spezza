import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/shared/repositories/goal_repository.dart';

/// Reusable edit button that opens a dialog to edit a goal's `goalexpense`, `category` and `name`.
///
/// The widget accepts the current values and a `src` map (used to detect id and DB key).
class EditGoalButton extends ConsumerWidget {
  final double goalAmount;
  final String category;
  final String name;
  final GoalExpense goal;
  final void Function(double parsedGoal, String newCategory, String newName)?
  onSaved;

  const EditGoalButton({
    super.key,
    required this.goalAmount,
    required this.category,
    required this.name,
    required this.goal,
    this.onSaved,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.edit, color: Colors.white, size: 18),
      onPressed: () async {
        final goalController = TextEditingController(
          text: goalAmount.toString(),
        );
        final categoryController = TextEditingController(
          text: category == '-' ? '' : category,
        );
        final nameController = TextEditingController(
          text: name == '-' ? '' : name,
        );
        final formKey = GlobalKey<FormState>();

        await showDialog<void>(
          context: context,
          builder: (dialogCtx) {
            return AlertDialog(
              title: const Text('Editar meta'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                    ),
                    TextFormField(
                      controller: goalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Valor'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final parsedGoal =
                        double.tryParse(
                          goalController.text.replaceAll(',', '.'),
                        ) ??
                        0.0;
                    final newCategory = categoryController.text.trim();
                    final newName = nameController.text.trim();

                    // notify parent immediately so UI can update
                    onSaved?.call(parsedGoal, newCategory, newName);

                    // close dialog before awaiting network
                    Navigator.of(dialogCtx).pop();

                    // perform update via repository in background
                    try {
                      // determine id
                      final idVal = goal.id;
                      int? idInt;
                      idInt = idVal;

                      final goalKey = 'goalexpense';

                      await ref.read(goalRepositoryProvider).updateGoal(idInt, {
                        goalKey: parsedGoal,
                        'category': newCategory,
                        'name': newName,
                      });
                    } catch (e) {
                      // ignore for now; parent may choose to handle failures
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
