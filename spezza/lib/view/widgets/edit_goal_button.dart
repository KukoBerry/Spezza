import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reusable edit button that opens a dialog to edit a goal's `goalexpense`, `category` and `name`.
///
/// The widget accepts the current values and a `src` map (used to detect id and DB key).
class EditGoalButton extends StatelessWidget {
  final double goalAmount;
  final String category;
  final String name;
  final Map<String, dynamic> src;
  final void Function(double parsedGoal, String newCategory, String newName)?
  onSaved;

  const EditGoalButton({
    super.key,
    required this.goalAmount,
    required this.category,
    required this.name,
    required this.src,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
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

                    // perform Supabase update in background
                    try {
                      final supabase = Supabase.instance.client;
                      // determine id
                      final idVal = src['id'] ?? src['Id'] ?? src['ID'];
                      int? idInt;
                      if (idVal is int) {
                        idInt = idVal;
                      } else if (idVal is String) {
                        idInt = int.tryParse(idVal.toString());
                      }
                      if (idInt == null) return;

                      final goalKey = src.containsKey('goalexpense')
                          ? 'goalexpense'
                          : 'goal';

                      await supabase
                          .from('budgetgoals')
                          .update({
                            goalKey: parsedGoal,
                            'category': newCategory,
                            'name': newName,
                          })
                          .eq('id', idInt);
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
