import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spezza/model/dto/expense.dart';
import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/view_model/graphic_overview_view_model.dart';
import 'dropdowns.dart';
import 'expense_graphic_linear.dart';

class LinearGraphicWithSelect extends ConsumerStatefulWidget {
  final List<String> categories;
  final DateTime startPeriod;
  final DateTime endPeriod;
  final GraphicOverviewPeriod overview;
  final String? selectedCategory;

  const LinearGraphicWithSelect(
    this.startPeriod,
    this.endPeriod,
    this.overview,
    this.selectedCategory, {
    super.key,
    required this.categories,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LinearGraphicWithSelectState();
}

class _LinearGraphicWithSelectState
    extends ConsumerState<LinearGraphicWithSelect> {
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null) {
      categories.add(widget.selectedCategory!);
    }
  }

  @override
  void didUpdateWidget(covariant LinearGraphicWithSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() {
        categories.clear();
        if (widget.selectedCategory != null) {
          categories.add(widget.selectedCategory!);
        }
      });
    }
  }

  void onSelectedCategories(List<String> categories) {
    setState(() {
      this.categories = categories;
    });
  }

  void showCategorySelector({
    required BuildContext context,
    required List<String> allCategories,
    required String selectedCategory,
    required List<String> selectedCategories,
    required void Function(List<String>) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> selected = selectedCategories;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione até 3 categorias'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allCategories.map((category) {
                    final isFixed = category == selectedCategory;
                    final isSelected = selected.contains(category);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(category),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        setState(() {
                          if (isFixed) return;
                          if (checked == true) {
                            if (selected.length < 3) {
                              selected.add(category);
                            }
                          } else {
                            selected.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSelected(selected);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar'),
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
    final expensesCompare = ref
        .read(graphicOverviewViewModelProvider.notifier)
        .allExpensesByPeriods(
          categories,
          widget.overview,
          widget.startPeriod,
          widget.endPeriod,
        );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white70 : Colors.black26;
    final textColor = isDark ? Colors.white70 : Colors.black54;
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: 0.7, color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução e comparação dos gastos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: ExpenseGraphicLinear(expenses: expensesCompare),
            ),
            if (widget.selectedCategory != 'Tudo')
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      showCategorySelector(
                        context: context,
                        allCategories: widget.categories,
                        selectedCategory: widget.selectedCategory!,
                        selectedCategories: categories,
                        onSelected: (selectedList) {
                          onSelectedCategories(selectedList);
                        },
                      );
                    },
                    child: Text(
                      '+ Adicionar categoria',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
